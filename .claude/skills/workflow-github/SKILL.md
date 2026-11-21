---
name: workflow-github
description: Workflow git et GitHub de Dramatoons (Release-Driven) - branches feature/release/hotfix, pull requests, messages de commit, tags de version, statuts des tickets du projet GitHub, recette en staging et mise en production. À charger avant de créer une branche, commiter, ouvrir ou fusionner une PR, créer ou faire avancer un ticket, préparer une release ou un hotfix, ou déployer.
---

# Workflow GitHub de Dramatoons (Release-Driven)

## Ce que Claude peut faire
- **Ne jamais commiter de lui-même**, dans aucun dépôt (y compris `dramatoons-workspace`) : après toute modification de fichier, laisser les changements non commités et attendre que l'utilisateur les ait relus et demande le commit. Pour un ticket, cette demande est « je valide le ticket xxx » (voir « Cycle d'un ticket avec Claude »).
- Travailler uniquement sur les branches de ticket (`<technical label>/...` et `hotfix/...`) : les créer, y commiter, les pousser, ouvrir une PR.
- Ne jamais commiter, fusionner ni pousser sur `main` ou une branche `release/*`, sauf demande explicite de l'utilisateur. Côté GitHub, un ruleset protège `main` et `release/*` (api et front) et `main` (extension) : pas de push direct, pas de force push, pas de suppression, fusion uniquement par PR (0 approbation requise).
- Créer un ticket GitHub seulement avec l'accord explicite de l'utilisateur, y compris un ticket de correction découvert pendant un développement : proposer le ticket (titre, problème, Release, Technical label) et attendre son accord. Remplir ensuite ses champs Release et Technical label.
- Faire avancer les statuts des tickets : `In Progress`, `In Review`, puis `In QA` une fois le ticket déployé en recette (voir « Statuts des tickets »). `Ready to Deploy` est réservé à l'utilisateur ; `Done` après une mise en production réussie (voir « Recette et mise en production d'une release »).
- Une PR extérieure (autre auteur, fork) n'est jamais fusionnée telle quelle : son check « Relecture IA » est rouge. Si son contenu est retenu, Claude le reprend sur une branche de ticket du dépôt, et le cycle normal s'applique.
- L'utilisateur ne relit pas les PR : il valide le code avant le commit. La relecture IA de GitHub (check « Relecture IA », workflow `relecture.yml`, consignes dans `relecture/consignes.md` à la racine) relit chaque PR, et Claude fusionne les PR d'un ticket une fois toutes vertes : « je valide le ticket xxx » vaut demande de les fusionner (voir « Cycle d'un ticket avec Claude »).
- Une branche de ticket ne vit que jusqu'à la fusion de sa PR : GitHub supprime alors la branche distante (réglage « Automatically delete head branches » de l'API et du front), et Claude supprime la branche locale (`git branch -d`, qui refuse une branche non fusionnée), puis `git fetch --prune`. Rien n'est perdu : la fusion par commit de fusion garde les commits dans la release, et la PR fusionnée garde le lien avec le ticket. Pour retravailler un ticket (PR refusée après fusion, `Rework`), recréer une branche du même nom depuis la release à jour.
- La recette (staging) est mise à jour automatiquement à chaque fusion dans `release/*` : le workflow `publish.yml` de l'API et du front publie l'image puis la déploie (job « Déploiement recette »). L'utilisateur valide la recette. La livraison (tag `vX.Y.Z`, production) suit automatiquement la fusion d'une release dans `main` (workflow `livraison.yml`), et la production attend l'approbation de l'utilisateur. Claude n'approuve ni ne rejette jamais un déploiement en production et ne le déclenche jamais (ni relance d'un job « Déploiement production », ni script lancé sur le serveur).
- Accès GitHub : remotes en HTTPS, authentifiés par `gh` (`gh auth setup-git`). Pas de SSH (la clé a une passphrase).

