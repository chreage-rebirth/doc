# Rappel comment on link une bibliothèque dynamique

Voir ce lien : https://www.cs.swarthmore.edu/~newhall/unixhelp/howto_C_libraries.html

Pour compiler une bibliothèque dynamique :

On commence par compiler un fichier `File.cpp` qui donnera la sortie suivante (les `...` est que je masque les choses inutiles) :
```bash
g++ ... -fPIE -fPIC -Ibuild -I./include -I./src -c /home/qq/MyGitHub/MyLogger/src/File.cpp -o /home/qq/MyGitHub/MyLogger/build/File.o
```

Et la création de la bibliothèque dynamique utilisant ce fichier (link):
```bash
g++ -pie -shared -o libmylogger.so.0.1 File.o ...
```

Explications :
- `-I` sont les includes. Sert à indiquer où sont les fichiers headers (*.h, *.hpp).
- `-fPIE -fPIC` et `-pie -shared` pour compiler et linker une bibliothèque dynamique.
- `-c` le fichier à compiler et `-o` le fichier compilé ou la bibliothèque dynamique.

Dans `/home/qq/MyGitHub/MyLogger/build` une bibliothèque dynamique a été créée. On peut voir les symboles (fonctions et méthodes compilées).
```bash
nm /home/qq/MyGitHub/MyLogger/build/libmylogger.so.0.1
```

Par exemple :
```
                 U _ZTVSt15basic_streambufIcSt11char_traitsIcEE@GLIBCXX_3.4
                 U _ZTVSt9basic_iosIcSt11char_traitsIcEE@GLIBCXX_3.4
000000000000bbe0 d _ZZN4tool3log6Logger13severityToStrERKNS0_8SeverityEE12c_severities
000000000000c2e0 b _ZZN4tool3log7ILogger17timeAndDateFormatEPKcE6buffer
```

Explications :
- `d` sont les symboles définis. Un symbole est soit une fonction, soit une méthode, soit une variable globale. On remarquera qu'en C++, par rapport à C, il y a des caractères bizarres en plus comme `_ZTVSt15`. On les appelle *mangling* (décoration de nom). Ils définissent des types et permettre ainsi à C++ le polymorphisme (même nom de fonction, mais différents types pour les arguments). En C ces symboles ne sont pas présents et par conséquent les symboles C et C++ ne sont pas compatibles. Il faudra penser à mettre un `extern "C" {`. Pour décoder les manglings il faut ajouter l'option `-C` (soit `nm -C /home/qq/MyGitHub/MyLogger/build/libmylogger.so.0.1`), vous verrez apparaître les noms des classes, les `namespaces` (si vous oubliez un de ces derniers vous aurez une erreur `undefined symbol`),  etc.
- `U` sont les symboles non définis. Si vous chargez votre bibliothèque dynamique vous aurez une erreur de link car le symbole est manquant. En général le symbole est présent dans une autre bibliothèque dynamique qui sera, elle aussi, linké dans votre programme exécutable.

Maintenant, utilisons notre bibliothèque dynamique pour en faire un exécutable. Je crée un fichier `main.cpp`. On suppose que la classe `File` a une méthode `qq` qui prend en argument une chaine de caractère et en ressort une autre :
```C
#include "MyLogger/File.hpp"
#include <iostream>

int main()
{
   File f;
   std::cout << f.qq("/foo/bar/ffooo.txt") << std::endl;
   return 0;
}
```

Je supposerai ici que g++ connait le chemin vers `MyLogger/File.hpp`: il suffit d'ajouter `-Imon/chemin`. Ce qui m'intéresse ici, c'est l'inclusion de la bibliothèque.

- Façon 1 la méthode facile : on met le chemin en dur.
```bash
g++ main.cpp /home/qq/MyGitHub/MyLogger/build/libmylogger.so.0.1 -o prog
```

- Façon 2 la méthode avec `-L` qui indique un chemin (on peut en combiner plusieurs) et `-l` qui remplace le préfixe `lib`.
```bash
g++ main.cpp -L/home/qq/MyGitHub/MyLogger/build/ -lmylogger -o prog
```

- Façon 3 sans `-L`:
```bash
g++ main.cpp -lmylogger -o prog
/usr/bin/ld : ne peut trouver -lmylogger
collect2: error: ld returned 1 exit status
```

Oups gcc n'a pas trouvé la bibliothèque dynamique. On va l'aider (sur bash):

```bash
export LD_LIBRARY_PATH="/home/qq/MyGitHub/MyLogger/build/:$LD_LIBRARY_PATH"
g++ main.cpp -lmylogger -o prog
```

TODO: à retester ça ne fonctionne pas :(

# Complément : fonctions faibles et fonctions fortes

Quand vous définissez une fonction C, par exemple le fichier `main.c`:
```C
#include <stdio.h>

int foo(int v)
{
   printf("Val: %d\n", v);
   return v;
}

// gcc -W -Wall main.c -o prog && ./prog
int main()
{
   return foo(42);
}
```

`foo` est une fonction implicitement dite *forte*. Si vous définissez une autre fonction `foo` le compilateur arrêtera la compilation avec une erreur du genre `foo est déjà définie`. En effet, il est impossible d'avoir deux fonctions fortes, car le compilateur ne sait pas laquelle utiliser.
Si on exécute ce programme il affichera sur la console `Val: 42` ainsi que le code d'erreur `42`.

Si vous ajoutez `__attribute__((weak))` alors la fonction devient faible. Une fonction faible est fonction qui peut se faire remplacer par une fonction forte du même prototype.

- Fichier `foo.c`:
```C
#include "foo.h"
#include <stdio.h>

__attribute__((weak)) int foo(int v)
{
   printf("Val: %d\n", v);
   return v;
}
```

- Fichier `foo.h`:
```C
#ifndef FOO_H
#define FOO_H

__attribute__((weak)) int foo(int v);

#endif
```

- Fichier `main.c`:
```C
#include <stdio.h>

int foo(int v)
{
   printf("Coucou: %d\n", v);
   return 1;
}

// gcc -W -Wall main.c foo.c -o prog && ./prog; echo $?
int main()
{
   return foo(42);
}
```

Si on exécute ce programme `./prog; echo $?`il affichera sur la console `Coucou: 42` ainsi que le code d'erreur `1` (et non pas `Val: 42` et le code de retour `42`). Par contre, si le compilateur détecte deux fonctions faibles du même prototype il arrêtera la compilation avec une erreur du genre `foo est déjà définie`. En effet, il est impossible d'avoir deux fonctions faibles, car le compilateur ne sait pas laquelle utiliser.

Quelle est l'utilité des fonctions faibles ? Il y en au moins trois :
- La première utilité ne nous concernera pas pour ce projet, mais dans les systèmes temps réel pour définir la table d'interruption. Les fonctions faibles définissent un comportement par défaut. Le développeur peut définir les siennes dans un autre fichier pour définir un autre comportement sans avoir à modifier le fichier de la table d'interruption. Il y aura deux symboles un faible et un fort.
- La seconde utilité qui nous intéresse est que tous les symboles issus des bibliothèques dynamiques sont faibles. Par exemple les fonctions POSIX du genre `printf`, `open`, `read` ... sont faibles et peuvent être redéfinies (à vos risques et périlles). `ssize_t read(int fd, void *buf, size_t count) { printf("pouet\n"); return -1; }`
- La troisième utilité dérive de la seconde : il est possible de faire des tests unitaires en mockant ces fonctions, mais vu que cela demande de bonnes connaissances sur `dlopen`, C++ et Google test cela dépasse le cadre de cet article. J'expliquerai comment faire dans un autre article.
