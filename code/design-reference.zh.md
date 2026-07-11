# 设计参考

## Tech Stack 冲突

这些组合会产生静默失败或不一致的输出。永远不要组合使用：

| 不要组合 | 原因 |
|---|---|
| 同一元素上 Tailwind + CSS Modules | Specificity 冲突，cascade 不可预测 |
| 同一元素上 Framer Motion + CSS transitions | 对同一属性做双重动画会导致卡顿 |
| styled-components 或 emotion + Tailwind | 两套竞争的 class 系统争夺同一个 DOM 节点 |
| 一个项目中 Heroicons + Lucide + Font Awesome | 视觉不一致，size 不匹配，bundle 膨胀 |
| 多个 Google Font families 做 display font | 互相竞争的个性会互相抵消 |
| Glassmorphism backdrop-filter + 实色 `border: 1px solid` | 实色边框会破坏分层深度错觉 |
| 深色背景 + `#ffffff` 全不透明文字 | 太刺眼；用 `rgba(255,255,255,0.85)` 或 `#f0f0f0` |
| Tailwind v4 `@theme` + 动态构造的 class 名 | `@theme` tokens JIT 生成 utility classes；如果 class 名由变量构建或不在扫描源中，class 会被 purge，样式静默消失。修复：在源文件中使用静态 class 名，添加到 `safelist`，或在 `:root` + `tailwind.config.js` 的 `extend.colors` 中定义自定义颜色而非用 `@theme` |

在写第一个组件之前，确定项目唯一的 CSS 策略：仅 Tailwind、仅 CSS Modules 或仅 CSS-in-JS。不要偏离。

## 常见陷阱

提交之前，检查是否有以下内容无意混入：

- 白色背景上的紫色或蓝色渐变作为 hero 背景
- 三段式 hero：大标题、一行副文本、两个 CTA 按钮并排
- 卡片网格：相同的圆角、相同的 drop shadow、相同的 padding
- 顶部导航栏：logo 左侧、链接居中、主操作最右
- 白色和 `#f9f9f9` 交替的 sections
- 居中的图标或插图在标题上方，标题在段落上方
- 四列等权重的 footer

如果出于设计意图使用，以上任何一条都可以出现。它们不能作为默认出现。

最终测试：如果你替换成完全不同的内容，布局仍然不需要改动就能合理，那你做的是模板，不是设计。重做。

## 内容真实性

看起来真实但实际不真实的占位文案，在用户阅读的瞬间就会破坏错觉。在交付前应用以下规则。

**示例数据：**
- 不用通用名字：不用 John Doe、Jane Smith、Alex Johnson，或任何读起来像填充物的名字。使用有文化多样性且有真实细节的名字（如 Priya Mehta、Lars Eriksson、Nia Okafor）。
- 不用通用公司名：不用 Acme Corp、Nexus、SmartFlow、TechCorp、Initech。选有行业感的名字（如 Meridian Logistics、Hokkaido Ceramics、Vantage Bioworks）。
- 不用 Lorem Ipsum。写与布局阅读层级匹配的简短真实文案。
- 数据样本不用整数。`99.99%` uptime、`50%` 转化率、`$100.00` MRR 看起来很假。用有机数值：`99.94%`、`47.2%`、`$99.00`。
- 多个头像实例不能共享同一张图片。多个博客或事件卡片不能共享同一个日期。

**UI 文案：**
- 所有标题用 sentence case。每个标题都用 Title Case 是 AI 生成正文最常见的破绽。
- 成功状态去掉感叹号（"Saved!" → "Saved"、"Done!" → "Done"）。`!` 只用于真正的紧急情况。
- 错误消息不要以 "Oops!" 开头。读起来居高临下。
- 错误消息不用被动语态（"Something went wrong" → "We couldn't load your data. Try refreshing."）。
- Hero 文案、CTA 和功能描述中禁用的 AI 营销词汇：Elevate、Seamless、Unleash、Delve、Tapestry、Game-changer、Next-Gen、"In the world of..."。这些词对产品传达不了任何东西。用具体价值替代。

## 占位符优于仿制品

当图标、图片或组件不可用时：使用占位符。在高保真设计中，有标签的占位符永远优于低质量的真实内容尝试。示例：hero 图片用灰色矩形、缺失 logo 用字母组合 wordmark、未设计的组件用虚线边框。

永远不要用内联 SVG 绘制插图。SVG 用于图标和几何形状。对于摄影、插图或产品截图，使用占位符并请用户提供真实素材。

