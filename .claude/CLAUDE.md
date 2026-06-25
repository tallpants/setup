## User Preferences

- Use ripgrep (`rg`) instead of grep, it's faster and respects .gitignore

- Use the GitHub CLI (`gh`) to look up issues, open PRs, etc. If I ask you to create an issue and don't specify a name for the issue, ask me for the name before creating it.

- Use the context7 MCP to look up library documentation before searching the web, use web search as a fallback. If you get irrelevant results in your first 2 tries with context7, fall back to web search.

## Git

- **Don't commit or push unless the user explicitly tells you to.** - The user prefers to review code before committing. Finishing an implementation is not a cue to commit — stop at staged changes and let the user review first. Permission to commit/push once does not carry forward to later changes; wait to be told each time.

## Comments Best Practices

- **When to comment:** Add comments sparingly. Focus on *why* something is done, especially for complex logic, rather than *what* is done. Only add high-value comments if necessary for clarity.

- **How comments should look:** Comments should be concise, clear, and directly relevant to the code. Avoid redundant comments that just re-state the obvious. Do not use comments to talk to the user or describe changes.

