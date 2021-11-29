# Getting fun with Chromium Embedded Framework (CEF)

Let experiment with prebuilt CEF **alone** (meaning without Godot). We will understand how the `cefsimple` application given in the `tests` folder is compiled. This application demonstrates the minimal functionality required to create a browser window. This is
the minimal code source needed to embed inside Godot.

These steps have been tested on Debian 11 64-bits and Ubuntu 18.04 64-bits.

Firstly, let name some folders. This will make our code shorter in this document. Do not forget to adapt the CEF version to your operating system with the desired version on https://cef-builds.spotifycdn.com/index.html:
```bash
TMP=/tmp
CEF_LINK=https://cef-builds.spotifycdn.com/cef_binary_96.0.14%2Bg28ba5c8%2Bchromium-96.0.4664.55_linux64.tar.bz2
CEF=$TMP/cef_binary_96.0.14+g28ba5c8+chromium-96.0.4664.55_linux64
CEF_TARBALL=$CEF.tar.bz2
CEFSIMPLE=$CEF/tests/cefsimple
CEFSIMPLE2=$CEF/tests/cefsimple2
```

Download and decompress it inside a temporary folder.
```bash
wget $CEF_LINK
tar jxvf $CEF_TARBALL
```

For later in this document, copy the `cefsimple` folder as `cefsimple2` and remove its `CMakeLists.txt` file:
```bash
cp -r $CEFSIMPLE $CEFSIMPLE2
rm -f $CEFSIMPLE2/CMakeLists.txt
```

## Cmake >= 3.19 is needed

On Debian 11, the cmake version is too old. You can look at this bash script to upgrade your cmake:
https://github.com/stigmee/doc/blob/master/doc/install_latest_cmake.sh

More information can be found at: https://trendoceans.com/how-to-install-cmake-on-debian-10-11/

## Compile chrome-sandbox, cefclient, cefsimple, ceftests

This compilation step is important not only for compiling examples but also because compiled packages
and library will be needed for the Stigmee project.

```bash
mkdir $CEF/build
cd $CEF/build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(nproc)
# make -j$(nproc) cefclient cefsimple ceftests
```

You can also follow https://github.com/Zabrimus/cef-makefile-sample in where a `pkg-config` file is created making simpler
the integration of CEF inside other projects.

Now, let check if our compiled binaries are functional!

### cefsimple

This application demonstrates the minimal functionality required to create a browser window.

You can launch `cefsimple`:
```bash
./tests/cefsimple/Release/cefsimple
```

If you try to run the application `./cefsimple` it will show the Google page. Else you can provide your URL:
```
./cefsimple --url='https://cef-builds.spotifycdn.com/index.html'
```

### cefclient

This application demonstrates a wide range of CEF functionalities.

You can launch `cefclient`:
```bash
./tests/cefclient/Release/cefclient
```

### ceftests

Contains unit tests that exercise the CEF APIs.

You can launch `ceftests`:
```bash
 ./tests/ceftests/Release/ceftests
```

## Understanding how cefsimple is compiled

Since `cefsimple` is working, we no longer need it and we are using the copied folder `cefsimple2` and try to redo manually steps that cmake made for us, as seen in the previous section.

The application `cefsimple2` needs two local libs (one shared and one static) to be compiled:
- libcef.so (~1 Gb) already present within the tarball.
- libcef_dll_wrapper.a (~5 Mb) compiled thru cmake in the previous step.

The `libcef shared` library exports a C API that isolates the user from the CEF runtime and code base. The `libcef_dll_wrapper` project, which is distributed in source code form as part of the binary release, wraps this exported C API in a C++ API that is then linked into the client application.

Let copy them inside `cefsimple2`:
```bash
cp -v $CEF/Debug/libcef.so $CEF/build/libcef_dll_wrapper/libcef_dll_wrapper.a $CEFSIMPLE2
```

