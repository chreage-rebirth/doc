# Compilation of Brave's code source without Docker

Brave code source is made of two parts:
- https://github.com/brave/brave-core which contains the C++ code source.
- https://github.com/brave/brave-browser: the bootsraper for downloading
  third-parts and compiling brave-core.

The whole code source, git repos and compiled files of Brave will use more than
60 gigabytes on your hard disk (but this depends on your operating system) and
can hold several hours for compiling more than 50000 files. You have two choices
for compiling it:
- The straight method by following their documentation https://github.com/brave/brave-browser#clone-and-initialize-the-repo
- Our suggested method: using Docker.

This document explain the first point, while the second point is explained here https://github.com/chreage-rebirth/bootstrap/blob/master/README.md

## Linux operating system

Additional informations from steps described here:
https://github.com/brave/brave-browser#clone-and-initialize-the-repo:

- Clone the Brave's bootstrap:
```
git clone https://github.com/brave/brave-browser.git --depth=1
cd brave-browser
```

- Download third-parts (long since git history are downloaded):
```
npm install
npm run init
```

- Run this command which will list all dependancies to install through `apt-get`. It seems to list but not to install, you to copy-past it as `sudo`. More information: https://groups.google.com/a/chromium.org/g/chromium-discuss/c/loz4A_KrlfU?pli=1
```
./src/build/install-build-deps.sh
```

- Compile around 50 000 files:
```
npm run build
```

Depending on the environment of your operating system, you may have more or less
difficulties to compile Brave. Problems we had encountered:
- All third part elements are git cloning with their whole git history which
  takes a lot of space.
- On Debian 11, libappindicator3 has been removed and replaced by
  libayatana-appindicator ([more info](https://www.reddit.com/r/debian/comments/pn1oia/what_happened_to_libappindicator31_in_debian_11/)).
- You need the good version of node.js (v10.24.1: ok, v12.22.5: ko, v12.22.7:
  ok, v16.13.0: ko). Versions: https://github.com/nodesource/distributions#debinstall

These points are solved using the Dockerfile.

## Windows operating system

https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/windows_build_instructions.md#Visual-Studio

"Windows 10 SDK version 10.0.19041.0" is necessary for the compilation
https://developer.microsoft.com/en-us/windows/downloads/sdk-archive/

You will have to install the ATL library coming from with the compiler Visual Studio (for example the community version 2019).
Then you will have to copy the file `atls.lib` in the folder `lib` of the SDK:
```
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.19041.0\um\x64
```

Finally, you will have to install Python 3.8 and Node v12.
