# Dramatoons : espace de travail

[Dramatoons](https://dramatoons.ovh) est un site de suivi de lecture de webtoons (bandes dessinées en ligne) : chaque lecteur tient sa bibliothèque, note les webtoons et retrouve le dernier chapitre lu.

> **Dramatoons n'héberge aucun webtoon.** Il conserve la fiche de chaque webtoon (titres, statut, couverture) et la progression de chaque lecteur (dernier chapitre lu, note, état), jamais le contenu des webtoons : aucun chapitre, aucune planche, et aucun lien vers des plateformes de diffusion non autorisées. Les webtoons se lisent ailleurs, sur les plateformes choisies par le lecteur.

Ce dépôt ne contient pas de code applicatif. C'est l'espace de travail commun aux dépôts du projet. Il porte surtout la configuration de [Claude Code](https://claude.com/claude-code), avec qui le projet est développé à partir de la version 2.4.0 : les instructions, les règles métier et le workflow sont écrits une fois ici, et valent pour tous les dépôts.

## Les dépôts

| Dépôt | Rôle | Technologies |
| --- | --- | --- |
| [dramatoons-api](https://github.com/remi-leconte/dramatoons-api) | API REST : webtoons, suivis de lecture, comptes et rôles | PHP, Symfony, API Platform, MariaDB, Redis |
| [dramatoons-front](https://github.com/remi-leconte/dramatoons-front) | Site web | Vue 3, TypeScript, Vite |
| [dramatoons-browser-extension](https://github.com/remi-leconte/dramatoons-browser-extension) | Extension pour Firefox et les navigateurs Chromium (en cours de création) | JavaScript |
| [dramatoons-extension-chromium](https://github.com/remi-leconte/dramatoons-extension-chromium) | Ancienne extension Chromium, remplacée par la précédente | JavaScript |
| [dramatoons-extension-firefox](https://github.com/remi-leconte/dramatoons-extension-firefox) | Ancienne extension Firefox, remplacée par la précédente | JavaScript |

Tout tourne dans Docker, en développement comme en production.

## Contenu

| Fichier | Rôle |
| --- | --- |
| [`CLAUDE.md`](CLAUDE.md) | Instructions générales lues par Claude Code : composants, modèle de données, résumé des règles métier |
| [`.claude/skills/regles-metier/`](.claude/skills/regles-metier/) | Règles métier complètes : visibilité des webtoons, publication, suivis, rôles, extension |
| [`.claude/skills/workflow-github/`](.claude/skills/workflow-github/SKILL.md) | Workflow git et GitHub : branches, tickets, pull requests, recette, livraison, hotfix |
| [`.claude/agents/testeur.md`](.claude/agents/testeur.md) | Agent qui vérifie qu'un ticket est couvert par des tests et que ces tests passent |
| [`relecture/consignes.md`](relecture/consignes.md) | Consignes de la relecture IA des pull requests, lancée par GitHub Actions dans l'API, le front et l'extension |
| [`clone-all.sh`](clone-all.sh) | Clone les dépôts de code au bon endroit |

Chaque dépôt de code a en plus son propre `CLAUDE.md`, pour ce qui ne concerne que lui.

## Comment le projet est développé

- **Un ticket par développement**, suivi dans un projet GitHub commun aux dépôts, et regroupé par version (`release/vX.Y.0`).
- **Le développeur décide, Claude Code exécute** : chaque ticket est discuté avant d'être codé. Le code et ses tests restent non commités jusqu'à la validation du développeur.
- **Deux contrôles par IA** : l'agent `testeur` vérifie, avant le commit, que les règles métier du ticket sont couvertes par des tests qui passent ; dans GitHub, la relecture IA relit chaque pull request, en priorité sur la sécurité et les règles métier, et la moindre remarque la bloque.
- **Intégration et livraison continues** (GitHub Actions) : vérifications et tests sur chaque pull request, image Docker publiée et recette mise à jour à chaque fusion dans la release. À la fusion de la release dans `main`, l'image recettée est livrée telle quelle, et la mise en production attend l'approbation du développeur.

## Démarrer

```sh
git clone https://github.com/remi-leconte/dramatoons-workspace.git dramatoons
cd dramatoons
./clone-all.sh
```

Lancer ensuite Claude Code à la racine : il lit le `CLAUDE.md`, les skills et les agents, puis le `CLAUDE.md` du dépôt sur lequel il travaille. Le démarrage de l'API et du front est décrit dans leurs dépôts respectifs.
