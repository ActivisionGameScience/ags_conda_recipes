#!/bin/bash

# for some reason ansible hardcodes /usr/share everywhere.  AAAAHHHHH
find . -type f -exec sed -i 's!/usr/share!$PREFIX/share!g' {} +

$PYTHON setup.py install

# Add more build steps here, if they are necessary.

# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build process.
