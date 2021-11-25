# Ajouter un module Chromium Embedded Framework à Godot

Comment modifier les sources de Godot version 3.4-stable (à voir pour Godot
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

## Télécharger Godot v3.4-stable

```bash
git clone git@github.com:godotengine/godot.git --depth=1 --branch 3.4-dev
```

## Télécharger Chromium Embedded Framework

Tout d'abord je télécharge une CEF déjà compilé (car c'est une plaie à compiler):
https://cef-builds.spotifycdn.com/index.html

Et je décompresse l'archive à l'endroit de mon choix. Je le place dans `godot/thirdparty/`

## Créer son module Godot v3.4-stable

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

```C++
#ifndef STIGMEE_CEF_REGISTER_TYPES_H
#define STIGMEE_CEF_REGISTER_TYPES_H

void register_cef_types();
void unregister_cef_types();

#endif // STIGMEE_CEF_REGISTER_TYPES_H
```

**Fichier register_types.cpp**

```C++
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

Pour le moment, c'est une classe vide qui ne fait rien avec CEF mais qui vient de
https://github.com/Lecrapouille/OffScreenCEF. Les explications du code sont
[ici](https://github.com/stigmee/doc/blob/master/doc/tuto_fun_cef.md).
Pour le moment elle se contente d'utiliser des symboles de CEF. Le fichier header
contient notre classe proxy CEF. Notre classe hérite de Godot soit d'un nœud,
soit d'une référence, soit d'une ressource.

```C++
#ifndef STIGMEE_CEF_H
#define STIGMEE_CEF_H

// Godot
#include "scene/main/node.h"

// Chromium Embedded Framework
#  include <cef_render_handler.h>
#  include <cef_client.h>
#  include <cef_app.h>

class ProxyCEF : public Node
{
private:

    GDCLASS(ProxyCEF, Node);

protected:

    static void _bind_methods();

public:

    //! \brief Default Constructor using a given URL.
    ProxyCEF();

    //! \brief
    ~ProxyCEF();

    //! \brief Load the given web page
    void load(const std::string &url);

    //! \brief Render the web page
    void draw();

    //! \brief Set the windows size
    void reshape(int w, int h);

    //! \brief Set the viewport
    bool viewport(float x, float y, float w, float h);

    //! \brief Get the viewport
    //inline glm::vec4 const& viewport() const
    //{
    //    return m_viewport;
    //}

    //! \brief TODO
    // void executeJS(const std::string &cmd);

    //! \brief Set the new mouse position
    void mouseMove(int x, int y);

    //! \brief Set the new mouse state (clicked ...)
    void mouseClick(CefBrowserHost::MouseButtonType btn, bool mouse_up);

    //! \brief Set the new keyboard state (char typed ...)
    void keyPress(int key, bool pressed);

private:

    // *************************************************************************
    //! \brief Private implementation to handle CEF events to draw the web page.
    // *************************************************************************
    class RenderHandler: public CefRenderHandler
    {
    public:

        //! \brief
        ~RenderHandler();

        //! \brief Compile OpenGL shaders and create OpenGL objects (VAO,
        //! VBO, texture, locations ...)
        bool init();

        //! \brief Render OpenGL VAO (rotating a textured square)
        void draw();

        //! \brief Resize the view
        void reshape(int w, int h);

        //! \brief Return the OpenGL texture handle
        int texture() const
        {
            return 0;
        }

        //! \brief CefRenderHandler interface
        virtual void GetViewRect(CefRefPtr<CefBrowser> browser, CefRect &rect) override;

        //! \brief CefRenderHandler interface
        //! Update the OpenGL texture.
        virtual void OnPaint(CefRefPtr<CefBrowser> browser, PaintElementType type,
                             const RectList &dirtyRects, const void *buffer,
                             int width, int height) override;

        //! \brief CefBase interface
        IMPLEMENT_REFCOUNTING(RenderHandler);

    private:

        //! \brief Dimension
        int m_width;
        int m_height;
    };

    // *************************************************************************
    //! \brief Provide access to browser-instance-specific callbacks. A single
    //! CefClient instance can be shared among any number of browsers.
    // *************************************************************************
    class BrowserClient: public CefClient
    {
    public:

        BrowserClient(CefRefPtr<CefRenderHandler> ptr)
            : m_renderHandler(ptr)
        {}

        virtual CefRefPtr<CefRenderHandler> GetRenderHandler() override
        {
            return m_renderHandler;
        }

        CefRefPtr<CefRenderHandler> m_renderHandler;

        IMPLEMENT_REFCOUNTING(BrowserClient);
    };

private:

    //! \brief Mouse cursor position on the OpenGL window
    int m_mouse_x;
    int m_mouse_y;

    //! \brief Chromium Embedded framework elements
    CefRefPtr<CefBrowser> m_browser;
    CefRefPtr<BrowserClient> m_client;
    RenderHandler* m_render_handler = nullptr;

