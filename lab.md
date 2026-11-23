# Lab 03 — ClubHub Time Machine & Pull Request Party

**Git & GitHub · Working Together Without Chaos**
Cellule DevOps · Club Informatique & Télécom · Durée : 60 min

> Lundi matin. Le hackathon a disparu de la page des événements, la liste des sponsors s'est volatilisée, et cinq personnes ont modifié le code pendant le week-end. Personne ne se souvient de rien.
> Heureusement, **Git, lui, se souvient de tout.**

Le lab a deux parties :

| Partie | Où | Durée | Ce que vous apprenez |
| --- | --- | --- | --- |
| **A · Time Machine** | Votre terminal Linux, en solo ou en binôme | 30 min | Historique, annuler, restaurer, branches, conflits |
| **B · Pull Request Party** | GitHub, en équipe de 3 ou 4 | 30 min | Branches distantes, pull requests, revue de code, conflits sur GitHub |

## Objectifs

À la fin du lab, vous saurez :

- configurer Git et lire un historique (`git config`, `git log`, `git show`) ;
- retrouver qui a changé quoi, et quand (`git log -p`) ;
- annuler un commit proprement (`git revert`) et restaurer un fichier supprimé (`git restore`) ;
- travailler sur une branche et la fusionner (`git switch -c`, `git merge`) ;
- résoudre un conflit de fusion ;
- proposer un changement à une équipe avec une pull request, le relire et le fusionner sur GitHub.

---

## Antisèche

| Commande | Ce qu'elle fait |
| --- | --- |
| `git config --global user.name "Prénom Nom"` | Dire à Git qui vous êtes (une seule fois par machine) |
| `git status` | Où en suis-je ? Qu'est-ce qui a changé ? |
| `git log` / `git log --oneline` | L'historique complet / résumé sur une ligne |
| `git log -p fichier` | L'historique d'un fichier, avec les lignes modifiées |
| `git show <hash>` | Le détail d'un commit |
| `git diff` | Ce qui a changé depuis le dernier commit |
| `git add fichier` | Préparer un fichier pour le prochain commit |
| `git commit -m "message"` | Enregistrer une photo du projet |
| `git revert --no-edit <hash>` | Annuler un commit en créant un nouveau commit inverse |
| `git restore --source=<hash> fichier` | Récupérer un fichier tel qu'il était dans un commit |
| `git switch -c nom` / `git switch nom` | Créer une branche et y aller / changer de branche |
| `git merge nom` | Fusionner la branche `nom` dans la branche actuelle |
| `git log --oneline --graph --all` | Voir toutes les branches sous forme de graphe |

Astuces :
- un hash peut être raccourci à ses 7 premiers caractères (`b85afbe`) ;
- `hash~1` veut dire « le commit juste avant `hash` » ;
- si `git log` remplit l'écran, flèches pour défiler, `q` pour quitter ;
- l'éditeur `nano` s'enregistre avec `Ctrl+O`, `Entrée`, puis se ferme avec `Ctrl+X`.

---

# Partie A · ClubHub Time Machine (30 min)

## Préparer la mission

```bash
bash setup.sh
cd ~/clubhub-timemachine
cat README.txt
cd clubhub
```

> Si `git` manque : `sudo apt update && sudo apt install -y git`

Les flags `CLUB{...}` se notent dans `~/clubhub-timemachine/flags.txt` :

```bash
echo 'CLUB{le_flag}' >> ~/clubhub-timemachine/flags.txt
```

Vérifiez votre progression à tout moment : `~/clubhub-timemachine/check.sh`

---

### Mission 0 · Qui êtes-vous ? (2 min)

Chaque commit porte le nom de son auteur. Avant de toucher au code, présentez-vous à Git avec votre nom et votre e-mail.

<details><summary>Indice</summary>

`git config --global user.name "…"` puis `git config --global user.email "…"`. Vérifiez avec `git config --list`.
</details>

---

### Mission 1 · Explorer le passé (4 min)

**Objectifs :**
1. Combien de commits compte la branche `main` ? Qui a fait le dernier ?
2. Le tout premier commit cache un message secret. Trouvez-le : c'est le flag 1.

