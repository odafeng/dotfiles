# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Supports macOS, Linux, and Windows.

## Managed files

| File | Description |
|------|-------------|
| `.gitconfig` | Git configuration (autocrlf per OS) |
| `.zshrc` | Zsh config (macOS/Linux) |
| `PowerShell/Microsoft.PowerShell_profile.ps1` | PowerShell profile (Windows) |
| `.claude/CLAUDE.md` | Claude Code global instructions |
| `.claude/settings.json` | Claude Code settings |

## Setup on a new machine

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <GITHUB_USERNAME> --source ~/dotfiles
```

## Daily usage

```bash
# Pull latest and apply
chezmoi update

# Edit a managed file
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply
```