Let compile `cefsimple2` (c++ >= version 14 is needed). Since this example creates a X11 window, you'll need the X11 library `-lX11`:
```bash
g++ --std=c++14 -W -Wall -Wno-unused-parameter -DCEF_USE_SANDBOX -DNDEBUG -D_FILE_OFFSET_BITS=64 -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -I$CEF -I$CEF/include cefsimple_linux.cc simple_app.cc simple_handler.cc simple_handler_linux.cc -o cefsimple2 ./libcef.so ./libcef_dll_wrapper.a -lX11
```

- The `-DNDEBUG` is for disabling the `#include <assert>` (See https://stackoverflow.com/a/5354352/8877076)
- The `-DCEF_USE_SANDBOX` is explained here https://bitbucket.org/chromiumembedded/cef/wiki/SandboxSetup
- The `-D_FILE_OFFSET_BITS=64` is probably for working with files larger than 2Gb.
- The `-D__STDC_FORMAT_MACROS` is for https://www.cplusplus.com/reference/cinttypes/
- The `-I` are for searching header files in given folders.

Be sure your `LD_LIBRARY_PATH` is refering to the local folder (`.`), else add it (or save it insie your `~/.bashrc` file):
```bash
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
```

The other solution, more complex, is to update your `ld.so.conf.d` but I think the simplest solution will consit to modify the CMake to create a static library for libcef (`libcef.a`) to force loading symbols inside the binary.

If you try to run the application `./cefsimple2` it will halt. It needs some local packages. Let copy them (for the moment I do not know how they are compiled):
```bash
(cd $CEF/build/tests/cefsimple/Debug/
 cp -v icudtl.dat resources.pak chrome_100_percent.pak chrome_200_percent.pak v8_context_snapshot.bin $CEFSIMPLE2
)

mkdir -p $CEFSIMPLE2/locales
cp -v $CEF/build/tests/cefsimple/Debug/locales/en-US.pak $CEFSIMPLE2/locales
```

Summary files, from the CEF official documentation:
- chrome-sandbox: sandbox support binary.
- libcef.so: main CEF library.
- libcef_dll_wrapper.a: static library that all applications using the CEF C++ API must link against.
- icudtl.dat: unicode support data.
- cef.pak, devtools_resources.pak: non-localized resources and strings.
- natives_blob.bin, snapshot_blob.bin: V8 initial snapshot.
- locales/*.pak: locale-specific resources and strings.
- files/binding.html: cefclient application resources.

Here a screenshot of what you are supposed to have inside your folder:
![cef_simple](cef_simple.png)

If you try to run the application `./cefsimple2` it will show the Google page. Else you can provide your URL:
```
./cefsimple2 --url='https://cef-builds.spotifycdn.com/index.html'
```

I also copy:
```bash
cp $CEF/Debug/libGLESv2.so $CEF/Debug/libEGL.so $CEFSIMPLE2
```

To fix these errors:
```
[1122/222502.068976:ERROR:egl_util.cc(74)] Failed to load GLES library: ...
```

And I installed this system packages:
```bash
sudo apt-get install libxcb-sync-dev libxcb-dri3-dev libxcb-present-dev
```

To fix these errors:
```
[1122/222607.278155:WARNING:gpu_sandbox_hook_linux.cc(445)] dlopen(libxcb-dri3.so) failed with error: libxcb-dri3.so: Ne peut ouvrir le fichier d'objet partagé: Aucun fichier ou dossier de ce type
[1122/222607.278459:WARNING:gpu_sandbox_hook_linux.cc(447)] dlopen(libxcb-present.so) failed with error: libxcb-present.so: Ne peut ouvrir le fichier d'objet partagé: Aucun fichier ou dossier de ce type
[1122/222607.278567:WARNING:gpu_sandbox_hook_linux.cc(450)] dlopen(libxcb-sync.so) failed with error: libxcb-sync.so: Ne peut ouvrir le fichier d'objet partagé: Aucun fichier ou dossier de ce type
```

## Modifying cefsimple for OpenGL Core or SDL2

There are non-maintained GitHub repos to replace the libX11 by:
- SDL2: https://github.com/gotnospirit/cef3-sdl2
- OpenGL Core: https://github.com/if1live/cef-gl-example

These repos are outdated (> 4 years), they do not compile and when I run them they crashed because of an infinite loop forking the application and finally the system will fall down. I have updated them into https://github.com/Lecrapouille/OffScreenCEF (the OpenGL version needs a better conversion of key pressed between glfw3 types and CEF types). One of the main reason is the non respect of the logic:

```C++
int main(int argc, char* argv[])
{
  CefMainArgs main_args(argc, argv);

  // CEF applications have multiple sub-processes (render, plugin, GPU, etc)
  // that share the same executable. This function checks the command-line and,
  // if this is a sub-process, executes the appropriate logic.
  int exit_code = CefExecuteProcess(main_args, nullptr, nullptr);
  if (exit_code >= 0) {
    // The sub-process has completed so exit the application.
    return exit_code;
  }
```

`argc, argv` are used by CEF/Chromium when forking they are passing informatio

Explanation of the source code (OpenGL version) [cefsimple_opengl](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl)

- [GLCore.hpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/GLCore.hpp) it's just a collection of static methods (hence functions in a namespace) as a help to OpenGL to compile shaders:
  - The [vertex shader](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/shaders/tex.vert), which launches for each summit. Its input `position` is the position of the vertices. `MVP` (model view projection) is to apply the rotation on the vertices. `Texcoord` is the positions of the texture on the vertices.
  - Le [fragment shader](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/shaders/tex.frag) this is the fragment shader: the colors of the rectangle come from the colors of the texture. We remove the transparent pixels.

- [GLWindow.hpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/GLWindow.hpp#) it is a class which encapsulates a classic window created by the lib glfw3 (method `init ()`) there are the classic private and virtual methods `setup ()` and `update ()` which are called by the method `start ()` and which allow the daughter class to implement the game init and the game update.

- [main.hpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.hpp#L184)
c'est la classe qui hérite de la fenetre GLWindow, ajoute/supprime des "browsers" CEF (ligne 217 `std::vector<std::shared_ptr<BrowserView>> m_browsers;`) et implemente les methodes `setup()` et `update()`.

- [main.hpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.hpp#L25)
c'est la classe qui encapsule 3 classes privées qui dérivent de l'API CEF: `CefRenderHandler` et `CefClient` (ligne 70 et 139). `BrowserView::RenderHandler::OnPaint` (ligne 100) est appellée par CEF quand il veut que l'on dessine. Cette classe contient tout l'artirail OpenGL: chargement + compilation, du shader + l'envoi du buffer CEF vers la texture OpenGL. La classe `BrowserView` encapsule tout ca.

- [main.cpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L435) on demarre CEF qui lance tous ces forks.

- [main.cpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L435)
je créé 2 browser avec leurs URL. Ligne 364 je définie où OpenGL doit dessiner sur la fenetre (c'est en pourcentage de la dimension de la fenetre). Donc j'ai demandé de dessiner sur 2 régions verticales. Ligne 368: bidouille pour dire au a la classe renderer de faire tourner la texture. Ligne 371 je créé des callbacks sur les événements de la fenetre: click souris, souris bouge, touche du clavier, redimensionnement de la fenetre. Les callbacks sont dés la ligne 8: reshape_callback ... elles dispatch les événements vers les browsers (et convertissent les types glfw3 vers CEF. D'ailleurs mon code pour le clavier est buggé).

- [main.cpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L84 chargement du shader OpenGL) On crée un rectangle (2 triangles). On charge un shader pour chaque browser. https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L84 On dessine la texture dans le view port. https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L84 CEF nous demande le viewport qu'on lui envoie. https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L84 CEF nous envoie son image que l'on place dans la texture.

- [main.cpp](https://github.com/Lecrapouille/OffScreenCEF/blob/master/cefsimple_opengl/main.cpp#L397) c'est la fonction qui faudra remplacer car elle lit les messages et j'ai l'impression que c'est ca qui rend l'application peut reactive (clic souris ...) sinon lire une vidéo youtube est rapide (pas de temps de l'attence) mais le scrollbar d'une fenetre est super long.

Pour Godot on aura besoin du viewport: a gauche la scene 3D, à droite la page web (uniquement si on a cliquer sur un lien web). On n'aura pas besoin de shader OpenGL je pense qu'un sprite Godot devrait faire l'affaire.
