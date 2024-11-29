#! /usr/bin/bash

CFLAGS="-lm -lmvec -lgfortran" FFLAGS="-std=legacy" ./configure --prefix=${PREFIX}
make clean

make -j$(nproc)
make install

cp src/*.h $PREFIX/include/appl_grid
