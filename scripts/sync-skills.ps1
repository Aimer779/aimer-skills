[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectRoot = (Get-Location).Path,

    [Alias("Skills")]
    [string[]]$SkillIds,

    [string]$Profile,

    [string]$CatalogPath,

    [switch]$List,

    [switch]$DryRun,

    [switch]$Apply,

    [switch]$Repair,

    [switch]$Remove
)

$ErrorActionPreference = "Stop"

if ($DryRun -and $Apply) {
    throw "DryRun and Apply cannot be used together."
}

if ($Remove -and ($Repair -or $Profile)) {
    throw "Remove cannot be combined with Repair or Profile."
}

if ($List -and ($DryRun -or $Apply -or $Repair -or $Remove -or $Profile -or $SkillIds)) {
    throw "List cannot be combined with another operation."
}

function Resolve-FullPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    return [System.IO.Path]::GetFullPath($resolved.Path)
}

function Normalize-Path {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return ([System.IO.Path]::GetFullPath($Path)).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
}

function Test-SamePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Left,

        [Parameter(Mandatory = $true)]
        [string]$Right
    )

    return [string]::Equals(
        (Normalize-Path $Left),
        (Normalize-Path $Right),
        [System.StringComparison]::OrdinalIgnoreCase
    )
}

function Test-PathWithin {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $normalizedPath = Normalize-Path $Path
    $normalizedRoot = Normalize-Path $Root

    if (Test-SamePath $normalizedPath $normalizedRoot) {
        return $true
    }

    $rootPrefix = $normalizedRoot + [System.IO.Path]::DirectorySeparatorChar
    return $normalizedPath.StartsWith(
        $rootPrefix,
        [System.StringComparison]::OrdinalIgnoreCase
    )
}

function Read-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    $text = [System.IO.File]::ReadAllText($Path)
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }

    return $text | ConvertFrom-Json
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [object]$Value
    )

    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $json = $Value | ConvertTo-Json -Depth 10
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Get-ItemKind {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $item = $null
    try {
        $item = Get-Item -Force -LiteralPath $Path -ErrorAction Stop
    } catch {
        return "Missing"
    }

    $linkType = $item.PSObject.Properties["LinkType"]
    if ($null -ne $linkType -and -not [string]::IsNullOrWhiteSpace([string]$linkType.Value)) {
        return [string]$linkType.Value
    }

    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        return "ReparsePoint"
    }

    return "Real"
}

function Get-ResolvedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        $item = Get-Item -Force -LiteralPath $Path -ErrorAction Stop
        $targetProperty = $item.PSObject.Properties["Target"]
        if ($null -ne $targetProperty -and $null -ne $targetProperty.Value) {
            $rawTarget = [string](@($targetProperty.Value)[0])
            if ([System.IO.Path]::IsPathRooted($rawTarget)) {
                return Normalize-Path $rawTarget
            }

            return Normalize-Path (Join-Path (Split-Path -Parent $Path) $rawTarget)
        }

        return Normalize-Path ((Resolve-Path -LiteralPath $Path -ErrorAction Stop).Path)
    } catch {
        return $null
    }
}

function Get-SkillName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SkillFile
    )

    $text = [System.IO.File]::ReadAllText($SkillFile)
    $match = [regex]::Match(
        $text,
        '(?m)^name:\s*(?:"([^"]+)"|([^\r\n]+))\s*$'
    )

    if (-not $match.Success) {
        throw "SKILL.md does not declare a name: $SkillFile"
    }

    if ($match.Groups[1].Success) {
        return $match.Groups[1].Value.Trim()
    }

    return $match.Groups[2].Value.Trim()
}

function Add-SelectedIds {
    param(
        [Parameter(Mandatory = $false)]
        [object[]]$Ids
    )

    foreach ($rawId in @($Ids)) {
        $id = ([string]$rawId).Trim()
        if ([string]::IsNullOrWhiteSpace($id)) {
            continue
        }

        if (-not $catalogIndex.ContainsKey($id)) {
            throw "Unknown skill id: $id"
        }

        if (-not $selectedIds.Contains($id)) {
            [void]$selectedIds.Add($id)
        }
    }
}

function New-DirectoryLink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LinkPath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath,

        [Parameter(Mandatory = $true)]
        [string]$LinkType
    )

    $parent = Split-Path -Parent $LinkPath
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    switch ($LinkType.ToLowerInvariant()) {
        "junction" {
            New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
            return
        }
        "symboliclink" {
            New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
            return
        }
        default {
            try {
                New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath | Out-Null
            } catch {
                Write-Warning "SymbolicLink creation failed; falling back to Junction."
                New-Item -ItemType Junction -Path $LinkPath -Target $TargetPath | Out-Null
            }
        }
    }
}

