#!/bin/bash

cp hpccmemf.txt src/hpccmemf.txt
cd src
mpirun -np 4 hpcc
cp hpccoutf.txt ../result.txt