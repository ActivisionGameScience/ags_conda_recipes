#!/bin/bash

cd libraries/liblmdb
make
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include
cp -a liblmdb.* $PREFIX/lib
cp -a *.h $PREFIX/include
