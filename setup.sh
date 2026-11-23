#!/usr/bin/env bash
# ClubHub Lab 03 — Beginner edition. Runs locally; no network needed.
set -euo pipefail
BASE="${CLUBHUB_LAB_DIR:-$HOME/clubhub-beginner-lab}"
case "${1:-}" in
  '') ;;
  --reset)
    if [[ ! -f "$BASE/.clubhub-beginner-marker" ]]; then
      echo "[ERROR] Refusing to reset a directory not created by this workshop: $BASE" >&2
      exit 1
    fi
    rm -rf -- "$BASE" ;;
  *) echo "Usage: bash setup.sh [--reset]" >&2; exit 1 ;;
esac
command -v git >/dev/null || { echo 'Git is required.' >&2; exit 1; }
[[ ! -e "$BASE" ]] || { echo "Directory already exists: $BASE (see lab.md for reset warning)" >&2; exit 1; }
mkdir -p "$BASE/practice" "$BASE/clubhub"
touch "$BASE/.clubhub-beginner-marker"
# The practice repo is EMPTY: students will create its first commit.
git -C "$BASE/practice" init -q -b main 2>/dev/null || { git -C "$BASE/practice" init -q; git -C "$BASE/practice" symbolic-ref HEAD refs/heads/main; }
R="$BASE/clubhub"
git -C "$R" init -q -b main 2>/dev/null || { git -C "$R" init -q; git -C "$R" symbolic-ref HEAD refs/heads/main; }
cd "$R"
commit_as() {
  local name="$1" email="$2" date="$3" msg="$4" body="${5:-}"
  git add -A
  if [[ -n "$body" ]]; then
    GIT_AUTHOR_NAME="$name" GIT_AUTHOR_EMAIL="$email" GIT_AUTHOR_DATE="$date" \
    GIT_COMMITTER_NAME="$name" GIT_COMMITTER_EMAIL="$email" GIT_COMMITTER_DATE="$date" \
      git -c commit.gpgsign=false commit -q -m "$msg" -m "$body"
  else
    GIT_AUTHOR_NAME="$name" GIT_AUTHOR_EMAIL="$email" GIT_AUTHOR_DATE="$date" \
    GIT_COMMITTER_NAME="$name" GIT_COMMITTER_EMAIL="$email" GIT_COMMITTER_DATE="$date" \
      git -c commit.gpgsign=false commit -q -m "$msg"
  fi
}
cat > README.md <<'EOF'
# ClubHub
A demo site for the CIT students' club. Open `index.html` in a browser.
EOF
cat > index.html <<'EOF'
<!doctype html><html lang="en"><meta charset="utf-8"><title>ClubHub</title>
<h1>ClubHub</h1><p>Welcome to our club!</p><a href="events.html">Events</a></html>
EOF
commit_as 'Salma Benali' 'salma@clubhub.example' '2026-11-20T09:00:00+01:00' 'Create ClubHub site'
cat > events.html <<'EOF'
<!doctype html><html lang="en"><meta charset="utf-8"><title>Events</title>
<h1>Club events</h1>
<ul>
<li class="event">Linux workshop</li>
<li class="event">CIT Hackathon</li>
<li class="event">Pizza and code night</li>
</ul></html>
EOF
commit_as 'Mehdi Alaoui' 'mehdi@clubhub.example' '2026-11-20T10:00:00+01:00' 'Add club events'
cat > sponsors.md <<'EOF'
# Hackathon sponsors
- Campus cafe
- Atlas print shop
EOF
commit_as 'Karim Idrissi' 'karim@clubhub.example' '2026-11-20T11:00:00+01:00' 'Add sponsors'
sed -i '/CIT Hackathon/d' events.html
commit_as 'Mehdi Alaoui' 'mehdi@clubhub.example' '2026-11-21T09:00:00+01:00' 'Small events cleanup'
sed -i 's/Welcome to our club!/Welcome to ClubHub!/g' index.html
commit_as 'Salma Benali' 'salma@clubhub.example' '2026-11-21T10:00:00+01:00' 'Improve welcome message'
cat > "$BASE/README.txt" <<'EOF'
CLUBHUB BEGINNER LAB
====================
practice/ : an empty Git repo for YOUR FIRST COMMIT.
clubhub/  : a small project with a fake history and a missing hackathon.
check.sh  : verifies the local (Part A) goals. It does NOT check GitHub PRs.

Read lab.md on GitHub for all instructions.
EOF
cat > "$BASE/check.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
B="$(cd "$(dirname "$0")" && pwd)"
R="$B/clubhub"; P="$B/practice"; S=0; T=5
check() { if "$1"; then printf '  [OK] %s\n' "$2"; S=$((S+1)); else printf '  [  ] %s\n' "$2"; fi; }
identity() { [[ -n "$(git -C "$P" config user.name || true)" && -n "$(git -C "$P" config user.email || true)" ]]; }
first_commit() { [[ "$(git -C "$P" rev-list --count HEAD 2>/dev/null || echo 0)" -ge 1 ]] && git -C "$P" ls-tree -r --name-only HEAD | grep -qx 'hello.txt'; }
restored() { git -C "$R" show main:events.html 2>/dev/null | grep -q 'CIT Hackathon'; }
feature_branch() { git -C "$R" show-ref --verify --quiet refs/heads/feature/my-event && git -C "$R" merge-base --is-ancestor feature/my-event main && [[ "$(git -C "$R" rev-list --count main..feature/my-event)" -eq 0 ]]; }
new_event() { [[ "$(git -C "$R" show main:events.html | grep -c 'class="event"' || true)" -ge 4 ]]; }
echo '=== ClubHub beginner lab — local checkpoint ==='
check identity 'Git identity configured'
check first_commit 'First commit contains hello.txt'
check restored 'Hackathon restored on main'
check feature_branch 'feature/my-event merged into main'
check new_event 'A new event appears on main'
printf '\nLocal score: %s/%s\n' "$S" "$T"
echo 'GitHub PR success is checked by your trainers on GitHub.'
EOF
chmod +x "$BASE/check.sh"
printf 'ClubHub beginner lab ready at: %s\n' "$BASE"
printf 'Read lab.md on GitHub. Then: cd "%s/practice"\n' "$BASE"
