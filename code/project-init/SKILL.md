---
name: project-init
description: "使用这个skill当用户说进行项目初始化，搭建基础框架，配置环境，以准备好开发和测试的基础设施。"
---

## Project Init: 项目初始化
项目初始化阶段，搭建基础框架，配置环境，准备好开发和测试的基础设施。为后续开发打好坚实基础。

## 触发条件
- 项目刚开始，需要搭建基础环境
- 需要配置开发工具、依赖、测试框架等

## 标准流程
1. 确定项目类型（如Web、CLI、库等）
2. 选择合适的技术栈（如语言、框架、数据库等）
3. 搭建项目结构（如目录、文件等）见下“技术栈路由”
4. 配置开发环境（如版本控制、依赖管理等）
5. 编写全局规范文件（AGENTS.md,CLAUDE.md）见template/AGENTS.md和template/CLAUDE.md
6. 输出项目初始化报告，等待用户确认

## 技术栈路由
- Next.js + Tailwind CSS 参考详情：`reference/project-init-nextjs.md`
- Python + FastAPI 参考详情：`reference/project-init-python.md`
- Java + Spring Boot 参考详情：`reference/project-init-java.md`
- Vue 3 + Vite 参考详情：`reference/project-init-vue.md`
- React + Vite 参考详情：`reference/project-init-react.md`

## 工具
- GitHub CLI（gh）, git: 用于创建仓库、管理代码等
- 虚拟环境工具使用`uv`: 用于管理 Python 依赖
- 环境变量管理使用`.env`: 用于存储敏感信息
- 包管理器总是使用`pnpm`: 用于安装项目依赖


## 踩坑经验
用户使用的是**windows**系统，以下是一些常见的踩坑点和解决方案：

1. GitHub 仓库创建
  ┌─────────────────┬────────────────────────────────────────────────┐
  │ 步骤            │ 命令/操作                                      │
  ├─────────────────┼────────────────────────────────────────────────┤
  │ 初始化 git      │ git init                                       │
  │ 创建初始文件    │ echo "# name" > README.md                      │
  │ gh 创建公开仓库 │ gh repo create name --public --source=. --push │
  └─────────────────┴────────────────────────────────────────────────┘
  踩坑点：
  • ❌ 空目录无法 git commit（nothing to commit）→ 需先创建任意文件（如 README）
  • ❌ SSH 被防火墙阻止（Connection closed by ... port 22）→ 改为 HTTPS：git remote set-url origin https://github.com/...

2. 虚拟环境管理（uv）
  uv venv
  source .venv/Scripts/activate   # Windows！不是 .venv/bin/activate
  uv pip install xxx

  踩坑点：
  • ❌ Linux/Mac 的 source .venv/bin/activate 在 Windows 上会报错 No such file → 必须用 .venv/Scripts/activate

3. 环境变量（.env）
  ┌──────────────┬────────────────┬────────────────────────────┐
  │ 文件         │ 作用           │ 是否提交 Git               │
  ├──────────────┼────────────────┼────────────────────────────┤
  │ .env         │ 真实密钥       │ ❌（已被 .gitignore 保护） │
  │ .env.example │ 模板（默认值） │ ✅                         │
  └──────────────┴────────────────┴────────────────────────────┘

踩坑点：
• ❌ .env 追加内容导致 Key 重复！ 后面追加的默认值会覆盖前面的真实值：
    MOONSHOT_API_KEY=sk-xxx        ← 真实值
    MOONSHOT_API_KEY=your_xxx_here ← 默认值（覆盖！）
    → 修改 .env 时先检查是否已存在该 key，不要直接 echo >> 追加
