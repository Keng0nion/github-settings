🌐 [中文](README.md) · English · [日本語](README.ja.md)

# github-settings

A [skill](https://agentskills.io) that lets AI agents read and change GitHub repository & profile settings directly — including **pinning repositories to your profile**, which no official API supports.

---

## Why this exists

We verified against the current public GraphQL schema (2026-02): `pinItem` / `unpinItem` **no longer exist**, the REST API has no pin endpoint, and `gh` has no pin command ([cli/cli#8871](https://github.com/cli/cli/issues/8871), still open). Community extensions are read-only too.

**The only write path is the web UI's "Customize your pins" dialog.** This skill encodes that reality instead of inventing a mutation that fails — pins are read via GraphQL and written by automating the web UI; everything else goes through `gh` CLI and REST.

---

## What it covers

- **Pinned repositories** — read via GraphQL (`pinnedItems` / `pinnableItems` / `pinnedItemsRemaining`, max 6, users & orgs); write via the web-UI automation flow, with manual fallback. Pins can be repos, gists, issues, PRs, or projects.
- **Repository settings** — `gh repo edit` quick reference: description, homepage, topics, visibility, default branch, merge strategy, issues/wiki/discussions/projects, template, secret scanning.
- **Branch protection & rulesets** — REST endpoints with payload guidance.
- **Other settings** — Actions permissions, environments, webhooks, deploy keys, collaborators, profile (name/bio/blog), social accounts.

---

## Install

One line (macOS & Linux):

```bash
curl -fsSL https://raw.githubusercontent.com/Keng0nion/github-settings/main/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/Keng0nion/github-settings.git
mkdir -p ~/.zcode/skills ~/.agents/skills
cp -r github-settings ~/.zcode/skills/
cp -r github-settings ~/.agents/skills/
```

Releases: packaged skill archives are attached to each [GitHub release](https://github.com/Keng0nion/github-settings/releases) — download the zip and drop it into `~/.zcode/skills/`.

Requires the GitHub CLI (`gh`) with `repo` scope (`gh auth login`). The pin write flow additionally needs a browser-automation skill (e.g. [agent-browser](https://github.com/vercel-labs/agent-browser)) with a GitHub-signed-in browser session.

---

## Usage

Once installed, just ask your agent naturally:

- "Pin xxx to my GitHub profile"
- "Add topics and update the description"
- "Enable secret scanning"

The agent will follow `SKILL.md`: read pins via GraphQL, change pins through the web UI, and manage everything else with `gh` CLI — always verifying changes with a read-back.

---

## Maintainer notes

After editing `SKILL.md` / `README.md`, sync them back with the GitHub Contents API (keeps the commit history clean, no local git needed):

```bash
gh api -X PUT repos/Keng0nion/github-settings/contents/SKILL.md \
  -f message="Update SKILL.md" \
  -f content="$(base64 < SKILL.md | tr -d '\n')" \
  -f sha="$(gh api repos/Keng0nion/github-settings/contents/SKILL.md --jq '.sha')"
```

Cut a release: `gh release create vX.Y.Z --repo Keng0nion/github-settings --title vX.Y.Z --generate-notes`, then attach the packaged zip with `gh release upload`.

---

## License

[MIT](LICENSE)
