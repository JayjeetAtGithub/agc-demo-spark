#!/bin/bash
set -ex

rm -rf /mnt/data
mkdir -p /mnt/data
for i in {1..64}; 
do
    cp Run2012B_SingleMu-1000.parquet /mnt/data/Run2012B_SingleMu-1000-$i.parquet
done
