## 环境初始化：Vite + React + TailwindCSS v4

### 0. 检查 Node.js 环境

先检查是否已安装 Node.js：
```bash
node -v
```

**如果显示版本号（如 v20.x.x）**：跳到步骤 1

### 1. 创建项目并安装依赖
pnpm create vite@latest . -- --template react && pnpm install

### 2. 安装 TailwindCSS v4（Vite 插件版）
pnpm install tailwindcss @tailwindcss/vite

### 3. 配置 vite.config.js
import tailwindcss from '@tailwindcss/vite'
export default { plugins: [react(), tailwindcss()] }

### 4. 配置 src/index.css
仅保留一行：@import "tailwindcss";
（Tailwind v4 已废弃 @tailwind base/components/utilities 写法）

### 5. 添加 jsconfig.json 路径别名（可选）

### 6. 安装 UI 增强库
pnpm install framer-motion lucide-react clsx tailwind-variants react-icons

### 7. 图标与动效约定
- framer-motion：滑入/过渡动效
- lucide-react：系统图标
- react-icons/si：社媒图标（Si 前缀）

完成后，迅速构建L1\L2\L3 文档，实现分型初始化。
等待下一步指令。
