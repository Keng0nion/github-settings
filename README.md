**目录：**

- [中文版](README.md)
- [英文版](README.en.md)
- [日文版](README.ja.md)

# github-settings

一个让 AI 直接完成 GitHub 仓库与个人资料设置的 skill —— 包括把仓库 **pin 到个人主页**（官方 API 至今没有这个能力）。

---

## 为什么做这个

- 针对当前公开 GraphQL schema（2026-02）实测：`pinItem` / `unpinItem` **已不存在**，REST API 无 pin 端点，`gh` 无 pin 命令（[cli/cli#8871](https://github.com/cli/cli/issues/8871) 仍开放），社区扩展也只能读不能写。
- **唯一的写入途径是网页端 "Customize your pins" 弹窗。** 本 skill 不凭空捏造不存在的 mutation，而是如实编码这个现实：pins 读取走 GraphQL、写入走网页自动化，其余设置走 `gh` CLI 与 REST。

---

## 覆盖能力

- **Pins 读取**走 GraphQL（`pinnedItems` / `pinnableItems` / `pinnedItemsRemaining`，上限 6 个，用户与组织均支持）；**写入**走网页自动化流程，附手动降级指引。可 pin 的不只是仓库，还有 gist、issue、PR、project。
- **仓库设置** —— `gh repo edit` 速查：描述、主页、topics、可见性、默认分支、合并策略、issues/wiki/discussions/projects、模板、密钥扫描。
- **分支保护与 rulesets** —— REST 端点与 payload 编写指引。
- **其他设置** —— Actions 权限、environments、webhooks、deploy keys、协作者、个人资料（名字/简介/博客）、社交账号。

---

## 安装

一行安装（macOS 和 Linux）：

```bash
curl -fsSL https://raw.githubusercontent.com/Keng0nion/github-settings/main/install.sh | bash
```

或手动安装：

```bash
git clone https://github.com/Keng0nion/github-settings.git
mkdir -p ~/.zcode/skills ~/.agents/skills
cp -r github-settings ~/.zcode/skills/
cp -r github-settings ~/.agents/skills/
```

发行版：每个 [GitHub release](https://github.com/Keng0nion/github-settings/releases) 都附有打包好的 skill 压缩包 —— 下载 zip 放入 `~/.zcode/skills/` 即可。

- 需要 `gh` CLI 并已登录（`repo` scope）。pin 写入流程另外需要浏览器自动化技能（如 agent-browser）和已登录 GitHub 的浏览器会话。

---

## 用法

安装完成后，直接用自然语言向你的 agent 提出请求即可：

- “把 xxx 仓库 pin 到我的主页”
- “给仓库加 topic 并改描述”
- “开启 secret scanning”

agent 会遵循 `SKILL.md`：pins 读取走 GraphQL、变更走网页端，其余设置全部用 `gh` CLI 管理 —— 并始终通过读回验证变更。

---

## 维护者笔记

```bash
gh api -X PUT repos/Keng0nion/github-settings/contents/SKILL.md \
  -f message="Update SKILL.md" \
  -f content="$(base64 < SKILL.md | tr -d '\n')" \
  -f sha="$(gh api repos/Keng0nion/github-settings/contents/SKILL.md --jq '.sha')"
```

- 编辑 `SKILL.md` / `README.md` 后用 GitHub Contents API 同步回仓库（保持提交历史干净，无需本地 git）。发版：`gh release create` 打 tag + notes，再 `gh release upload` 附打包的 zip。

---

## 许可证

[MIT](LICENSE)
