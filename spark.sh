#!/bin/sh
set -ex

rm -rf spark*

VERSION=3.3.1

apt update
apt install -y default-jre default-jdk python3-pip

wget https://dlcdn.apache.org/spark/spark-$VERSION/spark-$VERSION-bin-hadoop3.tgz
tar -xvf spark-$VERSION-bin-hadoop3.tgz
cd spark-$VERSION-bin-hadoop3

curl https://search.maven.org/remotecontent?filepath=org/apache/iceberg/iceberg-spark-runtime-3.3_2.12/1.1.0/iceberg-spark-runtime-3.3_2.12-1.1.0.jar -Lo jars/iceberg-spark-runtime-3.3_2.12-1.1.0.jar

./sbin/start-master.sh -h $1
./sbin/start-worker.sh spark://$1:7077

echo "Spark deployed at spark://$1:7077"