## Repères
- Tableau de bord : projet GitHub **Dramatoons** (n° 4, propriétaire `remi-leconte`), commun aux dépôts `dramatoons-api`, `dramatoons-front` et `dramatoons-browser-extension` (et aux anciennes extensions `dramatoons-extension-chromium` et `dramatoons-extension-firefox`).
- Version d'un ticket : champ **Release** du projet (commun aux 4 dépôts).
- Type technique d'un ticket : champ **Technical label** du projet, une seule valeur parmi `feature`, `fix`, `refactor`, `infra`, `docs`, `tests`. Il donne le préfixe de la branche.
- Domaine fonctionnel d'un ticket : champ **Functional labels** du projet (plusieurs valeurs possibles).
- Les labels propres à chaque dépôt (`bug`, `enhancement`…) ne sont plus utilisés.
- Numéro de version : `vX.Y.Z`. Une release s'appelle `vX.Y.0` (exemple : `v2.4.0`) ; un hotfix incrémente le dernier chiffre (exemple : `v2.3.1`).
- L'API et le front ont toujours la même version `X.Y`. Si l'un des deux doit avancer sans l'autre, on saute une version pour les réaligner.
- L'extension (`dramatoons-browser-extension`) suit ce workflow sans branche `release/*` : voir « Extension navigateur ». Les anciennes extensions ne sont plus modifiées.
- Le dépôt espace de travail (`dramatoons-workspace`, la racine) ne suit pas ce workflow : il n'a qu'une branche `main`, sur laquelle on commite directement. Il ne nécessite pas de ticket : Claude peut y commiter et pousser sans ticket associé.
- Environnements : local, staging (`api-staging.dramatoons.ovh`) et production.

## Branches
| Branche | Créée depuis | Fusionnée dans | Rôle |
| --- | --- | --- | --- |
| `main` | | | Code en production. On n'y travaille jamais directement. |
| `release/vX.Y.Z` | `main` | `main` | Regroupe les développements d'une version. Existe dans chaque dépôt concerné par la version. On n'y travaille jamais directement. |
| `<technical label>/#<id>-<description>` | `release/vX.Y.Z` de la version du ticket | `release/vX.Y.Z`, par PR | Un développement = un ticket = une branche. `<technical label>` est la valeur du champ du même nom, `<id>` le numéro du ticket du dépôt concerné (voir « Tickets et sous-tickets »), `<description>` 3 mots maximum, en minuscules et séparés par des tirets. Exemple : `fix/#117-recherche-catalogue`. |
| `hotfix/#<id>-<description>` | `release/vX.Y.Z` du hotfix, elle-même créée depuis `main` | cette `release/vX.Y.Z`, par PR | Correctif urgent de la production (voir « Hotfix »). |

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
- CI (api et front) : chaque PR vers `main` ou `release/*` lance `.github/workflows/ci.yml`, qui produit les checks `Vérifications` (`composer ci` ou `npm run ci`), `Tests` (`composer test` ou `npm test`) et `Image prod`. Les rulesets les rendent obligatoires : une PR ne se fusionne qu'avec tous ses checks verts. Vers `release/*` seulement, un second ruleset (« releases : relecture IA ») exige aussi le check « Relecture IA » (`relecture.yml`). Dans l'extension, les PR vers `main` ont les checks `Vérifications`, `Tests` et « Relecture IA », tous obligatoires. Le détail est dans la section « CI » du `CLAUDE.md` de chaque dépôt. Suivre les checks avec `gh pr checks <PR> --watch`.

## Tickets et sous-tickets
Les numéros de ticket sont propres à chaque dépôt : le ticket #12 du front et le #12 de l'API sont deux tickets différents. Chaque branche porte donc le numéro d'un ticket **du dépôt où elle est créée**.

| Le ticket concerne | Ticket principal dans | Sous-tickets (sub-issues) |
| --- | --- | --- |
| le front seulement | `dramatoons-front` | aucun |
| le front et l'API et/ou l'extension | `dramatoons-front` | un par autre dépôt concerné (API, extension), rattaché à ce dépôt |
| l'API seulement | `dramatoons-api` | aucun |
| l'extension, et l'API pour ses besoins | `dramatoons-browser-extension` | un dans `dramatoons-api` |
| l'API, et l'extension pour en suivre le changement | `dramatoons-api` | un dans `dramatoons-browser-extension` |
| l'extension seulement | `dramatoons-browser-extension` | aucun |

