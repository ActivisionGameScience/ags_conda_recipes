#!/bin/bash

C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib ./configure --prefix=$PREFIX --with-term-lib="ncursesw"

C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib make
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib make install
