# Dramatoons

Site de suivi de lecture de webtoons (BD en ligne). Prod : `dramatoons.ovh`, API sur `api.dramatoons.ovh` (staging : `api-staging.`).

## Composants
- `api/` : Symfony + API Platform, MariaDB, Redis, tout en Docker. PHP n'est PAS installé sur l'hôte.
- `front/` : Vue 3 + TypeScript, en Docker également.
- `ext-ch/` et `ext-ff/` : extensions navigateur Chromium et Firefox (publiée sous le nom `dramatoons-highlighter`). Elles utilisent `GET /webtoons?mode=ext`.

La racine est le dépôt `remi-leconte/dramatoons-workspace` : il ne contient que ce qui est commun (`CLAUDE.md`, `.claude/skills/`, `clone-all.sh`). Les 4 dossiers ci-dessus sont des dépôts git indépendants (`dramatoons-api`, `dramatoons-front`, `dramatoons-extension-chromium`, `dramatoons-extension-firefox`), ignorés par le dépôt racine : un changement de code se commite dans le dépôt du dossier concerné, pas à la racine. `clone-all.sh` les clone au bon endroit sur un nouveau poste. Le dépôt racine n'a qu'une branche `main`, sur laquelle on commite directement : il ne suit pas le workflow des 4 autres dépôts.

**Workflow git/GitHub** (branches, PR, statuts des tickets, releases, hotfix, déploiement) : charger le skill `workflow-github` avant toute action git ou GitHub dans un des 4 dépôts.

En dev : le front répond sur `http://localhost:5173`, l'API sur `http://localhost:8081`. Le réseau Docker externe `global_proxy_network` doit exister.

## Règles métier
Les règles complètes sont dans le skill `regles-metier` (`.claude/skills/regles-metier/`). **Le charger avant toute conception, modification, relecture ou test touchant aux droits, à la visibilité, à la publication ou aux suivis.**

En résumé :
- un visiteur non connecté ne voit aucun webtoon ;
- un webtoon créé est dépublié ; seuls les modérateurs/administrateurs le publient ou le dépublient ;
- un webtoon dépublié n'est visible que de son créateur, de ceux qui le suivaient avant sa dépublication, et des modérateurs/administrateurs via l'administration.

## Modèle de données
- **User** : `login` (identifiant de connexion), `email`, `roles`, `verified` (email validé), `publish` (compte actif), `lastLogin`.
- **Webtoon** :
  - `title` (WebtoonTitle principal), `secondaryTitles`, `slug` (calculé depuis le titre) ;
  - `status` (`ongoing` | `completed`), `publish` (visible de tous), `creator` (User) ;
  - `image` (nom du fichier de couverture) ;
  - `averageRating` et `readersCount`, dénormalisés et recalculés à chaque écriture d'un WebtoonUser.
- **WebtoonTitle** : un titre (principal ou alternatif) rattaché à un webtoon.
- **WebtoonUser** : le suivi d'un webtoon par un lecteur, unique par couple (`reader`, `webtoon`).
  - `bookmark` : dernier chapitre lu, un entier ; il n'y a pas d'entité Chapitre.
  - `rate` : note.
  - `state` : `reading` (en cours), `pause`, `break` (« Pas intéressé »), `completed`.
- Rôles : `ROLE_USER` < `ROLE_MODO` < `ROLE_ADMIN` (hiérarchiques).
