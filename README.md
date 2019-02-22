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

### Travail à rendre
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
appel de cette commande il est nécessaire d'utiliser une paire de
clés ssh. De plus, la connection entre les deux machines est effectuée
en root (bien que cela ne soit pas recommandé cela nous a paru
acceptable dans le cadre de l'exercice).

Nous utiliseront le fichier de configuration suivant
(/root/.ssh/config):

```
Host backup
	User root
	Port 22
	Hostname 192.168.33.201 # Backup server ip address
	IdentityFile ~/.ssh/backup-server-key
```

## Mise en place du script
> root@nextcloud:# git clone https://github.com/BasicAcid/sauvegarde

Il faut ensuite éditer la variable "BCK_HOST" des scripts respectifs et
remplacer la valeur par l'utilisateur et l'ip du serveur de backup,
ex: root@192.168.33.201 (ou par le nom d'hote si un sshconfig est
utilisé).

## Fonctionnement
### Backup
Le script de backup fonctionne de telle sorte que seules les données
modifiées ou ajoutées sont synchronisées, cela implique qu'une
sauvegarde complète sera effectuée lors de son premier lancement (ou
lors d'un chagement de semaine).

Nous utilisons la commande "date" pour récupérer une valeur unique se
rapportant à la semaine courante (numéro de la semaine dans l'année).

### Restauration
Le script de restauration commence par supprimer toutes les données
relatives à l'instance, des fichiers à la base de donnée. Il vérifie
cependant qu'il existe au moins une backup sur le serveur, et dans le
cas contraire renvoie un exit 1 avant toute suppression.

Il va ensuite transvaser via rsync la backup la plus récente, puis
créer une nouvelle database vide, et enfin importer le dump.

Des commandes occ de scan et de checks supplémentaires sont ensuite
lancées.

### Remove_old
Ce script supprime la plus vieille backup en date présente sur le
serveur, il suffit donc de l'automatiser pour qu'elle s'exécute tous
les mois (voir plus bas).

### Automatisation
Étant donné que le nom de backup change en fonction des semaine, il
suffit de mettre en place une tache cron tous les jours pour répondre
à la problématique, car une sauvegarde complète sera effectuée à
chaque nouvelle semaine:

0 0 * * * backup.sh

Il faut ensuite utiliser une seconde tâche pour supprimer la dernière
backup à la fin de chaque mois:

0 0 31 * * remove_old.sh
