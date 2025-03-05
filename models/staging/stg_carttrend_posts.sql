WITH raw_data AS (
    SELECT 
        `id_post`,
        `date_post`,
        `canal_social`,
        `volume_mentions`,
        `sentiment_global`,
        `contenu_post`
    FROM `cart-trend-projet.CartTrend.Carttrend_Posts`
),

cleaned_data AS (
    SELECT DISTINCT
        `id_post`,
        `date_post`,
        `canal_social`,
        `volume_mentions`,
        `sentiment_global`,
        `contenu_post`
    FROM raw_data
)

-- Trier par id_post de manière croissante
SELECT *
FROM cleaned_data
ORDER BY `id_post` ASC
