#!/bin/bash

cd c++
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$PREFIX

make
make install
