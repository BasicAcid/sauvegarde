# Sauvegarde Cloud

## Notes concernant l'installation
Le sujet du TP ne concernant les éventuelles modifications des
machines virtuelles fournies, nous nous contenteront d'expliquer la
démarche à suivre pour utiliser le(s) script(s) (cela à défaut de
fournir un script supplémentaire d'installation).

Le script utilise rsync pour synchroniser les données d'une machine à
l'autre, aussi pour ne pas avoir à entrer le mot de passe à chaque
appel de cette commande il est necessaire d'utiliser une paire de
clés ssh. De plus, la connection entre les deux machines est effectuée
en root (bien que cela ne soit pas recommandé cela nous a paru
acceptable dans le cadre de l'exercice).
