# Docker Brave

Docker Chréage:
https://hub.docker.com/repository/docker/lecrapouille/chreage

Rappel:
- Image: est un fichier en lecture seule qui contient le code source, les bibliothèques, les dépendances, outils ... nécessaires pour faire tourner une application.
- Conteneur: est une image accessible en écriture et en cours d'exécution dans lequel les utilisateurs peuvent isoler les applications du système sous-jacent.

Tutoriels :
- https://devopssec.fr/article/cours-complet-apprendre-technologie-docker
- [Docker : comprendre l'essentiel en 7 minutes (vidéo)](https://youtu.be/caXHwYC3tq8)
- [Apprendre Docker #2 - Créer ses propres images Docker (vidéo)](https://youtu.be/cWkmqZPWwiw)
- [Docker Tutorial 14: RUN command - Dockerfile (vidéo)](https://youtu.be/aayAPN4iSSE)

Pour plus d'information sur la création des images :
https://devopssec.fr/article/creer-ses-propres-images-docker-dockerfile#begin-article-section


## Téléchargement d'une image de Docker Hub
```
docker pull lecrapouille/chreage:<tag>
```
avec <tag>=first par exemple, cf. les [tags existants](https://hub.docker.com/r/lecrapouille/chreage/tags)


## Création d'une image
Voici les étapes pour obtenir l'image taguée "first" sur le Docker Hub :

Télécharger le dockerfile [ici](https://github.com/Lecrapouille/bacasablechreage/blob/master/brave/Dockerfile) et se déplacer dans le dossier contenant ce fichier:
```
cd <path/to/dockerfile>
```

Créer une image (que l'on nommera `chreage`) depuis le dossier contenant le fichier dockerfile :
```
docker build -t chreage .
```


## Utilisation d'une image sur la machine
Lister les images :
```
docker image ls
```

Vous devrez voir quelque chose du genre :
1. Pour une image créé sur la machine
```
REPOSITORY   TAG             IMAGE ID       CREATED             SIZE
chreage      latest          dfa21ee6f0e5   About an hour ago   1.22GB
```
2. Pour une image téléchargée sur Docker Hub
```
REPOSITORY             TAG             IMAGE ID       CREATED         SIZE
lecrapouille/chreage   first           79676430d90d   21 hours ago    1.27GB
```

Créer un container depuis l'image `chreage` tout en exécutant bash (`-t`: allouer un pseudo terminal virtuel et `-i` pour garder les entrées tapées au clavier, `/bin/bash` est le bash du container et non pas de votre système d'exploitation) :
1. Pour une image créé sur la machine
```
docker run -ti chreage:latest /bin/bash
```
2. Pour une image téléchargée sur Docker Hub
```
docker run -ti lecrapouille/chreage:first /bin/bash
```

On voit un prompt où 7f672295fd57 es l'identifiant du conteneur :
```
root@7f672295fd57:/Chreage#
```

Faire :
```
ls
```

Vous verrez le dossier :
```
brave-browser
```

Tant qu'on n'a pas tapé la commande `exit` dans le shell du conteneur pour arrêter le conteneur, on peut lister les conteneurs dont le nôtre en cours d'exécution depuis un shell de notre machine :
```
docker container ls
```

Possible résultat :
1. Pour une image créé sur la machine
```
CONTAINER ID   IMAGE            COMMAND   CREATED          STATUS          PORTS     NAMES
7f672295fd57   chreage:latest   "bash"    18 seconds ago   Up 18 seconds             elastic_kalam
```
2. Pour une image téléchargée sur Docker Hub
```
CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS          PORTS     NAMES
33ee7023f7d4   lecrapouille/chreage:first   "/bin/bash"              59 seconds ago   Up 57 seconds             lucid_jang
```

On peut créer un fichier (à nouveau dans le shell du conteneur) :
```
touch toto
```

Après la commande `exit` dans le conteneur, il se termine et `docker container ls` on ne le voit plus. Si on relance `docker run -ti chreage:latest /bin/bash` le fichier `toto` n'existe plus. En effet, un conteneur est éphémère : il est créé à partir d'une image et le fichier `toto` n'a pas été créé dans l'image. C'est pour cela que l'on utilise un dockerfile.


## Partage d'une image sur dockerhub
Pour une image créée sur la machine
```
docker login
docker tag chreage:<tag> lecrapouille/chreage:<tag>
docker push lecrapouille/chreage:<tag>
```
avec `<tag>=first` par exemple pour votre première image mise en ligne

## Chreage

```
docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --user="$(id --user):$(id --group)" lecrapouille/chreage:first
```
