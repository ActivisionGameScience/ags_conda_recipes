mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=%PREFIX%

nmake
nmake install
