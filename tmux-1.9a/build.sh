#!/bin/bash

sh autogen.sh
./configure --prefix=$PREFIX

C_INCLUDE_PATH=$PREFIX/include/ncursesw make
C_INCLUDE_PATH=$PREFIX/include/ncursesw make install
