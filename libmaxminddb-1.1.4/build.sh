#!/bin/bash

./bootstrap
./configure --prefix=$PREFIX

make
make install
