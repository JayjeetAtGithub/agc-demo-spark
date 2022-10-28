SELECT
  FLOOR((
    CASE
      WHEN MET_pt < 0 THEN -1
      WHEN MET_pt > 2000 THEN 2001
      ELSE MET_pt
    END) / 20) * 20 + 10 AS x,
  COUNT(*) AS y
FROM hep
GROUP BY FLOOR((
    CASE
      WHEN MET_pt < 0 THEN -1
      WHEN MET_pt > 2000 THEN 2001
      ELSE MET_pt
    END) / 20) * 20 + 10
ORDER BY x;