## 生产质量基线

交付前检查。这些不是审美选择，是不可妥协的。

> 将以下部分视为工艺细节，而非默认值。仅在它们服务于已锁定的视觉方向时应用。如果去掉一个细节对界面感受没有影响，就不要加。

### Accessibility
- 纯图标按钮需要 `aria-label`
- 操作用 `<button>`，导航用 `<a>`（不用 `<div onClick>`）
- 图片需要 `alt`（装饰性的用 `alt=""`）
- 可见的 focus 状态：`focus-visible:ring-*` 或等效方案；永远不要 `outline: none` 而不给替代

### 动画
- 遵守 `prefers-reduced-motion`：设置时禁用或减少动画
- 只动画 `transform`/`opacity`（compositor 友好，不触发 layout thrash）
- 永远不用 `transition: all`；显式列出属性
- 可中断动画：交互状态变化（hover、toggle、open/close）优先用 CSS transitions，因为它们能在动画中途重新定向；keyframe 动画留给单次运行的分段序列（如 staggered page enters）
- Staggered enter：将内容分成语义块，约 100ms 延迟；标题按单词分，约 80ms；典型 enter 使用 `opacity: 0 → 1`、`translateY(12px) → 0`、`blur(4px) → 0`
- 微妙 exit：用小的固定 `translateY(-12px)` 而非完整高度；duration 约 150ms `ease-in`，比 enter 更短更柔和
- Contextual icon swaps：动画参数 `scale: 0.25 → 1`、`opacity: 0 → 1`、`blur: 4px → 0px`。使用 spring 库时：`{ type: "spring", duration: 0.3, bounce: 0 }`。不用时：两个 icon 都保留在 DOM 中（一个 absolute），用 CSS `cubic-bezier(0.2, 0, 0, 1)` 交叉淡入淡出
- 按压缩放：按钮在 active/press 时用 CSS transitions 做 `scale(0.96)`，使按压可中断；添加 `static` prop 在 motion 会分散注意力时禁用
- Page-load guard：在 animated presence wrappers 上对 toggles、tabs 和 icon swaps 使用 `initial={false}` 防止首次渲染时的 enter 动画；不要用于有意的 page-load entrance 序列

### 性能
- Transition specificity：永远不用 `transition: all`；列出精确属性（如 `transition-property: scale, opacity`）。Tailwind 的 `transition-transform` 覆盖 `transform, translate, scale, rotate`；混合属性用 `transition-[scale,opacity,filter]`
- GPU compositing：只对 `transform`、`opacity` 或 `filter` 使用 `will-change`。永远不用 `will-change: all`。仅在发现首帧卡顿时添加；不要预防性地应用于每个元素
- 图片：显式设置 `width` 和 `height`（防止 layout shift）
- 首屏以下图片：`loading="lazy"`
- 关键字体：`font-display: swap`

### 触控和移动端
- `touch-action: manipulation`（防止双击缩放延迟）
- 全出血布局：刘海设备用 `env(safe-area-inset-*)`
- Modals 和 drawers：`overscroll-behavior: contain`
- Hover guard：用 `@media(hover:hover)` 包裹交互式 hover 状态，使其仅在指针设备上生效，不在触屏上生效。Tailwind：`[@media(hover:hover)]:hover:bg-...`。不这样做的话，移动端点击的元素会保持永久 hover 状态直到点击其他地方。

### 排版细节
- 文本换行：标题和短文本块（Chromium ≤6 行，Firefox ≤10 行）用 `text-wrap: balance`；正文段落和较长文本用 `text-wrap: pretty`；代码块和预格式化文本保持默认
- 字体平滑：在根布局上一次性应用 `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale`（仅 macOS）
- 表格数字：计数器、计时器、价格、数字列或任何动态更新的数字使用 `font-variant-numeric: tabular-nums`
- Letter-spacing 随字号缩放：display 类型需要负 tracking 看起来是精心设计的而非被拉伸的。两档：display 尺寸（32px 及以上）约 -0.022em，中等尺寸（20–28px）约 -0.012em，16px 及以下正常。应用于任何 display-weight typeface，不只是几何无衬线。大标题上的正 letter-spacing 永远是错的。

