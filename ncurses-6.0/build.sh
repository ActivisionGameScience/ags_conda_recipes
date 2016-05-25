#!/bin/bash

sh ./configure --prefix=$PREFIX \
    --with-shared \
    --enable-widec
#    --with-termlib \
#    --enable-termcap \

make -j$(getconf _NPROCESSORS_ONLN)
make install

cd $PREFIX/lib
ln -s libncursesw.so libncurses.so
