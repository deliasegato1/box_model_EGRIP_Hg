#!/bin/bash -i
set -e
kpp box.kpp
make -fMakefile_box
./box.exe
