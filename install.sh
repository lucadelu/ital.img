#!/bin/sh

# This file is useful to install ital.img dependencies

rm -f osmconvert
wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert

# TODO add mkgmap e splitter