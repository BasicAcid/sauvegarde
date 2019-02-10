# Sauvegarde Cloud

## Description du travail à effectuer
Vous devez mettre en place la sauvegarde de cette application de la
manière la plus efficace possible en considérant que le volume de
données peut devenir très important.  De plus, vous devrez permettre
une historisation de ces sauvegardes avec une durée de rétention de 30
jours.  Vous sauvegarderez bien évidemment les fichiers aussi bien que
la base de données de manière à ce qu’une restauration soit
parfaitement possible.  Vous planifierez cette sauvegarde de manière à
ce qu’elle s’effectue de manière totalement automatique, le plus
fréquemment possible et en mettent en application les bonnes pratiques
étudiées en cours.

## Travail à rendre
Vous enverrez l’ensemble des scripts ainsi qu’une procédure simplifiée
d’utilisation et de restauration de votre système par mail à l’adresse suivante:
anthony@avalone-fr.com
La date limite de remise est fixé au 22 février 2019.

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

Nous utiliseront le fichier de configuration suivant
(/root/.ssh/config):

Host backup
	User root
	Port 22
	Hostname 192.168.33.201
	IdentityFile ~/.ssh/backup-server-key
