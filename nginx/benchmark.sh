#!/bin/bash

if [ ! -d results ]
then
    mkdir results
fi

name=$1
ip_address=$2
timestamp=$(date +%Y-%m-%dT%H-%M-%S)

if [ ! "$ip_address" ] || [ ! "$name" ]
then
   echo "Required arguments not provided: <name> <ip_address>"
   exit 1
fi

output_folder="results/$name/$timestamp"
mkdir -p "$output_folder/report"
jmeter -n -t nginx_test.jmx -Jtarget $ip_address -l $output_folder/result.txt -e -o $output_folder/report