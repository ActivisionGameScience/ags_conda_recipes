#!/bin/bash

cp Version $PREFIX
$PYTHON setup.py install --apidir $PREFIX
rm $PREFIX/Version
