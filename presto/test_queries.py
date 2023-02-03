#!/usr/bin/env python3

import io
import logging
import time
import subprocess

from os.path import dirname, joi
from urllib.parse import quote_plus, urlencode
from matplotlib import pyplot as plt
from abc import ABC, abstractmethod

import numpy as np
import pandas as pd


class PrestoProxy(ABC):
  @abstractmethod
  def run(self, query_file, other_params):
    pass


class PrestoCliProxy(PrestoProxy):
  def __init__(self, cmd, server, catalogue, schema):
    self.cmd = cmd
    self.server = server
    self.catalogue = catalogue
    self.schema = schema

  def run(self, query):
    # Assemble command
    cmd = [self.cmd,
           '--server', self.server,
           '--catalog', self.catalogue,
           '--schema', self.schema,
           '--file', '/dev/stdin',
           '--output-format', 'CSV_HEADER']

    # Run query and read result
    return subprocess.check_output(cmd, encoding='utf-8', input=query)


def init_presto():
  # By default use the CLI
  presto_cmd = 'presto'
  presto_server = 'localhost:8080'
  presto_catalogue = 'hive'
  presto_schema = 'default'
  logging.info('Using executable %s', presto_cmd)
  logging.info('Using server %s', presto_server)
  logging.info('Using catalogue %s', presto_catalogue)
  logging.info('Using schema %s', presto_schema)
  return PrestoCliProxy(presto_cmd, presto_server, presto_catalogue,
                        presto_schema)


def test_query(query_id):
    presto = init_presto()

    num_events = 1000
    input_table = 'Run2012B_SingleMu-1000.parquet'

    root_dir = join(dirname(__file__))
    query_dir = join(root_dir, 'queries', query_id)
    query_file = join(query_dir, 'query.sql')
    ref_file = join(query_dir, 'ref{}.csv'.format(num_events))
    png_file = join(query_dir, 'plot{}.png'.format(num_events))
    lib_file = join(root_dir, 'queries', 'common', 'functions.sql')

    # Read query
    with open(query_file, 'r') as f:
        query = f.read()
    query = query.format(
        input_table=input_table,
    )

    # Read function library
    with open(lib_file, 'r') as f:
        lib = f.read()
    query = lib + query

    # Run query and read result
    start_timestamp = time.time()
    output = presto.run(query)
    end_timestamp = time.time()
    df = pd.read_csv(io.StringIO(output),
                     dtype= {'x': np.float64, 'y': np.int32})
    logging.info(df)

    running_time = end_timestamp - start_timestamp
    logging.info('Running time: {:.2f}s'.format(running_time))

    # Find query ID
    query_id_query = \
        """SELECT MAX(query_id)
           FROM system.runtime.queries
           WHERE state = 'FINISHED';"""
    output = presto.run(query_id_query)
    query_id = pd.read_csv(io.StringIO(output), header=0, names=['query_id'])
    logging.info("Query ID: %s", query_id.query_id[0])

    # Normalize query result
    df = df[df.y > 0]
    df = df[['x', 'y']]
    df.x = df.x.astype(float).round(6)
    df.y = df.y.astype(int)
    df.reset_index(drop=True, inplace=True)

    # # Freeze reference result
    # if pytestconfig.getoption('freeze_result'):
    #   df.to_csv(ref_file, index=False)

    # Read reference result
    df_ref = pd.read_csv(ref_file, dtype= {'x': np.float64, 'y': np.int32})
    logging.info(df_ref)

    # Plot histogram
    plt.hist(df.x, bins=len(df.index), weights=df.y)
    plt.savefig(png_file)

    # Normalize reference and query result
    df_ref = df_ref[df_ref.y > 0]
    df_ref = df_ref[['x', 'y']]
    df_ref.x = df_ref.x.astype(float).round(6)
    df_ref.y = df_ref.y.astype(int)
    df_ref.reset_index(drop=True, inplace=True)

    # Assert correct result
    pd.testing.assert_frame_equal(df_ref, df)


if __name__ == '__main__':
  queries = [
    'query-1',
    'query-2',
    'query-3',
    'query-4',
    'query-5',
    'query-6-1',
    'query-6-2',
    'query-7',
    'query-8'
  ]
  for query in queries:
    test_query(query)