<details><summary>Indice 1</summary>

`git log --oneline` montre un commit par ligne, mais seulement le titre du message.
</details>

<details><summary>Indice 2</summary>

`git log` (sans option) affiche les messages complets. Le premier commit est tout en bas.
</details>

---

### Mission 2 · Le détective (6 min)

La page `events.html` n'affiche plus le Hackathon CIT. Quelqu'un l'a supprimé.

**Objectifs :**
1. Trouvez **le commit** qui a supprimé le hackathon : son hash, son auteur, sa date, son message.
2. La ligne supprimée contenait le flag 2.

<details><summary>Indice 1</summary>

`git log --oneline -- events.html` liste uniquement les commits qui ont touché ce fichier.
</details>

<details><summary>Indice 2</summary>

`git show <hash>` affiche ce qu'un commit a changé : les lignes en rouge avec un `-` ont été supprimées.
</details>

**Question :** pourquoi « small cleanup » est-il un mauvais message de commit ?

---

### Mission 3 · Annuler sans casser (4 min)

Remettez le hackathon en ligne **sans réécrire l'histoire** : on annule le commit fautif avec un nouveau commit.

<details><summary>Indice</summary>

`git revert --no-edit <hash>` crée un commit qui fait exactement l'inverse de `<hash>`. Vérifiez avec `cat events.html` et `git log --oneline`.
</details>

> **Dans la vraie vie :** en équipe, on ne supprime jamais un commit déjà partagé. On l'annule avec `git revert`, et tout le monde voit ce qui s'est passé.

---

### Mission 4 · Ressusciter un fichier (5 min)

Le fichier `sponsors.md` a disparu. Il n'est plus dans le dossier… mais il est toujours dans l'historique.

**Objectifs :**
1. Trouvez le commit qui a supprimé `sponsors.md`.
2. Récupérez le fichier tel qu'il était **juste avant** ce commit, puis enregistrez-le dans un nouveau commit.
3. Le fichier contient le flag 3.

<details><summary>Indice 1</summary>

`git log --oneline -- sponsors.md` fonctionne même pour un fichier supprimé.
</details>

<details><summary>Indice 2</summary>

`git restore --source=<hash>~1 sponsors.md` récupère la version d'avant la suppression. Ensuite : `git add` et `git commit`.
</details>

---

### Mission 5 · Votre branche (5 min)

Vous voulez ajouter votre propre événement à ClubHub, sans risquer de casser `main`.

**Objectifs :**
1. Créez une branche `feature/<votre-prénom>-event`.
2. Ajoutez une ligne `<li class="event">…</li>` dans `events.html`, puis faites un commit.
3. Revenez sur `main` et fusionnez votre branche.

<details><summary>Indice</summary>

`git switch -c feature/sara-event` → `nano events.html` → `git add events.html` → `git commit -m "Add Git workshop event"` → `git switch main` → `git merge feature/sara-event`.
</details>

---

### Mission 6 · Le conflit (6 min)

Pendant le week-end, Ines a proposé un nouveau titre pour la page d'accueil, sur la branche `design/new-title`. Salma, elle, a changé **la même ligne** sur `main`. Fusionnez la branche d'Ines dans `main`.

```bash
git merge design/new-title
```

**Objectifs :**
1. Lisez le message de Git : quel fichier est en conflit ?
2. Ouvrez-le, choisissez le titre final (ou combinez les deux), et supprimez les marqueurs `<<<<<<<`, `=======` et `>>>>>>>`.
3. Terminez la fusion.

<details><summary>Indice 1</summary>

Entre `<<<<<<< HEAD` et `=======`, c'est la version de `main`. Entre `=======` et `>>>>>>> design/new-title`, celle de la branche. Git ne choisit pas à votre place.
</details>

<details><summary>Indice 2</summary>

Après avoir corrigé le fichier : `git add index.html` puis `git commit -m "Merge design/new-title"`. `git status` doit dire « nothing to commit, working tree clean ».
</details>

