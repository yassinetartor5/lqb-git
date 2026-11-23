#!/usr/bin/env bash
# =====================================================================
#  ClubHub Time Machine — Lab 03 · Git (partie A, en local)
#  Cellule DevOps · Club Informatique & Télécom
#
#  Usage :
#     bash setup.sh            prépare la mission dans ~/clubhub-timemachine
#     bash setup.sh --reset    remet la mission à zéro
#
#  Fonctionne sur Ubuntu/Debian (VM, WSL, Killercoda…). Pas besoin de sudo
#  ni d'Internet. Prérequis : bash et git.
# =====================================================================
set -u

BASE="${CLUBHUB_TM_DIR:-$HOME/clubhub-timemachine}"
REPO="$BASE/clubhub"

d() { printf '%s' "$1" | base64 -d; }
F1=$(d 'Q0xVQntldmVyeV9jb21taXRfdGVsbHNfYV9zdG9yeX0=')
F2=$(d 'Q0xVQntoaXN0b3J5X25ldmVyX2ZvcmdldHN9')
F3=$(d 'Q0xVQntub3RoaW5nX2lzX2V2ZXJfbG9zdH0=')

say()  { printf '\033[1;36m[setup]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[erreur]\033[0m %s\n' "$*"; exit 1; }

case "${1:-}" in
  --reset) rm -rf "$BASE"; say "Ancienne mission supprimée." ;;
  "") ;;
  *) fail "Option inconnue : $1 (utilisez --reset)" ;;
esac

command -v git >/dev/null 2>&1 || fail "git est requis. Installez-le : sudo apt update && sudo apt install -y git"
[ -e "$BASE" ] && fail "$BASE existe déjà. Pour recommencer : bash setup.sh --reset"

say "Construction du dépôt ClubHub et de son historique…"
mkdir -p "$REPO" && cd "$REPO" || fail "Impossible de créer $REPO"
git init -q -b main 2>/dev/null || { git init -q && git symbolic-ref HEAD refs/heads/main; }
command -v nano >/dev/null 2>&1 && git config core.editor nano

# commit <nom> <email> <date> <titre> [corps]
commit() {
  local n="$1" e="$2" t="$3" s="$4" b="${5:-}"
  git add -A
  if [ -n "$b" ]; then
    GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="$e" GIT_AUTHOR_DATE="$t" \
    GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="$e" GIT_COMMITTER_DATE="$t" \
      git -c commit.gpgsign=false commit -q --no-verify -m "$s" -m "$b"
  else
    GIT_AUTHOR_NAME="$n" GIT_AUTHOR_EMAIL="$e" GIT_AUTHOR_DATE="$t" \
    GIT_COMMITTER_NAME="$n" GIT_COMMITTER_EMAIL="$e" GIT_COMMITTER_DATE="$t" \
      git -c commit.gpgsign=false commit -q --no-verify -m "$s"
  fi
}
SALMA=("Salma Benali" "salma@clubhub.cit")
MEHDI=("Mehdi Alaoui" "mehdi@clubhub.cit")
INES=("Ines Tazi" "ines@clubhub.cit")
KARIM=("Karim Idrissi" "karim@clubhub.cit")
YASS=("Yassine Amrani" "yassine@clubhub.cit")

# 1 · squelette
cat > README.md <<'EOF'
# ClubHub

La plateforme des événements du Club Informatique & Télécom.
EOF
cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="utf-8"><title>ClubHub</title><link rel="stylesheet" href="style.css"></head>
<body>
<h1>ClubHub</h1>
<p>Bienvenue sur la plateforme du club.</p>
<a href="events.html">Voir les événements</a>
</body>
</html>
EOF
commit "${SALMA[@]}" "2026-11-20T18:02:00+01:00" "Initial commit: ClubHub skeleton" \
"Premier commit du projet. Bienvenue dans l'équipe !
Mot de passe de la cellule : $F1"

