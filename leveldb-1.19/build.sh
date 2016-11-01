#!/bin/bash

make
make check

mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

mv out-shared/libleveldb.* $PREFIX/lib/
mv out-static/*.a $PREFIX/lib/
mv include/leveldb $PREFIX/include/
