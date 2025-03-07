WITH raw_data AS (
    SELECT 
        `id_promotion`,
        `id_produit`,
        `type_promotion`,
        `valeur_promotion`,
        `date_début`,
        `date_fin`,
        `responsable_promotion`
    FROM `cart-trend-projet.CartTrend.Carttrend_Promotions`
),

cleaned_data AS (
    SELECT 
        -- Transformation de id_promotion :
        -- 1. Supprime "PROM" du début
        -- 2. Assure que le format soit "P" suivi de 3 chiffres (P001, P099, P100, etc.)
        CONCAT('P', LPAD(REGEXP_REPLACE(`id_promotion`, r'PROM(\d+)', r'\1'), 3, '0')) AS `id_promotion`,

        `id_produit`,
        `type_promotion`,
        
        -- Conversion des dates en format DATE
        SAFE_CAST(`date_début` AS DATE) AS `date_debut_date`,
        SAFE_CAST(`date_fin` AS DATE) AS `date_fin_date`,
        `responsable_promotion`,
        
        -- Extraction des promotions en pourcentage et conversion en FLOAT64 (/100)
        COALESCE(
            CASE 
                WHEN REGEXP_CONTAINS(`valeur_promotion`, r'^\d+%$') 
                THEN CAST(REGEXP_REPLACE(`valeur_promotion`, '%', '') AS FLOAT64) / 100
            END, NULL) AS `valeur_pourcentage`,
        
        -- Extraction des promotions en euros et conversion en FLOAT64
        COALESCE(
            CASE 
                WHEN REGEXP_CONTAINS(`valeur_promotion`, r'^€\s*\d+,\d+$') 
                THEN CAST(REPLACE(REGEXP_REPLACE(`valeur_promotion`, r'€\s*', ''), ',', '.') AS FLOAT64)
                WHEN REGEXP_CONTAINS(`valeur_promotion`, r'^€\s*\d+$') 
                THEN CAST(REGEXP_REPLACE(`valeur_promotion`, r'€\s*', '') AS FLOAT64)
            END, NULL) AS `valeur_remise`

    FROM raw_data
)

SELECT * FROM cleaned_data