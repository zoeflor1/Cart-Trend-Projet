WITH raw_data AS (
    SELECT 
        `id_post`,
        PARSE_DATE('%Y-%m-%d', `date_post`) AS date_post,  -- Conversion en DATE
        TRIM(`canal_social`) AS canal_social,
        `volume_mentions`,
        `sentiment_global`,
        `contenu_post`,
        EXTRACT(YEAR FROM PARSE_DATE('%Y-%m-%d', `date_post`)) AS annee_post,  -- Extraction de l'année
        EXTRACT(MONTH FROM PARSE_DATE('%Y-%m-%d', `date_post`)) AS mois_post,  -- Extraction du mois
        -- Création de la colonne mois-année au format mm-yyyy
        FORMAT_DATE('%Y-%m', PARSE_DATE('%Y-%m-%d', `date_post`)) AS mois_annee_post
    FROM `cart-trend-projet.CartTrend.Carttrend_Posts`
),

cleaned_data AS (
    SELECT DISTINCT
        `id_post`,
        `date_post`,
        `canal_social`,
        `volume_mentions`,
        `sentiment_global`,
        `contenu_post`,
        `annee_post`,
        `mois_post`,
        `mois_annee_post`
    FROM raw_data
)

-- Trier par id_post de manière croissante
SELECT *
FROM cleaned_data
ORDER BY mois_annee_post DESC