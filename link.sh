#!/bin/bash

mkdir -p ~/.config/opencode
mkdir -p ~/.config/nvim
mkdir -p ~/.github
mkdir -p ~/.claude/output-styles

# Home directory
ln -sf ~/dotfiles/.vimrc ~/.vimrc
ln -sf ~/dotfiles/.ideavimrc ~/.ideavimrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.global-gitignore ~/.global-gitignore
ln -sf ~/dotfiles/wezterm/.wezterm.lua ~/.wezterm.lua
ln -sfn ~/dotfiles/.agents ~/.agents

# Neovim
ln -sfn ~/dotfiles/nvim ~/.config/nvim

# OpenCode
ln -sfn ~/dotfiles/opencode/agents ~/.config/opencode/agents
ln -sfn ~/dotfiles/opencode/commands ~/.config/opencode/commands
ln -sfn ~/dotfiles/opencode/tools ~/.config/opencode/tools
ln -sf ~/dotfiles/opencode/opencode.json ~/.config/opencode/opencode.json
ln -sf ~/dotfiles/opencode/rules.md ~/.config/opencode/rules.md
ln -sf ~/dotfiles/opencode/tui.json ~/.config/opencode/tui.json

# GitHub Copilot
ln -sf ~/dotfiles/github-copilot/global-copilot-instructions.md ~/.github/global-copilot-instructions.md
ln -sf ~/dotfiles/github-copilot/global-git-commit-instructions.md ~/.github/global-git-commit-instructions.md
ln -sf ~/dotfiles/github-copilot/mcp.json ~/.github/mcp.json

# Claude
ln -sf ~/dotfiles/.claude/output-styles/senior-developer-mode.md ~/.claude/output-styles/senior-developer-mode.md
