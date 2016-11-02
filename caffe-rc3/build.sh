#!/bin/bash

mkdir build
cd build
ld && cd build


if [[ $(uname) == "Darwin" ]]; then
    pythonlib=`find $PREFIX -name "libpython*.dylib"`
    python_h=`find $PREFIX -name "Python.h"`
    pythoninc=`dirname $python_h` 
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCPU_ONLY=ON -DCMAKE_OSX_DEPLOYMENT_TARGET="" -DPYTHON_LIBRARY=$pythonlib -DPYTHON_INCLUDE_DIR=$pythoninc
else
    cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCPU_ONLY=ON
fi
make all
make install
#make runtest

# python stuff ends up in the wrong spot
mv $PREFIX/python/caffe $SP_DIR/
mv $SP_DIR/caffe/_caffe.dylib $SP_DIR/caffe/_caffe.so
mv $PREFIX/python/*.py* $PREFIX/bin/
rm $PREFIX/python/requirements.txt; rmdir $PREFIX/python
