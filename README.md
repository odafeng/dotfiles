# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Supports macOS, Linux, and Windows.

## Managed files

| File | Description |
|------|-------------|
| `.gitconfig` | Git configuration (name, email, autocrlf per OS) |
| `.zshrc` | Zsh config (macOS/Linux, OS-specific PATH and aliases) |
| `PowerShell/Microsoft.PowerShell_profile.ps1` | PowerShell profile (Windows only) |
| `.claude/CLAUDE.md` | Claude Code global instructions |
| `.claude/settings.json` | Claude Code settings |

## Setup on a new machine

### macOS / Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply odafeng --source ~/dotfiles
```

### Windows (PowerShell)

```powershell
# Install chezmoi (choose one)
winget install twpayne.chezmoi
# or
choco install chezmoi

# Apply dotfiles
chezmoi init --apply odafeng --source ~/dotfiles
```

First run will prompt for your email address.

## Daily usage

```bash
# Edit a managed file (edits the template in source dir)
chezmoi edit ~/.zshrc

# See what would change before applying
chezmoi diff

# Apply changes to home directory
chezmoi apply

# Commit and push after editing
cd ~/dotfiles && git add -A && git commit -m "update ..." && git push

# On another machine, pull latest and apply
chezmoi update
```
