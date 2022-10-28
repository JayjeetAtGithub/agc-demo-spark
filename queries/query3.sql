SELECT
  FLOOR((
    CASE
      WHEN Jpt < 15 THEN 14.99
      WHEN Jpt > 60 THEN 60.01
      ELSE Jpt
    END - 0.15) / 0.45) * 0.45 + 0.375 AS x,
  COUNT(*) AS y
FROM hep
LATERAL VIEW EXPLODE(Jet_pt) as Jpt
LATERAL VIEW EXPLODE(Jet_eta) as Jeta 
WHERE abs(Jeta) < 1
GROUP BY FLOOR((
    CASE
      WHEN Jpt < 15 THEN 14.99
      WHEN Jpt > 60 THEN 60.01
      ELSE Jpt
    END - 0.15) / 0.45) * 0.45 + 0.375
ORDER BY x;
