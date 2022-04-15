#!/bin/bash

cp config.txt src/hpccinf.txt
cd src
mpirun -np 4 hpcc
cp hpccoutf.txt ../result.txt