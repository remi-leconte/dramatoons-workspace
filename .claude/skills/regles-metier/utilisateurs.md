# Règles métier : utilisateurs

### utilisateur - compte
1. Tout le monde peut créer un compte avec un login, un email et un mot de passe. Le login et l'email sont uniques.
2. Un nouveau compte a le rôle utilisateur (ROLE_USER), il est actif (user.publish = 1) et son email n'est pas vérifié (user.verified = 0).
3. On se connecte avec son login (pas son email) et son mot de passe.
4. Un compte désactivé (user.publish = 0) ne peut pas se connecter (message « Votre compte a été désactivé. »).
5. Un email non vérifié n'empêche pas de se connecter ni d'utiliser le site.
6. La session dure 1 h et se renouvelle automatiquement pendant 30 jours.

### utilisateur - vérification de l'email
1. Un lien de vérification, valable 1 h, est envoyé à l'inscription et à chaque changement d'email. Après un changement d'email, le compte repasse à « non vérifié ».
2. L'utilisateur peut redemander un lien depuis son profil.

### utilisateur - mot de passe oublié
1. L'utilisateur saisit son email et reçoit un lien, valable 1 h, pour choisir un nouveau mot de passe. Si l'email est inconnu, le site ne le signale pas.
2. Le nouveau mot de passe doit faire au moins 6 caractères.

### utilisateur - profil
1. Un utilisateur, quel que soit son rôle, peut modifier son login, son email et son mot de passe. Après un changement de login, il est déconnecté et doit se reconnecter.
2. Un utilisateur peut supprimer son compte. Ses suivis (webtoonUser) sont supprimés avec lui.
3. Les webtoons qu'il a créés :
   - dépubliés et suivis par personne, ou uniquement par lui (voir webtoons.md, webtoon - base : règle 3) : ils sont supprimés ;
   - publiés, ou dépubliés mais suivis par au moins une autre personne : ils sont attribués au compte « Utilisateur supprimé » (créé à l'installation par `app:create-deleted-user`).
4. Le compte « Utilisateur supprimé » ne peut pas être supprimé.

### utilisateur - administration
1. Seuls les administrateurs ont accès à l'administration des utilisateurs (les modérateurs n'y ont pas accès).
2. Un administrateur peut lister, filtrer et trier les utilisateurs, et voir leurs suivis.
3. Un administrateur peut modifier le login, l'email et le rôle d'un utilisateur (un seul rôle : utilisateur, modérateur ou administrateur).
4. Un administrateur peut envoyer à un utilisateur l'email de mot de passe oublié ou un nouveau lien de vérification, et supprimer son compte.
5. Un administrateur peut activer ou désactiver un compte (user.publish).
6. Le premier administrateur est créé en ligne de commande (`app:create-admin`).

### utilisateur - rôles
1. Trois rôles hiérarchiques : utilisateur < modérateur < administrateur. Chaque rôle a tous les droits du rôle inférieur.
2. Le modérateur a des droits étendus sur les webtoons (voir webtoons.md), mais aucun droit sur les autres comptes.

### utilisateur - données visibles
1. L'email, l'état de vérification et l'état du compte (actif ou non) ne sont visibles que par l'utilisateur lui-même et les administrateurs.
2. Le login, le rôle et les dates (création, dernière connexion) des utilisateurs sont lisibles par tout le monde.
