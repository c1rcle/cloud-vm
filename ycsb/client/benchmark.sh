#!/bin/bash

usage () {
    echo "YCSB benchmark
    -y  [required] Path to YCSB root folder
    -c  [required] MongoDB connection string
    -n  [required] Test tag
    -r  Database record count
    -t  Worker threads
    -o  Target operations per second"
    exit 1
}

record_count=50000
threads=1
target=100

while getopts y:c:n:r:t:o: option; do
    case $option in
        (y) ycsb_root=$OPTARG;;
        (c) mongo_url=$OPTARG;;
        (n) tag=$OPTARG;;
        (r) record_count=$OPTARG;;
        (t) threads=$OPTARG;;
        (o) target=$OPTARG;;
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

    ./$ycsb_root/bin/ycsb.sh run mongodb -P $1 \
        -p mongodb.url=$mongo_url \
        -p recordcount=$record_count \
        -p measurementtype=timeseries \
        -threads $threads \
        -target $target \
        -s > "$output_folder/$2_run_result.txt"

    mongosh --quiet "$mongo_url" --eval "db.dropDatabase()"
}

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