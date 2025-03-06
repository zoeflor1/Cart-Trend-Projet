WITH raw_data AS (
    SELECT 
        `ID`,
        `Catégorie`,
        `Marque`,
        `Produit`,
        `Prix`,
        `Sous-catégorie`,
        `Variation`
    FROM `cart-trend-projet.CartTrend.Carttrend_Produits`
),

cleaned_data AS (
    SELECT 
        -- Remplacement des valeurs vides par 'NaN'
       `ID`,
        `Catégorie`,
        COALESCE(NULLIF(`Marque`, ''), 'NaN') AS `Marque`,
        `Produit`,
        `Prix`,
        COALESCE(NULLIF(`Sous-catégorie`, ''), 'NaN') AS `Sous_catégorie`,
        COALESCE(NULLIF(`Variation`, ''), 'NaN') AS `Variation`
    FROM raw_data
)

-- Sélectionner uniquement les lignes uniques sur la colonne ID
SELECT DISTINCT *
FROM cleaned_data
