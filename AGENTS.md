# aimer-skills 仓库说明

## 仓库定位

这是 Aimer 的个人 skills 中心仓库，用来集中积累、维护和复用不同领域的 AI
工作流与项目指导能力。

- GitHub：Aimer779/aimer-skills
- 本地中心仓库：D:\aimer-skills
- 仓库类型：以 Markdown、JSON 和 PowerShell 为主的 skill 文档仓库
- 核心目标：中心仓库维护一次，其他项目通过软连接读取最新版本

不要把这里理解成某个业务项目。这里的主要产物是可复用的 skill、skill
管理工具和 GEB 文档协议。

## 目录结构

~~~text
.
├─ AGENTS.md                         # 本仓库说明和 AI 协作规则
├─ skill-catalog.json                # skill 注册表、标签、触发词和 profiles
├─ scripts/
│  └─ sync-skills.ps1                # 创建、修复和移除项目级 skill 链接
└─ code/
   ├─ design/SKILL.md                # UI、落地页和视觉设计
   ├─ tdd/SKILL.md                   # 测试驱动开发
   ├─ handoff/SKILL.md               # 会话交接
   ├─ project-init/SKILL.md          # 项目初始化
   ├─ spec-write/SKILL.md            # 最小 spec 编写
   ├─ grill-with-docs/SKILL.md      # 基于文档的计划压力测试
   ├─ grill-me/SKILL.md              # 计划和设计追问
   ├─ aimer-skill-manager/SKILL.md   # 全局 skill 管理入口
   └─ GEB-system/                    # GEB 分形文档协议和相关模板
~~~

只有包含 SKILL.md 的目录才是 Codex 可发现的 skill。GEB-system、CLAUDE.md
和 AGENTS.md 模板属于项目指导资产，不应自动当作 skill 安装。

## 当前 skill 体系

| Skill | 主要用途 |
|---|---|
| design | 构建设计系统、落地页和前端视觉方案 |
| tdd | 使用红-绿-重构循环进行测试驱动开发 |
| handoff | 记录会话完成项、验证结果和下一轮目标 |
| project-init | 初始化项目、环境和开发测试基础设施 |
| spec-write | 把任务压缩成目标、范围、边界和验证方式明确的最小 spec |
| grill-with-docs | 结合领域模型和文档压力测试计划 |
| grill-me | 通过连续追问澄清计划和设计 |
| aimer-skill-manager | 选择、链接、修复和同步项目 skills |

## Skill 管理方式

中心仓库是唯一源码来源：

~~~text
C:\Users\Max\.agents\skills\aimer-skill-manager
  -> D:\aimer-skills\code\aimer-skill-manager
~~~

已设置用户级环境变量：

~~~text
AIMER_SKILLS_ROOT=D:\aimer-skills
~~~

项目需要使用共享 skill 时，manager 应在项目中创建：

~~~text
<project>/.agents/skills/<skill-id>
  -> D:\aimer-skills\code/<skill-id>
~~~

不要复制 skill 内容到其他项目。中心仓库中的修改会通过软连接自动生效；
新增、重命名或移除 skill 时，需要重新执行同步。

推荐使用 manager：

~~~text
$aimer-skill-manager
~~~

手动同步示例：

~~~powershell
& "$env:AIMER_SKILLS_ROOT/scripts/sync-skills.ps1" -ProjectRoot (Get-Location).Path -Profile frontend -Apply
~~~

默认先使用 DryRun 检查计划，再使用 Apply 执行。同步脚本必须遵守以下边界：

- 只处理 skill-catalog.json 中登记的 skill。
- 只允许链接中心仓库内部的目录。
- 不覆盖真实文件或真实目录。
- 不替换指向其他位置的已有链接。
- 只删除确认指向中心仓库预期位置的链接。
- 不自动安装 AGENTS.md、CLAUDE.md 或 GEB 模板。

## 文件维护规则

### 新增或修改 skill

1. 在 code/<skill-id>/ 下创建或维护 SKILL.md。
2. SKILL.md 的 frontmatter 必须包含 name 和 description。
3. name 必须与目录名和 skill-catalog.json 中的 id 一致。
4. 在 skill-catalog.json 中登记 path、summary、tags、triggers 和适用 profile。
5. 使用 sync-skills.ps1 -List 验证 catalog 可读取。
6. 使用临时项目执行 DryRun 和 Apply 测试。

### 修改 manager

manager 的源码位于 code/aimer-skill-manager/SKILL.md。修改后，全局软连接会
直接读取最新内容，不需要复制或重新安装。若 Codex 当前会话没有刷新，启动
新会话或重启 Codex。

### 修改 GEB 文档

GEB-system 是协议和模板参考区。修改其中的 AGENTS 或 CLAUDE 模板时，注意
它们分别服务于不同的项目指导体系，不要混淆文件名或引用路径。

## AI 协作约定

- 开始工作前先阅读本文件，并根据任务需要读取最接近的目录说明。
- 搜索代码、日志和纯文本时使用 rg；不要用 PowerShell Get-Content 或
  Select-String 做搜索。
- Git 命令使用 rtk git 前缀；GitHub CLI 命令使用 rtk gh 前缀。
- 文件编辑使用 apply_patch，保留用户已有的未提交修改。
- 这是文档和脚本仓库，通常不需要安装生产依赖。
- 如果确实需要新增生产依赖，先向用户确认。
- 修改目录结构、catalog、manager 或同步脚本后，必须进行相应的干运行或
  最小可复现测试。
- 完成修改后检查 git diff --check、同步脚本输出和 Git 工作区状态。
- 不要把本机绝对路径、令牌、密钥或个人凭据写入仓库。

## 变更完成标准

一次完整的 skill 变更至少应满足：

1. skill 的说明文件和 catalog 一致。
2. manager 能够通过 catalog 找到该 skill。
3. sync-skills.ps1 能在目标项目创建或确认软连接。
4. 目标项目无需复制 skill 内容即可读取中心仓库的最新版本。
5. 相关测试或 DryRun 结果已记录。
6. Git 工作区状态清晰，提交内容只包含本次任务相关变更。
