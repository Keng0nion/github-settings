#!/bin/bash
# github-settings skill installer — macOS & Linux
# Installs the skill into both global skill directories used by AI agents.
set -e

REPO="Keng0nion/github-settings"
DESTS=("$HOME/.zcode/skills" "$HOME/.agents/skills")

command -v git >/dev/null 2>&1 || { echo "error: git is required (brew install git)"; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
git clone --depth 1 "https://github.com/$REPO.git" "$TMP/github-settings" >/dev/null 2>&1 \
  || { echo "error: could not clone https://github.com/$REPO"; exit 1; }

for dest in "${DESTS[@]}"; do
  mkdir -p "$dest"
  rm -rf "$dest/github-settings"
  cp -R "$TMP/github-settings" "$dest/"
  echo "installed: $dest/github-settings"
done

echo
echo "done — the skill is available on the agent's next turn."
echo "API calls require 'gh auth login' (repo scope); the pin write flow needs"
echo "a browser-automation skill (e.g. agent-browser)."
