# github-settings

A [skill](https://agentskills.io) that lets AI agents read and change GitHub repository & profile settings directly — including **pinning repositories to your profile**, which no official API supports.

| 中文 | English | 日本語 |
|---|---|---|
| 一个让 AI 直接完成 GitHub 仓库与个人资料设置的 skill —— 包括把仓库 **pin 到个人主页**（官方 API 至今没有这个能力）。 | A skill that lets AI agents read and change GitHub repository & profile settings directly — including **pinning repositories to your profile**, which no official API supports. | AI が GitHub のリポジトリ設定・プロフィール設定を直接操作できるスキル —— **リポジトリをプロフィールにピン留め**（公式 API には存在しない機能）にも対応。 |

---

## Why this exists / 为什么做这个 / なぜ作ったのか

We verified against the current public GraphQL schema (2026-02): `pinItem` / `unpinItem` **no longer exist**, the REST API has no pin endpoint, and `gh` has no pin command ([cli/cli#8871](https://github.com/cli/cli/issues/8871), still open). Community extensions are read-only too.

**The only write path is the web UI's "Customize your pins" dialog.** This skill encodes that reality instead of inventing a mutation that fails — pins are read via GraphQL and written by automating the web UI; everything else goes through `gh` CLI and REST.

- 针对当前公开 GraphQL schema（2026-02）实测：`pinItem` / `unpinItem` **已不存在**，REST API 无 pin 端点，`gh` 无 pin 命令（[cli/cli#8871](https://github.com/cli/cli/issues/8871) 仍开放），社区扩展也只能读不能写。
- **唯一的写入途径是网页端 "Customize your pins" 弹窗。** 本 skill 不凭空捏造不存在的 mutation，而是如实编码这个现实：pins 读取走 GraphQL、写入走网页自动化，其余设置走 `gh` CLI 与 REST。
- 現在の公開 GraphQL スキーマ（2026-02）で検証：`pinItem` / `unpinItem` は**既に存在しない**、REST API に pin エンドポイントはなく、`gh` にも pin コマンドがない（[cli/cli#8871](https://github.com/cli/cli/issues/8871) は未解決）。コミュニティ拡張も読み取り専用。
- **唯一の書き込み経路は Web UI の "Customize your pins" ダイアログ。** 本スキルは存在しないミューテーションを捏造せず、この現実をそのままコード化：pin の読み取りは GraphQL、書き込みは Web UI 自動化、その他の設定は `gh` CLI と REST で対応。

---

## What it covers / 覆盖能力 / 対応範囲

- **Pinned repositories** — read via GraphQL (`pinnedItems` / `pinnableItems` / `pinnedItemsRemaining`, max 6, users & orgs); write via the web-UI automation flow, with manual fallback. Pins can be repos, gists, issues, PRs, or projects.
- **Repository settings** — `gh repo edit` quick reference: description, homepage, topics, visibility, default branch, merge strategy, issues/wiki/discussions/projects, template, secret scanning.
- **Branch protection & rulesets** — REST endpoints with payload guidance.
- **Other settings** — Actions permissions, environments, webhooks, deploy keys, collaborators, profile (name/bio/blog), social accounts.
- **Pins 读取**走 GraphQL（`pinnedItems` / `pinnableItems` / `pinnedItemsRemaining`，上限 6 个，用户与组织均支持）；**写入**走网页自动化流程，附手动降级指引。可 pin 的不只是仓库，还有 gist、issue、PR、project。
- **仓库设置** —— `gh repo edit` 速查：描述、主页、topics、可见性、默认分支、合并策略、issues/wiki/discussions/projects、模板、密钥扫描。
- **分支保护与 rulesets** —— REST 端点与 payload 编写指引。
- **其他设置** —— Actions 权限、environments、webhooks、deploy keys、协作者、个人资料（名字/简介/博客）、社交账号。

---

## Install / 安装 / インストール

```bash
git clone https://github.com/Keng0nion/github-settings.git
mkdir -p ~/.zcode/skills ~/.agents/skills
cp -r github-settings ~/.zcode/skills/
cp -r github-settings ~/.agents/skills/
```

Requires the GitHub CLI (`gh`) with `repo` scope (`gh auth login`). The pin write flow additionally needs a browser-automation skill (e.g. [agent-browser](https://github.com/vercel-labs/agent-browser)) with a GitHub-signed-in browser session.

- 需要 `gh` CLI 并已登录（`repo` scope）。pin 写入流程另外需要浏览器自动化技能（如 agent-browser）和已登录 GitHub 的浏览器会话。
- `gh` CLI（`repo` スコープ）とログインが必要。pin の書き込みにはさらにブラウザ自動化（agent-browser など）とログイン済みブラウザセッションが必要。

---

## Usage / 用法 / 使い方

Once installed, just ask your agent naturally:

- “把 xxx 仓库 pin 到我的主页” / "Pin xxx to my GitHub profile" / 「xxx をプロフィールにピン留めして」
- “给仓库加 topic 并改描述” / "Add topics and update the description" / 「トピックを追加して説明を更新して」
- “开启 secret scanning” / "Enable secret scanning" / 「secret scanning を有効にして」

The agent will follow `SKILL.md`: read pins via GraphQL, change pins through the web UI, and manage everything else with `gh` CLI — always verifying changes with a read-back.

---

## License

[MIT](LICENSE)