# 2 · page des événements
cat > events.html <<EOF
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="utf-8"><title>ClubHub · Événements</title><link rel="stylesheet" href="style.css"></head>
<body>
<h1>Événements du club</h1>
<ul>
<li class="event">Atelier Linux · mardi 18 h</li>
<li class="event">Hackathon CIT · samedi 9 h <!-- validé par le bureau : $F2 --></li>
<li class="event">Soirée jeux &amp; pizza · jeudi 19 h</li>
</ul>
</body>
</html>
EOF
commit "${MEHDI[@]}" "2026-11-20T19:15:00+01:00" "Add events page"

# 3 · style
cat > style.css <<'EOF'
body { font-family: sans-serif; background: #070031; color: #F5F5F5; margin: 40px; }
h1 { color: #00CBFF; }
.event { margin: 8px 0; }
EOF
commit "${INES[@]}" "2026-11-20T21:40:00+01:00" "Add style"

# 4 · sponsors
cat > sponsors.md <<EOF
# Sponsors du hackathon

- Café du campus (petits-déjeuners)
- Imprimerie Atlas (t-shirts)

Code d'accès à la salle des serveurs : $F3
EOF
commit "${KARIM[@]}" "2026-11-21T10:05:00+01:00" "Add sponsors list"

# 5 · README
cat >> README.md <<'EOF'

## Lancer le site
Ouvrez index.html dans votre navigateur.
EOF
commit "${YASS[@]}" "2026-11-21T11:30:00+01:00" "Update README"
BASE_TITLE=$(git rev-parse HEAD)

# 6 · suppression par erreur
git rm -q sponsors.md
commit "${KARIM[@]}" "2026-11-21T15:12:00+01:00" "Remove unused files"

# 7 · le commit fautif
grep -v 'Hackathon CIT' events.html > events.tmp && mv events.tmp events.html
commit "${MEHDI[@]}" "2026-11-21T23:47:00+01:00" "small cleanup"

# 8 · nouveau titre sur main
sed -i 's#<h1>ClubHub</h1>#<h1>ClubHub · Events</h1>#' index.html
commit "${SALMA[@]}" "2026-11-22T09:20:00+01:00" "Change homepage title"

# branche design/new-title (part du commit 5)
git switch -q -c design/new-title "$BASE_TITLE" 2>/dev/null || git checkout -q -b design/new-title "$BASE_TITLE"
sed -i 's#<h1>ClubHub</h1>#<h1>ClubHub · Le club en action</h1>#' index.html
commit "${INES[@]}" "2026-11-22T10:05:00+01:00" "New homepage title"
git switch -q main 2>/dev/null || git checkout -q main
git rev-parse main > "$BASE/.setup_tip"

# ---------- Briefing ---------------------------------------------------
cat > "$BASE/README.txt" <<'EOF'
=====================================================================
   ClubHub Time Machine
=====================================================================

Lundi matin. Le hackathon a disparu de la page des événements,
la liste des sponsors s'est volatilisée, et cinq personnes ont
modifié le code pendant le week-end. Personne ne se souvient de rien.

Heureusement, Git, lui, se souvient de TOUT.

Le dépôt se trouve dans :  clubhub/

VOTRE MISSION
  Enquêter dans l'historique, réparer ClubHub et ajouter votre
  propre contribution, sans rien perdre.

RÈGLES DU JEU
  - Les missions sont dans lab.md (partie A).
  - Certaines missions rapportent un FLAG de la forme CLUB{...}.
    Notez-les dans flags.txt (un par ligne) :
        echo 'CLUB{...}' >> flags.txt
  - Vérifiez votre progression à tout moment :
        ./check.sh
  - Interdit : lire setup.sh. Un vrai dev n'a que git log !
EOF
printf '# Mes flags (un par ligne) :\n' > "$BASE/flags.txt"
date +%s > "$BASE/.started"

# ---------- Vérificateur ----------------------------------------------
cat > "$BASE/check.sh" <<'EOF'
#!/usr/bin/env bash
# Vérifie votre progression. Lancez : ./check.sh
B="$(cd "$(dirname "$0")" && pwd)"
R="$B/clubhub"
G='\033[1;32m'; X='\033[1;31m'; Y='\033[1;33m'; N='\033[0m'
ok=0; total=0
line() { total=$((total+1)); if [ "$1" = 1 ]; then ok=$((ok+1)); printf "  ${G}[OK]${N} %s\n" "$2"; else printf "  ${X}[--]${N} %s\n" "$2"; fi; }
v() { if eval "$1" >/dev/null 2>&1; then echo 1; else echo 0; fi; }
has_flag() { for l in $(grep -o 'CLUB{[^}]*}' "$B/flags.txt" 2>/dev/null); do
  [ "$(printf %s "$l" | sha256sum | cut -c1-64)" = "$1" ] && return 0; done; return 1; }
g() { git -C "$R" "$@"; }
TIP=$(cat "$B/.setup_tip" 2>/dev/null)

identity() { [ -n "$(g config user.name)" ] && [ -n "$(g config user.email)" ]; }
reverted() { g show main:events.html | grep -q 'Hackathon CIT'; }
restored() { g cat-file -e main:sponsors.md; }
branch_merged() {
  for b in $(g for-each-ref --format='%(refname:short)' refs/heads/feature/); do
    t=$(g rev-parse "$b"); [ "$t" != "$TIP" ] && g merge-base --is-ancestor "$t" main && return 0
  done; return 1; }
new_event() { [ "$(g show main:events.html | grep -c 'class="event"')" -ge 4 ]; }
conflict_done() {
  g merge-base --is-ancestor design/new-title main && ! g show main:index.html | grep -Eq '^(<<<<<<<|=======|>>>>>>>)'; }
clean() { [ -z "$(g status --porcelain)" ]; }

echo; echo "========= ClubHub Time Machine · progression ========="
echo "Mission 0 · Qui êtes-vous ?";        line "$(v identity)" "Nom et e-mail configurés dans Git"
echo "Mission 1 · Explorer le passé";      line "$(v 'has_flag c7c9f93ca621794617a25233c634c40c978a6dc4805bdc74bbf96e0e03a7f74e')" "Flag 1 trouvé"
echo "Mission 2 · Le détective";           line "$(v 'has_flag 5060f53306dab42a0f68d223f088e1dae180ca39abe1254a71b8f2432996effc')" "Flag 2 trouvé"
echo "Mission 3 · Annuler sans casser";    line "$(v reverted)" "Le hackathon est de retour sur main"
echo "Mission 4 · Ressusciter un fichier"; line "$(v 'has_flag 5c78442494ff0ddc860520fae2d517d26e754b54fb8457407a568e6bd4fa9d5e')" "Flag 3 trouvé"
                                           line "$(v restored)" "sponsors.md est de retour sur main"
echo "Mission 5 · Votre branche";          line "$(v branch_merged)" "Une branche feature/… fusionnée dans main"
                                           line "$(v new_event)" "Votre événement apparaît sur main"
echo "Mission 6 · Le conflit";             line "$(v conflict_done)" "design/new-title fusionnée, conflit résolu"
                                           line "$(v 'conflict_done && clean')" "Rien ne traîne : git status est propre"
echo
echo "Bonus"
b=0
if g rev-parse -q --verify refs/tags/v1.0 >/dev/null; then b=$((b+1)); printf "  ${Y}[★]${N} Tag v1.0 posé\n"; else printf "  [ ] Bonus A : poser le tag v1.0\n"; fi
if [ -n "$(git config --global alias.lg 2>/dev/null)" ]; then b=$((b+1)); printf "  ${Y}[★]${N} Alias git lg créé\n"; else printf "  [ ] Bonus B : créer l'alias git lg\n"; fi
echo
printf "Score : %s/%s" "$ok" "$total"; [ "$b" -gt 0 ] && printf "  + %s bonus" "$b"; echo
if [ "$ok" = "$total" ]; then
  s=$(cat "$B/.started" 2>/dev/null || date +%s); m=$(( ($(date +%s) - s) / 60 ))
  printf "${G}"
  echo "  ######################################################"
  echo "  #   MAÎTRE DU TEMPS ! L'historique est réparé.       #"
  echo "  #   Admirez votre travail :                          #"
  echo "  #   git log --oneline --graph --all                  #"
  echo "  ######################################################"
  printf "${N}"; echo "  Temps de mission : ${m} min"
fi
echo
EOF
chmod +x "$BASE/check.sh"

say "Mission prête dans : $BASE"
echo
echo "   cd $BASE"
echo "   cat README.txt"
echo
