# eshopping Agent · 智能选购助手

基于 **LangGraph、FastAPI 和 React** 的跨境电商选购 Agent。通过自然语言描述预算、用途和收货地，完成需求澄清、商品检索、方案比较与交易确认。

## 核心功能

- **对话选购**：流式回答、商品卡片、商品比较与收藏，支持查看工具执行过程。
- **智能检索**：Embedding + Qdrant 向量召回，支持精排与降级检索，并按预算等条件过滤。
- **个性化辅助**：管理长期偏好和个人 Skill，按需注入选购上下文。
- **交易确认**：明确确认后执行本地订单与库存事务，通过幂等与并发控制避免重复操作。
- **持久化与恢复**：保存会话、确认状态和执行记录，支持自动化任务及模型配置管理。

## 技术栈与结构

| 模块 | 技术 |
| --- | --- |
| 前端 | React、TypeScript、Vite、AG-UI |
| 后端与 Agent | Python、FastAPI、LangGraph |
| 存储与检索 | SQLAlchemy、SQLite、Qdrant；Redis 为可选组件 |
| 观测与测试 | OpenTelemetry、pytest、Vitest |

代码采用领域、应用、基础设施与接口分层：

```text
app/domain/          业务对象、规则与接口
app/application/     Agent 编排与业务用例
app/infrastructure/  模型、检索、存储与观测实现
app/presentation/    FastAPI 与 AG-UI 接口
frontend/            React 页面
configs/             模型配置
scripts/             启动与评测工具
tests/、eval/         测试与评测数据
```

## 本地启动（Windows / PowerShell）

需要 Python **3.11–3.13**、uv、Node.js（推荐 **22**）和 npm，请确保这些工具已加入 PATH。最小本机模式使用 SQLite 和本地 Qdrant，无需 Docker 或 Redis。

### 1. 安装依赖

在项目根目录执行：

```powershell
Get-Command python.exe, uv.exe, node.exe, npm.cmd -ErrorAction Stop
python.exe --version
uv.exe --version
node.exe --version
npm.cmd --version
uv.exe sync --frozen
npm.cmd --prefix frontend ci
```

### 2. 配置模型

首次创建本地配置，已有文件保持不变：

```powershell
if (-not (Test-Path -LiteralPath '.env')) {
    Copy-Item -LiteralPath '.env.example' -Destination '.env'
}
```

在 `.env` 中填写实际可用的服务与模型，例如：

```dotenv
LLM_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
LLM_API_KEY=填写你的真实密钥
LLM_MODEL=qwen3-max
EMBEDDING_MODEL=text-embedding-v4
```

模型服务需支持 OpenAI 兼容协议、工具调用和流式输出。Embedding 默认复用同一网关和密钥；如服务不同，另设 `EMBEDDING_BASE_URL` 与 `EMBEDDING_API_KEY`。首次索引可能产生模型调用费用。不要提交 `.env` 或真实密钥；未配置有效密钥时无法完成后端启动与真实选购。

### 3. 启动前后端

在项目根目录打开两个 PowerShell 终端，分别执行：

```powershell
# 终端一：后端
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\scripts\start-backend.ps1
```

```powershell
# 终端二：前端
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
.\scripts\start-frontend.ps1
```

- 页面：[http://127.0.0.1:5173](http://127.0.0.1:5173)
- 接口文档：[http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- 健康检查：`Invoke-RestMethod -Uri 'http://127.0.0.1:8000/health'`

前端自动代理后端接口。本地 Qdrant 使用单进程启动，避免多个后端共用同一数据目录；终端按 `Ctrl+C` 停止服务。

## 验证

```powershell
Get-Command '.\.venv\Scripts\python.exe', npm.cmd -ErrorAction Stop
& '.\.venv\Scripts\python.exe' -m pytest -q
npm.cmd --prefix frontend test
npm.cmd --prefix frontend run build
```

健康检查和测试不代表模型链路已验证。配置完成后，可在页面输入“预算 300 元以内，找一个寄到中国的轻便背包”，检查流式回答、商品卡片与执行记录。部分集成测试需要额外服务。
