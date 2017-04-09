#!/bin/bash

./configure --prefix=$PREFIX --build=$BUILD --host=$HOST
make
make check
make install
