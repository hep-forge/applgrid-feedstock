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

# The bundled config.sub predates arm64-apple-darwin hosts ("config.sub
# arm64-apple-darwin20.0.0 failed"), and automake keeps an existing one:
# use gnuconfig's, as the other autotools recipes here do.
if [[ "$(uname)" == "Darwin" ]]; then
  for f in config.sub config.guess; do
    find . -name "$f" -exec cp "$BUILD_PREFIX/share/gnuconfig/$f" {} \;
  done
fi

FFLAGS="-std=legacy" ./configure --prefix=${PREFIX}
make clean

NPROC=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
make -j$NPROC
make install

cp src/*.h $PREFIX/include/appl_grid
ln -sf ./appl_grid/* $PREFIX/include
