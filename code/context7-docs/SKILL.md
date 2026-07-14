---
name: context7-docs
description: Use the Context7 CLI when a coding task depends on current or version-specific behavior of an external library, framework, SDK, API, CLI tool, or cloud service that cannot be verified from the project manifest, lockfile, installed types or package source, repository code, tests, or local documentation. Retrieve focused documentation for API syntax, configuration, setup, migrations, and library-specific debugging. Do not use for repository-local behavior, stable language fundamentals, generic programming concepts, or questions already answerable from local evidence.
---

# Context7 Documentation

Use the globally installed `ctx7` CLI only when current external documentation is materially relevant and local evidence is insufficient.

## Workflow

1. When project context exists, inspect the manifest, lockfile, installed types or package source, repository code, tests, and local documentation. Identify the exact library and installed version. Stop if these sources answer the question.
2. Formulate one narrow implementation question. Remove secrets, credentials, personal data, and proprietary code from it.
3. Resolve the library unless the user supplied an ID in `/org/project` or `/org/project/version` format:

   ```bash
   ctx7 library <official-name> "<specific-question>"
   ```

4. Select the best match by exact name, description, version, snippet coverage, source reputation, and benchmark score. Use a version-specific ID only when `library` returns one compatible with the installed version.
5. Fetch documentation with the selected ID:

   ```bash
   ctx7 docs <library-id> "<specific-question>"
   ```

6. Compare the retrieved documentation with the installed version, local types, and existing code. Distinguish documented facts from implementation judgments.
7. If the task requests a code change, implement the smallest correct change and run the relevant formatter, type checker, tests, or build.
8. Summarize only the documentation evidence that affected the answer or implementation. Do not copy large documentation dumps into the response.

Run no more than three Context7 requests for one user question. Split distinct concepts into separate `docs` queries only when the remaining request budget allows it. Keep interacting concepts together.

Read [references/query-workflow.md](references/query-workflow.md) when selecting among results, handling versions, composing queries, or recovering from incomplete results.

## Boundaries

- Use Context7 for potentially changed external technology behavior only when local evidence is insufficient.
- Do not use it for repository-local APIs, stable language features, pure business logic, general algorithms, mechanical refactoring, or questions answerable from existing source, types, tests, or local documentation.
- Do not use `ctx7 skills` commands. This skill does not search, install, remove, or generate third-party skills.
- Do not configure MCP. Context7 access in this skill is CLI-only.
- Prefer the global `ctx7` command. Do not install or upgrade it unless the user asks.

## Configuration and failures

Read [references/setup.md](references/setup.md) only when `ctx7` is missing, authentication or quota fails, the user asks how Context7 is configured, or the CLI has network problems.

Never silently substitute model memory when current documentation could not be retrieved. State the failure and, when available, fall back to the technology's official documentation while disclosing that Context7 was unavailable or incomplete.
