#!/bin/bash

if [ ! -d results ]
then
    mkdir results
fi

cd src

for iteration in {1..10}
do
    mpirun --use-hwthread-cpus hpcc
    mv hpccoutf.txt "../results/iteration_$iteration.txt"
done