SELECT
  FLOOR((
    CASE
      WHEN J.pt < 15 THEN 14.99
      WHEN J.pt > 60 THEN 60.01
      ELSE J.pt
    END - 0.15) / 0.45) * 0.45 + 0.375 AS x,
  COUNT(*) AS y
FROM hep_table_main_restructured
LATERAL VIEW EXPLODE(Jet) as J
WHERE abs(J.eta) < 1
GROUP BY FLOOR((
    CASE
      WHEN J.pt < 15 THEN 14.99
      WHEN J.pt > 60 THEN 60.01
      ELSE J.pt
    END - 0.15) / 0.45) * 0.45 + 0.375
ORDER BY x;
