# Règles métier : extension navigateur

Ces règles valent pour l'extension `dramatoons-browser-extension` (version 2.5.0 et suivantes), commune à Firefox et aux navigateurs Chromium. Les anciennes extensions (`ext-ch`, `ext-ff`, version 2.x) ne sont plus modifiées. Tout ce que faisait l'extension Firefox 2.3 est repris ici, sauf ce qu'une règle change explicitement.

### extension - base
1. L'extension s'utilise sur n'importe quel site : elle surligne, dans la page affichée, les titres des webtoons de la bibliothèque de l'utilisateur, avec leur note et leur dernier chapitre lu.
2. Elle fonctionne de la même façon sur Firefox et sur les navigateurs Chromium (Chrome, Edge…). Elle s'appelle « Dramatoons Highlighter » et garde ses icônes.
3. Elle n'utilise que l'API de Dramatoons : aucune donnée de la page visitée n'est envoyée nulle part.

### extension - fenêtre
1. Un clic sur le bouton de l'extension ouvre sa fenêtre. En haut, le logo et « Dramatoons » ouvrent le site dans un nouvel onglet.
2. Déconnecté, la fenêtre affiche le formulaire de connexion : « Login », « Mot de passe », bouton « Se connecter ».
3. Connecté, elle affiche, dans cet ordre :
   - « Utilisateur : » et le login de l'utilisateur ;
   - « Webtoons suivis : » et le nombre de webtoons de sa bibliothèque, c'est-à-dire de webtoons que l'extension peut surligner ;
   - l'interrupteur « Extension activée : » de l'onglet courant ;
   - le bouton « Rafraîchir : », seulement si l'onglet est activé (voir « liste des webtoons ») ;
   - le bouton « Déconnexion ».
4. Ouvrir la fenêtre fait un seul appel à l'API, `GET /me`, qui donne le login et ce nombre (`total`, compté comme la bibliothèque) : c'est le seul appel fait en dehors d'un onglet activé.
5. Sa présentation (cartes blanches sur fond gris clair, interrupteur et bouton « rafraîchir » verts, bouton de déconnexion rouge) reprend celle de l'extension 2.3.

### extension - connexion
1. L'utilisateur se connecte avec son compte Dramatoons, avec les mêmes règles que sur le site : un compte désactivé (user.publish = 0) ne peut pas se connecter (voir utilisateurs.md).
2. Si la connexion est refusée, la fenêtre affiche le message de l'API (par exemple « Votre compte a été désactivé. »), ou « Identifiants invalides. » si l'API n'en donne pas ; si l'API ne répond pas, « Erreur de connexion au serveur. ».
3. Après la connexion, si l'onglet courant est activé, il est surligné aussitôt.
4. La session se prolonge comme sur le site : à l'expiration du jeton, l'extension le renouvelle seule ; si le renouvellement échoue (session expirée, compte désactivé entre-temps), l'utilisateur est déconnecté et doit se reconnecter.
5. La session est gardée à la fermeture du navigateur : l'utilisateur reste connecté jusqu'à sa déconnexion ou l'échec du renouvellement.
6. La déconnexion efface la session et retire le surlignage de tous les onglets activés.

### extension - activation
1. L'extension s'active onglet par onglet, avec l'interrupteur de sa fenêtre. Un nouvel onglet est désactivé.
2. Tant qu'un onglet n'est pas activé, l'extension n'y fait rien, même si l'utilisateur est connecté : aucun script dans la page, aucun appel à l'API.
3. L'activation surligne aussitôt la page. Déconnecté, l'extension ne surligne rien.
4. Un onglet activé le reste quand on y change de page ou qu'on recharge la page, jusqu'à ce qu'on le désactive ou qu'on le ferme. Chaque nouvelle page de l'onglet est surlignée.
5. La désactivation retire le surlignage de la page.
6. Si l'accès aux sites n'est pas accordé à l'extension (refusé ou retiré par l'utilisateur dans les réglages du navigateur), la fenêtre de l'extension le signale et propose de l'autoriser.

### extension - liste des webtoons
1. Les webtoons surlignés sont ceux de la bibliothèque de l'utilisateur, sans autre filtre (règle identique à la bibliothèque, voir webtoons.md), quel que soit leur état, avec ou sans note ou chapitre lu.
2. La liste est chargée à l'activation d'un onglet et à chaque clic sur « rafraîchir », jamais à chaque page : les pages suivantes de l'onglet utilisent la liste déjà chargée.
3. « Rafraîchir » recharge la liste (après un changement fait sur le site : nouveau suivi, note, chapitre, état, titre), retire le surlignage de la page puis la surligne de nouveau, et met à jour le nombre de webtoons de la fenêtre.

### extension - surlignage
1. Chaque titre d'un webtoon, principal ou secondaire, est cherché dans le texte de la page, de la même façon. Le texte des scripts et des styles n'est pas lu.
2. La recherche ne tient compte ni de la casse, ni des accents, ni de la ponctuation (« solo leveling ragnarok » trouve « Solo Leveling : Ragnarök »).
3. Seuls des mots entiers sont surlignés : « Solo » ne surligne pas le début de « Solomon ». Un titre fait d'un mot courant (« Love », « Home ») est surligné partout où ce mot apparaît.
4. Le titre doit apparaître en entier dans le texte de la page, sauf s'il y est tronqué (règle 5). Un titre que le site coupe seulement à l'affichage (« … » ajouté par la mise en page, texte complet dans la page) est bien trouvé.
5. Un titre tronqué dans le texte de la page est surligné : un texte suivi de « ... » ou « … », qui est le début d'un titre d'au moins 10 caractères (sans compter casse, accents et ponctuation), même coupé au milieu d'un mot (« Solo Leveling: Rag… »). Sans « ... » ni « … » à la fin, un début de titre n'est pas surligné. Si ce début correspond à plusieurs webtoons de la bibliothèque, il est quand même surligné, avec la couleur, la note et le chapitre du premier webtoon par ordre alphabétique.
6. Quand plusieurs titres se chevauchent au même endroit, c'est le plus long qui l'emporte : si la bibliothèque contient « Solo Leveling » et « Solo Leveling : Ragnarok », chacun est surligné là où il apparaît, avec sa propre note et son propre chapitre.
7. Le titre trouvé est surligné tel qu'il est écrit sur la page. La couleur du fond dépend de l'état du suivi, avec les couleurs du site : en cours en bleu, en pause en orange, pas intéressé en rouge, terminé en vert, et en gris si le webtoon n'a pas d'état. Le texte surligné est écrit en blanc, et le curseur prend la forme d'un point d'interrogation à son survol.
8. Juste après chaque titre surligné, une pastille blanche aux bords arrondis, en texte noir, affiche « ⭐ <note> 📌 <chapitre> ». Une valeur absente n'est pas affichée (« ⭐ 8 » ou « 📌 42 » seuls) ; s'il n'y a ni note ni chapitre, il n'y a pas de pastille.
9. Le même texte s'affiche en infobulle au survol du titre surligné, pour les sites qui coupent les titres à l'affichage et cachent ainsi la pastille. Sans note ni chapitre, il n'y a pas d'infobulle.
10. Le texte ajouté à la page après son chargement (défilement infini, page suivante chargée sans recharger l'onglet) est surligné lui aussi, au fur et à mesure, sans clic sur « rafraîchir » ni ralentissement visible de la page.
11. Un titre dans un lien est surligné, et le lien fonctionne toujours. Le surlignage ne change rien d'autre à la page : mise en page, texte des champs de saisie, liens.
