#!/bin/bash

cp config.txt hpcc/hpccinf.txt
cd hpcc
mpirun -np 4 hpcc
cp hpccoutf.txt ../output.txt