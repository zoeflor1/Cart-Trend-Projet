WITH tc_data AS (
    SELECT
        `événement_type`,
        SUM(clics) AS total_clics,
        SUM(conversions) AS total_conversion
    FROM
        {{ ref('stg_carttrend_campaigns') }}
    GROUP BY
        `événement_type`
)

SELECT
    `événement_type`,
    CASE
        WHEN total_clics > 0 THEN ROUND(CAST(total_conversion AS FLOAT64) / total_clics * 100, 2)
        ELSE 0
    END AS tc_moyen
FROM
    tc_data