### Surfaces
- 同心 border radius：计算 `outerRadius = innerRadius + padding`，使嵌套圆角感觉是有意的而非机械的；如果 padding 超过 `24px`，将各层视为独立 surface 并各自选择 radius
- 光学对齐：用眼睛微调图标位置，不只是靠数学，让按钮感觉居中；带文字和图标的按钮在图标侧用稍少的 padding（如 `pl-4 pr-3.5`）；播放三角形和不对称图标应向较重的一侧偏移 `1px`-`2px`，或直接修改 SVG
- Shadow 优于 border：对 cards、buttons 和 elevated elements 使用多层 `box-shadow` 制造深度，让 surface 感觉被抬起而非被围起来；`border` 只用于分隔线、表格单元格和布局分隔（主要适用于 light mode；dark surfaces 见下方 dark-mode surface 层级规则）
- 图片轮廓：添加微妙的 inset outline 让图片保持自身深度而不改变布局尺寸：`outline: 1px solid rgba(0,0,0,0.1); outline-offset: -1px`（light）或 `outline: 1px solid rgba(255,255,255,0.1); outline-offset: -1px`（dark）
- 最小点击区域：每个交互目标至少保持 40×40px，即使小控件也要感觉慷慨和精确；可见元素较小时用居中的 pseudo-element 扩展，永远不要让两个交互元素的点击区域重叠
- 多卡片对齐：在卡片组中，所有 CTA 按钮底部对齐，使卡片间的高度变化不会产生参差不齐的操作行。在定价或比较卡片中，feature list 条目跨所有列对齐到共享的 Y 原点。在并排面板（testimonials、plans、feature breakdowns）中，title、description、price 和 action button 必须跨行共享 baselines。Section 上下 padding 不必对称：光学平衡通常要求底部 padding 比顶部大 20-25%。正文段落宽度限制在约 65 字符（ch）以保持舒适的阅读行长度。
- Light-mode app surface 层级：相邻嵌套 surface 必须视觉可区分。最低要求：sidebar 和主区域之间、主区域和 cards 之间 background-color lightness 差异至少 4%；或 elevated cards 上至少 `0 1px 3px rgba(0,0,0,0.10)` 的 shadow。近白背景上的白色卡片配 `box-shadow: 0 1px 2px rgba(0,0,0,0.05)` 是看不见的——那不是深度，是噪音。
- Dark-mode surface 层级：页面 canvas 是近黑色实色（如 `#08090a`）。通过在该 canvas 上叠加半透明白色来传达 elevation：cards 用 `rgba(255,255,255,0.02)`，elevated surfaces 用 `0.04`，prominent panels 用 `0.05`。Borders 遵循相同逻辑：`rgba(255,255,255,0.05)` 为微妙，`0.08` 为标准。传统 drop shadow（深色在深色上）几乎不可见；通过 background opacity 的亮度阶梯是 dark surfaces 的主要深度线索。
- Border radius 系统：在方向锁定期间定义一个命名的 radius scale，而非临时选值。最小 scale 是 3-4 档（如 `{4px, 8px, 12px, pill}`）；更丰富的系统可能有 6-8 档。重点是在第一个组件之前确定一个命名集合，让所有 surfaces 说同一种空间语言——而不是覆盖每个可能的 radius 值。

### 在现有 UI 上扩展

扩展现有界面时，先花时间理解它的视觉词汇。在写第一行新代码之前匹配以下所有：
- 文案语气和阅读层级（技术的？随意的？有力的？）
- Color palette 和语义 color 角色（哪些 tokens 表示"danger"、"success"、"muted"）
- Hover 和 click 状态：scale、color shift、underline、background fill
- 动画风格：duration、easing、交互是 bounce 还是严格 ease-out
- Shadow 和 card 处理：哪些 surfaces 是 elevated 的，哪些是 flush 的
- 布局密度和留白节奏
- Border radius 选择以及按钮是 pill、square 还是特定固定值

如果替换成不同内容会让新组件看起来格格不入，说明词汇匹配得还不够。

## 数据可视化界面

### Dashboard 默认值

Dashboards 是 utility 界面：帮助用户定位、展示状态、支持操作。不要 hero sections，不要营销文案。每个元素必须通过回答用户的一个问题来证明自己的存在。

- 主要布局：顶部状态摘要，下方详情；或 sidebar filters + 主图表区域。
- 留白：比营销页紧凑；用户是扫描，不是阅读。使用慷慨的列间距，不是慷慨的行高。
- 数字密度：屏幕上同时出现很多数字不是问题。拥挤而没有对齐才是。所有数字列使用 `font-variant-numeric: tabular-nums`。数字右对齐，标签左对齐。

### 图表选择