    //! \brief OpenGL has created GPU elements with success
    bool m_initialized = false;

public:

    //! \brief If set to false then the web page is turning.
    bool m_fixed = true;
};

#endif // STIGMEE_CEF_H
```

**Fichier proxy_cef.cpp**

```C++
#include "proxy_cef.h"
#include <iostream>

//------------------------------------------------------------------------------
void ProxyCEF::_bind_methods()
{
    //ClassDB::bind_method(D_METHOD("do_action", "value"), &ProxyCEF::do_action);
}

//------------------------------------------------------------------------------
ProxyCEF::RenderHandler::~RenderHandler()
{}

//------------------------------------------------------------------------------
bool ProxyCEF::RenderHandler::init()
{
    return true;
}

//------------------------------------------------------------------------------
void ProxyCEF::RenderHandler::draw()
{
}

//------------------------------------------------------------------------------
void ProxyCEF::RenderHandler::reshape(int w, int h)
{
    m_width = w;
    m_height = h;
}

//------------------------------------------------------------------------------
bool ProxyCEF::viewport(float x, float y, float w, float h)
{
    if (!(x >= 0.0f) && (x < 1.0f))
        return false;

    if (!(x >= 0.0f) && (y < 1.0f))
        return false;

    if (!(w > 0.0f) && (w <= 1.0f))
        return false;

    if (!(h > 0.0f) && (h <= 1.0f))
        return false;

    if (x + w > 1.0f)
        return false;

    if (y + h > 1.0f)
        return false;

    return true;
}

//------------------------------------------------------------------------------
void ProxyCEF::RenderHandler::GetViewRect(CefRefPtr<CefBrowser> browser, CefRect &rect)
{
    rect = CefRect(0, 0, m_width, m_height);
}

//------------------------------------------------------------------------------
void ProxyCEF::RenderHandler::OnPaint(CefRefPtr<CefBrowser> browser, PaintElementType type,
                            const RectList &dirtyRects, const void *buffer,
                            int width, int height)
{
}

//------------------------------------------------------------------------------
ProxyCEF::ProxyCEF()
    : m_mouse_x(0), m_mouse_y(0)
{
    CefWindowInfo window_info;
    window_info.SetAsWindowless(0);

    m_render_handler = new RenderHandler();
    m_initialized = m_render_handler->init();
    m_render_handler->reshape(128, 128); // initial size

    CefBrowserSettings browserSettings;
    browserSettings.windowless_frame_rate = 60; // 30 is default

    m_client = new BrowserClient(m_render_handler);
    m_browser = CefBrowserHost::CreateBrowserSync(window_info, m_client.get(),
                                                  ""/*url*/, browserSettings,
                                                  nullptr, nullptr);
}

//------------------------------------------------------------------------------
ProxyCEF::~ProxyCEF()
{
    CefDoMessageLoopWork();
    m_browser->GetHost()->CloseBrowser(true);

    m_browser = nullptr;
    m_client = nullptr;
}

//------------------------------------------------------------------------------
void ProxyCEF::load(const std::string &url)
{
    assert(m_initialized);
    m_browser->GetMainFrame()->LoadURL("");
}

//------------------------------------------------------------------------------
void ProxyCEF::draw()
{
    CefDoMessageLoopWork();
    m_render_handler->draw();
}

//------------------------------------------------------------------------------
void ProxyCEF::reshape(int w, int h)
{
    m_render_handler->reshape(w, h);
    m_browser->GetHost()->WasResized();
}

//------------------------------------------------------------------------------
void ProxyCEF::mouseMove(int x, int y)
{
    m_mouse_x = x;
    m_mouse_y = y;

    CefMouseEvent evt;
    evt.x = x;
    evt.y = y;

    bool mouse_leave = false; // TODO
    m_browser->GetHost()->SendMouseMoveEvent(evt, mouse_leave);
}

//------------------------------------------------------------------------------
void ProxyCEF::mouseClick(CefBrowserHost::MouseButtonType btn, bool mouse_up)
{
    CefMouseEvent evt;
    evt.x = m_mouse_x;
    evt.y = m_mouse_y;

    int click_count = 1; // TODO
    m_browser->GetHost()->SendMouseClickEvent(evt, btn, mouse_up, click_count);
}

