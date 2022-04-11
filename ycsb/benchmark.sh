#!/bin/bash

usage () {
    echo "YCSB benchmark
    -c  [required] Path to driver config
    -y  [required] Path to YCSB root folder
    -r  Database record count
    -t  Worker threads
    -o  Target operations per second"
    exit 1
}

record_count=100000
threads=1
target=100

while getopts p:c:y:r:t:o option; do
    case $option in
        (c) provider_config=$OPTARG;;
        (y) ycsb_root=$OPTARG;;
        (r) record_count=$OPTARG;;
        (t) threads=$OPTARG;;
        (o) target=$OPTARG;;
        (*) usage
    esac
done

if [ ! "$provider_config" ] || [ ! "$ycsb_root" ]
then
   echo "Required arguments not provided"
   usage
fi

run_benchmark () {
    ./bin/ycsb.sh load mongodb -P $1 \
        -P $provider_config \
        -p recordcount=$record_count \
        -s > "results/$2_load_result.txt"

    ./bin/ycsb.sh run mongodb -P $1 \
        -P $provider_config \
        -p recordcount=$record_count \
        -threads $threads \
        -target $target \
        measurementtype=timeseries \
        -s > "results/$2_run_result.txt"
}

mkdir results
provider_config=$(readlink -e "$provider_config")
echo "$provider_config"
cd $ycsb_root

# Update-heavy (workload A)
run_benchmark "workloads/workloada" "a"

# Read only (workload C)
run_benchmark "workloads/workloadc" "c"

# Read latest (workload D)
run_benchmark "workloads/workloadd" "d"

# Read-modify-write (workload F)
run_benchmark "workloads/workloadf" "f"

exit 0