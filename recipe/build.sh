#! /usr/bin/bash


mkdir build-scripts
cd build-scripts

cmake $RECIPE_DIR/scripts
cd ..

libtoolize
autoheader
aclocal
autoconf
automake --add-missing

FFLAGS="-std=legacy" ./configure --prefix=${PREFIX}
make clean

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install

cp src/*.h $PREFIX/include/appl_grid
ln -sf ./appl_grid/* $PREFIX/include
