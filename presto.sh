#!/bin/bash
set -e

apt update
apt install -y openjdk-8-jdk

rm -rf $HOME/workspace
mkdir -p $HOME/workspace
cp hive-default.xml.template $HOME/workspace
cd $HOME/workspace

wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar -xvf apache-hive-3.1.3-bin.tar.gz
rm -rf /opt/hive
mkdir -p /opt/hive
cp -r apache-hive-3.1.3-bin/. /opt/hive

wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
tar -xvf hadoop-3.3.1.tar.gz
rm -rf /opt/hadoop
mkdir -p /opt/hadoop
cp -r hadoop-3.3.1/. /opt/hadoop

wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server/0.278.1/presto-server-0.278.1.tar.gz
tar -xvf presto-server-0.278.1.tar.gz
rm -rf /opt/presto
mkdir -p /opt/presto
cp -r presto-server-0.278.1/. /opt/presto

export PRESTO_HOME=/opt/presto
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/hive
export PATH=$PATH:${HADOOP_HOME}:${HADOOP_HOME}/bin:$HIVE_HOME:/bin:.

$HADOOP_HOME/bin/hadoop fs -mkdir -p /user/hive/warehouse
cp hive-default.xml.template $HIVE_HOME/conf/hive-site.xml
mkdir -p $HIVE_HOME/hcatalog/var/log
$HIVE_HOME/bin/schematool -dbType derby -initSchema
$HIVE_HOME/hcatalog/sbin/hcat_server.sh start
mkdir -p $PRESTO_HOME/etc/catalog

cat > $PRESTO_HOME/etc/config.properties << EOF
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
discovery-server.enabled=true
discovery.uri=http://localhost:8080
EOF

cat > $PRESTO_HOME/etc/jvm.config << EOF
-server
-Xmx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
EOF

cat > $PRESTO_HOME/etc/node.properties << EOF
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/tmp/presto/data
EOF

cat > $PRESTO_HOME/etc/catalog/hive.properties << EOF
connector.name=hive-hadoop2
hive.metastore.uri=thrift://localhost:9083
EOF

cat > $PRESTO_HOME/etc/catalog/iceberg.properties << EOF
connector.name=iceberg
hive.metastore.uri=thrift://localhost:9083
iceberg.catalog.type=hive
EOF

$PRESTO_HOME/bin/launcher start

wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/0.278.1/presto-cli-0.278.1-executable.jar
chmod +x presto-cli-0.278.1-executable.jar
mv presto-cli-0.278.1-executable.jar /usr/local/bin/presto

## Notes:
# Hcat Server PID: /opt/hive/hcatalog/sbin/../var/log/hcat.pid