$scriptRoot = Split-Path -Parent $PSScriptRoot
$centralRootCandidate = if ([string]::IsNullOrWhiteSpace($env:AIMER_SKILLS_ROOT)) {
    $scriptRoot
} else {
    $env:AIMER_SKILLS_ROOT
}

if (-not (Test-Path -LiteralPath $centralRootCandidate -PathType Container)) {
    throw "Central repository root does not exist: $centralRootCandidate"
}

$centralRoot = Resolve-FullPath $centralRootCandidate

if ([string]::IsNullOrWhiteSpace($CatalogPath)) {
    $CatalogPath = Join-Path $centralRoot "skill-catalog.json"
} else {
    $CatalogPath = Resolve-FullPath $CatalogPath
}

if (-not (Test-Path -LiteralPath $CatalogPath -PathType Leaf)) {
    throw "Catalog file does not exist: $CatalogPath"
}

if (-not (Test-PathWithin $CatalogPath $centralRoot)) {
    throw "Catalog must be inside the central repository: $CatalogPath"
}

$catalog = Read-JsonFile $CatalogPath
if ($null -eq $catalog) {
    throw "Catalog is empty or invalid: $CatalogPath"
}

if ($null -eq $catalog.schemaVersion) {
    throw "Catalog is missing schemaVersion: $CatalogPath"
}

if ($null -eq $catalog.repository -or [string]::IsNullOrWhiteSpace([string]$catalog.repository.skillsRoot)) {
    throw "Catalog is missing repository.skillsRoot: $CatalogPath"
}

$sourceRoot = Resolve-FullPath (Join-Path $centralRoot ([string]$catalog.repository.skillsRoot))
if (-not (Test-PathWithin $sourceRoot $centralRoot)) {
    throw "skillsRoot must be inside the central repository: $sourceRoot"
}

$targetRelative = ".agents/skills"
if ($null -ne $catalog.defaults -and $null -ne $catalog.defaults.projectTarget) {
    $targetRelative = [string]$catalog.defaults.projectTarget
}

$stateRelative = ".aimer-skills.json"
if ($null -ne $catalog.defaults -and $null -ne $catalog.defaults.stateFile) {
    $stateRelative = [string]$catalog.defaults.stateFile
}

$linkType = "auto"
if ($null -ne $catalog.defaults -and $null -ne $catalog.defaults.linkType) {
    $linkType = [string]$catalog.defaults.linkType
}

$catalogIndex = @{}
foreach ($entry in @($catalog.skills)) {
    $id = [string]$entry.id
    if ([string]::IsNullOrWhiteSpace($id)) {
        throw "Every catalog skill must have an id."
    }

    if ($catalogIndex.ContainsKey($id)) {
        throw "Duplicate catalog skill id: $id"
    }

    if ([string]::IsNullOrWhiteSpace([string]$entry.path)) {
        throw "Catalog skill has no path: $id"
    }

    $catalogIndex[$id] = $entry
}

if ($List) {
    Write-Output "Available skills:"
    foreach ($entry in @($catalog.skills) | Where-Object { $_.enabled -ne $false }) {
        Write-Output ("{0} | {1} | {2}" -f $entry.id, $entry.scope, $entry.summary)
    }
    return
}

try {
    $projectRoot = (Resolve-Path -LiteralPath $ProjectRoot -ErrorAction Stop).Path
} catch {
    throw "Project root does not exist: $ProjectRoot"
}

$projectRoot = Resolve-FullPath $projectRoot
if (Test-SamePath $projectRoot $centralRoot) {
    throw "ProjectRoot cannot be the central repository itself."
}

$projectSkillsRoot = Join-Path $projectRoot $targetRelative
$statePath = Join-Path $projectRoot $stateRelative
$state = Read-JsonFile $statePath
$currentStateIds = @()

if ($null -ne $state -and $null -ne $state.skills) {
    $currentStateIds = @($state.skills | ForEach-Object { ([string]$_).Trim() } | Where-Object { $_ })
}

$selectedIds = New-Object System.Collections.Generic.List[string]

if ($Profile) {
    if ($null -eq $catalog.profiles) {
        throw "Catalog does not define profiles."
    }

    $profileProperty = $catalog.profiles.PSObject.Properties[$Profile]
    if ($null -eq $profileProperty) {
        throw "Unknown profile: $Profile"
    }

    Add-SelectedIds @($profileProperty.Value)
}

