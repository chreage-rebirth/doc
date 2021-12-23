# Ajouter un module Chromium Embedded Framework à Godot

**Attention:** Cette procédure fonctionne ([single
executable](tuto_fun_cef.md#understanding-how-cef-starts-its-sub-processes)) et
est valide mais elle nécessite de modifier le code source de Godot et de le
recompiler. Une autre procédure non décrite ici sera préférable (Separate
Sub-Process Executable) car ne demande pas de modifier Godot (voir ici son
implementation https://github.com/stigmee/godot-modules/tree/dev-lecrapouille).

Comment modifier les sources de Godot version 3.4-stable (à voir pour Godot
V4-instable) pour ajouter un nouveau type de nœud pour le graphe de scène (aussi
nommé scene graph ou scene tree) afin de faire un nœud pour
[CEF](https://bitbucket.org/chromiumembedded/cef/src/master/) ? Pour ceux qui
veulent savoir comment fonctionne un graphe de scène voir ce
[lien](https://research.ncl.ac.uk/game/mastersdegree/graphicsforgames/) et
sélectionner l'article Scene Graphs.

Pour le moment, cette page explique comment c'est réalisable. Dans un deuxième
temps, il sera nécessaire de faire un point d'architecture pour voir comment ce
module pourra servir pour le fonctionnement de Stigmee et de quel classe Godot
il doit hériter, son API pour une utilisation dans un GDScript.

Les sources de Godot sont ici :
[https://github.com/godotengine/godot](https://github.com/godotengine/godot). La
définition de la classe mère d'un nœud graphe de scène est ici :
[https://github.com/godotengine/godot/tree/master/scene/main](https://github.com/godotengine/godot/tree/master/scene/main). Par
exemple le nœud HTTP Request dont la doc est décrite sur ce
[lien](https://docs.godotengine.org/fr/stable/tutorials/networking/http_request_class.html)
(son [code
source](https://github.com/godotengine/godot/blob/master/scene/main/http_request.cpp)
et son
[header](https://github.com/godotengine/godot/blob/master/scene/main/http_request.h)).
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

Tout d'abord je télécharge une CEF déjà compilé (car c'est une plaie à
compiler): https://cef-builds.spotifycdn.com/index.html et je décompresse
l'archive à l'endroit de mon choix. Je le place dans `godot/thirdparty/`

Pour plus d'information, lire ce [document](tuto_fun_cef.md) qui explique les
entrailles de CEF, comment le compiler, etc.

## Créer son module Godot v3.4-stable

Il faut créer un dossier que l'on nommera, par exemple, `cef` dans le dossier
`godot/modules`. On prendra soin d'éviter de créer des conflits de noms entre
votre module est celui de CEF.

Il vous faudra au minimum, les fichiers suivants (seul le nom pour les fichiers
`browser.cpp` et `browser.h` est laissé libre) :
- browser.cpp
- browser.h
- register_types.cpp
- register_types.h
- SCsub
- config.py

**Fichier register_types.h**

Il faut ajouter ces deux fonctions afin que notre future classe C++ `BrowserView`
pour notre module puisse être enregistrée par Godot. Le terme `cef` doit référer
au nom de votre dossier.

```C++
#ifndef STIGMEE_CEF_REGISTER_TYPES_H
#  define STIGMEE_CEF_REGISTER_TYPES_H

void register_cef_types();
void unregister_cef_types();

#endif // STIGMEE_CEF_REGISTER_TYPES_H
```

**Fichier register_types.cpp**

```C++
#include "register_types.h" // Godot
#include "core/class_db.h" // Godot
#include "browser.h" // Notre module

void register_cef_types()
{
   ClassDB::register_class<BrowserView>();
}

void unregister_cef_types()
{}
```

**Fichier config.py**

C'est un fichier de configuration du module (documentation par exemple), c'est
un simple script python. Le code minimal est:

```
def can_build(env, platform):
    return True

def configure(env):
    pass
```

**Fichier browser.h**

C'est une classe qui vient de
https://github.com/Lecrapouille/OffScreenCEF/tree/master/cefsimple_opengl (qui
lui meme vient de l'exemple cefsimple donné dans les sources de CEF). Les
explications sont données
[ici](https://github.com/stigmee/doc/blob/master/doc/tuto_fun_cef.md). Notre
classe peut hériter d'une classe Godot comme par exemple soit d'un nœud, soit
d'une référence, soit d'une ressource, voir d'une texture. Il est 'a noter que
ni Godot ni CEF n'ont de namespace.

```C++
#ifndef STIGMEE_CEF_H
#  define STIGMEE_CEF_H

// Godot
#  include "scene/main/node.h"

// Chromium Embedded Framework
#  include <cef_render_handler.h>
#  include <cef_client.h>
#  include <cef_app.h>

class BrowserView: public Node
{
protected:

    // Godot: mandatory. Export symbols for GDScript
    static void _bind_methods();

public:

    // Godot: mandatory
    GDCLASS(BrowserView, Node);

    //! \brief Default constructor. Load Google page.
    BrowserView();

    //! \brief Default destructor.
    ~BrowserView();

    //! \brief Return the Godot texture
    Ref<ImageTexture> get_texture() { return m_texture; }

    //! \brief Load the given web page
    void load_url(const String &url);

    //! \brief Set the windows size
    void reshape(int w, int h);

    //! \brief Set the new mouse position.
    void mouseMove(int x, int y);

    //! \brief Set the new mouse state (clicked ...)
    void mouseClick(int button, bool mouse_up);

    //! \brief Set the new keyboard state (char typed ...)
    void keyPress(int key, bool pressed);

private:

    // *************************************************************************
    //! \brief Private implementation to handle CEF events to draw the web page.
    // *************************************************************************
    class RenderHandler: public CefRenderHandler
    {
    public:

        RenderHandler(BrowserView& owner);

        //! \brief Resize the browser's view
        void reshape(int w, int h);

        //! \brief CefRenderHandler interface. Get the view port.
        virtual void GetViewRect(CefRefPtr<CefBrowser> browser, CefRect &rect) override;

        //! \brief CefRenderHandler interface. Update the Godot's texture.
        virtual void OnPaint(CefRefPtr<CefBrowser> browser, PaintElementType type,
                             const RectList &dirtyRects, const void *buffer,
                             int width, int height) override;

        //! \brief CefBase interface
        IMPLEMENT_REFCOUNTING(RenderHandler);

    private:

        //! \brief Browser's view dimension
        int m_width;
        int m_height;

        //! \brief Access to BrowserView::m_image
        BrowserView& m_owner;

        //! \brief
        PoolVector<uint8_t> m_data;
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

        // CefClient
        virtual CefRefPtr<CefRenderHandler> GetRenderHandler() override
        {
            return m_renderHandler;
        }

        CefRefPtr<CefRenderHandler> m_renderHandler;

        IMPLEMENT_REFCOUNTING(BrowserClient);
    };

private:

    //! \brief Chromium Embedded Framework elements
    CefRefPtr<CefBrowser> m_browser;
    CefRefPtr<BrowserClient> m_client;
    RenderHandler* m_render_handler = nullptr;

    //! \brief Mouse cursor position on the main window
    int m_mouse_x;
    int m_mouse_y;

    //! \brief Godot's temporary image (CEF => Godot)
    Ref<ImageTexture> m_texture;
    Ref<Image> m_image;
};

#endif // STIGMEE_CEF_H
```

**Fichier browser.cpp**

- `_bind_methods()` permet d'exporter les méthodes pour une utilisation dans les
  scripts Godot.
- `get_texture()` retourne un pointeur sur la texture Godot ou est affichée la
  page web.
- `onPaint` est la callback de CEF quand un morceau de la page doit être
  affichée.
- CEF a besoin qu'on lui donne des informations tels que la taille de la page
  web (`reshape`), la position de la souris (`MouseClick`), les touches du
  clavier, etc.
- CEF propose d'autres API comme la page précédente, la suivante, zoom, non
  données ici.

```C++
//------------------------------------------------------------------------------
void BrowserView::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("load_url", "url"), &BrowserView::load_url);
    ClassDB::bind_method(D_METHOD("get_texture"), &BrowserView::get_texture);
    ClassDB::bind_method(D_METHOD("reshape", "w", "h"), &BrowserView::reshape);
    ClassDB::bind_method(D_METHOD("on_key_pressed", "key", "pressed"), &BrowserView::keyPress);
    ClassDB::bind_method(D_METHOD("on_mouse_moved", "x", "y"), &BrowserView::mouseMove);
    ClassDB::bind_method(D_METHOD("on_mouse_click", "buton", "up"), &BrowserView::mouseClick);
}

//------------------------------------------------------------------------------
BrowserView::BrowserView()
    : m_mouse_x(0), m_mouse_y(0)
{
    std::cout << "BrowserView::BrowserView()" << std::endl;
    m_image.instance();
    m_texture.instance();

    CefWindowInfo window_info;
    window_info.SetAsWindowless(0);

    m_render_handler = new RenderHandler(*this);
    m_render_handler->reshape(128, 128); // initial browser's view size

    CefBrowserSettings settings;
    settings.windowless_frame_rate = 60; // 30 is default

    m_client = new BrowserClient(m_render_handler);
    m_browser = CefBrowserHost::CreateBrowserSync(window_info, m_client.get(),
                                                  "https://www.google.com/", settings,
                                                  nullptr, nullptr);
}

//------------------------------------------------------------------------------
BrowserView::~BrowserView()
{
    CefDoMessageLoopWork();
    m_browser->GetHost()->CloseBrowser(true);

    m_browser = nullptr;
    m_client = nullptr;
}

//------------------------------------------------------------------------------
BrowserView::RenderHandler::RenderHandler(BrowserView& owner)
    : m_owner(owner)
{}

//------------------------------------------------------------------------------
void BrowserView::RenderHandler::reshape(int w, int h)
{
    m_width = w;
    m_height = h;
}

//------------------------------------------------------------------------------
void BrowserView::RenderHandler::GetViewRect(CefRefPtr<CefBrowser> browser, CefRect &rect)
{
    rect = CefRect(0, 0, m_width, m_height);
}

//------------------------------------------------------------------------------
// FIXME find a less naive algorithm
void BrowserView::RenderHandler::OnPaint(CefRefPtr<CefBrowser> browser, PaintElementType type,
                                         const RectList &dirtyRects, const void *buffer,
                                         int width, int height)
{
    // Sanity check
    if ((width <= 0) || (height <= 0) || (buffer == nullptr))
        return ;

    // BGRA8: blue, green, red components each coded as byte
    int const COLOR_CHANELS = 4;
    int const SIZEOF_COLOR = COLOR_CHANELS * sizeof(char);
    int const TEXTURE_SIZE = SIZEOF_COLOR * width * height;

    // Copy CEF image buffer to Godot PoolVector
    m_data.resize(TEXTURE_SIZE);
    PoolVector<uint8_t>::Write w = m_data.write();
    memcpy(&w[0], buffer, TEXTURE_SIZE);

    // Color conversion BGRA8 -> RGBA8: swap B and R chanels
    for (int i = 0; i < TEXTURE_SIZE; i += COLOR_CHANELS)
    {
        std::swap(w[i], w[i + 2]);
    }

    // Copy Godot PoolVector to Godot texture.
    m_owner.m_image->create(width, height, false, Image::FORMAT_RGBA8, m_data);
    m_owner.m_texture->create_from_image(m_owner.m_image, Texture::FLAG_VIDEO_SURFACE);
}

//------------------------------------------------------------------------------
void BrowserView::load_url(const String &url)
{
    m_browser->GetMainFrame()->LoadURL(url.utf8().get_data());
}

//------------------------------------------------------------------------------
void BrowserView::reshape(int w, int h)
{
    m_render_handler->reshape(w, h);
    m_browser->GetHost()->WasResized();
}

//------------------------------------------------------------------------------
void BrowserView::mouseMove(int x, int y)
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
void BrowserView::mouseClick(int button, bool mouse_up)
{
    CefMouseEvent evt;
    evt.x = m_mouse_x;
    evt.y = m_mouse_y;

    CefBrowserHost::MouseButtonType btn;
    switch (button)
    {
        case BUTTON_LEFT:
          btn = CefBrowserHost::MouseButtonType::MBT_LEFT;
          std::cout << "BrowserView::mouseClick Left " << mouse_up << std::endl;
          break;
        case BUTTON_RIGHT:
          btn = CefBrowserHost::MouseButtonType::MBT_RIGHT;
          std::cout << "BrowserView::mouseClick Right " << mouse_up << std::endl;
          break;
        case BUTTON_MIDDLE:
          btn = CefBrowserHost::MouseButtonType::MBT_MIDDLE;
          std::cout << "BrowserView::mouseClick Middle " << mouse_up << std::endl;
          break;
        default:
          return;
    }

    int click_count = 1; // TODO
    m_browser->GetHost()->SendMouseClickEvent(evt, btn, mouse_up, click_count);
}

//------------------------------------------------------------------------------
void BrowserView::keyPress(int key, bool pressed)
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
env.Append(CXXFLAGS=['-DCEF_USE_SANDBOX', '-DNDEBUG', '-D_FILE_OFFSET_BITS=64',
                         '-D__STDC_CONSTANT_MACROS', '-D__STDC_FORMAT_MACROS'])
```

Documentation Scons:
- https://www.scons.org/doc/0.93/HTML/scons-user/x275.html
- https://scons.org/doc/1.3.0/HTML/scons-user/x4763.html

## Modification du main de Godot v3.4-stable

On doit lancer CEF. Celui-ci a besoin du `argc` et `argv` de la fonction `main`
(command line). CEF y ajoute des informations à ses processus forkés en la
modifiant. Ceci impacte Godot qui lui aussi à besoin du `argc` et `argv` pour
lancer son éditeur 3D. On doit donc faire des copies de la command line.  Si on
ne renseigne pas `argc` et `argv` à CEF celui-ci peut partir en boucle infinie en
lançant des forks et tuer en quelques secondes votre système d'exploitation.

Modifions le fichier `godot/platform/x11/godot_x11.cpp`. Il faut ajouter les
fonctions `CEFsetUp` et :

```C++
// Chromium Embedded Framework
#  include <cef_render_handler.h>
#  include <cef_client.h>
#  include <cef_app.h>
#  include <iostream>

//------------------------------------------------------------------------------
static void CEFsetUp(int argc, char** argv)
{
    std::cout << ::getpid() << "::" << ::getppid() << ": " << __FILE__ << ": "
              << __PRETTY_FUNCTION__ << std::endl;
    CefMainArgs args(argc, argv);
    int exit_code = CefExecuteProcess(args, nullptr, nullptr);
    if (exit_code >= 0)
    {
        std::cerr << ::getpid() << "::" << ::getppid() << ": "
                  << "[CEF_start] CefExecuteProcess(): Chromium sub-process has completed"
                  << std::endl;
        exit(exit_code);
    }
    else if (exit_code == -1)
    {
        // we are here in the father proccess.
        std::cerr << ::getpid() << "::" << ::getppid() << ": "
                  << "[CEF_start] CefExecuteProcess(): argv not for Chromium: ignoring!" << std::endl;
    }
    std::cerr << ::getpid() << "::" << ::getppid() << ": "
              << "[CEF_start] CefExecuteProcess(): done" << std::endl;

    // Configure Chromium
    CefSettings settings;
    // TODO CefString(&settings.locales_dir_path) = "cef/linux/lib/locales";
    settings.windowless_rendering_enabled = true;
    //settings.ignore_certificate_errors = true;
#if !defined(CEF_USE_SANDBOX)
    settings.no_sandbox = true;
#endif

    bool result = CefInitialize(args, settings, nullptr, nullptr);
    if (!result)
    {
        std::cerr << ::getpid() << "::" << ::getppid() << ": "
                  << "[CEF_start] CefInitialize: failed" << std::endl;
        exit(-2);
    }
    std::cerr << ::getpid() << "::" << ::getppid() << ": "
              << "[CEF_start] CefInitialize: OK" << std::endl;
}

//------------------------------------------------------------------------------
static void CEF_stop()
{
    std::cerr << ::getpid() << "::" << ::getppid() << ": "
              << "[CEF_stop]" << std::endl;
    CefShutdown();
}

//------------------------------------------------------------------------------
int main(int argc, char *argv[])
{
int main(int argc, char *argv[])
{
    // Backup command line since CEF and Godot are sharing argv and CEF is
    // modifying it.
    std::cout << ::getpid() << "::" << ::getppid() << ": "
              << __FILE__ << ": " << __PRETTY_FUNCTION__ << std::endl;
    std::vector<std::string> backup_args;
    for (int i = 0; i < argc; ++i)
    {
        std::cerr << "arg " << i << ": " << argv[i] << std::endl;
        backup_args.push_back(argv[i]);
    }

    // Start forking CEF
    CEF_start(argc, argv);

    // Restore command line since for Godot.
    std::cerr << ::getpid() << "::" << ::getppid() << ": "
              << "[CEF_start] Apres CEF_start " << std::endl;
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
            std::cerr << ::getpid() << "::" << ::getppid()
                      << ": Main::setup failed" << std::endl;
        free(cwd);
                CEF_stop();
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

    CEF_stop();
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
avoir choisi les mêmes noms pour leurs erreurs sans la protection des namespaces
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

Cette modification, fonctionne pour le moment mais fera échouer la compilation de CEF au prochain coup.
Une meilleure solution consiste à changer temporairement les noms des erreurs CEF (ou Godot) le temps
d'inclure les includes.
```c++
// Chromium Embedded Framework
#define ERR_OUT_OF_MEMORY CEF__ERR_OUT_OF_MEMORY
#define ERR_FILE_NOT_FOUND CEF__ERR_FILE_NOT_FOUND

#  include <cef_types.h>
#  include <cef_render_handler.h>
#  include <cef_client.h>
#  include <cef_app.h>
#  include <cef_helpers.h>

#undef ERR_OUT_OF_MEMORY
#undef ERR_FILE_NOT_FOUND

// Godot
//#define ERR_OUT_OF_MEMORY GODOT__ERR_OUT_OF_MEMORY
//#define ERR_FILE_NOT_FOUND GODOT__ERR_FILE_NOT_FOUND
#  include "core/error_list.h"
#  include "scene/main/node.h"
#  include "scene/resources/texture.h"
//#undef ERR_OUT_OF_MEMORY
//#undef ERR_FILE_NOT_FOUND
```

Il reste un dernier warning mais il ne semble pas impacter note module. Il faudra quand même investiguer dessus.

## Vérification du module Godot

Si vous avez fait hériter votre classe proxy de `Node`, il suffit de cliquer sur
le bouton '+' dans le scène graphe pour ajouter votre nœud. Voici un exemple avec
un Control, deux CEF, deux TextureRect et le GDScript suivant:

```
# Mouse and keyboard events needed for Chromium Embedded Framework
func _input(event):
    if event is InputEventMouseButton:
        get_node("CEF1/BrowserView").on_mouse_click(event.button_index, event.pressed)
        get_node("CEF2/BrowserView").on_mouse_click(event.button_index, event.pressed)
    elif event is InputEventMouseMotion:
        get_node("CEF1/BrowserView").on_mouse_moved(event.position.x, event.position.y)
        get_node("CEF2/BrowserView").on_mouse_moved(event.position.x, event.position.y)

# Create two Chromium Embedded Framework browser view inside a 3D scene
func _ready():
    var CEF1 = get_node("CEF1/BrowserView")
    CEF1.reshape(400, 400)
    CEF1.load_url("https://youtu.be/")
    get_node("CEF1/TextureRect").texture = CEF1.get_texture()

    var CEF2 = get_node("CEF2/BrowserView")
    CEF2.reshape(200, 200)
    CEF2.load_url("https://bitbucket.org/")
    get_node("CEF2/TextureRect").texture = CEF2.get_texture()
    pass

# Runtime
func _process(delta):
    pass
```

Vous devriez voir une page web s'afficher.
