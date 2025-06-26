-- Excel file name CZS_InventTable

SELECT 
    inv.[OLDITEMID],
    inv.[EnumStr_ItemType],
    inv.[EnumStr_PRODUCTSUBTYPE],
    inv.[ITEMNAME],
    inv.[DATAAREAID],
    inv.[ITEMIDCOMPANY],
    inv.[PRIMARYVENDORID],
    inv.[MODELGROUPID],
    inv.[ITEMGROUPID],
    inv.[DIMGROUPID],
    inv.[INTRACODE],
    inv.[PBAInventItemGroupId],
    inv.[SCHE_CRMPRODUCTCODE],
    inv.[BOMUNITID],
    inv.[LEGACYKEY],
    inv.[QUANTITY],
    inv.[ITEMID]
    FROM (                  
            SELECT *,
            DENSE_RANK() OVER (PARTITION BY [LEGACYKEY] ORDER BY ITEMNAME) AS rn
            FROM ##InventTable
          ) AS inv
    WHERE inv.rn = 1