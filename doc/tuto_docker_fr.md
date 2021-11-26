# Introduction rapide à Docker adapté au projet Stigmee

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

Nous allons télécharger une image déjà prête depuis https://hub.docker.com.
- Créer un compte Docker et aller au repository: https://hub.docker.com/r/lecrapouille/stigmee
- Taper la commande suivante (bash ou powershell) :
```bash
docker pull lecrapouille/stigmee:first
Using default tag: latest
latest: Pulling from lecrapouille/stigmee
Digest: sha256:580216370dc62ca1119e5ead8670ca8c1c9183561c38114254c5acc74945680c
Status: Image is up to date for lecrapouille/stigmee:latest
docker.io/lecrapouille/stigmee:latest
```

Où `first` est un nom de tag qui existe. La liste des autres tags est donnée
[ici](https://hub.docker.com/r/lecrapouille/stigmee/tags). Cette image est celle
d'une Debian 10 modifiée pour les besoins de notre projet.

Note: in my case this was already in sync but downloading the image will depend on your connection speed)
You can then start the docker container from that image.

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

# Docker installation for Windows

## Enabling Hyper-V / Compatibility with other paravirtualization layers

For those who are new to docker, after installing the software from https://docs.docker.com/desktop/windows/install/
do not forget :

- Activate Hyper-V support in the Bios (should already by activated on recent platforms)
- enable the Hyper-V feature :

From a PowerSHell command line
```bash
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```
(or alternatively, go to "Enable or disable windows features" and check the Hyper-V group)
(restart your system)

Depending on the configuration, it's still possible that Hyper-V is not enable at that point, in which case Docker will raise an error upon startup.
It that is the case, the following command should solve the issue :
```bash
bcdedit /set hypervisorlaunchtype auto
```
(restart your system)

Note : Docker is not compatible with other virtualisazation subsystem (notably VirtualBox), so note the use of both systems might not be possible depending on which software you are using and which paravirtualized layer it is build on. to be able to use Virtualbox at that point, you will need to disable Hyper-V like so :
```bash
bcdedit /set hypervisorlaunchtype off
```

## Configure Docker storage

If you've got several hard drives installed in your system, it might be advisable to change the location of Docker's virtual storage to avoid filling up your system partition.
For example, the cammands below will transfer the virtual storage to D:\Docker

```bash
C:\Users\Alain>wsl --shutdown

C:\Users\Alain>wsl --export docker-desktop-data docker-desktop-data.tar

C:\Users\Alain>wsl --unregister docker-desktop-data
Désinscription...

C:\Users\Alain>wsl --import docker-desktop-data D:\Docker\ docker-desktop-data.tar --version 2
```
