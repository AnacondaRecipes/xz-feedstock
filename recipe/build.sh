#!/bin/bash

./configure --prefix=$PREFIX --host=$HOST
make
make check
make install
