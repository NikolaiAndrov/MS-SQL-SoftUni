-- Excel file name CZS_InventTableModule

SELECT 
	invm.ITEMID,
	invm.EnumStr_MODULETYPE,
	invm.UNITID,
	invm.TAXITEMGROUPID,
	invm.DATAAREAID,
	invm.LEGACYKEY
	FROM (
			SELECT *,
			ROW_NUMBER() OVER (PARTITION BY LEGACYKEY ORDER BY EnumStr_MODULETYPE) AS rn
			FROM ##InventTableModule
		 )	AS invm
	WHERE invm.rn = 1