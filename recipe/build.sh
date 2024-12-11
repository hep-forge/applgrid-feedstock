#! /usr/bin/bash

FFLAGS="-std=legacy" ./configure --prefix=${PREFIX}
make clean

make -j$(nproc)
make install

cp src/*.h $PREFIX/include/appl_grid
