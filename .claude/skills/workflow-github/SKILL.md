---
name: workflow-github
description: Workflow git et GitHub de Dramatoons (Release-Driven) - branches feature/release/hotfix, pull requests, messages de commit, tags de version, statuts des tickets du projet GitHub, recette en staging et mise en production. À charger avant de créer une branche, commiter, ouvrir ou fusionner une PR, créer ou faire avancer un ticket, préparer une release ou un hotfix, ou déployer.
---

# Workflow GitHub de Dramatoons (Release-Driven)

## Ce que Claude peut faire
- **Ne jamais commiter de lui-même**, dans aucun dépôt (y compris `dramatoons-workspace`) : après toute modification de fichier, laisser les changements non commités et attendre que l'utilisateur les ait relus et demande le commit. Pour un ticket, cette demande est « je valide le ticket xxx » (voir « Cycle d'un ticket avec Claude »).
- Travailler uniquement sur les branches de ticket (`<technical label>/...` et `hotfix/...`) : les créer, y commiter, les pousser, ouvrir une PR.
- Ne jamais commiter, fusionner ni pousser sur `main` ou une branche `release/*`, sauf demande explicite de l'utilisateur. Côté GitHub, un ruleset protège `main` et `release/*` (api et front) : pas de push direct, pas de force push, pas de suppression, fusion uniquement par PR (0 approbation requise).
- Créer les tickets à la demande de l'utilisateur et remplir leurs champs Release et Technical label.
- Faire avancer les statuts des tickets jusqu'à `Ready for Release`. Les statuts suivants (`Recette`, `Ready for Prod`, `Done`) seulement à la demande de l'utilisateur.
- L'utilisateur ne relit pas les PR : il valide le code avant le commit, et l'agent `relecteur-pr` relit et fusionne la PR (voir « Cycle d'un ticket avec Claude »).
- Garder les branches de ticket (en local et sur GitHub) jusqu'à la mise en production de la release ; elles peuvent être supprimées ensuite.
- La mise en recette (staging) et la mise en production sont faites à la main par l'utilisateur, qui valide aussi la recette. Il n'y a pas encore de déploiement automatique.
- Accès GitHub : remotes en HTTPS, authentifiés par `gh` (`gh auth setup-git`). Pas de SSH (la clé a une passphrase).

## Repères
- Tableau de bord : projet GitHub **Dramatoons** (n° 4, propriétaire `remi-leconte`), commun aux 4 dépôts `dramatoons-api`, `dramatoons-front`, `dramatoons-extension-chromium` et `dramatoons-extension-firefox`.
- Version d'un ticket : champ **Release** du projet (commun aux 4 dépôts).
- Type technique d'un ticket : champ **Technical label** du projet, une seule valeur parmi `feature`, `fix`, `refactor`, `infra`, `docs`, `tests`. Il donne le préfixe de la branche.
- Domaine fonctionnel d'un ticket : champ **Functional labels** du projet (plusieurs valeurs possibles).
- Les labels propres à chaque dépôt (`bug`, `enhancement`…) ne sont plus utilisés.
- Numéro de version : `vX.Y.Z`. Une release s'appelle `vX.Y.0` (exemple : `v2.4.0`) ; un hotfix incrémente le dernier chiffre (exemple : `v2.3.1`).
- L'API et le front ont toujours la même version `X.Y`. Si l'un des deux doit avancer sans l'autre, on saute une version pour les réaligner.
- Les extensions ne suivent pas encore ce workflow (elles n'ont que `main`).
- Le dépôt espace de travail (`dramatoons-workspace`, la racine) ne suit pas ce workflow : il n'a qu'une branche `main`, sur laquelle on commite directement. Il ne nécessite pas de ticket : Claude peut y commiter et pousser sans ticket associé.
- Environnements : local, staging (`api-staging.dramatoons.ovh`) et production.

## Branches
| Branche | Créée depuis | Fusionnée dans | Rôle |
| --- | --- | --- | --- |
| `main` | | | Code en production. On n'y travaille jamais directement. |
| `release/vX.Y.Z` | `main` | `main` | Regroupe les développements d'une version. Existe dans chaque dépôt concerné par la version. On n'y travaille jamais directement. |
| `<technical label>/#<id>-<description>` | `release/vX.Y.Z` de la version du ticket | `release/vX.Y.Z`, par PR | Un développement = un ticket = une branche. `<technical label>` est la valeur du champ du même nom, `<id>` le numéro du ticket du dépôt concerné (voir « Tickets et sous-tickets »), `<description>` 3 mots maximum, en minuscules et séparés par des tirets. Exemple : `fix/#117-recherche-catalogue`. |
| `hotfix/#<id>-<description>` | `main` | `main` et toutes les `release/*` en cours | Correctif urgent de la production. |

## Messages de commit
Format, inspiré de la convention *Conventional Commits* :

```
<technical label>(#<id>): <résumé>

<corps facultatif : pourquoi ce changement, ce qu'il faut savoir>
```

- `<technical label>` et `<id>` : ceux du ticket. Pour un hotfix : `hotfix(#<id>)`.
- `<résumé>` : en français, au présent, sans majuscule initiale ni point final, 72 caractères maximum. Il décrit ce que fait le commit.
- Exemples : `fix(#117): corrige la recherche du catalogue`, `feature(#97): ajoute les titres secondaires`.
- Un commit = un changement cohérent. Ne pas mélanger deux sujets dans un même commit.
- Dans le dépôt espace de travail (`dramatoons-workspace`), les commits n'ont pas de ticket : seulement `<résumé>`, avec les mêmes règles d'écriture.
- Pas de ligne `Co-Authored-By` ni d'autre signature dans les commits.

## Pull requests
- Titre : `#<id> <titre du ticket>`.
- Description : ce qui change, comment le tester, et le lien vers le ticket (`Refs #<id>`, ou `Refs remi-leconte/<dépôt>#<id>` si le ticket est dans un autre dépôt).
- Cible : la branche `release/vX.Y.Z` de la version du ticket, dans le même dépôt que la branche.
- CI (api et front) : chaque PR vers `main` ou `release/*` lance `.github/workflows/ci.yml`, qui produit deux checks, `Vérifications` (`composer ci` ou `npm run ci`) et `Image prod`. Les rulesets les rendent obligatoires : une PR ne se fusionne qu'avec les deux checks verts. Le détail est dans la section « CI » du `CLAUDE.md` de chaque dépôt. Suivre les checks avec `gh pr checks <PR> --watch`.

## Tickets et sous-tickets
Les numéros de ticket sont propres à chaque dépôt : le ticket #12 du front et le #12 de l'API sont deux tickets différents. Chaque branche porte donc le numéro d'un ticket **du dépôt où elle est créée**.

| Le ticket concerne | Ticket principal dans | Sous-tickets (sub-issues) |
| --- | --- | --- |
| le front seulement | `dramatoons-front` | aucun |
| le front et l'API et/ou les extensions | `dramatoons-front` | un par autre dépôt concerné (API, extension Chromium, extension Firefox), rattaché à ce dépôt |
| l'API seulement | `dramatoons-api` | aucun |
| l'API et les extensions | `dramatoons-api` | un par extension concernée |
| une extension seulement | le dépôt de l'extension | aucun |

- Un ticket est créé par défaut dans `dramatoons-front`, puis déplacé dans le bon dépôt s'il ne concerne pas le front. Quand Claude crée un ticket dont le dépôt est connu (ex. : API seulement), il le crée directement dans ce dépôt.
- Un ticket créé est ajouté au projet Dramatoons, avec sa Release et son Technical label.
- Le dépôt du ticket principal travaille avec le ticket principal. Chaque autre dépôt travaille avec son sous-ticket : branche, commits et PR portent le numéro du sous-ticket.
- Si un champ du sous-ticket est vide (Release, Technical label…), on reprend la valeur du ticket principal.
- Le ticket principal ne peut pas avoir un statut plus avancé que le moins avancé de ses sous-tickets. Exemple : il ne passe en `Ready for Prod` que lorsque tous ses sous-tickets y sont.

## Statuts des tickets (champ Status)
Noms exacts : `Backlog` → `Tâche en cours` → `Merge Request` → `Ready for Release` → `Recette` → `Ready for Prod` → `Done`, avec `Tâche à corriger` en cas de recette échouée.

| Événement | Nouveau statut |
| --- | --- |
| Création du ticket | `Backlog` |
| Création de la branche en local (début du développement) | `Tâche en cours` |
| PR ouverte | `Merge Request` |
| PR refusée | `Tâche en cours`, ou `Tâche à corriger` si le ticket est déjà passé par la recette |
| PR acceptée et fusionnée dans la release | `Ready for Release`, et assigner le ticket à l'utilisateur (`remi-leconte`) |
| Staging mis à jour avec la branche release | `Recette` |
| Recette échouée | `Tâche à corriger`. Un retour arrière (rollback) du staging peut être nécessaire. |
| Recette réussie | `Ready for Prod` |
| Mise en production | `Done` |

- `Tâche à corriger` se traite comme `Tâche en cours` : ce statut indique seulement que le ticket est déjà passé par la recette.
- Un ticket n'est à traiter que si sa version est celle de la release en cours. Un ticket sans version, ou d'une autre version, ne se traite pas.

## Développement d'un ticket
1. Vérifier que le ticket porte la version de la release en cours (champ Release) et un Technical label. Dans un dépôt autre que celui du ticket principal, travailler avec le sous-ticket de ce dépôt.
2. Créer `<technical label>/#<id>-<description>` depuis `release/vX.Y.Z`, puis passer le ticket en `Tâche en cours`.
3. Développer et commiter sur cette branche.
4. Ouvrir une PR de cette branche vers `release/vX.Y.Z`, puis passer le ticket en `Merge Request`.
5. Si la PR est refusée : corriger les retours, puis ouvrir une nouvelle PR, jusqu'à ce qu'elle soit acceptée.
6. Si la PR est acceptée : fusionner, puis passer le ticket en `Ready for Release` et l'assigner à `remi-leconte`.

Avec Claude, la relecture et les étapes 5 et 6 sont faites par l'agent `relecteur-pr` : voir ci-dessous.

## Cycle d'un ticket avec Claude
1. **Discussion** : l'utilisateur et Claude discutent du ticket. Claude ne crée rien et ne code rien.
2. **Développement** : l'utilisateur valide ce qui a été dit. Claude crée le ticket (Release, Technical label), la branche, passe le ticket en `Tâche en cours`, code **sans commiter**, puis lance l'agent `testeur` avec le ticket et la liste des fichiers modifiés (sans lui dire quels résultats attendre). Tant que le verdict est `ÉCHEC`, Claude corrige et relance `testeur`. Un échec dû à une règle ambiguë ou muette se fait trancher par l'utilisateur. Quand le verdict est `VALIDÉ`, Claude résume ce qu'il a fait et le résultat des tests.
3. **Relecture par l'utilisateur** : il pose ses questions, demande des modifications ; Claude les fait, toujours sans commiter, et relance `testeur` jusqu'au verdict `VALIDÉ` avant de rendre la main.
4. **Validation** : sur « je valide le ticket xxx », Claude :
   - commite **uniquement les fichiers liés au ticket** (ajoutés un par un, jamais `git add -A` ni `git commit -a`) ; les autres changements non commités du dépôt restent tels quels ;
   - pousse, ouvre la PR vers `release/vX.Y.Z` (ou réutilise la PR déjà ouverte), passe le ticket en `Merge Request` ;
   - si le ticket a des sous-tickets : fait de même dans chaque dépôt concerné, avec la branche et la PR de chaque sous-ticket ;
   - attend que la CI de toutes les PR soit verte (`gh pr checks`) ; si un check échoue, Claude corrige sans commiter, l'explique à l'utilisateur, et retourne à l'étape 3 ;
   - lance l'agent `relecteur-pr` une seule fois avec toutes les PR (ticket principal et sous-tickets) : pour chacune, le dépôt, la PR et le ticket.
5. **Retour de `relecteur-pr`** (pour l'instant, toute remarque est bloquante, même de style) :
   - `FUSIONNÉE` : toutes les PR sont fusionnées et tous les tickets en `Ready for Release`, assignés à `remi-leconte`. Claude met à jour les branches release locales si l'agent ne l'a pas fait, le dit à l'utilisateur : c'est fini.
   - `BLOQUÉE` (au moins une remarque ou question, sur n'importe laquelle des PR ; aucune n'est alors fusionnée) : Claude corrige, **sans commiter**, puis explique à l'utilisateur le problème et sa correction ; retour à l'étape 3. Une question de l'agent est aussi un problème : le code est faux, ou une précision manque (fichier `.md`, `CLAUDE.md`, skill, commentaire « pourquoi ») ; Claude la corrige là où elle manque plutôt que de répondre à l'agent.

## Recette et mise en production d'une release
1. Mettre à jour le staging avec `release/vX.Y.Z`, puis passer les tickets `Ready for Release` en `Recette`.
2. Recetter chaque ticket : `Ready for Prod` si c'est bon, `Tâche à corriger` sinon.
3. Quand **tous** les tickets de la version sont en `Ready for Prod` : fusionner `release/vX.Y.Z` dans `main` (par PR, imposé par le ruleset) et poser le tag `vX.Y.Z` sur `main`.
4. Faire une dernière recette de `main` sur le staging.
5. Si tout est bon, mettre à jour la production avec `main`, puis passer les tickets en `Done`.
6. Préparer la version suivante :
   - si elle n'est pas commencée : créer `release/vX.Y.0` suivante depuis `main` ;
   - si elle est déjà commencée : fusionner `main` dans sa branche `release/*`.

## Hotfix
1. Créer `hotfix/#<id>-<description>` depuis `main` et corriger.
2. Tester le correctif en staging, au choix :
   - avec la release en cours ;
   - ou avec une release dédiée, si les développements en cours posent problème.
3. Une fois validé :
   - fusionner le hotfix dans `main` et poser le tag de la version corrigée (exemple : `v2.3.1`) ;
   - fusionner le hotfix dans toutes les branches `release/*` en cours de développement ;
   - mettre la production à jour avec `main`.
