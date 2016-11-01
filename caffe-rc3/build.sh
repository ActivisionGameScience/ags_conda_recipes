#!/bin/bash

mkdir build
cd build
ld && cd build
if [[ $(uname) == "Darwin" ]]; then
    # these two lines should be deleted after rc3 because the cmake file has since been fixed
    mv ../cmake/Modules/FindvecLib.cmake ../cmake/Modules/FindvecLib.cmake.orig
    sed "s/vecLib.h/cblas.h/g" ../cmake/Modules/FindvecLib.cmake.orig > ../cmake/Modules/FindvecLib.cmake
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCPU_ONLY=ON -DCMAKE_OSX_DEPLOYMENT_TARGET="" 
else
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCPU_ONLY=ON
fi
make all
make install
#make runtest
