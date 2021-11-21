# Getting fun with CEF

Tested on Debian 11 64-bits.

Download CEF and untar CEF: https://cef-builds.spotifycdn.com/index.html
For example, on Linux:

```bash
cd /tmp
wget https://cef-builds.spotifycdn.com/cef_binary_96.0.14+g28ba5c8+chromium-96.0.4664.55_linux64.tar.bz2
tar xvf cef_binary_96.0.14+g28ba5c8+chromium-96.0.4664.55_linux64.tar.bz2
```

## Cmake >= 3.19 needed

You can look at this bash script to upgrade your cmake:
https://github.com/stigmee/doc/blob/master/doc/install_latest_cmake.sh

## Compile chrome-sandbox, cefclient, cefsimple, ceftests

More information can be found at: https://pastebin.com/trVzB1J7

```bash
cd cef_binary_96.0.14+g28ba5c8+chromium-96.0.4664.55_linux64
mkdir build && cd build
cmake ..
make -j$(nproc)
# make -j$(nproc) cefclient cefsimple
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
