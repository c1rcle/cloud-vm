#!/bin/bash

apt install -y build-essential openmpi-bin libopenmpi-dev libatlas-base-dev
git clone --depth 1 --branch 1.5.0 https://github.com/icl-utk-edu/hpcc.git
cp Make.linux hpcc/hpl/Make.linux

cd hpcc
make arch=linux