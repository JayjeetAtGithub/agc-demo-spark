-- Make the structure of Electrons and Muons uniform, and then union their arrays
WITH uniform_structure_leptons AS (
  SELECT
    event,
    MET,
    array_union(
      transform(
        COALESCE(Muon, ARRAY()),
        x -> CAST( STRUCT(x.pt, x.eta, x.phi, x.mass, x.charge, 'm') AS STRUCT<pt: FLOAT, eta: FLOAT, phi: FLOAT, mass: FLOAT, charge: INT, type: CHAR(256)> )
      ),
      transform(
        COALESCE(Electron, ARRAY()),
        x -> CAST( STRUCT(x.pt, x.eta, x.phi, x.mass, x.charge, 'e') AS STRUCT<pt: FLOAT, eta: FLOAT, phi: FLOAT, mass: FLOAT, charge: INT, type: CHAR(256)> )
      )
    ) AS Leptons
  FROM hep_table_main_restructured
  WHERE cardinality(Muon) + cardinality(Electron) > 2
),


-- Create the Lepton pairs, transform the leptons using PtEtaPhiM2PxPyPzE and then sum the transformed leptons
lepton_pairs AS (
  SELECT
    *,
    CAST(
      STRUCT(
        l1.pt * cos(l1.phi) + l2.pt * cos(l2.phi),
        l1.pt * sin(l1.phi) + l2.pt * sin(l2.phi),
        l1.pt * ( ( exp(l1.eta) - exp(-l1.eta) ) / 2.0 ) + l2.pt * ( ( exp(l2.eta) - exp(-l2.eta) ) / 2.0 ),
        sqrt(l1.pt * cosh(l1.eta) * l1.pt * cosh(l1.eta) + l1.mass * l1.mass) + sqrt(l2.pt * cosh(l2.eta) * l2.pt * cosh(l2.eta) + l2.mass * l2.mass)
      ) AS
      STRUCT <x: REAL, y: REAL, z: REAL, e: REAL>
    ) AS l,
    idx1 AS l1_idx,
    idx2 AS l2_idx
  FROM uniform_structure_leptons
  LATERAL VIEW POSEXPLODE(Leptons) AS idx1,l1
  LATERAL VIEW POSEXPLODE(Leptons) AS idx2,l2
  WHERE idx1 < idx2 AND l1.type = l2.type AND l1.charge != l2.charge
),


-- Apply the PtEtaPhiM2PxPyPzE transformation on the particle pairs, then retrieve the one with the mass closest to 91.2 for each event
processed_pairs AS (
  SELECT
    event,
    min_by(
      STRUCT(
        l1_idx,
        l2_idx,
        Leptons,
        MET.pt,
        MET.phi
      ),
      abs(91.2 - sqrt(l.e * l.e - l.x * l.x - l.y * l.y - l.z * l.z))
    ) AS system
  FROM lepton_pairs
  GROUP BY event
),


-- For each event get the max pt of the other leptons
other_max_pt AS (
  SELECT event, CAST(max_by(sqrt(2 * system.pt * l.pt * (1.0 - cos((system.phi- l.phi + pi()) % (2 * pi()) - pi()))), l.pt) AS REAL) AS pt
  FROM processed_pairs
  LATERAL VIEW POSEXPLODE(system.Leptons) AS idx,l
  WHERE idx != system.l1_idx AND idx != system.l2_idx
  GROUP BY event
)


-- Compute the histogram
SELECT
  FLOOR((
    CASE
      WHEN pt < 15 THEN 14.99
      WHEN pt > 250 THEN 250.1
      ELSE pt
    END - 0.9) / 2.35) * 2.35 + 2.075 AS x,
  COUNT(*) AS y
FROM other_max_pt
GROUP BY FLOOR((
    CASE
      WHEN pt < 15 THEN 14.99
      WHEN pt > 250 THEN 250.1
      ELSE pt
    END - 0.9) / 2.35) * 2.35 + 2.075
ORDER BY x NULLS LAST;
