#!/bin/sh
set -e

export PRESTO_HOME=/opt/presto
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive
export PATH=$PATH:${HADOOP_HOME}:${HADOOP_HOME}/bin:$HIVE_HOME:/bin:.

$PRESTO_HOME/bin/launcher stop
$HIVE_HOME/hcatalog/sbin/hcat_server.sh stop

rm -rf $PRESTO_HOME
rm -rf $HIVE_HOME
rm -rf $HADOOP_HOME
rm -rf /user/hive/warehouse
