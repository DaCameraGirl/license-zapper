#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# license-zapper — mass LICENSE production for the busy builder. 💖
#
# Finds every repo of an owner that has NO license file and stamps one in,
# straight through the GitHub API (no clone needed). Dry-run by default so it
# never touches anything until you pass --go.
#
# Requires: gh (authenticated), bash, base64.
#
# Examples:
#   bash zap-licenses.sh                       # dry run, proprietary, DaCameraGirl
#   bash zap-licenses.sh --license mit         # dry run, MIT
#   bash zap-licenses.sh --go                  # actually stamp proprietary
#   bash zap-licenses.sh --license mit --go    # actually stamp MIT
#   bash zap-licenses.sh --only Repo1,Repo2 --go
# ---------------------------------------------------------------------------
set -euo pipefail

OWNER="DaCameraGirl"
LICENSE="proprietary"     # proprietary | mit
NAME="Angela Hudson"
YEAR="$(date +%Y)"
GO=0                       # 0 = dry run, 1 = actually write
INCLUDE_ARCHIVED=0
ONLY=""                    # optional comma-separated repo allow-list
# Repos being folded into AI-Video-Annotator and archived — never license these.
EXCLUDE="Warehouse-Annotator,Warehouse-Caption-Checker"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --license) LICENSE="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --year) YEAR="$2"; shift 2 ;;
    --only) ONLY="$2"; shift 2 ;;
    --exclude) EXCLUDE="$2"; shift 2 ;;
    --include-archived) INCLUDE_ARCHIVED=1; shift ;;
    --go) GO=1; shift ;;
    -h|--help) grep '^#' "$0" | cut -c3-; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

license_text() {
  if [[ "$LICENSE" == "mit" ]]; then
    cat <<EOF
MIT License

Copyright (c) $YEAR $NAME

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF
  else
    cat <<EOF
Copyright (c) $YEAR $NAME. All Rights Reserved.

This software and associated files (the "Software") are the proprietary
and confidential property of $NAME.

NO PERMISSION is granted to any person to use, copy, modify, merge,
publish, distribute, sublicense, sell, or create derivative works of the
Software, in whole or in part, without the prior written permission of
the copyright holder.

Viewing this Software in a public repository does not grant any license
or right to use it. Unauthorized use, reproduction, or distribution is
prohibited and may violate applicable copyright and other laws.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
  fi
}

has_license() {
  # 0 if a LICENSE file already exists, 1 if none (404).
  gh api "repos/$OWNER/$1/license" >/dev/null 2>&1
}

in_only() {
  [[ -z "$ONLY" ]] && return 0
  case ",$ONLY," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

is_excluded() {
  [[ -z "$EXCLUDE" ]] && return 1
  case ",$EXCLUDE," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

echo "license-zapper"
echo "  owner:   $OWNER"
echo "  license: $LICENSE   (as: $NAME, $YEAR)"
echo "  mode:    $([[ $GO -eq 1 ]] && echo 'GO (writing)' || echo 'DRY RUN (no changes)')"
echo

LICENSE_B64="$(license_text | base64 | tr -d '\n')"

mapfile -t REPOS < <(
  gh repo list "$OWNER" --limit 300 \
    --json name,isArchived \
    --jq ".[] | select(.isArchived == ($([[ $INCLUDE_ARCHIVED -eq 1 ]] && echo true || echo false)) or (.isArchived|not)) | .name"
)

zapped=0; skipped=0; planned=0
for repo in "${REPOS[@]}"; do
  in_only "$repo" || continue
  if is_excluded "$repo"; then
    echo "  excluded   $repo (being archived)"
    skipped=$((skipped+1))
    continue
  fi
  if has_license "$repo"; then
    skipped=$((skipped+1))
    continue
  fi
  if [[ $GO -eq 1 ]]; then
    gh api -X PUT "repos/$OWNER/$repo/contents/LICENSE" \
      -f message="Add LICENSE ($LICENSE)" \
      -f content="$LICENSE_B64" >/dev/null
    echo "  ZAPPED  $repo"
    zapped=$((zapped+1))
  else
    echo "  would zap  $repo"
    planned=$((planned+1))
  fi
done

echo
if [[ $GO -eq 1 ]]; then
  echo "Done. Stamped $zapped repo(s); $skipped already had a license."
else
  echo "Dry run. $planned repo(s) would be stamped; $skipped already have a license."
  echo "Re-run with --go to apply (add --license mit to use MIT instead)."
fi