| 用例 | 图表类型 |
|---|---|
| 跨类别比较值 | Bar chart（标签长时用水平方向） |
| 随时间变化的趋势 | Line chart；多数据点的时间序列避免用 bars |
| 部分-整体关系 | Treemap（6+ segments）或 stacked bar；pie 仅用于 2-4 segments |
| 分布 | Histogram 或 box plot；永远不用 pie chart |
| 相关性 | Scatter plot；不要用 line chart |

超过 4 个 segments 的 pie chart 传达不了任何东西。用 treemap 或 ranked list 替代。

### 数字密集界面

- 每个数字列用 `font-variant-numeric: tabular-nums`，使数字垂直对齐。
- 所有数字右对齐；所有文本标签左对齐。同一列中混合对齐永远是错的。
- 微妙的行分隔线：`1px` 线，`rgba(0,0,0,0.06)`（light）或 `rgba(255,255,255,0.05)`（dark）。仅在表格非常宽（12+ 列）时使用交替行背景。
- 列间距：相邻列之间至少 `16px`；逻辑上不同的组之间更多。

### 用产品做基准

当用户引用一个产品做视觉基准时（"make it feel like Grafana" / "similar to Linear analytics"）：从该产品中提取 3-5 个具体的数据可视化相关属性，而非通用审美属性。有用的属性：chart color palette（精确值）、grid line weight 和 opacity、axis label size 和 color、tooltip border-radius 和 shadow、empty-state 处理。不要提取"minimal"或"clean"作为属性；这些不可执行。

## 要拒绝的 Reflex Fonts

LLM 默认使用这些字体因为它们主导了训练数据。使用它们等于宣告"没有做决策"。从有清晰声音的 foundry 中选择。

拒绝：Inter、DM Sans、DM Serif Display、DM Serif Text、Outfit、Plus Jakarta Sans、Instrument Sans、Instrument Serif、Space Grotesk、Space Mono、IBM Plex Sans、IBM Plex Serif、IBM Plex Mono、Syne、Fraunces、Newsreader、Lora、Crimson Pro、Crimson Text、Playfair Display、Cormorant、Cormorant Garamond。

## 字体选择流程

1. 写三个描述品牌的词（如"precise、minimal、fast"）。
2. 说出你会本能想到的三种字体。
3. 全部拒绝。
4. 从知名 foundry（Klim、Commercial Type、Colophon、Grilli Type、OH no Type、Village 等）或有清晰个性的开源选项中选择匹配品牌词的 typeface。能用一句话解释为什么选这个 typeface。

## Color 系统：OKLCH 规则

- 用 OKLCH 代替 HSL。OKLCH 是感知均匀的：相等的数值变化在光谱各处产生相等的感知变化。
- 当 lightness 接近极端值时降低 chroma。85% lightness 时 chroma 约 0.08 就够了；推到 0.15 看起来刺眼。15% lightness 时，同样收紧 chroma。
- 用 0.005 到 0.01 的 chroma 将 neutrals 向品牌色相偏移。即使这么微小的量也是可感知的，能创造潜意识的凝聚力。
- 60-30-10 是关于视觉权重，不是像素计数。60% neutral/surface、30% 次要文字和 borders、10% accent。
- 永远不要在彩色背景上用灰色文字。用背景色相降低 lightness 的色调替代。

## Theme 矩阵

根据受众和场景刻意选择 light 或 dark。两者都不是默认值。

| 场景 | 方向 | 原因 |
|---|---|---|
| 交易或分析 dashboard，夜班使用 | Dark | 高数据密度；长时间使用减少眩光 |
| 儿童阅读或学习应用 | Light | 友好，对仍在发展对比敏感度的眼睛疲劳度低 |
| 企业 SRE 或 observability 工具 | Dark | 操作员场景；dark surfaces 在低光 NOC 室一目了然 |
| 周末规划、食谱、日记 | Light | 白天环境使用；light 感觉随意且亲切 |
| 音乐播放器或媒体浏览器 | Dark | 内容优先；dark surfaces 退后让媒体突出 |
| 医院或临床患者门户 | Light | 信任和可读性至关重要；临床关联偏好 light |
| 复古或手工品牌网站 | 暖色/奶油色 light | Dark 会与模拟素材参考冲突 |

如果从场景中无法明确判断，默认用 light。如果用户场景暗示两种模式，先发 light 版本再叠加 dark-mode tokens。

## 绝对禁令（CSS-Pattern 层级）

这些模式出现在大多数 AI 生成的界面中。每个都有具体的重写方式。不是穷尽列表——任何作为无意识默认而非有意选择应用的 CSS pattern 都属于同一类别。

