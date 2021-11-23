# Getting fun with CEF

Tested on Debian 11 64-bits.

Firstly, let name some folders. This will shorter code in this document. Adapt the CEF version to ypur operating system with the desired
version on https://cef-builds.spotifycdn.com/index.html:
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

## Compile chrome-sandbox, cefclient, cefsimple, ceftests

### Cmake >= 3.19 is needed

You can look at this bash script to upgrade your cmake:
https://github.com/stigmee/doc/blob/master/doc/install_latest_cmake.sh

More information can be found at: https://pastebin.com/trVzB1J7

```bash
mkdir $CEF/build
cd $CEF/build
cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j$(nproc)
# make -j$(nproc) cefclient cefsimple ceftests
```

### cefsimple

Contains the cefsimple sample application configured to build
using the files in this distribution. This application demonstrates
the minimal functionality required to create a browser window.

You can launch `cefsimple`:
```bash
./tests/cefsimple/Release/cefsimple
```

### cefclient

Contains the cefclient sample application configured to build
using the files in this distribution. This application demonstrates
a wide range of CEF functionalities.

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

See also https://github.com/Zabrimus/cef-makefile-sample in where a `pkg-config` file is also created.

We are going to use the copied folder `cefsimple2` but not directly `cefsimple`.

The application `cefsimple2` needs two local libs (one shared and one static) to be compiled:
- libcef.so (~1 Gb)
- libcef_dll_wrapper.a (~5 Mb)

The libcef shared library exports a C API that isolates the user from the CEF runtime and code base. The libcef_dll_wrapper project, which is distributed in source code form as part of the binary release, wraps this exported C API in a C++ API that is then linked into the client application.

Let copy them inside `cefsimple2`:
```bash
cp -v $CEF/Debug/libcef.so $CEF/build/libcef_dll_wrapper/libcef_dll_wrapper.a $CEFSIMPLE2
```

Let compile `cefsimple2` (c++ >= version 14 is needed). Since this example creat X11 window you'll need the `-lX11`:
```bash
g++ --std=c++14 -W -Wall -Wno-unused-parameter -DCEF_USE_SANDBOX -DNDEBUG -D_FILE_OFFSET_BITS=64 -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -I$CEF -I$CEF/include cefsimple_linux.cc simple_app.cc simple_handler.cc simple_handler_linux.cc -o cefsimple2 ./libcef.so ./libcef_dll_wrapper.a -lX11
```

Be sure your `LD_LIBRARY_PATH` is refering to the local folder (`.`), else add it:
```bash
export LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH
```

The other solution more complex is to update your `ld.so.conf.d` but I think the simplest solution will consit to modify the CMake to create a static library for libcef (`libcef.a`) to force loading symbols inside the binary.

If you try to run the application `./cefsimple2` it will halt. It needs some local packages. Let copy them (for the moment I do not know how they are compiled):
```bash
(cd $CEF/build/tests/cefsimple/Debug/
 cp -v icudtl.dat resources.pak chrome_100_percent.pak chrome_200_percent.pak v8_context_snapshot.bin $CEFSIMPLE2
)

mkdir -p $CEFSIMPLE2/locales
cp -v $CEF/build/tests/cefsimple/Debug/locales/en-US.pak $CEFSIMPLE2/locales
```

- chrome-sandbox: sandbox support binary.
- libcef.so: main CEF library.
- libcef_dll_wrapper.a: static library that all applications using the CEF C++ API must link against.
- icudtl.dat: unicode support data.
- cef.pak, devtools_resources.pak: non-localized resources and strings.
- natives_blob.bin, snapshot_blob.bin: V8 initial snapshot.
- locales/*.pak: locale-specific resources and strings.
- files/binding.html: cefclient application resources.

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

WIP

There are non-maintained GitHub repos to replace the libX11 by:
- SDL2: https://github.com/gotnospirit/cef3-sdl2
- OpenGL Core: https://github.com/if1live/cef-gl-example

These repos are outdated (> 4 years), they do not compile and when I run them they crashed because of an infinite loop forking the application and finally the system will fall down. I'm currently updating them into https://github.com/Lecrapouille/OffScreenCEF
