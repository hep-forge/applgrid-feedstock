#! /usr/bin/bash

FFLAGS="-std=legacy" ./configure --enable-no-undefined --prefix=${PREFIX}
make clean

make -j$(nproc)
make install

cp src/*.h $PREFIX/include/appl_grid
