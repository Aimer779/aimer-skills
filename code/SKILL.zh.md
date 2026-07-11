---
name: design
description: "为任何组件、页面或视觉界面生成有辨识度的、生产级 UI。当用户发送截图并附带视觉投诉时，驱动截图迭代。不适用于后端逻辑或数据管线。"
when_to_use: "设计, 做页面, 做组件, 不好看, 不和谐, 样式, 前端, UI, build page, create component, make it look good, style, design, screenshot with visual complaint"
---

# 设计：带着明确主张去做

如果一个界面用默认 prompt 就能生成出来，那它就不够好。

## 截图迭代模式

当用户发送截图或图片并附带投诉时激活（"这里很丑"、"这个不对"、"fix this"、"looks wrong"）。现有产品就是方向，跳过五问锁定流程。

**流程：**

1. 阅读截图。用一句话描述问题：具体哪里不对（spacing、contrast、alignment、typeface、color）。
2. 等用户确认诊断后再动代码。
3. 如果诊断结果是已知的 UX 问题（split-view sync、infinite scroll、virtualised list、sticky header），花一轮调研 2-3 个同类成熟产品的解决方案再写代码。引用每个产品的做法。仅当修复是纯视觉层面的（color、spacing、copy）时才跳过。
4. 找到对应的代码：grep 组件名或 class，读实际文件。不要靠记忆或猜测文件位置。
5. 应用最小修复。一个组件，一个问题。
6. 请用户在浏览器中验证。没有这一步不要交付。

**边界**：如果修复需要改动 3 个或更多组件，或者暴露的是方向问题而非具体 bug，暂停并运行完整的方向锁定再继续。

**重设计优先级**（在现有 UI 基础上改造而非从零构建时）：字体替换 → 颜色清理 → hover/active 状态 → 布局和留白 → 替换通用组件 → 添加 loading/empty/error 状态 → 排版微调。这个顺序在最小化每次改动影响范围的同时最大化视觉提升。完整规则见 `references/design-reference.zh.md`。

## 先锁定方向

**在开始任何组件、页面或视觉工作之前**：列出 2-3 个同类成熟产品（如 Notion、Linear、Typora、iA Writer、Raycast），各写一句话说明它们如何解决当前的具体问题。然后再写代码。仅当任务是纯视觉层面的（color、spacing、copy）时才跳过。

在写任何代码之前，直接询问用户（使用环境原生的提问或审批机制，如果有的话）：

1. **谁在用，什么场景？** 分析师 dashboard 和 landing page 或 onboarding flow 不一样。如果答案是 sidebar + 主工作区布局，见下方"App shell 例外"。
2. **审美方向是什么？** 精确命名：dense editorial、raw terminal、ink-on-paper、brutalist grid、warm analog。"简洁现代"不是方向。如果用户给出参考网站或产品（"感觉像 Linear / Claude.ai / Vercel"），不要直接接受——从中提取 3 个具体属性：button radius 哲学、surface depth 处理方式（shadow vs background step vs border）、accent color 色系。用这些来命名。

   **参考是知名品牌时的快捷方式**（Linear、Stripe、Claude、Vercel、Apple、Tesla、Notion、Figma、Airbnb、Spotify 等约 56 个品牌已收录在 `awesome-design-md` 中——见 `references/design-reference.zh.md` 的 brand preset 部分）：询问用户是否要通过 `npx getdesign@latest add <brand>` 拉取预设。用户同意后执行，读取项目根目录生成的 `DESIGN.md`，然后基于该文件做 3 属性分解而非靠记忆。预设是起点，不是方向——用户仍需精确命名审美方向，本 skill 的 reflex-font 黑名单和绝对禁令在任何冲突中优先。

3. **用户会记住什么？** 一种字体、color system、出人意料的 motion、不对称布局。选一个并让它显而易见。
4. **硬约束是什么？** Framework、bundle size、contrast 最低要求、keyboard accessibility。
5. **标志性的 micro-interaction 是什么？** 按压缩放、staggered reveal、contextual icon animation。选一个并确切知道怎么实现。

五个问题全部回答之前不要开始。

### 源码仓库作为参考

当用户提供一个现有产品的仓库 URL 或粘贴源代码来复现或扩展时：文件树是菜单，不是饭菜。不要靠记忆或训练数据重建 UI，而是读实际源码：
- Theme 和 token 文件：`theme.ts`、`colors.ts`、`tokens.css`、`_variables.scss` 或等效文件
- 全局样式表和 layout scaffold
- 用户提到的具体组件

提取精确值：hex codes、spacing scale 条目、font stacks、border radii。粗略近似不是像素级还原。

