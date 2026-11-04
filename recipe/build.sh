#! /usr/bin/bash


mkdir build-scripts
cd build-scripts

cmake $RECIPE_DIR/scripts
cd ..

# configure.ac finds libgfortran with a bare `gfortran` and looks for
# libgfortran.so. On macOS conda's gfortran is only target-prefixed and the
# library is libgfortran.dylib: FRTLLIB came out as "-L -lgfortran" and
# libtool refused it. Ask conda's $FC for the .dylib (configure.ac is
# regenerated below).
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i.bak -e 's/gfortran --print-file-name=libgfortran\.so/${FC} --print-file-name=libgfortran.dylib/' \
             -e "s/sed 's|libgfortran\.so||'/sed 's|libgfortran.dylib||'/" \
             -e 's/gfortran --print-file-name=libgfortran\.a/${FC} --print-file-name=libgfortran.a/' configure.ac
  rm -f configure.ac.bak
  grep -qF '${FC} --print-file-name=libgfortran.dylib' configure.ac
  # src/Makefile.am builds its own FRTLLIB the same way, with a bare
  # `gfortran` at make time. libgfortran.dylib is in $PREFIX/lib, which
  # conda's LDFLAGS already search: -lgfortran is enough.
  sed -i.bak 's/^    FRTLLIB  = -L\$(subst .*$/    FRTLLIB  = -lgfortran/' src/Makefile.am
  rm -f src/Makefile.am.bak
  if grep -q 'FRTLLIB  = -L' src/Makefile.am; then echo "FRTLLIB not replaced" >&2; exit 1; fi
fi

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
