# Ajouter un module Chromium Embedded Framework à Godot

Comment modifier les sources de Godot version 3-stable (à voir pour Godot
V4-instable) pour ajouter un nouveau type de nœud pour le graphe de scène (aussi
nommé scene graph ou scene tree) afin de faire un nœud pour
[CEF](https://bitbucket.org/chromiumembedded/cef/src/master/). Pour ceux qui
veulent savoir comment fonctionne un graphe de scène voir ce
[lien](https://research.ncl.ac.uk/game/mastersdegree/graphicsforgames/) et
sélectionner l'article Scene Graphs.

Pour le moment, c'est pour savoir si c'est réalisable. Dans un deuxième temps,
il sera nécessaire de faire un point d'architecture pour voir comment ce nœud
pourra servir pour le fonctionnement de Stigmee.

Les sources de Godot sont ici :
[https://github.com/godotengine/godot](https://github.com/godotengine/godot). La
définition de la classe mère d'un nœud graphe de scène est ici :
[https://github.com/godotengine/godot/tree/master/scene/main](https://github.com/godotengine/godot/tree/master/scene/main). Par
exemple le nœud HTTP Request dont la doc est décrite sur ce
[lien](https://docs.godotengine.org/fr/stable/tutorials/networking/http_request_class.html)
son [code
source](https://github.com/godotengine/godot/blob/master/scene/main/http_request.cpp)
et son
[header](https://github.com/godotengine/godot/blob/master/scene/main/http_request.h).

On pourrait penser à ajouter nos fichiers dans ce répertoire pour créer notre
propre nœud, mais le plus simple est de suivre est de suivre la procédure
décrite ici :
https://docs.godotengine.org/fr/stable/development/cpp/custom_modules_in_cpp.html

Je fais un résumé adapté pour Stigmee.

## Télécharger Chromium Embedded Framework

Tout d'abord je télécharge une CEF déjà compilé (car c'est une plaie à compiler):
https://cef-builds.spotifycdn.com/index.html

Et je décompresse l'archive à l'endroit de votre choix. Pour ce document
`/home/qq/chreage_workspace/built_CEF/`

## Créer son module Godot v3

Il faut créer un dossier que l'on nommera, par exemple, `cef` dans le dossier
`godot/modules`. On prendra soin d'éviter de créer des conflits de noms entre
votre module est celui de CEF.

Il vous faudra au minimum, les fichiers suivants (Le nom des fichiers
`proxy_cef.cpp` et `proxy_cef.h` est laissé libre) :
- proxy_cef.cpp
- proxy_cef.h
- register_types.cpp
- register_types.h
- SCsub
- config.py

**Fichier register_types.h**

Il faut ajouter ces deux fonctions afin que notre future classe C++ `ProxyCEF`
pour notre module doit être enregistrée par Godot. Le terme `cef` doit référer
au nom de votre dossier.

```
#ifndef STIGMEE_CEF_REGISTER_TYPES_H
#define STIGMEE_CEF_REGISTER_TYPES_H

void register_cef_types();
void unregister_cef_types();

#endif // STIGMEE_CEF_REGISTER_TYPES_H
```

**Fichier register_types.cpp**

```
#include "register_types.h" // Godot
#include "core/class_db.h" // Godot
#include "proxy_cef.h" // Notre module

void register_cef_types()
{
   ClassDB::register_class<ProxyCEF>();
}

void unregister_cef_types()
{}
```

**Fichier config.py**

C'est un fichier de configuration du module, c'est un simple script python. Le
code minimal est:
```
def can_build(env, platform):
    return True

def configure(env):
    pass
```

**Fichier proxy_cef.h**

Pour le moment, c'est une classe vide qui ne fait rien avec CEF (à suivre). Pour
le moment elle se contente d'utiliser des symboles de CEF. Le fichier header
contient notre classe proxy CEF. Notre classe hérite de Godot soit d'un nœud,
soit d'une référence, soit d'une ressource.

```C
#ifndef STIGMEE_CEF_H
#define STIGMEE_CEF_H

#include "scene/main/node.h" // Godot
#include "include/cef_app.h" // libCEF

class ProxyCEF :
   // Godot
   public Node, // ou Reference ou Resource
   // libCEF
   public CefApp, public CefBrowserProcessHandler
{
    GDCLASS(ProxyCEF, Node); // Godot

public:

    ProxyCEF(); // Constructeur de notre module
    ~ProxyCEF(); // Destructeur
    void do_action(int value); // Une action de notre module qui ne fait rien

  // Code libCEF a definir
  CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() override
  {
    return this;
  }

  // CefBrowserProcessHandler methods:
  void OnContextInitialized() override;
  CefRefPtr<CefClient> GetDefaultClient() override;

protected:

    // Godot
    static void _bind_methods();

private:

  // CEF: Include the default reference counting implementation.
  IMPLEMENT_REFCOUNTING(ProxyCEF);
};

#endif // STIGMEE_CEF_H
```

**Fichier proxy_cef.cpp**

```
#include "proxy_cef.h" // Notre module
#include "cef_command_line.h" // libCEF
#include "tests/cefsimple/simple_handler.h" // libCEF
#include <iostream> // std::cout

ProxyCEF::ProxyCEF()
{
    std::cout << "Bye ProxyCEF" << std::endl;
    //CefRefPtr<CefCommandLine> command_line = nullptr;// = CefCommandLine::CreateCommandLine();
    //if (command_line != nullptr)
    //   command_line->InitFromArgv(2, nullptr);
}

ProxyCEF::~ProxyCEF()
{
    std::cout << "Bye ProxyCEF" << std::endl;
}

void ProxyCEF::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("do_action", "value"), &ProxyCEF::do_action);
}

void ProxyCEF::do_action(int value)
{
    std::cout << "ProxyCEF do action " << value << std::endl;
}

void ProxyCEF::OnContextInitialized()
{
}

CefRefPtr<CefClient> ProxyCEF::GetDefaultClient()
{
  // Called when a new browser window is created via the Chrome runtime UI.
  return nullptr;//SimpleHandler::GetInstance();
}
```

**Fichier SCsub**

Il sert de Makefile pour compiler les sources. On inclut les sous répertoires du dossier include de CEF
```
Import('env')

env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/base'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/base/internal'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/capi'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/capi/test'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/capi/views'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/internal'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/test'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/views'])
env.Append(CPPPATH = ['/home/qq/chreage_workspace/built_CEF/include/wrapper'])
env.Append(LIBS = 'cef', LIBPATH = ['/home/qq/chreage_workspace/built_CEF/Debug/'])
env.add_source_files(env.modules_sources, "*.cpp")
```

Documentation Scons:
- https://www.scons.org/doc/0.93/HTML/scons-user/x275.html
- https://scons.org/doc/1.3.0/HTML/scons-user/x4763.html

## Compilation du module Godot

On compile en allant dans le répertoire parent de Godot et faire (pour Linux):
```
scons -j$(nproc) platform=linuxbsd
```

Evidemment, la compilation ne se passe pas bien. En effet Godot et CEF semblent
avoir choisi les mêmes noms pour leurs erreurs
`/home/qq/chreage_workspace/built_CEF/include/base/internal/cef_net_error_list.h`. Pour
le moment on va modifier
`/home/qq/chreage_workspace/built_CEF/include/internal/cef_types.h` et changer :

```
#define NET_ERROR(label, value) ERR_##label = value
```

par :
```
#define NET_ERROR(label, value) CEF__ERR_##label = value,
```

Il reste un warning. Il faudra faire un patch pour CEF.

## Vérification du module Godot

Si vous avez fait hériter votre classe proxy de `Node`, il suffit de cliquer sur
le bouton '+' dans le scène graphe pour ajouter votre nœud. Si avez fait hériter
votre classe proxy de `Reference`, on peut créer un noeud Mesh (comme un cube)
et lui attacher un script avec par exemple code suivant :
```
func _ready():
    var s = Cef.new()
    s.do_action(10)
    pass
```

Dans le deux cas, on aura un message sur la console :
```
Hello ProxyCEF
ProxyCEF do action 10
Bye ProxyCEF
```
