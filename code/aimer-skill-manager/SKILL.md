---
name: aimer-skill-manager
description: Manage the user's central skill repository. Use when initializing a project, selecting shared skills, creating project-local skill links, repairing skill links, or syncing shared skills.
---

# Aimer Skill Manager

## Purpose

Use the central repository as the single source of truth for reusable skills.
The manager chooses skills and delegates filesystem changes to the deterministic
sync script.

## Source of truth

1. Resolve the central repository from the AIMER_SKILLS_ROOT environment variable.
2. If the variable is missing, ask the user for the central repository path. Do not scan the whole disk or guess a repository.
3. Read <central-root>/skill-catalog.json.
4. Treat each catalog path as relative to <central-root>/code.
5. A valid skill directory must contain SKILL.md whose frontmatter name
   matches the catalog id.

## When to use

Use this skill when the user asks to:

- initialize or bootstrap a project;
- choose shared skills for a project;
- install, link, repair, sync, or remove project skills;
- inspect the central skill catalog.

For an explicit install or link request, changes are authorized. For a request
that only asks for recommendations, do not modify the filesystem.

## Workflow

1. Resolve the project root. Prefer the repository root when the current
   directory is inside a Git repository.
2. Inspect the project language, framework, package files, and existing
   .agents/skills links.
3. Read the catalog and select skills using tags, triggers, summaries, and
   dependencies.
4. Present the selected skill IDs and the links that will be created.
5. For a recommendation-only request, stop after the plan.
6. For an explicit install request, run the sync script with -DryRun first,
   then run it with -Apply.
7. Verify the resulting links and report the project state file.

## Sync script

The deterministic script is:

~~~text
<central-root>/scripts/sync-skills.ps1
~~~

Example:

~~~powershell
& "$env:AIMER_SKILLS_ROOT/scripts/sync-skills.ps1" -ProjectRoot (Get-Location).Path -SkillIds @("design", "tdd") -Apply
~~~

The script supports -List, -Profile, -DryRun, -Apply, -Repair, and -Remove.

## Safety rules

- Only link skill IDs registered in skill-catalog.json.
- Only link source directories inside the central repository.
- Never copy skill contents into a project.
- Never overwrite a real file or directory.
- Never replace a link that points somewhere else.
- Only remove a link when it resolves to the expected central source.
- Do not automatically link AGENTS.md, CLAUDE.md, or GEB templates.
  Those are project guidance assets and require a separate explicit request.
- Keep project state in .aimer-skills.json; store logical skill IDs, never
  machine-specific absolute paths.

## Update behavior

Existing project links read the latest central files automatically. Re-run the
sync script when a skill is added, renamed, removed, or newly selected. If a
Codex session does not show a changed skill, start a new session or restart
Codex.
