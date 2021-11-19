# Aide pour Docker adapté au projet Stigmee

Projet Stigmee: https://github.com/stigmee

Rappel:
- Image: est un fichier en lecture seule qui contient le code source, les
  bibliothèques, les dépendances, outils ... nécessaires pour faire tourner une
  application.
- Conteneur: est une image accessible en écriture et en cours d'exécution dans
  lequel les utilisateurs peuvent exécuter les applications du système isolé
  sous-jacent.

Tutoriels :
- https://devopssec.fr/article/cours-complet-apprendre-technologie-docker
- [Docker : comprendre l'essentiel en 7 minutes (vidéo)](https://youtu.be/caXHwYC3tq8)
- [Apprendre Docker #2 - Créer ses propres images Docker (vidéo)](https://youtu.be/cWkmqZPWwiw)
- [Docker Tutorial 14: RUN command - Dockerfile (vidéo)](https://youtu.be/aayAPN4iSSE)

Pour plus d'information sur la création des images :
https://devopssec.fr/article/creer-ses-propres-images-docker-dockerfile#begin-article-section

## Téléchargement d'une image depuis https://hub.docker.com

Nous allons télécharger une image déjà prête depuis https://hub.docker.com avec la commande suivante :
```bash
docker pull lecrapouille/stigmee:first
```

Où `first` est un nom de tag qui existe. La liste des autres tags est donnée
[ici](https://hub.docker.com/r/lecrapouille/stigmee/tags). Cette image est celle
d'une Debian 10 modifiée pour les besoins de notre projet.

## Création d'une image

Au lieu de télécharger une préexistante, vous pouvez construire la votre avec
comme tag par défaut `latest`. Voici les étapes :

Télécharger un Dockerfile. Par exemple le notre
[ici](https://github.com/stigmee/bootstrap/blob/master/Dockerfile) et se
déplacer dans le dossier contenant ce fichier :

```bash
cd <path/to/dockerfile>
```

Puis créer une image (que l'on nommera `stigmee`) depuis le dossier contenant le fichier dockerfile :
```bash
docker build -t stigmee .
```

## Utilisation d'une image sur la machine

Une fois l'image créée, on peut lister toutes les images :
```
docker image ls
```

Vous devrez voir quelque chose du genre :
1. Pour une image créé sur la machine
```
REPOSITORY   TAG             IMAGE ID       CREATED             SIZE
stigmee      latest          dfa21ee6f0e5   About an hour ago   1.22GB
```
2. Pour une image téléchargée sur Docker Hub :
```
REPOSITORY             TAG             IMAGE ID       CREATED         SIZE
lecrapouille/stigmee   first           79676430d90d   21 hours ago    1.27GB
```

Créer un conteneur depuis l'image `stigmee` tout en exécutant un interpréteur de commande shell appartenant au container:

1. Pour une image créée depuis votre machine (host) :
```bash
docker run -ti stigmee:latest /bin/bash
```

2. Pour une image téléchargée sur Docker Hub :
```bash
docker run -ti lecrapouille/stigmee:first /bin/bash
```

Les paramètres sont:
- `-t` ou `--tty` : Allouer un pseudo TTY.
- `-i` ou `--interactive` : Garder un STDIN ouvert.
- `/bin/bash` est la commande que l'on veut lancer depuis le Docker, ici le
  `bash` (du container et non pas de votre système d'exploitation).

On voit un prompt où 7f672295fd57 es l'identifiant du conteneur :
```bash
root@173e39f6201e:/workspace#
```

Faire :
```bash
cd / && ls
```

Vous verrez les dossiers :
```
bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var  workspace
root@173e39f6201e:/#
```

Une fois de plus vous voyez le contenu de l'arborescence de votre conteneur et non celle de votre système.

Par défaut Docker tourne en mode `root` (super utilisateur), vous pouvez lui passer vos identifiants utilisateurs:
```bash
docker run -ti -u $(id -u ${USER}):$(id -g ${USER}) lecrapouille/stigmee:first /bin/bash
```

Cela vous sera utile quand vous partagerez un dossier en écriture avec
docker. Sinon vous aurez des fichiers avec des droits `root` et vous devrez
taper le mot de passe root pour les modifier/supprimer.

Tant qu'on n'a pas tapé la commande `exit` dans le bash du conteneur pour
arrêter le conteneur, on peut lister les conteneurs en cours d'exécution, dont
le nôtre, depuis un autre bash de notre machine :

```
docker container ls
```

Possible résultat :
1. Pour une image créé sur la machine
```
CONTAINER ID   IMAGE            COMMAND   CREATED          STATUS          PORTS     NAMES
7f672295fd57   stigmee:latest   "bash"    18 seconds ago   Up 18 seconds             elastic_kalam
```
2. Pour une image téléchargée sur Docker Hub
```
CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS          PORTS     NAMES
33ee7023f7d4   lecrapouille/stigmee:first   "/bin/bash"              59 seconds ago   Up 57 seconds             lucid_jang
```

On peut créer un fichier (à nouveau dans le shell du conteneur) :
```
touch toto
```

Après la commande `exit` dans le conteneur, il se termine et `docker container
ls` on ne le voit plus. Si on relance `docker run -ti stigmee:latest /bin/bash`
le fichier `toto` n'existe plus. En effet, un conteneur est éphémère : il est
créé à partir d'une image et le fichier `toto` n'a pas été créé dans
l'image. C'est pour cela que l'on utilise un dockerfile.


## Partage de votre image sur https://hub.docker.com

Pour transférer votre nouvelle image créée sur votre compte https://hub.docker.com, faire les commandes suivantes :
```
docker login
docker tag stigmee:<tag> lecrapouille/stigmee:<tag>
docker push lecrapouille/stigmee:<tag>
```

avec `<tag>` valant par exemple `first` pour votre première image mise en
ligne.

## Compiler votre code source

Une méthode possible pour compiler votre code est de:
- avoir un docker avec le bon environnement de compilation ainsi que le même
  système d'exploitation que votre machine.
- télécharger votre code source sur votre machine (par exemple git clone).
- de partager votre dossier avec Docker. Docker verra votre code source, il aura
  les bons outils pour le compiler.
- vous pouvez utiliser l'exécutable (mais qui peut échouer si votre
  environnement ne les a pas).

```
cd /mon/dossier/code/source
docker run --rm -ti -v $(pwd):$(pwd) -u $(id -u ${USER}):$(id -g ${USER}) stigmee:latest /bin/bash
```

Toute modification dans vos dossiers partagés dans Docker impacteront
directement vos fichiers sur le système.

## Application graphique depuis Docker

Vous ne pouvez pas lancer d'applications graphiques depuis Docker. Il faut
partager le serveur graphique de votre machine avec Docker. La commande suivante
permet de lancer l'application `xclock` si elle a été installée dans votre image :

```
docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --user="$(id --user):$(id --group)" lecrapouille/stigmee:first xclock
```
