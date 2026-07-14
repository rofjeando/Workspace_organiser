# GitHub Authentication via 1Password CLI

## The Problem

GitHub dropped password authentication for git operations in 2021. Attempting a plain `git push` over HTTPS now fails with:

```
remote: Invalid username or token. Password authentication is not supported.
fatal: Authentication failed for 'https://github.com/...'
```

The solution is a **Personal Access Token (PAT)**. This document describes how to store it in 1Password and retrieve it at push time — so the token is never typed or pasted in plain text.

---

## Configuration (this account)

| Item | Value |
|------|-------|
| GitHub username | `rofjeando` |
| 1Password entry | `GitHub Personal Access Token` (vault: Private) |
| 1Password reference | `op://Private/GitHub Personal Access Token/token` |

---

## Prerequisites

### 1. 1Password CLI installed
```bash
brew install 1password-cli
```

### 2. CLI signed in
```bash
op signin
```
The CLI uses biometric auth (Touch ID) after the first sign-in.

### 3. Token exists in 1Password
The PAT must be stored in 1Password under:
- Vault: `Private`
- Entry: `GitHub Personal Access Token`
- Field: `token`

To create a new PAT on GitHub: Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens (or Classic). Minimum scope needed for push: `repo`.

---

## Solution A — One-time push (fixes a single blocked push)

```bash
TOKEN=$(op read "op://Private/GitHub Personal Access Token/token")
git push "https://rofjeando:${TOKEN}@github.com/rofjeando/REPO-NAME.git" main
```

Replace `REPO-NAME` and `main` with the actual repo name and branch.

`$TOKEN` is held in memory only — it never appears in terminal output.

---

## Solution B — Store in macOS keychain (fixes all future pushes)

Run once after Solution A:

```bash
TOKEN=$(op read "op://Private/GitHub Personal Access Token/token")
printf "protocol=https\nhost=github.com\nusername=rofjeando\npassword=${TOKEN}\n" | git credential approve
```

After this, plain `git push` works from any local repo without any token handling. The credential is stored in the macOS Keychain via git's credential helper.

**To verify it was stored:**
```bash
git credential fill <<EOF
protocol=https
host=github.com
EOF
```
Should return `username=rofjeando` and `password=<token>`.

---

## Full sequence (both in one block)

```bash
TOKEN=$(op read "op://Private/GitHub Personal Access Token/token")
git push "https://rofjeando:${TOKEN}@github.com/rofjeando/REPO-NAME.git" main
printf "protocol=https\nhost=github.com\nusername=rofjeando\npassword=${TOKEN}\n" | git credential approve
```

---

## Verification after push (mandatory)

Always confirm local and remote are in sync:

```bash
# 1. Local HEAD
git log HEAD -1 --oneline

# 2. Remote HEAD (use FETCH_HEAD if origin/main ref is stale)
git fetch && git log origin/main -1 --oneline

# 3. Diff must be empty
git diff HEAD origin/main
```

Both commit hashes must match and the diff must be empty.

> Note: if you pushed using an explicit URL (Solution A), the local `origin/main`
> tracking ref may not update automatically. Run `git fetch` first to sync it.

---

## For AI agents (Claude Code, Devin, etc.)

Provide the agent with the 1Password reference path and this instruction:

> "My GitHub token is in 1Password at `op://Private/GitHub Personal Access Token/token`.
> Use `op read` to retrieve it at runtime and pass it via the HTTPS URL format:
> `https://rofjeando:${TOKEN}@github.com/rofjeando/REPO.git`
> Never echo the token value."

The agent can then use Solution A + B above without any manual intervention.

---

## Token rotation

When the PAT expires or is revoked:
1. Generate a new PAT on GitHub (Settings → Developer Settings → Personal Access Tokens)
2. Update the value in 1Password under `GitHub Personal Access Token / token`
3. Re-run Solution B to refresh the macOS keychain entry
4. No other files need to change
