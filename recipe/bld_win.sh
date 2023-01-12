#!/bin/bash

export BUILD=x86_64-w64-mingw32
export HOST=x86_64-w64-mingw32

./configure \
      --prefix=${PREFIX} \
      --enable-silent-rules \
      --disable-dependency-tracking \
      --disable-nls \
      --disable-scripts \
      --disable-threads \
      --disable-shared \
      --enable-small \
      --build=$BUILD \
      CFLAGS="-march=x86-64 -mtune=generic -Os"

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

cp -v src/liblzma/.libs/liblzma.a "$LIBRARY_PREFIX/lib/liblzma_static.lib"

make distclean

# Build the normal speed-optimized (shared) binaries.
./configure \
    --prefix= \
    --enable-silent-rules \
    --disable-dependency-tracking \
    --disable-nls \
    --disable-scripts \
    --build="$BUILD" \
    CFLAGS="-march=x86-64 -mtune=generic -O2"
make -C src/liblzma
make -C src/xz LDFLAGS=-static
make -C tests check

cp -v src/liblzma/.libs/liblzma-*.dll "$LIBRARY_PREFIX/bin/liblzma.dll"
cp -v src/liblzma/.libs/liblzma.a "$LIBRARY_PREFIX/lib/liblzma.lib"

find $PREFIX -name '*.la' -delete