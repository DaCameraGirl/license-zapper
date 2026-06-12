# license-zapper 💖

Mass LICENSE production for the builder who makes repos faster than she licenses
them.

It finds every repo on your GitHub account that has **no license file** and
stamps one in through the GitHub API — no cloning, no clicking through twenty
repos one at a time. **Dry-run by default**, so it never changes anything until
you pass `--go`.

Built by Angela Hudson · DaCameraGirl

## Why

A repo with no `LICENSE` is legally "all rights reserved" by default, but it
*looks* unfinished and leaves people unsure what they're allowed to do. If you
ship a lot of repos, stamping each one by hand is a chore. This zaps them all.

## Origin

Born the night of 2026-06-12 out of a joke — *"I wish I could just zap all my
repos with a license"* — and shipped about an hour later. On his first real run
he stamped **20 bare repos** in one pass. Full story in the
[changelog](CHANGELOG.md).

## Requirements

- [GitHub CLI](https://cli.github.com/) (`gh`), authenticated: `gh auth login`
- `bash` + `base64` (Git Bash on Windows works fine)

## Usage

```bash
bash zap-licenses.sh                     # dry run (proprietary) — shows what it WOULD do
bash zap-licenses.sh --license mit       # dry run, MIT
bash zap-licenses.sh --go                # actually stamp the proprietary license
bash zap-licenses.sh --license mit --go  # actually stamp MIT
```

### Options

| Flag | Default | Meaning |
| --- | --- | --- |
| `--owner <name>` | `DaCameraGirl` | GitHub account to scan |
| `--license <type>` | `proprietary` | `proprietary` or `mit` |
| `--name <name>` | `Angela Hudson` | Name written into the license |
| `--year <year>` | current year | Copyright year |
| `--only <a,b>` | (all) | Only touch these repos |
| `--exclude <a,b>` | retiring repos | Never touch these repos |
| `--include-archived` | off | Also include archived repos |
| `--go` | off (dry run) | Actually write the LICENSE |

## Safety

- **Dry run unless `--go`.** Preview first, every time.
- Skips any repo that already has a license file.
- Skips archived (read-only) repos unless you ask for them.
- `--only` / `--exclude` give you precise control.

## License

Copyright © 2026 Angela Hudson. All Rights Reserved. See [LICENSE](LICENSE).
