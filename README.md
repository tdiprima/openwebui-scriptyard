# openwebui-scriptyard

Friday, May 30, 2025

**TL;DR:** I kept solving the same Open WebUI headaches over and over. This repo is where I stopped doing that.

---

## The Problem

[Open WebUI](https://github.com/open-webui/open-webui) is a powerful self-hosted AI interface, but running it in production means wrestling with:

- Deploying and redeploying Docker containers without losing data
- Managing users and permissions directly in SQLite when the UI isn't enough
- Bulk-uploading files to knowledge bases without babysitting every request
- Debugging LiteLLM, Caddy, and network configs when things silently break
- Keeping everything updated without a runbook

This repo is my collection of scripts and tools for all of that — built from real operational pain, not hypotheticals.

---

## What's Here

| Folder | What it does |
|--------|-------------|
| `Deploy/` | Deploy Open WebUI with Docker, including OIDC auth setup |
| `SQLite/` | Inspect the database, list users, promote them to admin |
| `Upload/` | Bulk-upload files to a knowledge collection with crash-resume |
| `Query/` | Hit the Open WebUI API directly (Node.js example) |
| `bmi512/` | Scripts from a specific server deployment — Caddy, LiteLLM, UFW, log extraction, update guide |

---

## Why It's Useful

- **Crash-resume uploads** — stop mid-run, restart, no duplicates
- **User management without the UI** — promote users, inspect accounts via SQLite
- **Deployment scripts** — repeatable, no guesswork
- **Real-world configs** — not toy examples; used on actual infrastructure

---

## Tech Stack

Python · Bash · JavaScript · Docker · SQLite · LiteLLM · Caddy

---

## License

[MIT](LICENSE)

<br>
