SELECT
  HistogramBin(j.pt, 15, 60, 100) AS x,
  COUNT(*) AS y
FROM {input_table}
CROSS JOIN UNNEST(Jet) AS j
GROUP BY HistogramBin(j.pt, 15, 60, 100)
ORDER BY x;
