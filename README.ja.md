**目次：**

- [中国語](README.md)
- [英語](README.en.md)
- [日本語](README.ja.md)

# github-settings

AI が GitHub のリポジトリ設定・プロフィール設定を直接操作できるスキル —— **リポジトリをプロフィールにピン留め**（公式 API には存在しない機能）にも対応。

---

## なぜ作ったのか

- 現在の公開 GraphQL スキーマ（2026-02）で検証：`pinItem` / `unpinItem` は**既に存在しない**、REST API に pin エンドポイントはなく、`gh` にも pin コマンドがない（[cli/cli#8871](https://github.com/cli/cli/issues/8871) は未解決）。コミュニティ拡張も読み取り専用。
- **唯一の書き込み経路は Web UI の "Customize your pins" ダイアログ。** 本スキルは存在しないミューテーションを捏造せず、この現実をそのままコード化：pin の読み取りは GraphQL、書き込みは Web UI 自動化、その他の設定は `gh` CLI と REST で対応。

---

## 対応範囲

- **ピン留めされたリポジトリ** — 読み取りは GraphQL（`pinnedItems` / `pinnableItems` / `pinnedItemsRemaining`、上限 6 件、ユーザーと組織の両方に対応）、書き込みは Web UI 自動化フロー（手動でのフォールバック付き）。ピン留めできるのはリポジトリ、gist、issue、PR、project。
- **リポジトリ設定** — `gh repo edit` クイックリファレンス：説明、ホームページ、topics、可視性、デフォルトブランチ、マージ戦略、issues/wiki/discussions/projects、テンプレート、シークレットスキャン。
- **ブランチ保護と rulesets** — REST エンドポイントとペイロードの記述ガイド。
- **その他の設定** — Actions 権限、environments、webhooks、deploy keys、コラボレーター、プロフィール（名前/バイオ/ブログ）、ソーシャルアカウント。

---

## インストール

1 行でインストール（macOS と Linux）：

```bash
curl -fsSL https://raw.githubusercontent.com/Keng0nion/github-settings/main/install.sh | bash
```

または手動で：

```bash
git clone https://github.com/Keng0nion/github-settings.git
mkdir -p ~/.zcode/skills ~/.agents/skills
cp -r github-settings ~/.zcode/skills/
cp -r github-settings ~/.agents/skills/
```

リリース：各 [GitHub release](https://github.com/Keng0nion/github-settings/releases) にはパッケージ済みのスキルアーカイブが添付されています —— zip をダウンロードして `~/.zcode/skills/` に置いてください。

- `gh` CLI（`repo` スコープ）とログインが必要。pin の書き込みにはさらにブラウザ自動化（agent-browser など）とログイン済みブラウザセッションが必要。

---

## 使い方

インストール後は、自然な言葉で agent にお願いするだけです：

- 「xxx をプロフィールにピン留めして」
- 「トピックを追加して説明を更新して」
- 「secret scanning を有効にして」

agent は `SKILL.md` に従って動きます：pin の読み取りは GraphQL、pin の変更は Web UI 経由、その他はすべて `gh` CLI で管理 —— 常に読み戻して変更を検証します。

---

## メンテナンス

`SKILL.md` / `README.md` を編集したら、GitHub Contents API でリポジトリに同期し戻します（コミット履歴がきれいなまま、ローカル git 不要）：

```bash
gh api -X PUT repos/Keng0nion/github-settings/contents/SKILL.md \
  -f message="Update SKILL.md" \
  -f content="$(base64 < SKILL.md | tr -d '\n')" \
  -f sha="$(gh api repos/Keng0nion/github-settings/contents/SKILL.md --jq '.sha')"
```

リリースを切る：`gh release create vX.Y.Z --repo Keng0nion/github-settings --title vX.Y.Z --generate-notes` を実行し、その後 `gh release upload` でパッケージ済みの zip を添付します。

---

## ライセンス

[MIT](LICENSE)