//------------------------------------------------------------------------------
void ProxyCEF::keyPress(int key, bool pressed)
{
    CefKeyEvent evt;
    evt.character = key;
    evt.native_key_code = key;
    evt.type = pressed ? KEYEVENT_CHAR : KEYEVENT_KEYUP;

    m_browser->GetHost()->SendKeyEvent(evt);
}
```

**Fichier SCsub**

Il sert de Makefile pour compiler les sources. On inclut les sous répertoires du dossier include de CEF
```
Import('env')
env.Append(CPPPATH = ['#thirdparty/cef_binary'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/base'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/base/internal'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/capi'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/capi/test'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/capi/views'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/internal'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/test'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/views'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/wrapper'])
env.Append(LIBS = 'cef', LIBPATH = ['#main'])
env.Append(LIBS = 'libcef_dll_wrapper', LIBPATH = ['#main'])
env.add_source_files(env.modules_sources, "*.cpp")
```

Documentation Scons:
- https://www.scons.org/doc/0.93/HTML/scons-user/x275.html
- https://scons.org/doc/1.3.0/HTML/scons-user/x4763.html

## Modification du main de Godot v3.4-stable

On doit lancer CEF. Celui-ci a besoin du `argc` et `argv` de la fonction `main`.
CEF ajoute des informations à ses processus forkés. Ceci impacte Godot qui lui aussi
à besoin du `argc` et `argv` pour lancer son éditeur 3D. On doit en faire des copies.
Si on ne reseigne pas `argc` et `argv` à CEF celui-ci peut partir en boucle infinie
en lançant des forks et tuer votre système d'exploitation.

Modifions le fichier `godot/platform/x11/godot_x11.cpp` :
```C++
// Chromium Embedded Framework
#  include <cef_render_handler.h>
#  include <cef_client.h>
#  include <cef_app.h>
#  include <iostream>

//------------------------------------------------------------------------------
static void CEFsetUp(int argc, char** argv)
{
    std::cerr << "CEFsetUp" << std::endl;
    CefMainArgs args(argc, argv);
    int exit_code = CefExecuteProcess(args, nullptr, nullptr);
    if (exit_code >= 0)
    {
        std::cerr << "CefExecuteProcess: child proccess has endend, so exit" << std::endl;
        exit(exit_code);
    }
    else if (exit_code == -1)
    {
        // we are here in the father proccess.
        std::cerr << "CefExecuteProcess: father" << std::endl;
    }

    std::cerr << "CEFsetUp: done" << std::endl;
    // Configurate Chromium
    CefSettings settings;
    // TODO CefString(&settings.locales_dir_path) = "cef/linux/lib/locales";
    settings.windowless_rendering_enabled = true;
//#if !defined(CEF_USE_SANDBOX)
    settings.no_sandbox = true;
//#endif

    bool result = CefInitialize(args, settings, nullptr, nullptr);
    if (!result)
    {
        std::cerr << "CefInitialize: failed" << std::endl;
        exit(-2);
    }
    std::cerr << "CEFsetUp: OK" << std::endl;
}

int main(int argc, char *argv[])
{
        std::cerr << "CEFsetUp: avant " << std::endl;
        std::vector<std::string> backup_args;
        for (int i = 0; i < argc; ++i)
        {
           std::cerr << "arg " << i << ": " << argv[i] << std::endl;
           backup_args.push_back(argv[i]);
        }

        CEFsetUp(argc, argv);
        std::cerr << "CEFsetUp: Apres " << std::endl;
        for (int i = 0; i < argc; ++i)
        {
           std::cerr << "arg " << i << ": " << argv[i] << std::endl;
           argv[i] = &(backup_args[i][0]);
        }

	OS_X11 os;

	setlocale(LC_CTYPE, "");

	char *cwd = (char *)malloc(PATH_MAX);
	ERR_FAIL_COND_V(!cwd, ERR_OUT_OF_MEMORY);
	char *ret = getcwd(cwd, PATH_MAX);

	Error err = Main::setup(argv[0], argc - 1, &argv[1]);
	if (err != OK) {
		free(cwd);
                CefShutdown();
		return 255;
	}

	if (Main::start()) {
		os.run(); // it is actually the OS that decides how to run
	}
	Main::cleanup();

	if (ret) { // Previous getcwd was successful
		if (chdir(cwd) != 0) {
			ERR_PRINT("Couldn't return to previous working directory.");
		}
	}
	free(cwd);

        CefShutdown();
	return os.get_exit_code();
}
```

Il faut ajouter ce code dans le fichier Scub du même répertoire:
```
env.Append(CPPPATH = ['#thirdparty/cef_binary'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/base'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/base/internal'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/capi'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/capi/test'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/capi/views'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/internal'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/test'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/views'])
env.Append(CPPPATH = ['#thirdparty/cef_binary/include/wrapper'])
env.Append(LIBS = 'cef', LIBPATH = ['#main'])
env.Append(LIBS = 'libcef_dll_wrapper', LIBPATH = ['#main'])
```

## Compilation du module Godot v3.4-stable

On compile en allant dans le répertoire parent de Godot et faire (pour Linux):
```
scons -j$(nproc) platform=x11
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

Si vous avez compilé CEF et Godot depuis un Docker, il vous faut surement indiquer le chemin de la libCEF:
```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKSPACE_STIGMEE/CEF/chromium_git/chromium/src/out/Release_GN_x64
```

