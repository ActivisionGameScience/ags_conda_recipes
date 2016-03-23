#export CFLAGS="-I$PREFIX/include"
#export LDFLAGS="-L$PREFIX/lib/libncursesw.so"
export LIBRARY_PATH="$PREFIX/lib"
./configure --with-features=huge \
            --disable-selinux \
            --enable-multibyte \
            --enable-python3interp \
            --with-python-config-dir=$PREFIX/lib/python3.5/config \
            --with-tlib=ncursesw \
            --enable-cscope --prefix=$PREFIX
make VIMRUNTIMEDIR=$PREFIX/share/vim/vim74
make install
