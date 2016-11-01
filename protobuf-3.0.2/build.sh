#!/bin/bash

sh autogen.sh
./configure --prefix=$PREFIX

C_INCLUDE_PATH=$PREFIX/include make
C_INCLUDE_PATH=$PREFIX/include make install

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION_VERSION=2

cd python
rm $SP_DIR/google/__init__.* # fixes conflict with google-apputils
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib python setup.py build --cpp_implementation
C_INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib python setup.py install --cpp_implementation
