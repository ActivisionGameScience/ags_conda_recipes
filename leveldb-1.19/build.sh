#!/bin/bash

make
make check

mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

if [[ $(uname) == "Darwin" ]]; then
    cd out-shared
    libfile=`ls libleveldb.dylib.*.*`
    cd ..
    install_name_tool -id  @rpath/./$libfile out-shared/$libfile 
else
    echo "Do we need to relink for Linux?"
fi
mv out-shared/libleveldb.* $PREFIX/lib/

mv out-static/*.a $PREFIX/lib/
mv include/leveldb $PREFIX/include/