Lancez `~/clubhub-timemachine/check.sh`. Tout est vert ? Admirez votre travail :

```bash
git log --oneline --graph --all
```

### Bonus (partie A)

- **Bonus A · Version officielle.** Posez le tag `v1.0` sur `main` : `git tag v1.0`.
- **Bonus B · Votre raccourci.** Créez l'alias `git lg` qui affiche le graphe : `git config --global alias.lg "log --oneline --graph --all"`.

---

# Partie B · Pull Request Party (30 min)

Maintenant, on passe sur GitHub, en équipe de 3 ou 4. Chacun a besoin de son compte GitHub.

### B1 · Créer le dépôt de l'équipe (5 min) — le capitaine

1. Ouvrez le dépôt modèle donné par le formateur, puis **Use this template → Create a new repository**.
2. Nom : `clubhub-team-<nom-de-l-équipe>`, visibilité **Public**.
3. **Settings → Collaborators → Add people** : invitez chaque membre de l'équipe.
4. Les membres acceptent l'invitation (notification GitHub ou e-mail).

### B2 · Votre première pull request (8 min) — chacun

Directement sur GitHub, sans terminal :

1. Ouvrez `team.md`, cliquez sur le crayon (**Edit**).
2. Remplissez **votre** section (« Membre 1 », « Membre 2 »…).
3. **Commit changes…** → choisissez **Create a new branch for this commit and start a pull request** → nommez la branche `add-<votre-prénom>`.
4. **Propose changes** → **Create pull request**, avec un titre clair (« Add Sara to team.md »).

### B3 · La revue de code (7 min)

1. Chaque PR est relue par **un autre** membre : onglet **Files changed** → laissez au moins un commentaire → **Review changes → Approve**.
2. Une fois approuvée, l'auteur clique **Merge pull request**.

> Chacun a modifié une section différente du même fichier : GitHub fusionne tout seul. Pas de conflit.

### B4 · Le conflit d'équipe (10 min)

1. **Chacun en même temps** : créez une PR qui remplace la ligne `Team motto: …` du `README.md` par votre proposition de devise.
2. Fusionnez la première PR.
3. Les autres PR affichent maintenant **This branch has conflicts**. Cliquez **Resolve conflicts**, choisissez la devise finale ensemble, supprimez les marqueurs, **Mark as resolved → Commit merge**, puis fusionnez.

### Livrable de l'équipe

- au moins **une PR fusionnée par membre** ;
- au moins **un conflit résolu** ;
- une capture de **Insights → Network** (le graphe des branches) à montrer au formateur.

### Bonus (partie B)

- **Bonus C · Protéger `main`.** Le capitaine active une règle sur `main` : **Settings → Branches** → exiger une pull request et au moins une approbation. Essayez de pousser directement sur `main` : GitHub refuse.
- **Bonus D · Depuis le terminal.** Clonez le dépôt (`git clone https://github.com/<capitaine>/<dépôt>.git`), ajoutez une ligne dans `events.md` sur une nouvelle branche, puis `git push -u origin <branche>` et ouvrez la PR sur GitHub. Pour le mot de passe, GitHub demande un **personal access token** (Settings → Developer settings → Personal access tokens), pas votre mot de passe.

---

## Débrief : pourquoi Git et GitHub en DevOps ?

| Ce que vous avez fait | Ce que fait une équipe DevOps avec |
| --- | --- |
| Lire l'historique, trouver un coupable | Comprendre d'où vient un bug en production |
| `git revert` | Annuler une mise en production ratée, proprement |
| Branches et fusions | Travailler à plusieurs sans se bloquer |
| Résoudre un conflit | Intégrer souvent pour éviter les gros conflits |
| Pull request + revue | Aucun code n'arrive en production sans relecture |
| Protéger `main` | `main` est toujours déployable |

À la séance 06, chaque pull request lancera automatiquement les tests (CI). Tout commence ici.

## Bloqué ou tout cassé ?

```bash
bash setup.sh --reset     # recommence la partie A depuis zéro
git merge --abort         # annule une fusion en cours (conflit)
git status                # en cas de doute, toujours commencer par là
```