- Un ticket est créé par défaut dans `dramatoons-front`, puis déplacé dans le bon dépôt s'il ne concerne pas le front. Quand Claude crée un ticket dont le dépôt est connu (ex. : API seulement), il le crée directement dans ce dépôt.
- Un ticket créé est ajouté au projet Dramatoons, avec sa Release et son Technical label.
- Le dépôt du ticket principal travaille avec le ticket principal. Chaque autre dépôt travaille avec son sous-ticket : branche, commits et PR portent le numéro du sous-ticket.
- Claude remplit toujours la Release et le Technical label de chaque sous-ticket, comme pour le ticket principal : les jobs qui posent les statuts lisent la Release du ticket lui-même. Pour un autre champ vide du sous-ticket, on reprend la valeur du ticket principal.
- Le ticket principal ne peut pas avoir un statut plus avancé que le moins avancé de ses sous-tickets. Exemple : il ne passe en `Ready to Deploy` que lorsque tous ses sous-tickets y sont.

## Statuts des tickets (champ Status)
Noms exacts : `Backlog` → `In Progress` → `In Review` → `In QA` → `Ready to Deploy` → `Done`, avec `Rework` en cas de recette échouée. Il n'y a pas d'état entre la fusion et la recette : chaque fusion dans la release déploie la recette.

