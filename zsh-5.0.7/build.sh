#!/bin/bash

C_INCLUDE_PATH=$PREFIX/include ./configure --prefix=$PREFIX --with-term-lib="ncursesw"

C_INCLUDE_PATH=$PREFIX/include make
C_INCLUDE_PATH=$PREFIX/include make install
