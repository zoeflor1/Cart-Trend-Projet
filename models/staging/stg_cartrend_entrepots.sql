-- models/staging/stg_entrepots.sql

SELECT
    `id_entrepôt`,

    -- Nettoyer la colonne localisation en supprimant les espaces au début et à la fin
    TRIM(localisation) AS localisation,

    -- Assurer que les valeurs de capacité_max, volume_stocké et taux_remplissage ne soient pas négatives
    -- Si elles sont négatives, les mettre à 0
    CASE
        WHEN `capacité_max` < 0 THEN 0
        ELSE `capacité_max`
    END AS capacite_max,

    CASE
        WHEN `volume_stocké` < 0 THEN 0
        ELSE `volume_stocké`
    END AS volume_stocke,

    CASE
        WHEN taux_remplissage < 0 THEN 0
        ELSE taux_remplissage
    END AS taux_remplissage,

    -- Conserver la température moyenne de l'entrepôt sans modification
    `température_moyenne_entrepôt`

FROM `cart-trend-projet.CartTrend.Carttrend_Entreprots`
WHERE `id_entrepôt` IS NOT NULL