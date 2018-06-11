#!/bin/bash
export LC_ALL=C
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
apt-get update
mcdir -p /data/configdb
mcdir -p /data/db
mcdir -p /data/arb-rs0
mcdir -p /data/arb-rs1
apt-get install mongodb-org -y