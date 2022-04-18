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

cd "$(dirname ${BASH_SOURCE[0]})"

info_message "Retrieving benchmark dependencies"
wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | \
    sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

apt-get update
apt-get install -y openjdk-11-jdk maven mongodb-mongosh

info_message "Downloading YCSB binaries"
download_with_curl "https://github.com/brianfrankcooper/YCSB/releases/download/0.17.0/ycsb-0.17.0.tar.gz" ycsb.tar.gz
mkdir ycsb-core
tar -xf ycsb.tar.gz -C ycsb-core --strip-components 1

rm ycsb.tar.gz
chown -R $SUDO_UID:$SUDO_GID .
info_message "Configuration complete"
exit 0