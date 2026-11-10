# Règles métier : webtoons

### webtoon - base
1. Tous les utilisateurs peuvent créer un webtoon, il sera alors dépublié (webtoon.publish = 0)
2. Un webtoon est une entrée dans la table webtoon et une ou plusieurs dans la table webtoonTitle.
3. Si un utilisateur suit un webtoon cela signifie qu'il existe une entrée dans la table webtoonUser avec l'id du webtoon et l'id de l'utilisateur et qu'au moins 1 champ (rate, state ou bookmark) est renseigné. Un bookmark à 0 équivaut à un bookmark null.
   - Donner une note, un état ou un bookmark (différent de 0) à un webtoon crée l'entrée webtoonUser si elle n'existe pas.
   - Retirer la note, l'état et le bookmark (bookmark à 0 ou vide) supprime l'entrée webtoonUser : il n'existe jamais d'entrée webtoonUser vide.
4. Un utilisateur non connecté n'a accès à aucun webtoon.
5. Un webtoon peut être visible via : l'onglet bibliothèque, l'onglet catalogue, l'administration, les extensions navigateurs et la barre de recherche principale du site dans l'entête.
6. Dans ces règles, « modifier/supprimer un webtoon » porte sur la table webtoon (y compris sa couverture, champ image) et ses titres (webtoonTitle). Le suivi (webtoonUser) n'en fait pas partie.
7. Le créateur d'un webtoon est l'utilisateur qui l'a créé. Personne ne peut créer un webtoon au nom d'un autre, ni le réattribuer ou le donner à quelqu'un d'autre. Seule exception : la suppression d'un compte (voir les règles utilisateurs).
8. Le slug n'est modifiable par personne : il est calculé à la création à partir du titre principal, et recalculé à chaque modification de ce titre.
9. La couverture d'un webtoon est une image JPEG de 1 Mo au maximum. Tout autre fichier est refusé.
### webtoon - administration
1. Seuls les modérateurs ou administrateurs ont accès à l'administration des webtoons. L'administration des utilisateurs est réservée aux administrateurs (voir utilisateurs.md) : dans l'administration des webtoons, un modérateur voit le login des lecteurs mais pas leur fiche.
2. Tous les webtoons sont visibles dans l'administration et les modo/admin ont un accès complet au webtoon (modification/suppression).
3. Les modérateurs/administrateurs peuvent publier/dépublier un webtoon (webtoon.publish) depuis l'administration et, en raccourci, depuis la bibliothèque et le catalogue pour les webtoons qu'ils y voient.
4. En dehors de l'administration, un modérateur/administrateur a les mêmes droits qu'un utilisateur normal : il ne peut modifier/supprimer un webtoon que s'il en est le créateur (voir « modification/suppression »). Seule la publication fait exception.
### webtoon - bibliothèque
1. Un utilisateur, quel que soit son rôle, ne verra dans l'onglet bibliothèque que les webtoons qu'il suit (voir webtoon - base: règle 3) et les webtoons, dépubliés, qu'il a créés (dans le cas où il ne les suit pas)
### webtoon - catalogue
1. Un utilisateur, quel que soit son rôle, ne verra dans l'onglet catalogue que les webtoons publiés (webtoon.publish = 1).
### webtoon - recherche
1. règles identiques au catalogue.
### webtoon - extension navigateur
1. règle identique à la bibliothèque.
### webtoon - modification/suppression
1. Seuls le créateur d'un webtoon dépublié et les modo/admin pourront le modifier/supprimer (webtoon, webtoonTitle).
2. Si le webtoon est publié alors le créateur ne pourra plus le modifier/supprimer (webtoon, webtoonTitle) et il apparaitra dans le catalogue et dans la bibliothèque de ceux qui le suivent.
### webtoon - cas spécifique (webtoon publié, suivi par quelqu'un d'autre que le créateur, puis dépublié)
1. Dans le cas où un utilisateur suit un webtoon dépublié et qu'il n'en est pas le créateur alors il le verra dans sa bibliothèque et pourra continuer à modifier les données de suivi.
2. Si au moins 1 utilisateur (autre que le créateur) suit un webtoon dépublié alors personne ne pourra modifier/supprimer le webtoon à part un modérateur/administrateur.
3. Si le webtoon est publié puis dépublié mais que personne d'autre que le créateur ne suit le webtoon alors le créateur peut continuer à le modifier/supprimer.
### webtoon - autres
1. Les données de la table webtoonUser ne doivent être visibles que par l'utilisateur concerné (webtoonUser.reader) et les modérateurs/administrateurs. Seuls les totaux stockés dans webtoon (règle 2) en dérivent.
2. La note moyenne et le nombre de lecteurs (webtoon.averageRating et webtoon.readersCount) sont recalculés à partir de tous les suivis à chaque modification d'un suivi, que le webtoon soit publié ou non. Ils sont visibles par tous ceux qui voient le webtoon. Un lecteur est un suivi dont l'état n'est pas « Pas intéressé » (break) ; la note moyenne porte sur toutes les notes.
