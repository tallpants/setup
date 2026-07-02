| File | Destination |
|------|-------------|
| `.claude/*` | `~/.claude/*` |
| `.claude.json` | `~/.claude.json` |
| `.zprofile` | `~/.zprofile` (base configuration) |
| `.zprofile_branch` | `~/.zprofile` (work-specific configuration - needs to be merged with base) |
| `.zpreztorc_custom` | `~/.zpreztorc` (Prezto customizations only - deltas to merge into the stock Prezto template) |
| `prompt_sorindoppler_setup` | `~/.zprezto/modules/prompt/functions/prompt_sorindoppler_setup` (custom Prezto prompt theme - sorin fork showing the active Doppler config; set via `prompt sorindoppler`) |
| `ghostty_config` | `~/.config/ghostty/config` |
| `ghostty-themes/*` | `~/.config/ghostty/themes/*` |

### Misc. Tooling

- [QLMarkdown: Quick Look for Markdown](https://github.com/sbarex/QLMarkdown)
- [Prezto: zsh configuration framework](https://github.com/sorin-ionescu/prezto) - `~/.zprezto` is an upstream clone; only the customizations above are tracked here
- [SignalShifter: Audio input and output control from macOS menu bar](https://apps.apple.com/us/app/signal-shifter/id6446061552?mt=12)
