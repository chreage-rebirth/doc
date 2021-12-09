# Petite introduction à GitHub et aux commandes Git pour le projet Stigmee

Après plusieurs années à utiliser git qui est un outil assez compliqué à
appréhender pour le novice, je propose ici un petit tutoriel où vous pourrez
utiliser git efficacement car, tout compte fait, pour le travail de tous les
jours, seule une poignée de commandes est réellement nécessaire à connaître :
certaines commandes seront à faire à la main (comme `git clone`, `fetch`,
`pull`, `rebase`), d'autres commandes seront à faire via une IHM, interface
homme machine, (comme `add`, `push`, `cherry pick`).  N'étant pas un puriste de
la ligne de commande, je préfère mélanger commandes manuelles et commandes via
IHM pour plus de souplesse.

## Notion de Git

Dans un projet informatique, qu'il soit fait par une seule personne ou par un
ensemble de personnes, on aime garder un historique de nos modifications
passées, car en cas de régression (une fonctionnalité que l'on casse dans notre
logiciel en cours de développement), on souhaite pouvoir revenir en arrière afin
de retrouver notre code source avant la régression. De plus si plusieurs
personnes travaillent ensemble on souhaite également avoir de la souplesse comme
éviter d'avoir des conflits dans les fichiers modifiés, permettent à des
personnes non connectées au serveur de gestion de continuer à travailler.

C'est là qu'intervient git, développé par Linus Torvalds afin de pallier le peu
de souplesse qui offrait les gestionnaires de version comme SVN ou CVS. Git fut
rapidement développé et des serveurs comme GitHub, GitLab ... permettent
d'héberger vos projets.

Dans ce document j'appelle un `commit` la modification/changement atomique d'un
ou plusieurs fichiers à un instant donné. Les fichiers ne sont pas
nécessairement du code source pour un projet informatique, mais doivent être
idéalement être du texte. Un commit ne contient que les lignes modifiées et non
pas le fichier dans son ensemble. C'est ce que l'on nomme un `patch`. Ceci nous
rappelle pourquoi il est important de commiter des fichiers textes et non pas
des fichiers binaires (pdf, dll, exécutables ...). Si l'on désire commiter de
(gros) fichiers binaires, il faudra utiliser `git lfs` (que je ne maitrise pas
encore). Un commit contient également un titre et une description des
modifications apportées donc des informations utiles pour vos collègues afin de
comprendre votre modification (ou vous en souvenir plusieurs mois après). Chaque
commit à un identifiant unique sur 40 caractères comme
`9384d10e23407cb2284dfb03e0a3cc38a02b73e8` appelé SHA1 (nom tiré de l'algorithme
du même gabarit que md5sum ou crc32). Un historique git est un ensemble
chronologique de commits faits par une ou plusieurs développeurs. C'est alors un
ensemble de patchs qui sont automatiquement appliqués les uns sur les autres
(comme une pile d'assiettes).

Une notion importante dans git est la notion de branches locales et de branches
distantes. Une branche contient un ensemble de commits. Par défaut une branche
principale nommée `master` (ou `main` sur GitHub pour des raisons
polito-sociales) est créée pour vous. Vous pouvez créer autant de branches que
vous le désirez. En général `master` contient des `commit` bons qui ne
provoquent, idéalement, jamais de régressions, c'est une branche prête pour
créer des livrables (`releases`) de votre projet. Une branche `develop` peut
exister et contient le code instable qui peut provoquer des régressions. Des
branches `dev-ma-feature1`, `dev-ma-feature2` peuvent exister afin qu'un
développeur puisse sereinement développer une nouvelle fonctionnalité au
logiciel. Quand il aura fini il ira fusionner (`merge`) sa branche avec celle de
`develop`. Quand `develop` aura reçu plusieurs fonctionnalités, vous pouvez la
fusionner dans la branche `master`. Quand votre programme devient gros, vous
pouvez avoir à maintenir plusieurs versions de votre logiciel par exemple les
versions `v3.4` et `v4.0`. Git propose aussi des `tags` à savoir des étiquettes
pouvoir nommer un SHA1 particulier par exemple `v3.4-stable`.

Quand vous faites des modifications sur les fichiers de votre projet, elles se
font en deux temps : d'abord vous les commitées sur votre branche `locale` à
savoir sur votre ordinateur puis, dans un deuxième temps, quand un ensemble de
commits vous semble bons, vous pouvez les commiter sur le serveur distant (par
exemple GitHub). Vous pouvez retravailler autant de fois que vous le souhaitez
votre branche locale (`git rebase`) avant de les pousser sur la branche
distante. Une fois présents sur la branche distante (donc disponible sur le
serveur comme, par exemple, sur GitHub) il est mal vu d'y retravailler, car
d'autres personnes peuvent, entre temps, avoir récupéré vos modifications et
auront donc des conflits à résoudre dans votre code (qui aura changé par rapport
à eux). Git généralise l'idée de branche distante. Vous pouvez avoir plusieurs
serveurs distants et séparés. Ils auront des commits et des branches différents
(par exemple le serveur git de votre entreprise ou des serveurs de diverses
organisations). Ils pourront éventuellement être vus comme des locaux pour
d'autres serveurs distants (par exemple GitHub).

Enfin git, vous permet de travailler sur plusieurs repository en même temps.  Le
votre par défaut se nommera `origin` et le repo d'origine `upstream` (mis à
jour). Ceci par exemple vous permet de travailler sur un `fork` d'un projet
GitHub tout en traquant les modifications du projet d'origine.