| Pattern | 原因 | 重写 |
|---|---|---|
| `border-left` 或 `border-right` 宽于 1px 作为 section accent | admin 和 dashboard UI 中最被滥用的"设计手法"；超过发丝分隔线的任何宽度看起来都像错误 | 改变元素结构：用彩色点、短水平线、背景色块或排版权重变化替代 |
| `background-clip: text` 渐变文字 | 装饰性的而非有意义的；最常见的 AI 设计破绽之一；打印或高对比度模式下不可读 | 用实色品牌色、tinted neutral 或排版权重做强调 |
| `backdrop-filter: blur` glassmorphism 作为默认 card surface | 低性能设备开销大；过度使用；实色边框会破坏分层深度错觉 | 用 background color steps 和 `box-shadow` 的 elevated surfaces 替代 |
| Purple-to-blue 渐变或 cyan-on-dark accent 系统 | 典型的"AI 设计" color palette；对品牌传达不了任何东西 | 通过上述 OKLCH 规则从品牌词中选择 palette |
| 通用圆角矩形卡片配 `box-shadow` 作为默认容器 | 模板思维；对每种内容类型不分层级地应用相同容器 | 默认无卡片 sections；仅在内容类型需要时添加 card 处理 |
| Modals 作为 overflow UI 的懒惰逃避 | 打断流程并破坏浏览器返回导航；在 inline expansion、drawer 或单独页面更好时使用 | Inline expand、detail panel 或 dedicated route；仅在操作确实需要 focus-lock 时用 modals |
| `transition: all` 或动画 width/height/padding/margin | 强制浏览器每帧都做 layout 重算 | 列出精确属性（`transition-property: transform, opacity`）；height reveals 用 `grid-template-rows: 0fr to 1fr` |

## Motion 细节

补充主 SKILL.md 约束中的 motion timing。

- 不要 bounce 或 elastic easing。真实物体平滑减速。用 exponential ease-out（`ease-out-quart`、`ease-out-quint` 或 `cubic-bezier(0.16,1,0.3,1)`）实现自然、高品质的减速。
- 只动画 `transform` 和 `opacity`。其他任何属性都会触发 layout 或 paint。
- Height reveals 用 `grid-template-rows: 0fr` 到 `1fr` transitions 而非直接动画 `height`。避免 `height: auto` 动画陷阱。
- Icon swaps：120ms 交叉淡入淡出，用 `opacity` 和微妙的 `scale(0.9)` 到 `scale(1)`。不要旋转除非旋转有语义意义（如表示方向变化的 chevron）。
- 不要用 `transition: all` 即使是快速原型捷径。它同时动画 layout、color 和 font-size，导致可见卡顿。

## Reference-site 品牌预设（awesome-design-md）

`VoltAgent/awesome-design-md` 维护 66+ 个从真实品牌网站提取的精选 DESIGN.md 文件。运行 `npx getdesign@latest add <brand>` 将文件放入项目根目录，给 agent 具体的 token 值来分解而非靠记忆推理。

**使用规则：** 永远不要自动运行命令。在方向锁定期间作为选项提供，仅在用户明确批准后运行，将结果视为种子分解材料，而非最终方向。

**目录中的品牌**（当用户提到参考时识别这些）：

| 类别 | 品牌 |
|---|---|
| AI & LLM | Claude、Cohere、ElevenLabs、Mistral、Ollama、Replicate、RunwayML、Together AI、xAI |
| Dev Tools & IDEs | Cursor、Expo、Lovable、Raycast、Superhuman、Vercel、Warp |
| Backend / DB / DevOps | ClickHouse、Composio、HashiCorp、MongoDB、PostHog、Sanity、Sentry、Supabase |
| Productivity & SaaS | Cal.com、Intercom、Linear、Mintlify、Notion、Resend、Zapier |
| Design & Creative | Airtable、Clay、Figma、Framer、Miro、Webflow |
| Fintech & Crypto | Binance、Coinbase、Kraken、Revolut、Stripe、Wise |
| E-commerce & Retail | Airbnb、Meta、Nike、Shopify |
| Media & Consumer | Apple、IBM、NVIDIA、Pinterest、PlayStation、SpaceX、Spotify、Uber |
| Automotive | BMW、Bugatti、Ferrari、Lamborghini、Tesla |

**冲突解决：** 本 skill 的规则始终优先。如果预设推荐了 Reflex Fonts 黑名单上的字体（如 Inter 做 display face），丢弃它并应用字体选择流程。如果它提出了绝对禁令表中的 pattern（如 purple-to-blue 渐变），丢弃它。在交付摘要中说明覆盖。

