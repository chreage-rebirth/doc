#!/bin/bash

# Instruction following
# https://trendoceans.com/how-to-install-cmake-on-debian-10-11/

VERSION=3.21.0

sudo apt-get remove -y cmake

cd /tmp
wget https://github.com/Kitware/CMake/releases/download/v$VERSION/cmake-$VERSION.tar.gz
tar xvf cmake-$VERSION.tar.gz
cd cmake-$VERSION

# ./bootstrap -- -DCMAKE_USE_OPENSSL=OFF
./bootstrap

gmake -j$(nproc)
sudo make install

cmake --version
