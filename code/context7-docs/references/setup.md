# CLI Configuration

This skill uses the Context7 CLI directly. It does not require or configure a Context7 MCP server.

## Verify the installation

```bash
ctx7 --version
ctx7 whoami
```

`whoami` confirms the login state and may display account details. Do not reproduce those details unless the user explicitly needs them.

## Install or update when requested

Prefer pnpm when it is available:

```bash
pnpm add -g ctx7@latest
```

Alternative:

```bash
npm install -g ctx7@latest
```

Do not install or upgrade automatically. First verify whether the existing global command works.

## Authenticate

Interactive OAuth login:

```bash
ctx7 login
ctx7 login --no-browser
```

Check or clear the session:

```bash
ctx7 whoami
ctx7 logout
```

For non-interactive environments, set `CONTEXT7_API_KEY` in the environment. Never paste, log, or place the key in a query, source file, or command output shown to the user.

## Handle failures

- Quota error: tell the user the quota was reached and suggest `ctx7 login` or `CONTEXT7_API_KEY` for authenticated limits.
- Missing command: report that the global CLI is unavailable and offer the install command; do not install without permission.
- DNS, name-resolution, or fetch failure inside a sandbox: retry outside the sandbox when the environment permits it.
- Authentication failure: run `ctx7 whoami`, then ask the user to log in again without exposing identity details.
- Empty or irrelevant documentation: follow the fallback procedure in `query-workflow.md`; do not treat login as the cause without evidence.