来源：[github.com/VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)

## 参考素材优先级

当同时有源代码和截图可用于参考 UI 时：读代码。源文件包含精确的 token 值；截图需要猜测。从写下来的内容重建，而非从可见的内容。

当只提供 URL 时：抓取只返回提取的文本，没有布局信息。对于视觉参考（"make it look like X"），要求提供截图而非从剥离的 HTML 推断视觉设计。

## DESIGN.md Scaffold（可选，生产级 UI）

对于多页面或生产级 UI，在写第一个组件之前输出一个简短的 `DESIGN.md` 风格摘要。这迫使枚举那些本来会被隐含的决定，并让用户及早纠正方向。九个部分：

1. **视觉主题和氛围** - mood、density、design philosophy，2-3 句话
2. **Color Palette 和角色** - 每个 color token 的语义名 + 值 + 功能角色
3. **Typography 规则** - font family、size scale、weight scale、line-height、letter-spacing；超过 4 级时用表格
4. **组件样式** - buttons（所有状态）、cards（如果使用）、inputs、navigation；用状态描述（default、hover、active、disabled）
5. **布局原则** - spacing scale、grid columns、留白哲学
6. **深度和 Elevation** - shadow 系统或 background-color-step 系统；描述每个层级
7. **Do's 和 Don'ts** - 5 到 10 条针对本项目的防护栏，不是通用规则
8. **响应式行为** - breakpoints、导航如何折叠、touch target 最小值
9. **Agent Prompt 指南** - 快速 color 参考（name: value 对）+ 3 到 5 个可直接粘贴到后续请求的示例组件 prompts。Prompts 必须具体到无需进一步查询即可执行：每个值、每个 radius、每个 letter-spacing、每个 weight 都内联。示例标准（值仅作说明，使用项目自己的 tokens）："Create a hero on `{bg-canvas}`，headline at 48px weight 600，line-height 1.00，letter-spacing -0.022em，color `{text-primary}`，CTA at `{accent}` with `{btn-radius}` radius"；这种具体程度，而非"hero with primary color and CTA button"

对于单个组件或快速原型，跳过。SKILL.md 中的三行论点就够了。

## 交付前检查清单：战略性遗漏

这些是 AI 生成的 UI 中最常缺失的项目，因为它们需要有意识的产品思考，而非视觉判断。每次交付前过一遍。

- [ ] **自定义 404 页面**：通用框架 404 是破碎的体验。构建一个品牌化的页面，提供清晰的返回路径（首页链接、搜索或最常用的导航项）。
- [ ] **返回导航**：每个用户操作可达的页面必须有清晰、可用的返回路径。死胡同页面（详情视图、确认屏幕、仅 modal 流程）是 UX 失败。
- [ ] **表单客户端验证**：email 字段在提交前验证格式；必填字段显示 inline 错误；错误消息出现在字段旁边，不只是表单顶部。
- [ ] **Skip-to-content 链接**：文档中第一个可聚焦元素是一个视觉隐藏的 `<a href="#main-content">Skip to main content</a>`。Keyboard accessibility 必需。
- [ ] **Cookie consent**：如果产品在欧盟或加州运营，cookie consent UI 不是可选的。根据管辖范围确定实现。
- [ ] **Footer 隐私和条款链接**：每个产品页面都需要这些。缺少它们意味着"demo"，不是"product"。

这些不是视觉打磨项目。它们是 demo 和可发布产品之间的区别。

## AI 水检（AI Slop Test）

一个陌生人扫一眼第一个 viewport 会立刻说"这是 AI 做的"吗？如果是，说明已确定的方向还不够坚定。常见元凶：reflex font、默认紫色 accent、居中 hero 配下方通用卡片网格。修改 typography、color 系统或 layout 直到答案翻转。

---

*Reflex Fonts、Font Selection、OKLCH、Theme Matrix、Absolute Bans、Motion Specifics 和 AI Slop Test 的规则改编自 [pbakaus/impeccable](https://github.com/pbakaus/impeccable)（Apache 2.0）。DESIGN.md Scaffold 改编自 [getdesign.md](https://getdesign.md)（MIT）；概念归功于 Google Stitch。Brand preset 目录来自 [VoltAgent/awesome-design-md](https://github.com/VoltAgent/awesome-design-md)（MIT）。Content Authenticity、Multi-Card Alignment 和 Strategic Omissions 受 [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) 启发。*