![gitk](tuto_git_fr_01.png)

Dans la figure suivante, `remote/origin/master` indique le dernier état connu de
la branche `master` distante sur le repo nommé `origin` (qui est pour ce
document https://github.com/stigmee/doc). Le dernier commit a pour titre *Update
CI doc* alors que sur notre branche `master` locale nous avons faits deux
commits: *Add git tutorial* et *Update README*. Ce dernier a pour identifiant
unique SHA1 `7fb29f070fc02adab998560504b5bf6a45b57cd5`. En vert (+) et rouge (-)
le patch concernant l'unique fichier modifié README.md. En vert les lignes qui
ont été ajoutées alors qu'en rouge les lignes qui ont été supprimées.

## Les outils importants

Voici une liste d'outils git que j'utilise tous les jours: `git`, `gitk`,
`git-cola`, `meld`, `emacs` (et son package magit.el). Ils s'installent via
`apt-get install` pour Linux, `homebrew` pour Mac OS X. gitk est directement
inclus avec git. Pour le package Emacs il vous faudra utiliser le serveur
MELPA. Vous pouvez évidement utiliser d'autres outils tel que git-gui, gitamine,
kraken ...

- `meld` n'est pas un outil git, mais il permet de comparer des fichiers et de
  les fusionner. Il permet aussi de comparer deux dossiers (récursion sur les
  fichiers modifiés) mais aussi sur vos modifications git en cours (par rapport
  au dernier commit). meld permettra surtout de résoudre des conflits de merge
  (par exemple si vous étiez en train de modifier un fichier code source pour
  ajouter de nouvelles fonctions alors qu'un de vos collègues vient de commiter
  des modifications sur ce fichier et dans la même fonction que vous). Une
  alternative à meld est `beyond compare` (mais sous licence payante).

![meld](tuto_git_fr_02.png)

- `gitk` permet de voir l'historique de vos commits sur votre branche
  actuelle. `gitk --all` permet de voir l'historique de vos commits sur toutes
  les branches (locales et distantes). gitk est utile pour ajouter un tag sur un
  commit particulier ou bien créer une branche temporaire afin de ne pas perdre
  un ensemble de commits si vous désirez retravailler vos branches. Un dernier
  usage de gitk est de cueillir des cerises (cherry pick) à savoir récupérer un
  commit particulier d'une autre sur votre branche courante. Une alternative à
  `gitk` est `gitamine` car il afficherait un graphe des commits plus clair.

![gitk](tuto_git_fr_01.png)

- `git-cola` vous évitera de taper à la console des `git add`, `git commit` et
  `git push`: il suffira de cliquer sur leurs noms. git-cola permet aussi de
  commiter des portions de fichiers ce qui est utile pour faire plusieurs petits
  commits "atomiques". Une fois les fichiers sélectionnés, vous pouvez les
  commiter sur votre branche git locale (cela correspond à la commande `git
  commit`). Il vous faudra avant Mettre un titre à votre commit ainsi qu'une
  description de vos modifications (afin d'aider vos collègues à comprendre
  votre commit). Si vous cliquez et que vous avez réalisé que votre commit
  contenait une erreur. Vous pouvez corriger votre dernier commit local via
  `git-cola --amend`. Une alternative à git cola est `git-gui`. git-cola permet
  aussi de commiter toutes vos commits locaux sur la branche
  distante. Personnellement, je n'utilise plus que cet outil et ne tape plus
  aucune commande dans la console.

![gitcola](tuto_git_fr_03.png)

- Si vous voulez modifier des commits anciens sur votre branche locale,
`git-cola --amend` ne peut plus vous aider (que l'on détaillera plus loin dans
ce document) et il faudra donc utiliser `git rebase` qui ouvrira mon Emacs qui
lui appeler son package magit. Je suis tellement fan de magit que je ne sais pas
utiliser un autre outil. Par exemple, dans la figure suivante, je veux
retravailler sur les 5 derniers commits locaux.

![magit](tuto_git_fr_04.png)

Magit m'affiche les commits dans l'ordre inverse et me propose d'éditer mes
commits en sélectionnant une action sur chaque commit (ne rien faire, modifier
un commit, renommer un titre, fusionner ou changer l'ordre des commits.

## Configuration de votre environnement de travail

Pour utiliser git, sinon il vous embêtera, il faut d'abord le configurer pour
ajouter votre nom et email en tapant dans une console bash :

```
git config --global user.name "John Doe"
git config --global user.email johndoe@example.com
```

On peut aussi le faire en éditant le fichier `~/.gitconfig`. N'ayez pas peur
d'afficher votre véritable nom et adresse email afin que l'on puisse vous
contacter. GitHub, par défaut masquera votre adresse email mais pas votre nom.

Pensez à configurer tout de suite git-cola pour lancer vos éditeurs
préférés. Dans mon cas :
- éditeur de code : `emacs`
- Fusion de fichiers : `meld`.

git-cola va modifier votre fichier `~/.gitconfig`.

## Création d'un projet git

Se fait via la commande `git init` mais le plus simple est de créer un repo
depuis GitHub en cliquant sur le bouton `+` puis `Create new repository` comme
sur la figure suivante :

![createrepo](tuto_git_fr_05.png)

- Ajouter une licence. Pour Stigmee ce sera `GNU General Public License v3.0`.

- Ajouter un fichier `.gitignore` prédéfini pour filtrer les fichiers à ne pas
commiter (vous ne les verrez plus apparaître dans git-cola). Par exemple :

```
*~
build/
*.o
```

Permet d'ignorer les commits de tous les fichiers de sauvegarde ayant pour
dernier caractère le symbole `~` (n'importe où dans les dossiers). De ne pas
prendre le dossier et son contenu `build`, de ne pas commiter les fichiers C
compilés (fichier objets).

- Ajouter un fichier README au format Markdown. Personnellement je ne l'ajoute
pas personnellement, car je préfère l'éditer avec mon éditeur de texte préféré
puis de le commiter (donc en deux temps).

## Git cloner, prendre en compte les modifications de vos collègues

Rapatrier le repository git. Cliquez sur le bouton vert comme sur la figure
suivante :

![gitclone](tuto_git_fr_06.png)

**Ne jamais prendre le zip** car il ne contient pas le .git et ne contiendra pas
le code source des sous-modules git (si vous en avez créés). Deux options : git
clone via https ou via ssh. La seconde est la plus sure, c'est celle que
j'utilise mais nécessitera de créer une clef ssh sur votre ordinateur
https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent. La
première est plus simple pour tout ce qui est pour vos scripts shell et
procédures pour les intégrations continues. Si vous avez une clef ssh et que
vous avez git cloné via https, vous ne pourrez pas pousser vos commits git il
vous faudra changer l'url de votre repo (donc git clonez avec la bonne option) :

```
git clone git@github.com:stigmee/doc.git
```

Cette commande est à faire une seule fois. Pour se mettre à jour afin de suivre
les modifications de vos collègues (branches distantes) faire :

```
git fetch --all
```

Pour mettre à jour les modifs des autres collègues avant de commiter sur la
branche distance, il faudra de temps en temps (mais surtout juste avant de
pousser vos modifs sur la branche distante) récupérer les modifications devos
collègues sur votre branche locale:
```
git pull --rebase origin master
```

A adapter `master` par le nom de votre branche locale.

## Branches

Pour voir toutes les branches (locales et distances) existantes ainsi que la
branche sur laquelle vous êtes actuellement placé :

```
git branch --all
```

Pour créer et sauter sur une nouvelle branche:
```
git branch -b ma-nouvelle-branche
```

Pour sauter sur une autre branche:
```
git branch mon-autre-branche
```

Pour rappel, le but des branches est de permettre aux développeurs de travailler
sur leurs "features" tranquillement dans leur coin (un travail qui peut prendre
des semaines/mois) sans avoir de conflits directs avec ses collègues concernant
des fichiers modifiés. A la fin du travail il faut fusionner (merge) les
branches. Supposons que vous êtes sur la branche `develop` et que vous voulez
merger la branche `dev-feature1` :

```
git merge --ff dev-feature1
```

Ou bien :

```
git merge --no-ff dev-feature1
```

La différence d'option est ![gitmerge](https://webdevdesigner.com/images/content/9069061/66cbfdbf8a05fd1bae8b88159da7974e.png)

## Modifier votre code, branche locale et branche distante

Le plus simple est d'utiliser :
- `git cola` pour commiter vos modifications locales (bouton `commiter`) puis
  distantes (bouton `pousser`).
- `git cola --amend` pour corriger votre dernier commit.
- `git rebase -i HEAD~5` pour corriger les commits parmi les 5 derniers. `git
rebase -i --root` pour corriger le premier commit. Cela appellera, chez moi,
Emacs. Editez les commandes pour chaque commit avec les touches suivantes :
- `e` (edit) pour modifier les fichiers commités (en combinaison avec `git cola
  --amend` pour la modification).
- `r` (reword) pour modifier le titre ou le commentaire.
- `k` (kill) pour supprimer un commit.
- `s` (squash) pour fusionner le commit avec le commit parent (celui qui est une
  ligne au-dessus).
- `p` et `n` pour changer l'ordre des commits (attention aux possibles conflits
  qui faudra gérer via l'outil meld ou bien abandonné en tapant `git rebase
  --abord`).

Après chaque fichier retravaillé, il faut taper `git rebase --continue` dans la
console pour travailler sur le commit suivant. En cas de soucis tapez `git
rebase --abort` pour revenir dans l'état d'avant votre tentative de rebase.

Vous avez plein de modifications locales et que vous voulez faire un rebase, git
refuse, car vous perdriez vos modifications non sauvegardées. Commitez les ou
bien faites une sauvegarde :
```
git stash
```

Puis, pour les récupérer:
```
git stash
```

## Reset et blame

Vous avez fait n'importe quoi (plein de commits locaux), vous voulez vous
remettre dans l'état original. Via gitk, créér une branche temporaire puis faites un:
```
git reset
```

ou bien revenir sur le bon SHA1:

```
git reset --hard <SHA1>
```

Vous venez de perdre vos modifs ? Vous allez vous imomller sur votre bureau en
guise de protestation ? Avant de craquer une allumette, sachez que git
sauvegarde son état après chaque commande. Du coup tentez un :

```
git reflog
```

suivi d'un des SHA1
```
git reset --hard <SHA1>
```

Sauvé ? Gardez vos allumettes et votre jerrycan pour trouver une autre victime,
nous allons trouver un développeur fautif sur la dernière régression constatée
par l'équipe de validation :
```
gitk <fichier>
git blame <fichier>
```

La première commande, vous montre l'historique du fichier désiré. La deuxième
montre le SHA1 et le nom de la dernière personne pour chaque ligne du fichier.
Vous avez trouvé le fautif ? Si oui, j'ai ricane, sinon retrouvez votre victime
en cherchant le commit fautif par dichotomie :

```
git bisect
```

git vous demandera un commit où votre programme fonctionne et un autre commit où
votre programme ne fonctionne plus. Par itération dichotomique vous allez tester
les commits et vous rapprocher de votre future victime.

## GitHub Pull request

Permet d'éviter de commiter directement dans le projet mais va proposer une page
GitHub intermédiaire (onglet pull request) qui permettra de faire un "code
review" à savoir une revue de code. Le(s) responsable(s) du projet valideront le
commit et l'auteur pourra reprendre sont travail jusqu'à son acceptation. Un des
auteurs commitera les modifications avec la possibilité d'options comme la
fusion des commits intermédiaires, un merge ...

Pour cela il faut cloner le repository GitHub (bouton `fork`), commiter vos
modifications sur votre nouveau repository cloné puis sur GitHub cliquer sur le
bouton "proposer un pull request", de préférence évitez de commiter sur la
branche `master` du projet (sait on jamais une régression est si vite arrivée)
mais sur une branche temporaire (`dev-xxx`).

## Remote

Cette section peut être ignorée dans un premier temps. Si vous avez cloné un
projet GitHub et que vous voulez suivre les évolutions pour éventuellement
proposer d'autres pull request:

```
git remote add upstream URL
```

Où `URL` est l'url du projet parent GitHub et `upstream` est le nom désiré.

```
git remote -v
git fetch --all
```
