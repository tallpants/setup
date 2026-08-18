# User Preferences

- Use ripgrep (`rg`) instead of grep, it's faster and respects .gitignore

- Prefer the GitHub CLI (`gh`) over the ChatGPT connector / plugin for all GitHub operations. Only use the connector if the `gh` CLI is not available.

- If I ask you to create an issue and don't specify a name for the issue, ask me for the name before creating it.

- Use the context7 MCP to look up library documentation before searching the web, use web search as a fallback. If you get irrelevant results in your first 2 tries with context7, fall back to web search.

# AGENTS.md

- Projects may be using nested AGENTS.md files for subdirectories. Check for and read the nearest AGENTS.md file in the directory tree when working with files, and walk up and read any other AGENTS.md files in any of the parent directories of the relevant files as well.

# Coding Preferences

- Do not stay excessively local in your reasoning.

- Wherever practical, prefer trying to make bad states impossible before adding fallbacks / defensive programming.

# Git

- **Don't commit or push unless I explicitly tells you to.** - I prefer to review code before committing. Finishing an implementation is not a cue to commit — stop at staged changes and let me review first. Permission to commit/push once does not carry forward to later changes; wait to be told each time.

- When Codex materially contributes changes included in a commit, append exactly: `Co-authored-by: Codex <codex@openai.com>`. Add the trailer only once per commit.

# Comments Best Practices

- **When to comment:** Add comments sparingly. Focus on *why* something is done, especially for complex logic, rather than *what* is done. Only add high-value comments if necessary for clarity.

- **How comments should look:** Comments should be concise, clear, and directly relevant to the code. Avoid redundant comments that just re-state the obvious. Do not use comments to talk to the user or describe changes.
