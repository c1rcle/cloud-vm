#!/bin/bash

if [ ! -d bin ]
then
    git clone https://github.com/eembc/coremark.git bin
fi

if [ ! -d results ]
then
    mkdir results
fi

CPU_COUNT=$(nproc --all)

make -C bin clean
for iteration in {1..10}
do
    make -C bin
    mv bin/run1.log "results/single_core_run1_iter_$iteration.log"
    mv bin/run2.log "results/single_core_run2_iter_$iteration.log"
done

make -C bin clean
for iteration in {1..10}
do
    make -C bin XCFLAGS="-DMULTITHREAD=$CPU_COUNT -DUSE_PTHREAD -pthread"
    mv bin/run1.log "results/all_cores_run1_iter_$iteration.log"
    mv bin/run2.log "results/all_cores_run2_iter_$iteration.log"
done