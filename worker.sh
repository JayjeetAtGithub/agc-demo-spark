#!/bin/sh
set -ex

rm -rf spark*

VERSION=3.3.1

wget https://dlcdn.apache.org/spark/spark-$VERSION/spark-$VERSION-bin-hadoop3.tgz
tar -xvf spark-$VERSION-bin-hadoop3.tgz
cd spark-$VERSION-bin-hadoop3

./sbin/start-worker.sh $1

echo "Worker connected to spark://$1:7077"
