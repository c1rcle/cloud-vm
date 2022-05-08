#!/bin/bash

fio --loops=5 --size=500m --filename=/mnt/fs/fiotest.tmp --stonewall --ioengine=libaio --direct=1 \
  --name=Seqread --bs=1m --rw=read \
  --name=Seqwrite --bs=1m --rw=write \
  --name=512Kread --bs=512k --rw=randread \
  --name=512Kwrite --bs=512k --rw=randwrite \
  --name=4kQD32read --bs=4k --iodepth=32 --rw=randread \
  --name=4kQD32write --bs=4k --iodepth=32 --rw=randwrite \
  > result.txt

rm -f /mnt/fs/fiotest.tmp