| Événement | Nouveau statut |
| --- | --- |
| Création du ticket | `Backlog`, attribué à personne |
| Création de la branche en local (début du développement) | `In Progress`, et attribuer le ticket à l'utilisateur (`remi-leconte`), qui le reste jusqu'à `Done` |
| PR ouverte (« je valide le ticket xxx ») | `In Review` |
| PR refusée (check rouge) | `In Progress`, ou `Rework` si le ticket est déjà passé par la recette |
| PR fusionnée dans la release | le ticket reste en `In Review` jusqu'au déploiement de la recette |
| Job « Déploiement recette » réussi après la fusion | `In QA` |
| Recette échouée | `Rework`. Un retour arrière (rollback) du staging peut être nécessaire : dans GitHub, relancer **seulement** le job « Déploiement recette » (« Re-run this job ») du run « Publication » d'un commit précédent de la release, jamais « Re-run all jobs », qui reconstruirait l'image. Au-delà de 30 jours, GitHub ne relance plus le job : lancer le script de déploiement à la main sur le serveur. Seuls les commits fusionnés depuis le déploiement automatique (front#149, api#111) se redéploient ainsi ; pour un commit plus ancien, relancer l'ancienne recette, construite dans un autre dossier du serveur qui contient le code et qui y reste jusqu'au retrait de git du serveur. Si les commits annulés contiennent une migration de l'API, la défaire d'abord (section « Publication et déploiement » de `api/CLAUDE.md`). |
| Recette réussie | `Ready to Deploy`, par l'utilisateur |
| Mise en production réussie | `Done` |

- `In QA` et `Done` sont posés par les workflows de l'API et du front, à la fin des jobs de déploiement (section « Statuts des tickets » de leur `CLAUDE.md`). L'étape ne fait jamais échouer le job : un échec (erreur dans le run), une étape qui ne trouve aucun ticket (avertissement) ou une relance du job (notice, aucun statut changé) se corrigent à la main par Claude.
- `Rework` se traite comme `In Progress` : ce statut indique seulement que le ticket est déjà passé par la recette.
- Un ticket n'est à traiter que si sa version est celle de la release en cours. Un ticket sans version, ou d'une autre version, ne se traite pas.

## Développement d'un ticket
1. Vérifier que le ticket porte la version de la release en cours (champ Release) et un Technical label. Dans un dépôt autre que celui du ticket principal, travailler avec le sous-ticket de ce dépôt.
2. Créer `<technical label>/#<id>-<description>` depuis `release/vX.Y.Z`, puis passer le ticket en `In Progress` et l'attribuer à `remi-leconte`.
3. Développer et commiter sur cette branche.
4. Ouvrir une PR de cette branche vers `release/vX.Y.Z`, puis passer le ticket en `In Review`.
5. Si la PR est refusée : corriger les retours, puis ouvrir une nouvelle PR, jusqu'à ce qu'elle soit acceptée.
6. Si la PR est acceptée : fusionner. Le ticket passe en `In QA` dès que la recette est déployée.

Avec Claude, la relecture est faite par la relecture IA de GitHub, et les étapes 5 et 6 par Claude : voir ci-dessous.

## Cycle d'un ticket avec Claude
1. **Discussion** : l'utilisateur et Claude discutent du ticket. Claude ne crée rien et ne code rien.
2. **Développement** : l'utilisateur valide ce qui a été dit. Claude crée le ticket (Release, Technical label), la branche, passe le ticket en `In Progress` en l'attribuant à `remi-leconte`, écrit le code et ses tests (PHPUnit, Vitest) **sans commiter**, puis lance l'agent `testeur` avec le ticket et la liste des fichiers modifiés (sans lui dire quels résultats attendre). `testeur` n'écrit rien : il vérifie que chaque cas du ticket et des règles métier est couvert par un test, et lance les vérifications et les tests. Tant que le verdict est `ÉCHEC`, Claude écrit les tests manquants, corrige et relance `testeur`. Un échec dû à une règle ambiguë ou muette se fait trancher par l'utilisateur. Quand le verdict est `VALIDÉ`, Claude résume ce qu'il a fait et le résultat des tests.
3. **Relecture par l'utilisateur** : il pose ses questions, demande des modifications ; Claude les fait, toujours sans commiter, et relance `testeur` jusqu'au verdict `VALIDÉ` avant de rendre la main.
   - Exception : une modification qui ne touche que des commentaires ou de la documentation (`.md`, `CLAUDE.md`) ne relance pas `testeur`. Les tests automatiques et la CI suffisent ; la relecture IA relit toujours la PR.
   - Un ticket qui ne modifie que des workflows de CI (`.github/workflows/`), que PHPUnit et Vitest ne peuvent pas exécuter, n'a pas de test écrit : `testeur` le vérifie par relecture, Claude le teste en simulation (commandes en lecture seule sur les vraies données, sans rien écrire), et le premier run réel après la fusion sert de preuve, que Claude contrôle et signale à l'utilisateur.
4. **Validation** : sur « je valide le ticket xxx », Claude :
   - commite **uniquement les fichiers liés au ticket** (ajoutés un par un, jamais `git add -A` ni `git commit -a`) ; les autres changements non commités du dépôt restent tels quels ;
   - pousse, ouvre la PR vers `release/vX.Y.Z` (jamais de changement de cible ensuite : fermer la PR et en ouvrir une nouvelle) **en brouillon** (`gh pr create --draft`, ou réutilise la PR déjà ouverte), passe le ticket en `In Review` ;
   - si le ticket a des sous-tickets : fait de même dans chaque dépôt concerné, avec la branche et la PR de chaque sous-ticket ;
   - une fois toutes les PR du ticket ouvertes, les passe prêtes (`gh pr ready <n> -R remi-leconte/<dépôt>`) : la relecture IA ne tourne pas sur un brouillon, et chaque relecture trouve ainsi toutes les PR liées ;
   - attend la fin de tous les checks de toutes les PR (`gh pr checks <PR> --watch`), relecture IA comprise : les PR d'un même ticket sont relues ensemble, chaque relecture lisant aussi les PR liées des autres dépôts.
5. **Résultat des checks** (pour l'instant, toute remarque de la relecture est bloquante, même de style) :
   - **Tous verts sur toutes les PR** : Claude fusionne toutes les PR, l'API d'abord. C'est Claude, et non la fusion automatique de GitHub, qui fusionne : GitHub fusionnerait chaque PR de son côté, et une PR de l'API pourrait entrer dans la release alors que celle du front est bloquée. La fusion est tout ou rien (`gh pr merge <n> --merge`). Si une fusion échoue, il s'arrête et dit précisément ce qui est fusionné et ce qui ne l'est pas. Il se place ensuite sur la release à jour, supprime les branches locales du ticket (`git branch -d`) et fait `git fetch --prune`. Il suit enfin le job « Déploiement recette » de chaque dépôt (run « Publication » de la fusion, `gh run watch`), qui passe les tickets en `In QA`, vérifie leur statut et le dit à l'utilisateur : c'est fini. Si un déploiement échoue, les tickets restent en `In Review` : il le signale. Si l'étape « Statuts des tickets » a signalé une erreur, un avertissement ou une notice, ou si le run « Publication » de la fusion a été annulé par la concurrence (fusions rapprochées : le run suivant déploie le code, mais ne change que le statut de son propre ticket), il corrige les statuts à la main.
   - **Au moins un check rouge, sur n'importe laquelle des PR** : aucune PR n'est fusionnée. Claude repasse les tickets en `In Progress` (ou `Rework`), lit le commentaire de la relecture (`gh pr view <n> --comments`) ou le journal du check en échec, corrige **sans commiter**, puis explique à l'utilisateur le problème et sa correction ; retour à l'étape 3. Une question de la relecture est aussi un problème : le code est faux, ou une précision manque (fichier `.md`, `CLAUDE.md`, skill, commentaire « pourquoi ») ; Claude la corrige là où elle manque plutôt que d'y répondre.
   - **Après une correction poussée sur une partie seulement des PR du ticket** : relancer aussi la relecture des autres PR (`gh run rerun <run> -R remi-leconte/<dépôt>`, dernier run « Relecture » de la PR), qui ont vu l'ancienne version.
   - **Relecture en échec sans verdict** : lire l'erreur du job (`gh run view <run> --log-failed`). Quota de l'abonnement atteint ou panne : ce n'est pas une remarque, le dire à l'utilisateur et relancer le job plus tard (`gh run rerun <run> --failed`). Erreur explicite sur la PR (dossier réservé `_relecture/` ou `_workspace/` versionné) : la corriger comme une remarque.

## Mettre un ticket de côté
Sur « mets le ticket xxx de côté » (valant validation de ce commit), Claude commite le travail en cours sur la branche du ticket, au format habituel, avec un résumé qui dit où il en est, et pousse la branche, **sans ouvrir de PR** : rien n'est déclenché (ni CI, ni relecture, ni recette). Le ticket reste en `In Progress`. À la reprise, Claude fusionne la release dans la branche si elle a avancé, puis le cycle reprend à l'étape 2.

## Recette et mise en production d'une release
1. Le staging est à jour avec `release/vX.Y.Z` dès que le job « Déploiement recette » de la dernière fusion a réussi (API et front) : le job passe alors les tickets fusionnés en `In QA` (étape 5 du cycle d'un ticket).
2. L'utilisateur recette chaque ticket : `Ready to Deploy` si c'est bon, `Rework` sinon.
3. Quand la recette est bonne, l'utilisateur dit « je valide la recette ». C'est sa demande explicite de fusionner la release dans `main`. Claude :
   - vérifie qu'aucun ticket de la version ne reste en `In QA` (l'utilisateur passe lui-même les tickets en `Ready to Deploy` ; ceux de l'extension, publiée à part, ne comptent pas) ; s'il en reste, il les signale et ne fusionne rien ;
   - vérifie que la release contient déjà tout `main` (sinon, le signaler : il faut fusionner `main` dans la release et recetter), car la livraison s'arrête si `main` diffère du dernier commit recetté ;
   - ouvre la PR `release/vX.Y.Z` → `main` dans chaque dépôt concerné (API et front), attend ses checks (`gh pr checks --watch`) et la fusionne (« Create a merge commit »). Ne pas poser de tag : la livraison le pose ;
   - suit les runs « Livraison » jusqu'à ce que le job « Déploiement production » attende l'approbation, puis dit à l'utilisateur que tout est prêt pour la mise en production.
4. La fusion lance le workflow `livraison.yml` (section « Livraison » du `CLAUDE.md` de l'API et du front) : tag `vX.Y.Z`, image recettée réétiquetée `vX.Y.Z` sans reconstruction. La recette n'est pas redéployée : elle tourne déjà sur cette image.
5. L'utilisateur approuve dans GitHub le job « Déploiement production », celui de l'API d'abord, puis celui du front. Claude vérifie ensuite que les deux jobs ont réussi (`gh run view`, en lecture seule) et que les jobs ont passé les tickets de la version en `Done` (sinon, il les y passe à la main). Claude crée ensuite, dans chaque dépôt livré, la release GitHub du tag `vX.Y.Z` (`gh release create vX.Y.Z --verify-tag --latest --title … --notes-file …`) :
   - titre : `vX.Y.Z : <évolutions majeures>`, seulement les plus grosses ;
   - description : un court résumé, puis les tickets de la version de ce dépôt regroupés par thème (droits et visibilité, nouveautés, corrections, qualité et tests, intégration et livraison continues…), chacun avec son numéro, et un lien vers la release de l'autre dépôt ;
   - aucune donnée sensible : ni infrastructure (serveurs, ports, chemins, clés, sauvegardes), ni détail d'exploitation d'une faille corrigée ; un ticket d'exercice annulé (revert) n'y figure pas.
   Si la version ne doit finalement pas partir en production : l'utilisateur rejette le job « Déploiement production » (sinon le run en attente bloque la livraison suivante), puis le problème se corrige par un hotfix (voir « Hotfix »).
6. Après une mise en production réussie, Claude prépare la version suivante :
   - si elle n'est pas commencée : créer `release/vX.Y.0` suivante depuis `main` ;
   - si elle est déjà commencée : fusionner `main` dans sa branche `release/*`, par une PR `main` → `release/vX.Y.0` : sa relecture IA passe sans relire, ce code étant déjà relu et livré.

## Extension navigateur
L'extension (`dramatoons-browser-extension`) n'a ni recette ni déploiement automatiques : elle est publiée à la main sur les stores, par l'utilisateur.
- **Branches et PR** : la branche de ticket part de `main`, et sa PR vise `main`. Le cycle d'un ticket est le même (brouillon, `gh pr ready`, checks, fusion par Claude avec les PR liées des autres dépôts, l'API d'abord).
- **Version** : le champ Release d'un ticket de l'extension est la version du site avec laquelle elle sera publiée, et la version de `manifest.json` et de `package.json` est la même. Le premier ticket d'une nouvelle version la change dans les deux fichiers.
- **Statuts**, posés à la main : `In QA` par Claude à la fusion (l'utilisateur teste alors `main`), `Ready to Deploy` par l'utilisateur, `Done` par Claude quand l'utilisateur dit l'avoir publiée sur les stores.
- **Dépendance à l'API** : une version de l'extension qui utilise un changement de l'API ne se publie qu'après la mise en production de cette API.
- **Publication** : sur la demande de l'utilisateur (« je publie la X.Y.Z »), Claude vérifie que la version de `manifest.json` est `X.Y.Z` et qu'aucun ticket de l'extension de cette Release n'est avant `Ready to Deploy`, puis pose le tag `vX.Y.Z` sur `main` et le pousse (`git tag vX.Y.Z origin/main && git push origin vX.Y.Z`). S'il manque quelque chose, il le signale et ne pose rien.

## Hotfix
Un hotfix passe par une release dédiée : seule la fusion d'une `release/vX.Y.Z` dans `main` est livrée automatiquement, avec l'image recettée.
1. Créer depuis `main` la release de la version corrigée (exemple : `release/v2.4.1`), puis `hotfix/#<id>-<description>` depuis cette release, et corriger.
2. La PR du hotfix vise cette release : sa fusion déploie la recette, comme pour un ticket. La recette affiche alors le hotfix, et non plus la release en cours.
3. Une fois validé :
   - fusionner la release du hotfix dans `main` : la livraison pose le tag (exemple : `v2.4.1`) et déploie, comme pour une release ;
   - fusionner ensuite `main` dans toutes les branches `release/*` en cours de développement.
