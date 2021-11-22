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

## Understanding how cefsimple2 is compiled

See also https://github.com/Zabrimus/cef-makefile-sample/blob/master/Makefile

`cefsimple2` needs the two local libs (one shared and one static) to be compiled:
- libcef.so (~1 Gb)
- libcef_dll_wrapper.a (~5 Mb)

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

If you try to run the application `./cefsimple2` it will halt. It needs some local packages. Let copy them (for the moment I do not know how they are compiled):
```bash
(cd $CEF/build/tests/cefsimple/Debug/
 cp -v icudtl.dat resources.pak chrome_100_percent.pak chrome_200_percent.pak v8_context_snapshot.bin $CEFSIMPLE2
)

mkdir -p $CEFSIMPLE2/locales
cp -v $CEF/build/tests/cefsimple/Debug/locales/en-US.pak $CEFSIMPLE2/locales
```

If you try to run the application `./cefsimple2` it will show the google page. Else you can provide your URL:
```
./cefsimple2 --url='https://cef-builds.spotifycdn.com/index.html'
```
