#!/bin/sh
set -ex

rm -rf spark*

wget https://dlcdn.apache.org/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz
tar -xvf spark-3.3.0-bin-hadoop3.tgz
cd spark-3.3.0-bin-hadoop3

./sbin/start-master.sh -h $1

echo "Connect workers to spark://$1:7077"
