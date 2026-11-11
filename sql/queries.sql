/* PREGUNTA 1: Top 10 países con mayor facturación por empleado */
SELECT 
    c.country AS pais_destino,
    SUM(f.OperatingrevenueTurnover) AS ingresos,
    SUM(f.Numberofemployees) AS total_empleados,
    (SUM(f.OperatingrevenueTurnover)) / SUM(f.Numberofemployees) AS facturacion_por_empleado
FROM mreid_facts f
INNER JOIN dim_countries c ON f.iso3_d = c.iso3
WHERE f.year = 2021
GROUP BY f.iso3_d, c.country
HAVING SUM(f.OperatingrevenueTurnover) > 0 
   AND SUM(f.Numberofemployees) >= 100
ORDER BY facturacion_por_empleado DESC
LIMIT 10;

/* PREGUNTA 2: 10 países con menor facturación por empleado */
SELECT 
    c.country AS pais_destino,
    SUM(f.OperatingrevenueTurnover) AS ingresos,
    SUM(f.Numberofemployees) AS total_empleados,
    (SUM(f.OperatingrevenueTurnover)) / SUM(f.Numberofemployees) AS facturacion_por_empleado
FROM mreid_facts f
INNER JOIN dim_countries c ON f.iso3_d = c.iso3
WHERE f.year = 2021
GROUP BY f.iso3_d, c.country
HAVING SUM(f.OperatingrevenueTurnover) > 0 
   AND SUM(f.Numberofemployees) >= 100
ORDER BY facturacion_por_empleado ASC
LIMIT 10;

/* PREGUNTA 3: Obtén las filiales y activos por sector entre 2010 y 2021 (Facturación doméstica en España) */
SELECT
  s.naics2description as sector,
  f.year,
  SUM(f.extensive) as filiales,
  SUM(f.TotalassetsthUSD) as activos
FROM mreid_facts f
INNER JOIN dim_sectors s ON f.naics2 = s.naics2
WHERE f.year BETWEEN 2010 AND 2021 AND f.iso3_o = 'ESP' AND f.iso3_d = 'ESP'
GROUP BY s.naics2description, f.year;

/* PREGUNTA 4: Obtén el nº de filiales extranjeras e inversión en activos por sector, 2010-2021 */
SELECT
  s.naics2description as sector,
  f.year,
  SUM(f.extensive) as filiales,
  SUM(f.TotalassetsthUSD) as activos
FROM mreid_facts f
INNER JOIN dim_sectors s ON f.naics2 = s.naics2
WHERE f.year BETWEEN 2010 AND 2021 AND f.iso3_o != 'ESP' AND f.iso3_d = 'ESP'
GROUP BY s.naics2description, f.year;

/* PREGUNTA 5: Obtén la inversión extranjera (en EUR) en la Península Ibérica en 2020 */
SELECT
  c.country AS pais,
  CASE 
    WHEN COUNT(f.year) = 0 THEN 'sin datos'
    ELSE CAST(ROUND(SUM(f.TotalassetsthUSD_eur)/1000, 2) AS CHAR)
  END AS activos
FROM dim_countries c
LEFT JOIN mreid_facts f 
    ON c.iso3 = f.iso3_d 
   AND f.year = 2020 
   AND f.naics2 = 52 
   AND f.iso3_o <> f.iso3_d
WHERE c.iso3 IN ('ESP', 'PRT', 'AND')
GROUP BY c.iso3, c.country
ORDER BY c.country ASC;

/* PREGUNTA 6: Obtén facturación en Italia en 2015 para el sector Real Estate (en EUR) */
SELECT
  s.naics2description,
  SUM(f.OperatingrevenueTurnover_eur),
  SUM(f.Numberofemployees),
  (SUM(f.OperatingrevenueTurnover_eur)/NULLIF(SUM(f.Numberofemployees), 0)) AS media_por_empleado  
FROM mreid_facts f
INNER JOIN dim_sectors s ON f.naics2 = s.naics2
WHERE f.iso3_d = 'ITA' AND f.naics2 = 53 AND f.year = 2015
GROUP BY s.naics2description;

/* PREGUNTA 7: Mapa mundial */
SELECT 
  c.country,
  f.iso3_d,
  f.year,
  SUM(f.extensive) AS filiales,
  SUM(f.TotalassetsthUSD)/1000 AS activos
FROM mreid_facts f
INNER JOIN dim_countries c ON f.iso3_d = c.iso3 
GROUP BY f.iso3_d, c.country, f.year;

/* PREGUNTA 8: España */
SELECT 
  f.year,
  CASE  
    WHEN f.iso3_o = 'ESP' THEN 'Doméstica'
    ELSE 'Extranjera'
  END AS tipo_actividad,
  SUM(f.extensive) AS filiales,
  SUM(f.TotalassetsthUSD_eur)/1000 AS activos
FROM mreid_facts f
WHERE f.iso3_d = 'ESP' AND f.year BETWEEN 2010 AND 2021
GROUP BY f.year,
  CASE 
    WHEN f.iso3_o = 'ESP' THEN 'Doméstica'
    ELSE 'Extranjera'
  END 
ORDER BY f.year ASC;