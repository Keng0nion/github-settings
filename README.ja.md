🌐 [中文](README.md) · [English](README.en.md) · 日本語

# github-settings

AI が GitHub のリポジトリ設定・プロフィール設定を直接操作できるスキル —— **リポジトリをプロフィールにピン留め**（公式 API には存在しない機能）にも対応。

---

## なぜ作ったのか

- 現在の公開 GraphQL スキーマ（2026-02）で検証：`pinItem` / `unpinItem` は**既に存在しない**、REST API に pin エンドポイントはなく、`gh` にも pin コマンドがない（[cli/cli#8871](https://github.com/cli/cli/issues/8871) は未解決）。コミュニティ拡張も読み取り専用。
- **唯一の書き込み経路は Web UI の "Customize your pins" ダイアログ。** 本スキルは存在しないミューテーションを捏造せず、この現実をそのままコード化：pin の読み取りは GraphQL、書き込みは Web UI 自動化、その他の設定は `gh` CLI と REST で対応。

---

## 対応範囲

- **Pinned repositories** — read via GraphQL (`pinnedItems` / `pinnableItems` / `pinnedItemsRemaining`, max 6, users & orgs); write via the web-UI automation flow, with manual fallback. Pins can be repos, gists, issues, PRs, or projects.
- **Repository settings** — `gh repo edit` quick reference: description, homepage, topics, visibility, default branch, merge strategy, issues/wiki/discussions/projects, template, secret scanning.
- **Branch protection & rulesets** — REST endpoints with payload guidance.
- **Other settings** — Actions permissions, environments, webhooks, deploy keys, collaborators, profile (name/bio/blog), social accounts.

---

## インストール

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

- `gh` CLI（`repo` スコープ）とログインが必要。pin の書き込みにはさらにブラウザ自動化（agent-browser など）とログイン済みブラウザセッションが必要。

---

## 使い方

Once installed, just ask your agent naturally:

- 「xxx をプロフィールにピン留めして」
- 「トピックを追加して説明を更新して」
- 「secret scanning を有効にして」

The agent will follow `SKILL.md`: read pins via GraphQL, change pins through the web UI, and manage everything else with `gh` CLI — always verifying changes with a read-back.

---

## メンテナンス

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
