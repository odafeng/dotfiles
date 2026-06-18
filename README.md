# dotfiles

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Supports macOS, Linux, and Windows.

## Managed files

| File | Description |
|------|-------------|
| `.gitconfig` | Git configuration (name, email, autocrlf per OS) |
| `.zshrc` | Zsh config (macOS/Linux, OS-specific PATH and aliases; Powerlevel10k + macOS `rm`→trash) |
| `.p10k.zsh` | Powerlevel10k prompt config (requires the theme, see below) |
| `PowerShell/Microsoft.PowerShell_profile.ps1` | PowerShell profile (Windows only) |
| `.claude/CLAUDE.md` | Claude Code global instructions |
| `.claude/settings.json` | Claude Code settings (incl. custom status line) |
| `.claude/statusline/statusline.js` | Claude Code status line renderer |
| `.config/ghostty/config` | Ghostty terminal config |

## CLI/TUI toolset

Modern terminal tools wired into `.zshrc` (each guarded by `command -v`, so the
config is safe on machines where a tool isn't installed). Install them with:

```bash
brew bundle --file=Brewfile      # see Brewfile for the list
gh extension install dlvhdr/gh-dash
```

| Tool | Replaces / adds | Shell hook |
|------|-----------------|------------|
| `eza` | `ls` | aliases `ls`/`ll`/`la`/`lt` |
| `bat` | `cat` | `catp`, `BAT_THEME` |
| `zoxide` | `cd` | `z` / `zi` |
| `atuin` | history | Ctrl-R, ↑ |
| `lazygit` | git TUI | `lg` |
| `lazydocker` | docker TUI | `lzd` |
| `gh dash` | PR/issue dashboard | `ghd` |
| `git-delta` | git pager | via `.gitconfig` |
| `btop` | `top` | — |
| `ghostty` | terminal | — |

## Powerlevel10k prompt

`.zshrc` sets `ZSH_THEME="powerlevel10k/powerlevel10k"`. Install the theme as an
oh-my-zsh custom theme on a new machine:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

`.p10k.zsh` carries the prompt config; re-run `p10k configure` to regenerate.

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
