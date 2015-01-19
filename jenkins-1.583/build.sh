#!/bin/bash

mkdir -vp ${PREFIX}/bin;

if [ "$(uname)" == "Darwin" ]; then
    cp -va ${SRC_DIR}/jenkins.war ${PREFIX}/bin/ || exit 1;
else
    cp -var ${SRC_DIR}/jenkins.war ${PREFIX}/bin/ || exit 1;
fi
