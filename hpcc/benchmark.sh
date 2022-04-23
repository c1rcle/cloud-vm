#!/bin/bash

cd src
mpirun --use-hwthread-cpus hpcc
mv hpccoutf.txt ../result.txt