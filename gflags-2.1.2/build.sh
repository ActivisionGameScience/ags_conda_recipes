#!/bin/bash

mkdir build && cd build
if [[ $(uname) == "Darwin" ]]; then
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_HEADERS=on -DBUILD_SHARED_LIBS=on -DCMAKE_OSX_DEPLOYMENT_TARGET=""
else
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_HEADERS=on -DBUILD_SHARED_LIBS=on
fi
make
make install