if ($SkillIds) {
    Add-SelectedIds $SkillIds
}

if (($Repair -or $Remove) -and $selectedIds.Count -eq 0) {
    Add-SelectedIds $currentStateIds
}

if ($selectedIds.Count -eq 0) {
    throw "No skills selected. Use SkillIds, Profile, Repair, or Remove."
}

$plans = @()

foreach ($id in $selectedIds) {
    $entry = $catalogIndex[$id]
    $sourcePath = Resolve-FullPath (Join-Path $sourceRoot ([string]$entry.path))

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
        throw "Skill source directory does not exist: $sourcePath"
    }

    if (-not (Test-PathWithin $sourcePath $centralRoot)) {
        throw "Skill source must be inside the central repository: $sourcePath"
    }

    $skillFile = Join-Path $sourcePath "SKILL.md"
    if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
        throw "Skill source is missing SKILL.md: $sourcePath"
    }

    $actualName = Get-SkillName $skillFile
    if ($actualName -ne $id) {
        throw "Catalog id '$id' does not match SKILL.md name '$actualName'."
    }

    $targetPath = Join-Path $projectSkillsRoot $id
    $itemKind = Get-ItemKind $targetPath
    $resolvedTarget = if ($itemKind -eq "Missing") {
        $null
    } else {
        Get-ResolvedPath $targetPath
    }

    if ($Remove) {
        if ($itemKind -eq "Missing") {
            $action = "NOOP"
        } elseif ($itemKind -in @("SymbolicLink", "Junction", "ReparsePoint") -and $null -ne $resolvedTarget -and (Test-SamePath $resolvedTarget $sourcePath)) {
            $action = "REMOVE"
        } else {
            $action = "CONFLICT"
        }
    } else {
        if ($itemKind -eq "Missing") {
            $action = "CREATE"
        } elseif ($itemKind -in @("SymbolicLink", "Junction", "ReparsePoint") -and $null -ne $resolvedTarget -and (Test-SamePath $resolvedTarget $sourcePath)) {
            $action = "UNCHANGED"
        } else {
            $action = "CONFLICT"
        }
    }

    $plans += [pscustomobject]@{
        Id = $id
        Source = $sourcePath
        Target = $targetPath
        Action = $action
    }
}

$conflicts = @($plans | Where-Object { $_.Action -eq "CONFLICT" })
if ($conflicts.Count -gt 0) {
    foreach ($conflict in $conflicts) {
        Write-Error ("Conflict for {0}: target already exists or points elsewhere: {1}" -f $conflict.Id, $conflict.Target)
    }
    throw "No changes were applied because conflicts were found."
}

$mode = if ($Apply) { "APPLY" } else { "DRY RUN" }
Write-Output ("{0}: project={1}" -f $mode, $projectRoot)
Write-Output ("skills target={0}" -f $projectSkillsRoot)

foreach ($plan in $plans) {
    Write-Output ("[{0}] {1} -> {2}" -f $plan.Action, $plan.Id, $plan.Source)
}

if (-not $Apply) {
    Write-Output "No files changed. Use -Apply to execute this plan."
    return
}

if (-not (Test-Path -LiteralPath $projectSkillsRoot -PathType Container)) {
    New-Item -ItemType Directory -Path $projectSkillsRoot -Force | Out-Null
}

foreach ($plan in $plans) {
    if ($plan.Action -eq "CREATE") {
        New-DirectoryLink -LinkPath $plan.Target -TargetPath $plan.Source -LinkType $linkType
    } elseif ($plan.Action -eq "REMOVE") {
        Remove-Item -LiteralPath $plan.Target -Force
    }
}

if ($Remove) {
    $remainingIds = @($currentStateIds | Where-Object { $selectedIds -notcontains $_ } | Sort-Object -Unique)
} else {
    $remainingIds = @($currentStateIds + @($selectedIds) | Sort-Object -Unique)
}

$newState = [ordered]@{
    schemaVersion = 1
    catalogSchemaVersion = $catalog.schemaVersion
    sourceRepository = $catalog.repository.name
    managedTarget = $targetRelative
    skills = $remainingIds
    updatedAt = (Get-Date).ToUniversalTime().ToString("o")
    managedBy = "aimer-skill-manager"
}

Write-JsonFile -Path $statePath -Value $newState
Write-Output ("State written: {0}" -f $statePath)
