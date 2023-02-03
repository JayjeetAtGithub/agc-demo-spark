SELECT
  HistogramBin(MET.pt, 0, 2000, 100) AS x,
  COUNT(*) AS y
FROM {input_table}
GROUP BY HistogramBin(MET.pt, 0, 2000, 100)
ORDER BY x;
