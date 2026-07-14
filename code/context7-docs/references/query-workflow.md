# Query Workflow

## Resolve the library

Use the official product name and the user's actual intent:

```bash
ctx7 library "Next.js" "How to configure typed routes in the current version"
ctx7 library Prisma "How to define a cascading one-to-many relation"
```

Always pass a specific query because it affects result ranking. If the name is ambiguous, ask for clarification when choosing incorrectly would materially change the answer. Otherwise select the strongest match and state the assumption.

The current `--json` output is a top-level array whose items use `id` for the Context7 library ID:

```bash
ctx7 library "Next.js" "typed routes configuration" --json
```

Select results in this order:

1. Exact official-name match
2. Description relevant to the requested technology
3. Requested version, when present
4. High or medium source reputation
5. Strong snippet coverage and benchmark score

Try one alternate spelling only when the first results are clearly wrong. Do not spend the entire three-request budget repeatedly resolving the same library.

## Handle versions

Use `/org/project/version` only when `library` lists a compatible version. Do not invent a versioned ID. If the exact version is unavailable, use the closest documented match only after telling the user about the mismatch.

Skip library resolution when the user supplies a valid `/org/project` or `/org/project/version` ID.

## Fetch useful documentation

```bash
ctx7 docs /vercel/next.js "How to configure typed routes in the current version"
```

Use one focused concept per query. Preserve multiple concepts in one query when the question is specifically about their interaction.

Good queries include the library, operation, and relevant constraint:

- `React useEffect cleanup for an aborted async request`
- `Prisma cascading delete for a required one-to-many relation`
- `AWS SDK for JavaScript v3 S3 multipart upload error handling`

Avoid vague queries such as `hooks`, `auth`, or `configuration`.

## Use the result

- Prefer returned API signatures, configuration keys, migration notes, and code examples over memory.
- Adapt examples to the project's installed version and conventions.
- Do not claim that Context7 verified a detail absent from its output.
- Preserve source links returned by Context7 when the answer benefits from attribution.

## Recover from weak results

If Context7 has no relevant match or lacks the needed detail:

1. State what coverage is missing.
2. Use the technology's official documentation through an available browsing tool.
3. Clearly label any remaining inference or version uncertainty.

Do not silently answer version-sensitive API questions from training knowledge.
