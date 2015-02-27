#!/bin/bash

mkdir $PREFIX/include
mkdir $PREFIX/lib

cp -ax include/* $PREFIX/include/
cp -ax lib/* $PREFIX/lib/
