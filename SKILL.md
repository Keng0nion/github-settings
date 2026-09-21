---
name: github-settings
description: >-
  Read and change GitHub repository and profile settings with gh CLI and the
  GitHub API: description, homepage, topics, visibility, default branch, merge
  strategy, branch protection, rulesets, Actions permissions, and pinned
  repositories. Use when the user asks to pin a repo to their GitHub profile,
  tweak repo settings, or otherwise manage GitHub settings from the terminal.
---

# GitHub Settings

Manage GitHub repository and profile settings through `gh` CLI and the GitHub
API.

## Read this first (verified 2026-02 API reality)

- **Profile pinned repos cannot be written through any official API.** The
  GraphQL `pinItem`/`unpinItem` mutations no longer exist (zero matches in the
  public `fpt` schema), the REST API has no pin endpoint, and `gh` has no pin
  command (cli/cli#8871, still open). Community extensions like `gh-pin-repo`
  are read-only too. **The only write path is the web UI's "Customize your
  pins" dialog** — automate it with a browser-automation skill such as
  `agent-browser`, or hand the user the manual URL. Do not invent a
  `pinItem` mutation; it will fail.
- **Reading pins works fine** via GraphQL (section 1). Limit: 6 pinned items
  per profile, for both users and organizations. Pins may be repositories,
  gists, issues, PRs, or projects — not just repositories.
- `gh repo edit` covers most repository settings. Branch protection and
  rulesets go through REST (section 3).

## 1. Pinned repositories

### Read (GraphQL)

Pins of the signed-in user:

```bash
gh api graphql -f query='query { viewer { pinnedItems(first: 6) { nodes { ... on Repository { id nameWithOwner stargazerCount } } } } }'
```

Pins of any user or organization (works for other accounts too):

```bash
gh api graphql -f query='query { user(login: "OWNER") { pinnedItems(first: 6) { totalCount nodes { ... on Repository { nameWithOwner } } } } }'
gh api graphql -f query='query { organization(login: "ORG") { pinnedItems(first: 6, types: [REPOSITORY]) { nodes { ... on Repository { nameWithOwner } } } } }'
```

What can be pinned, and how many slots remain (viewer only):

```bash
gh api graphql -f query='query { viewer { pinnableItems(first: 20, types: [REPOSITORY]) { nodes { ... on Repository { id nameWithOwner } } } pinnedItemsRemaining viewerCanChangePinnedItems } }'
```

### Write (web UI only)

No official API exists. Automate the web UI with a browser-automation skill
(e.g. `agent-browser`), using a browser session that is signed in to GitHub:

1. Open `https://github.com/{owner}` (user profile) or
   `https://github.com/orgs/{org}` (org profile).
2. Find and click **"Customize your pins"** — the pencil button at the top of
   the pinned-items section (hidden until you hover; if the profile has no
   pins, the section shows a "Customize your pins" link instead).
3. In the dialog, type the repository name into the search box, then click
   the checkbox next to each repo to pin it (deselect to unpin). Max 6 items.
4. Click **Save changes**.
5. Verify by re-running the GraphQL read query above — that, not the browser
   state, is the source of truth.

If no signed-in browser session is available, say so and give the user the
profile URL to do it manually. Never claim a pin was changed without the
GraphQL read confirming it.

## 2. Repository settings (`gh repo edit`)

```bash
gh repo edit OWNER/REPO \
  -d "Description" -h "https://example.com" \
  --add-topic topic1 --add-topic topic2 --remove-topic old-topic \
  --default-branch main --delete-branch-on-merge \
  --enable-issues --enable-wiki --enable-discussions --enable-projects \
  --enable-squash-merge --enable-merge-commit --enable-rebase-merge \
  --enable-auto-merge --allow-update-branch --allow-forking --template
```

Toggle any flag off with `--<flag>=false`. Visibility change requires an extra
consent flag:

```bash
gh repo edit OWNER/REPO --visibility private --accept-visibility-change-consequences
```

Equivalent REST call when `gh repo edit` does not wrap what you need:

```bash
gh api -X PATCH repos/OWNER/REPO -f description="..." -f homepage="..."
gh api -X PUT repos/OWNER/REPO/topics --input - <<< '{"names":["topic1","topic2"]}'
```

## 3. Branch protection & rulesets

Rulesets (current, preferred):

```bash
gh api repos/OWNER/REPO/rulesets                          # list
gh api -X POST repos/OWNER/REPO/rulesets --input rules.json
gh api -X PUT repos/OWNER/REPO/rulesets/ID --input rules.json
gh api -X DELETE repos/OWNER/REPO/rulesets/ID
```

Legacy branch protection on a single branch:

```bash
gh api -X PUT repos/OWNER/REPO/branches/main/protection --input protection.json
```

`protection.json` needs `required_status_checks`, `enforce_admins`,
`required_pull_request_reviews`, `restrictions` (use `null` where allowed).
Building these payloads by hand is error-prone — fetch an existing ruleset
with `gh api repos/OWNER/REPO/rulesets/ID` first and edit it.

## 4. Other settings endpoints

| Setting | Command |
|---|---|
| Secret scanning / push protection | `gh repo edit --enable-secret-scanning --enable-secret-scanning-push-protection` |
| Actions permissions | `gh api -X PUT repos/OWNER/REPO/actions/permissions -f enabled=true` |
| Actions workflow permissions | `gh api -X PUT repos/OWNER/REPO/actions/permissions/workflow -f default_workflow_permissions=read` |
| Environments | `gh api repos/OWNER/REPO/environments` |
| Webhooks | `gh api repos/OWNER/REPO/hooks` |
| Deploy keys | `gh api repos/OWNER/REPO/keys` |
| Collaborators | `gh api repos/OWNER/REPO/collaborators` |
| Profile (name, bio, blog) | `gh api -X PATCH user -f name="..." -f bio="..." -f blog="..."` |
| Social accounts | `gh api -X PATCH user/social_accounts --input - <<< '{"social_accounts":[{"provider":"twitter","url":"..."}]}'` |

## Troubleshooting

- **HTTP 404** — wrong endpoint, private repo without access, or missing
  scope. Check with `gh auth status`.
- **HTTP 422 Validation Failed** — fields missing/malformed; use `-F` for
  numbers/booleans, `-f` for strings, `--input` for JSON bodies.
- **GraphQL errors on a pin mutation** — expected: the mutation does not
  exist (see "Read this first"). Use the web-UI flow instead.
- **`--visibility` rejected** — add `--accept-visibility-change-consequences`.
