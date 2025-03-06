WITH raw_data AS (
    SELECT 
        `id_promotion`,
        `id_produit`,
        `type_promotion`,
        `valeur_promotion`,
        `date_début`,
        `date_fin`,
        `responsable_promotion`,
    FROM `cart-trend-projet.CartTrend.Carttrend_Promotions`
),

cleaned_data AS (
    SELECT 
        `id_promotion`,
        `id_produit`,
        `type_promotion`,
        `date_début`,
        `date_fin`,
        `responsable_promotion`,
        
        -- Extraction des promotions en pourcentage (ex: "20%")
        COALESCE(
            CASE 
                WHEN REGEXP_CONTAINS(`valeur_promotion`, r'^\d+%$') 
                THEN REGEXP_REPLACE(`valeur_promotion`, '%', '') 
            END, 'NaN') AS `valeur_pourcentage`,
        
        -- Extraction des promotions en euros (ex: "€ 27,00" -> "27.00")
        COALESCE(
            CASE 
                WHEN REGEXP_CONTAINS(`valeur_promotion`, r'^€\s*\d+,\d+$') 
                THEN REPLACE(REGEXP_REPLACE(`valeur_promotion`, r'€\s*', ''), ',', '.')
                WHEN REGEXP_CONTAINS(`valeur_promotion`, r'^€\s*\d+$') 
                THEN REGEXP_REPLACE(`valeur_promotion`, r'€\s*', '')
            END, 'NaN') AS `valeur_remise`

    FROM raw_data
)

SELECT * FROM cleaned_data
