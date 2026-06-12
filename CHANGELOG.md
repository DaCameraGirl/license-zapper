# Changelog

All notable changes to license-zapper are noted here.

## [1.0.0] — 2026-06-12

### Born 🐣
license-zapper came to life on the night of **June 12, 2026**. It started as a
throwaway joke — *"lol I wish I could make an app to just zap all my repos with
that license"* — and about an hour later it was a real, working tool.

### Why he exists
Angela (DaCameraGirl) ships repos *fast*, and a pile of them had **no LICENSE
file at all**. Legally that defaults to "all rights reserved," but it looks
unfinished and leaves people unsure what they're allowed to do. Stamping each
repo by hand is a chore. So the fix: stamp them all, in one command.

### What he does
- Scans every repo on a GitHub account (via `gh`)
- Finds the ones with **no license file**
- Stamps in a license (proprietary or MIT) through the GitHub API — no cloning
- **Dry-run by default**; skips archived repos and anything already licensed
- `--only` / `--exclude` for precise control

### His first run 💥
On his very first real run, he stamped Angela's proprietary "All Rights
Reserved" license into **20 bare repos** in a single pass. The two repos being
folded into the AI Video Annotator Suite — `Warehouse-Annotator` and
`Warehouse-Caption-Checker` — were excluded on purpose (they're headed for the
archive).

Built with Claude, owned by DaCameraGirl. 💖
