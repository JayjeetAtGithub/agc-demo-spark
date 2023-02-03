# iceberg-spark-hep

## Installing Spark and PySpark

```bash
apt update
apt install -y default-jre default-jdk python3-pip

git clone https://github.com/JayjeetAtGithub/iceberg-spark-hep
cd iceberg-spark-hep/
./master.sh localhost
./worker.sh spark://localhost:7077

pip install pyspark
```

## Starting PySpark Shell

```bash
pyspark \
    --master spark://localhost:7077 \
    --packages org.apache.iceberg:iceberg-spark-runtime-3.2_2.12:1.1.0 \
    --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
    --conf spark.sql.catalog.local=org.apache.iceberg.spark.SparkCatalog \
    --conf spark.sql.catalog.local.type=hadoop \
    --conf spark.sql.catalog.local.warehouse=$PWD/warehouse \
    --conf spark.sql.defaultCatalog=local \
    --conf spark.sql.catalogImplementation=in-memory
```
