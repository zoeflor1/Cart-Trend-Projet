WITH ctr_data AS (
    SELECT
        `événement_type`,
        SUM(clics) AS total_clics,
        SUM(impressions) AS total_impressions
    FROM
        {{ ref('stg_carttrend_campaigns') }}
    GROUP BY
        `événement_type`
)

SELECT
    `événement_type`,
    CASE
        WHEN total_impressions > 0 THEN ROUND(CAST(total_clics AS FLOAT64) / total_impressions * 100, 2)
        ELSE 0
    END AS ctr_moyen
FROM
    ctr_data
