#!/bin/bash

mkdir build
cd build
cmake ../ -DCBLOSC_ROOT=$PREFIX  -DCMAKE_INSTALL_PREFIX=$PREFIX

make
make install