只附加目标组件文件夹或 package。排除 `.git`、`node_modules`、`dist` 和 lock 文件。拖入整个 monorepo 会用无关代码污染上下文并降低输出质量。

### App shell 例外（sidebar + 主工作区）

当第一个问题的答案是 app shell（Slack、Linear、Notion 级别）：
- 装饰性背景默认关闭
- Surface 层级仅使用 background-color steps 和 shadow
- 所有交互元素添加 `active:scale-95`
- Button radius 在每种组件类型内保持一致（选一种：pill、square 或一个固定值——不要混用）
- 在第一个组件之前确定一个命名的 radius scale（见 `references/design-reference.zh.md` 的 Border radius 系统）

用一句话说明选定的方向，然后加载 `references/design-reference.zh.md` 并检查 tech stack 冲突表。在写第一个组件之前命名单一的 CSS 策略。

在写任何代码之前用三行总结方向：
- **视觉论点**：一句话描述 mood、material 和 energy（如"warm brutalist editorial with high-contrast ink type and rough paper texture"）
- **内容计划**：hero → support → detail → final CTA，各一行。对于 **app/dashboard 界面**：跳过营销结构，默认 utility 模式（orient、show status、enable action），除非明确要求否则不要 hero。
- **交互论点**：2-3 个具体的 motion 想法，改变页面感受（如"hero text 加载时滑入，section headers 固定而内容在其下方滚动，CTA hover 时脉动"）

对于生产级或多页面 UI，将论点扩展为 `references/design-reference.zh.md` 中的 9 部分 DESIGN.md scaffold（theme、palette、typography、components、layout、depth、do/don't、responsive、prompt guide）。对于单个组件，三行就够了。

## 不可妥协的约束

`references/design-reference.zh.md` 在方向锁定阶段已加载。它掌管所有规则：typography、OKLCH color、motion timings、layout 默认值、CSS-pattern 禁令、accessibility 基线和复杂度匹配。应用它们，不要在这里重复。

## 被要求给选项时

至少给 3 个变体，分布在真正不同的维度上：

- **可变维度**：visual density、typographic personality、color temperature、layout structure、motion character、装饰量、抽象程度
- **混合方式**：一个紧跟现有惯例的选项、一个用新方式重组 brand DNA 的选项、一个故意出人意料的选项
- **从基础到大胆递进**：第一个选项安全易懂，后面的选项逐步推进
- 仅 accent color 不同的三个选项不是三个变体。要改变 layout、typeface、motion、surface treatment。

## 踩坑

| 发生了什么 | 规则 |
|-----------|------|
| 用 Inter 做 display font | 它传达不了任何东西。选一个有个性的。 |
| 三张卡片，相同的 shadow、相同的 padding——一个模板 | 如果替换内容不需要改变布局，重做。 |
| 没打开浏览器就说看起来对 | 脑子里正确的代码在浏览器里可能坏掉。打开看看。 |
| 选了 glassmorphism，忽略了移动端约束 | `backdrop-filter` 在低性能设备上开销大。说明 tradeoff。 |
| Light-mode app：白色面板在白色背景上，视觉上无法区分 | 相邻嵌套 surface 必须视觉可区分。要么 background step（sidebar vs main ≥4% lightness 差异），要么 shadow 最小 `0 1px 3px rgba(0,0,0,0.10)`。 |

## 美学审查

在重要构建阶段后和交付时，重新阅读方向锁定中的视觉论点。如果屏幕上的内容漂移向通用默认值，找出最先出问题的具体元素（typeface、color、card treatment、spacing）并在继续之前修复。

在交付摘要之前运行这些检查：
- 第一屏中品牌或产品是否一目了然？
- 是否有一个强视觉锚点（真实图片，不是装饰渐变）？
- 只扫描标题能否理解页面？
- 每个 section 是否只有一个职责？
- 卡片是否真的必要，还是只是默认样式？
- motion 是改善了层级感或氛围感，还是只是装饰？
- 去掉所有装饰性阴影后，设计是否仍然感觉高级？
- AI 水检（AI Slop Test）：扫描第一屏的默认模式（reflex font、purple-to-blue gradient、居中 hero 配两个并排 CTA、三个相同卡片、通用顶部导航）。如果有任何非故意出现，修改 typography、color 或 layout 直到消除。

如果有检查不通过，先修复。请用户在全宽和 375px 下验证；如果布局在移动端宽度下坏掉，修复后再交付。

结束时：
- 审美方向，命名并用 2-3 句话论证
- 解释非显而易见的选择：typeface、color 决策、layout 逻辑
- 用真实内容替换占位内容的指引

交付后，停止。
