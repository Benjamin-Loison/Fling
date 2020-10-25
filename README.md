Des précisions sur certaines questions:
---------------------------------------

Question 0: Contrairement à certains camarades je n'ai pas cherché à optimiser la complexité de mes algorithmes en utilisant des structures de données plus ou moins compliqué. J'ai donc choisi un type ball et game qui me semblaient naturel: un Position.t et un ball list. Cependant après avoir constaté des problèmes de changement de couleurs lors de l'utilisation d'apply move j'ai rajouté un identifiant numérique unique à chaque ball.

Question 4: A part si l'objectif est de générer un terrain utilisant un procédé "idiot" comme par exemple à partir d'une balle posée quelque part sur la grille, on génère des balles à gauche, droite, bas, haut à 2 cases de distances lorsque c'est possible jusqu'à en avoir posé N, sans aucune notion de hasard en terme de direction, ni de distance de balles (au lieu de 2). La consigne semble imprécise sur ce point.

Question 7: Le correcteur pourra apprécier la possibilité de copier un terrain donné du dossier terrains (voir les exemples du sujet) dans fling en le renommant dans le dossier principale en "terrain.txt"

Question 8: Il me semblait difficile d'améliorer le rendu d'une balle en elle même puisque l'on travaille déjà avec la représentation 2D des balles: des cercles, contrairement à Neven je n'ai pas miser sur un reflet, mais plus sur un thème: les pokéballs de Pokémon. On remarquera les difficultés (le non-remplissage uniforme) avec la librarie Graphics donnée pour dessiner efficacement une demi-sphère creusée, en utilisant draw_arc dans la fonction draw_ball de draw.ml. Une utilisation d'image PNG ou SVG aurait été appréciée mais la bibliothèque ne semble pas permettre la lecture de telles images depuis des fichiers.

Question 9: La N-ème dimension était un thème alléchant cependant avec le squelette de code donné, il fallait redéfinir les types de bases comme direction dans rules.ml et et les fichiers position.ml* cependant la notion de tuple de dimension donnée semble nécessité une énumération exhaustive dans le code des différentes dimensions disponibles (https://stackoverflow.com/a/26005812). Il aurait alors fallu par exemple travailler avec une int list comme type 't' or cela aurait été très lourd à implémenter et j'ai donc décider de ne pas m'y attarder.

Certaines difficultés:
----------------------

J'ai cherché au début à travailler sous mon environnement Linux cependant des problèmes interminables avec la librarie Graphics, opam etc m'ont forcé à utiliser Windows avec WSL et le serveur graphique Xming.
Faire du débogage avec des print ne fonctionnaient qu'à condition d'utiliser après l'instruction "flush stdout;"

Ayant beaucoup travaillé avec gcc, passer sur un compilateur qui indique en cas de faute syntaxique seulement "Syntax error" alors que gcc dirait plutôt quelque chose comme "Syntax error: was expecting a ')' while found ';'", ce qui a été prise de tête par moment.

Contrairement à par exemple le Java, l'ordre des lignes de code importe, on ne peut pas utiliser quelque chose avant de l'avoir déclaré. De même deux fichiers qui s'utilisent l'un l'autre impliquent une impossibilité de compilation, pour résoudre ce problème j'ai crée deux fichiers antiCircularBuilds*.ml ne trouvant pas de meilleurs manières de faire.

Appendice:
----------

Lorsque le jeu est terminé car la partie est gagnée ou perdue (plus de mouvement possible), le programme s'arrête et affiche dans la console le résultat de la partie. On aurait aussi pu faire un retour au menu comme le fait les options "solve*".

Le correcteur pourra apprécier la possibilité de copier un terrain donné du dossier terrains (voir les exemples du sujet) dans fling en le renommant dans le dossier principale en "terrain.txt"

Le code et ses commentaires ont été rédigés en anglais afin de ne pas tomber dans un "franglais" désagréable à lire

Ligne 117 du game.ml par défaut on remarquera la coquille "resolve the preivous game"
On pourra aussi remarquer que dans le rules.mli ligne 21 "[make_move b d]" tandis que dans rules.ml ligne 15, le b devient un p "let make_move p d ="

La partie animation du déplacement des balles (question 8) et le bonus de la question 3 ont été éludées par manque de temps. Toutefois quelques éléments de réponse pour optimiser le solveur ont été écrits dans solver.ml
On pourra admettre qu'il y a toujours une instabilité sur les couleurs lors de la résolution d'une partie et qu'à partir de l'exemple 6 le solveur met trop de temps...
