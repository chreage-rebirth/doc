# Compilation of Godot's code source on Windows

# Windows operating system

This document explains how to build Godot using the git sources. Building godot (instead of using pre-compiled builds) notably allows creating additional modules using c++, instead of just being able to use those existing in the plugin stores (assets library).

## Validate the installation of python / Scons

```
python --version
scons --version
```

If `scons` is not installed, it can be installed using the python package manager like so:
```
pip install scons
```

## Validate the installation of Visual Studio Build Tools

Build tools can be obtained here: https://visualstudio.microsoft.com/downloads/?q=build+tools

Once the build tools installed, locate the command line for the Visual Studio Native Tools. It should be located under:
```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2022\Visual Studio Tools\VC
```

Here we want to use the x64 Native Tools command prompt:
- Do not pick up the "Developer command prompt" as it would try to build an x86 distribution by default.
- Do not use the traditional cmd prompt as it does not replicate the necessary environment variable to run scons appropriately.

## Download the sources

Create a directory to hold the godot installation (In my case it's `D:\godot`) and clone the Godot git repository :

```
D:\>cd D:/godot

D:\godot>git clone https://github.com/godotengine/godot.git
Cloning into 'godot'...
remote: Enumerating objects: 435465, done.
remote: Counting objects: 100% (627/627), done.
remote: Compressing objects: 100% (351/351), done.
Receiving objects: 100% (435465/435465), 688.80 MiB | 19.26 MiB/s, done.4838Receiving objects: 100% (435465/435465), 685.82 MiB | 19.66 MiB/s

Resolving deltas: 100% (338643/338643), done.
Updating files: 100% (9147/9147), done.

D:\godot>
```

Note that downloading the sources as described will result in the installation of godot v4.0-dev custom installation (not into a 3.3-4 build like those installed using the pre-compiled binaries)

## Compilation

Navigate to the VC command prompt (or open the same one using the start menu)

```
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2022\Visual Studio Tools\VC
```

Open the x64 Native Tools command prompt and navigate to the installation directory. Here it's `D:\godot\godot` since our git clone was done from `D:\godot`:
```
D:/godot/godot
```

Start the compilation using scons :
```
scons platform=windows
```

This should result into the following build in `./bin`:
