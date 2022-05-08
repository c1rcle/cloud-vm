#!/bin/bash

usage () {
    echo "YCSB benchmark
    -y  [required] Path to YCSB root folder
    -c  [required] MongoDB connection string
    -n  [required] Test tag
    -r  Database record count
    -o  Database operation count (run)
    -t  Worker threads"
    exit 1
}

record_count=50000
operation_count=1000
threads=(1)

while getopts y:c:n:r:o:t: option; do
    case $option in
        (y) ycsb_root=$OPTARG;;
        (c) mongo_url=$OPTARG;;
        (n) tag=$OPTARG;;
        (r) record_count=$OPTARG;;
        (o) operation_count=$OPTARG;;
        (t) threads=$OPTARG;;
        (*) usage
    esac
done

if [ ! "$ycsb_root" ] || [ ! "$mongo_url" ] || [ ! "$tag" ]
then
   echo "Required arguments not provided"
   usage
fi

run_benchmark () {
    ./$ycsb_root/bin/ycsb.sh load mongodb -P $1 \
        -p mongodb.url=$mongo_url \
        -p mongodb.upsert=true \
        -p recordcount=$record_count \
        -s > "$output_folder/$2_load_result.txt"

    for tcount in "${threads[@]}"
    do
        let target_ops=$tcount*$target
        ./$ycsb_root/bin/ycsb.sh run mongodb -P $1 \
            -p mongodb.url=$mongo_url \
            -p recordcount=$record_count \
            -p operationcount=$operation_count \
            -p measurementtype=timeseries \
            -threads $tcount \
            -s > "$output_folder/$2-$tcount-result.txt"
    done

    mongosh --quiet "$mongo_url" --eval "db.dropDatabase()"
}

IFS=','
read -r -a threads <<< "$threads"

timestamp=$(date +%Y-%m-%dT%H-%M-%S)
output_folder="results/$tag/$timestamp"
mkdir -p $output_folder

# Update-heavy (workload A)
run_benchmark "$ycsb_root/workloads/workloada" "a"

# Read only (workload C)
run_benchmark "$ycsb_root/workloads/workloadc" "c"

# Read-modify-write (workload F)
run_benchmark "$ycsb_root/workloads/workloadf" "f"

exit 0