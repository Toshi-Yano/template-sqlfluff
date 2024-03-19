CREATE OR REPLACE TABLE
  `ntv_dm_content.master_content` ( 
    series_id INT64 OPTIONS(description = 'GRIDシリーズID'),
    series_name STRING OPTIONS(description = 'シリーズ名'),
    title_id INT64 OPTIONS(description = 'GRIDタイトルID'),
    title_name STRING OPTIONS(description = 'タイトル'),
    content_id INT64 OPTIONS(description = 'GRIDコンテンツID'),
    vr_title_id STRING OPTIONS(description = 'VRコード'))
OPTIONS (
  description="GRIDの番組マスターに紐づいたVR、AVODのコンテンツマスターテーブル"
)
AS
WITH master_content AS (
  SELECT
    m.grid_series_id,
    m.series_name,
    t.grid_title_id,
    MAX(CASE WHEN s.sns_inf = 'twitter' THEN s.code  ELSE NULL END) AS twitter_screanname,
    MAX(CASE WHEN s.sns_inf = 'Facebook' THEN s.code  ELSE NULL END) AS facebook_screanname,
    MAX(CASE WHEN s.sns_inf = 'Instagram' THEN s.code  ELSE NULL END) AS instagram_screanname,
    hp.code AS permalink,
    time_slot
  FROM
    `ntv_cwh.master_content` AS m,
    UNNEST(title) AS t,
    UNNEST(t.content) AS c,
    UNNEST(t.sns) AS s,
    UNNEST(t.site) AS hp
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 24, 25
),
vr_content AS (
  SELECT
    ...
    is_final
  FROM
    `ntv_cwh.master_broadcast_vr_daily_rating`
),
avod_content AS (
  SELECT
    ...
  FROM
    `ntv_cwh.master_avod_content` mac,
    UNNEST(movie) m,
    UNNEST(upload_file) u
),
cotent_summary AS (
  SELECT 
    ...
  FROM
    master_content mc
  LEFT OUTER JOIN avod_content ac 
    ON mc.content_id = ac.content_id 
  LEFT OUTER JOIN vr_content vc 
    ON mc.onair_date = vc.onair_date 
    AND mc.vr_title_id = vc.vr_title_id
)
SELECT 
  series_id,
  series_name,
  title_id,
  title_name,
  content_id,
  vr_title_id
FROM
  cotent_summary
