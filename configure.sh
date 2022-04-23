#!/bin/bash

info_message () {
    echo -e "\n/**\n * $1\n */\n"
}

download_with_curl () {
    if [ ! -f "$2" ]
    then
        curl --location $1 --create-dirs --output $2
    fi
}

if [ $(id -u) != 0 ]
then
    echo "This script has to be run as root"
    exit 1
fi

if [ ! "$(grep 'avx' /proc/cpuinfo)" ]
then
    echo "The processor doesn't support the AVX instruction set required by MongoDB 5.0"
    exit 1
fi

mongo_ip=$1

if [ ! "$mongo_ip" ]
then
   echo "MongoDB IP binding not provided"
   exit 1
fi

cd "$(dirname ${BASH_SOURCE[0]})"

apt-get update -y
apt-get upgrade -y

info_message "Retrieving HPCC sources and dependencies"
apt-get install -y build-essential openmpi-bin libopenmpi-dev libatlas-base-dev
git clone --depth 1 --branch 1.5.0 https://github.com/icl-utk-edu/hpcc.git hpcc/src

$mem_size=$(grep MemTotal /proc/meminfo | awk '{print int($2 / 1024 * 0.8)}')
cp hpcc/Make.linux hpcc/src/hpl/Make.linux
cp hpcc/hpccmemf.txt hpcc/src/hpccmemf.txt
sed -i "s/<mem_size>/$mem_size/" hpcc/src/hpccmemf.txt

info_message "Building HPCC"
make -C hpcc/src arch=linux

info_message "Retrieving ONNX dependencies"
apt-get install -y mmv python3 python3-pip
pip install -r onnx/requirements.txt
download_with_curl "https://media.githubusercontent.com/media/onnx/models/main/vision/classification/mobilenet/model/mobilenetv2-7.tar.gz" temp/mobilenet.tar.gz
download_with_curl "https://media.githubusercontent.com/media/onnx/models/main/vision/classification/inception_and_googlenet/googlenet/model/googlenet-3.tar.gz" temp/googlenet.tar.gz
download_with_curl "https://media.githubusercontent.com/media/onnx/models/main/vision/classification/resnet/model/resnet34-v1-7.tar.gz" temp/resnet.tar.gz
    
extract_onnx_data () {
    archive=$1
    model_name=$2
    mkdir -p "onnx/data/$model_name" "onnx/data/$model_name/input"

    # Extract input files
    tar -xf $archive \
        -C "onnx/data/$model_name/input" \
        --strip-components 1 \
        --wildcards "*/input_0.pb" \
        
    # Extract model definition
    tar -xf $archive \
        -C "onnx/data/$model_name" \
        --strip-components 1 \
        --wildcards "*.onnx"

    mmv "onnx/data/$model_name/*.onnx" "onnx/data/$model_name/$model_name.onnx"
}

extract_onnx_data temp/mobilenet.tar.gz mobilenet
extract_onnx_data temp/googlenet.tar.gz googlenet
extract_onnx_data temp/resnet.tar.gz resnet

info_message "Configuring nginx"
apt-get install -y nginx
cp -r nginx/website/. /var/www/html

info_message "Configuring MongoDB instance"
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | \
    sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

apt-get update    
apt-get install -y mongodb-org
systemctl enable mongod.service
systemctl start mongod.service

info_message "Waiting for mongod to start..."
until nc -z localhost 27017
do
    sleep 1
done

info_message "Creating MongoDB admin user"
mongosh --quiet "mongodb://localhost/admin" ycsb/server/createUser.js

cp ycsb/server/mongod.conf /etc/mongod.conf
sed -i "s/<mongo_ip>/$mongo_ip/" /etc/mongod.conf
systemctl restart mongod

rm -rf temp
chown -R $SUDO_UID:$SUDO_GID .
info_message "Configuration complete"
exit 0