#!/usr/bin/env bash
# Rebuild Claude Code plugins on a fresh machine. Managed by chezmoi.
# run_onchange_: re-runs whenever this file's hash changes — edit the lists below
# (add/remove a plugin) to trigger a re-run on the next `chezmoi apply`.
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "[claude-plugins] claude CLI not found — skipping (re-run 'chezmoi apply' after installing Claude Code)."
  exit 0
fi

add_marketplace() { claude plugin marketplace add "$1" >/dev/null 2>&1 || true; }
install_plugin()  { claude plugin install "$1"        >/dev/null 2>&1 || true; }

# --- Extra marketplaces (the built-in 'claude-plugins-official' needs no add) ---
add_marketplace "ChromeDevTools/chrome-devtools-mcp"        # -> chrome-devtools-plugins
add_marketplace "mukul975/Anthropic-Cybersecurity-Skills"   # -> anthropic-cybersecurity-skills
add_marketplace "anthropics/skills"                         # -> anthropic-agent-skills

# --- Plugins from the official marketplace ---
for p in pyright-lsp clangd-lsp vercel \
         duckdb-skills nvidia-skills huggingface-skills \
         typescript-lsp github context7 claude-md-management; do
  install_plugin "${p}@claude-plugins-official"
done

# --- Plugins from extra marketplaces ---
install_plugin "cybersecurity-skills@anthropic-cybersecurity-skills"  # 762 security skills
install_plugin "document-skills@anthropic-agent-skills"
install_plugin "example-skills@anthropic-agent-skills"
install_plugin "claude-api@anthropic-agent-skills"

echo "[claude-plugins] bootstrap complete — restart Claude Code to load."
# NOTE: 'github' (token) and 'context7' (API key) need credentials configured
# separately — they are NOT stored here (this repo is public).
