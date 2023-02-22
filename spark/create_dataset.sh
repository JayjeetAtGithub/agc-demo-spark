#!/bin/bash
set -ex

rm -rf dataset/
mkdir -p dataset/
for i in {1..64}; 
do
    cp Run2012B_SingleMu-1000.parquet dataset/Run2012B_SingleMu-1000-$i.parquet
done
