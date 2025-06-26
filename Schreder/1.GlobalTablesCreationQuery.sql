DROP TABLE IF EXISTS ##TaxVatNumTable
DROP TABLE IF EXISTS ##PaymentTermsTable
DROP TABLE IF EXISTS ##CustBankAccountTable
DROP TABLE IF EXISTS ##CustAddressTable
DROP TABLE IF EXISTS ##CustomersTable
DROP TABLE IF EXISTS ##DeliveryModesTable
DROP TABLE IF EXISTS ##POHLTable
DROP TABLE IF EXISTS ##POHLTableStage
DROP TABLE IF EXISTS ##SOHTable
DROP TABLE IF EXISTS ##SOHTableStage
DROP TABLE IF EXISTS ##SOLTable
DROP TABLE IF EXISTS ##SOLTableStage
DROP TABLE IF EXISTS ##InventTable
DROP TABLE IF EXISTS ##InventTableStage
DROP TABLE IF EXISTS ##ExcelInventTable
DROP TABLE IF EXISTS ##ExcelInventSOTable
DROP TABLE IF EXISTS ##ExcelInventPOTable
DROP TABLE IF EXISTS ##InventTableModule 
DROP TABLE IF EXISTS ##InventTxtTable
DROP TABLE IF EXISTS ##VendBankAccountTable
DROP TABLE IF EXISTS ##VendorsTable
DROP TABLE IF EXISTS ##CustGroupsTable
DROP TABLE IF EXISTS ##DeliveryTermsTable


--Helper table creation

-- Invent Table generated from excel for the original Invent Table
SELECT 
	CONVERT(NVARCHAR(30), [íslo_díl]) AS ITEMID,
	[AX_confirm] AS NEWITEMCODE,
	[Zboží] AS ITEMNAME
	INTO ##ExcelInventTable
	FROM CZS_ItemsDeduplication_25_06
	WHERE [íslo_díl] IS NOT NULL
	GROUP BY [íslo_díl], [AX_confirm], [Zboží]
GO


 --Invent Table generated from excel for the SO Tables
--SELECT 
--	CONVERT(NVARCHAR(30), [íslo_díl]) AS ITEMID,
--	[AX_confirm] AS NEWITEMCODE,
--	[Zboží] AS ITEMNAME,
--	[Po_et_kus] AS QUANTITY,
--	SUBSTRING(OP_duel, 3, LEN(OP_duel)) AS SALESID
--	INTO ##ExcelInventSOTable
--	FROM CZS_ItemsDeduplication_25_06
--	WHERE [íslo_díl] IS NOT NULL
--	GROUP BY [íslo_díl], [AX_confirm], [Zboží], [Po_et_kus], [OP_duel]
--GO

SELECT 
    CONVERT(NVARCHAR(30), [íslo_díl]) AS ITEMID,
    [AX_confirm] AS NEWITEMCODE,
    [Zboží] AS ITEMNAME,
    [Po_et_kus] AS QUANTITY,
    SUBSTRING(OP_duel, 3, LEN(OP_duel)) AS SALESID,

    -- Safely convert mixed date formats
    CASE 
        WHEN [Termín_výroby] LIKE '__.__.____' THEN 
            TRY_CONVERT(DATETIME, 
                CONCAT(
                    SUBSTRING([Termín_výroby], 4, 2), '/', 
                    SUBSTRING([Termín_výroby], 1, 2), '/', 
                    SUBSTRING([Termín_výroby], 7, 4)
                ), 101
            )
        WHEN [Termín_výroby] LIKE '__/__/__' THEN 
            TRY_CONVERT(DATETIME, [Termín_výroby], 3)  -- dd/MM/yy
        WHEN [Termín_výroby] LIKE '__/__/____' THEN 
            TRY_CONVERT(DATETIME, [Termín_výroby], 103) -- dd/MM/yyyy
        ELSE NULL
    END AS SHIPPINGDATEREQUESTED,

    -- SHIPPINGDATEREQUESTED + 7 days
    DATEADD(DAY, 7, 
        CASE 
            WHEN [Termín_výroby] LIKE '__.__.____' THEN 
                TRY_CONVERT(DATETIME, 
                    CONCAT(
                        SUBSTRING([Termín_výroby], 4, 2), '/', 
                        SUBSTRING([Termín_výroby], 1, 2), '/', 
                        SUBSTRING([Termín_výroby], 7, 4)
                    ), 101
                )
            WHEN [Termín_výroby] LIKE '__/__/__' THEN 
                TRY_CONVERT(DATETIME, [Termín_výroby], 3)
            WHEN [Termín_výroby] LIKE '__/__/____' THEN 
                TRY_CONVERT(DATETIME, [Termín_výroby], 103)
            ELSE NULL
        END
    ) AS RECEIPTDATEREQUESTED

INTO ##ExcelInventSOTable
FROM CZS_ItemsDeduplication_25_06
WHERE [íslo_díl] IS NOT NULL
GROUP BY 
    [íslo_díl], 
    [AX_confirm], 
    [Zboží], 
    [Po_et_kus], 
    [OP_duel], 
    [Termín_výroby]


 --Invent Table generated from excel for the PO Tables
SELECT 
	CONVERT(NVARCHAR(30), [íslo_díl]) AS ITEMID,
	[AX_confirm] AS NEWITEMCODE,
	[Zboží] AS ITEMNAME,
	[Po_et_kus] AS QUANTITY,
	SUBSTRING(OV_duel, 3, LEN(OV_duel)) AS PURCHID
	INTO ##ExcelInventPOTable
	FROM CZS_ItemsDeduplication_25_06 
	WHERE [íslo_díl] IS NOT NULL
	GROUP BY [íslo_díl], [AX_confirm], [Zboží], [Po_et_kus], [OV_duel]
GO

--Helpers created

-- Tax Vat Num Table
SELECT 
    LEFT([af].DIC, 2) AS [COUNTRYREGIONID],
    MAX([af].NAZEV) AS [NAME],
    [af].DIC AS [VATNUM],
    'CZS' AS [DATAAREAID],
    MAX(af.UID) AS [LEGACYKEY]
	INTO ##TaxVatNumTable
    FROM AdresarFirem AS [af]
    WHERE  
        [af].DIC != '' 
        AND [af].AKTIVNI = 'True'
        --AND LEFT([af].DIC, 2) COLLATE Latin1_General_CS_AS LIKE '[A-Z][A-Z]'
    GROUP BY [af].DIC
GO


-- Payment Terms Table
SELECT DISTINCT 
	af.SPLATNOST AS [PAYMTERMID],
	CONCAT(af.SPLATNOST, ' dní') AS [DESCRIPTION],
	'CZS' AS [DATAAREAID],
	af.SPLATNOST AS [LEGACYKEY]
	INTO ##PaymentTermsTable
	FROM AdresarFirem AS af
	ORDER BY af.SPLATNOST
	GO


-- CustBankAccount Table
SELECT 
	[BANKCODETYPE] = 'Checking Account',
	[af].ZKRATKA AS [CUSTACCOUNT],
	[BANKGROUPID] = '',
	[bs].IBAN AS [BANKIBAN],
	[DATAAREAID] = 'CZS',
	[bs].UID AS [LEGACYKEY]
	INTO ##CustBankAccountTable
	FROM AdresarFirem AS [af]
	INNER JOIN BankovniSpojeni AS [bs]
	ON [af].UID = [bs].LINK_UID
	WHERE [af].AKTIVNI = 'True' AND [af].ZKRATKA LIKE 'O%' 
GO


-- CustAddress Table
SELECT
	[af].ZKRATKA AS [ACCOUNTNUM],
	[TYPE] = 2, -- Column not found, default value: Delivery. None - 0/Invoice - 1/Delivery - 2/Alt. delivery - 3/SWIFT - 4/Payment/Service/Confirming/Visit address
	[af].ADRESA1 AS [NAME],
	CONCAT_WS(' ', [af].ADRESA1, [af].CISLO_POPISNE_1, [af].PSC, [af].MISTO, [st].NAZEV) AS [ADDRESS],
	[DATAAREAID] = 'CZS',
	af.UID AS [LEGACYKEY]
	INTO ##CustAddressTable
	FROM AdresarFirem AS [af]
	LEFT JOIN Stat AS [st]
	ON [af].STAT_UID = [st].UID
	WHERE [af].AKTIVNI = 'True' AND [af].ZKRATKA LIKE 'O%'
GO


-- Custommers Table
SELECT DISTINCT 
	[af].ZKRATKA AS [ACCOUNTNUM],
	[af].NAZEV AS [NAME],	
	CONCAT_WS(' ', [af].ADRESA1, [af].CISLO_POPISNE_1, [af].PSC, [af].MISTO, [st].NAZEV) AS [ADDRESS],
	[INVOICEACCOUNT] = '',
	[CUSTGROUP] = 'TARLOC',
	[m].KOD AS [CURRENCY],
	[PAYMMODE] = '',
	[DATAAREAID] = 'CZS',
	[af].UID AS [LEGACYKEY],
	af.SPLATNOST AS [PAYMTERMID],
	[DLVTERM] = '',
	[DLVMODE] = '',
	[CASHDISC] = '',
	[af].DIC AS [VATNUM]
	INTO ##CustomersTable
	FROM AdresarFirem AS [af]
	LEFT JOIN Stat AS [st]
	ON [af].STAT_UID = [st].UID
	LEFT JOIN Mena AS [m]
	ON [af].MENA_UID = [m].UID
	WHERE [af].AKTIVNI = 'True' AND [af].ZKRATKA LIKE 'O%' --AND [af].DIC != '100106546'
GO

SELECT DISTINCT
	CUSTGROUP,
	CUSTGROUP AS [NAME],
	DATAAREAID,
	CUSTGROUP AS LEGACYKEY
    INTO ##CustGroupsTable
	FROM ##CustomersTable
GO

-- POHL Table
SELECT 
    --[CNTRECENTORDER] = 'NA',
	[COMPANY] = 'CZS',
	[CONFIGID] = '',
	--FORMAT([sov].VYTVORENO, 'dd/MM/yyyy HH:mm:ss') AS [CREATEDDATE],
	[INVENTCOLORID] = '',	
	[INVENTLOCATIONID] = '',	
	[INVENTREFID] = '',	
	[INVENTREFTRANSID] = '',	
	--[INVENTREFTYPE] = '',	
	[INVENTSITEID] = '',	
	[INVENTSIZEID] = '',	
	ISNULL([p].KOD, 'SERVICE/TAX') AS [ItemId],
	[sovp].UID AS [LEGACYKEY],
	--FORMAT([sov].DATUM_VYSTAVENI, 'dd/MM/yyyy HH:mm:ss') AS [ORDERDATE],
	[m].KOD AS [PRICECURRENCYCODE],
	[sovp].CENA_ZA_JEDNOTKU AS [PRICEUNIT],
	CONVERT(NVARCHAR(50), [sov].DOKLAD_CISLO) AS [PURCHID],
	--[PURCHLINERECID] = '',
	[sovp].CELKEM AS [PURCHPRICE],
	[sovp].MNOZSTVI AS [QUANTITY],
	--[QUANTITYREMAINDELIVERY] = '',
	[sovp].JEDNOTKA AS [QUANTITYUNITSYMBOL],
	--[RECID] = '',
	[afv].ZKRATKA AS [VENDACCOUNT]
	--[LINENUMBER] = ''
	INTO ##POHLTableStage
	FROM SkladovaObjednavkaVystavenaPolozka AS [sovp]
	LEFT JOIN SkladovaObjednavkaVystavena AS [sov]
	ON [sovp].LINK_UID = [sov].UID
	LEFT JOIN AdresarFirem AS [afv]
	ON [sov].DODAVATEL_UID = [afv].UID
	LEFT JOIN Produkt AS [p] 
	ON [sovp].PRODUKT_UID = [p].UID
	LEFT JOIN Mena AS [m]
	ON [sov].MENA_UID = [m].UID
	WHERE [sovp].TYP = 'O' AND DATEPART(YEAR, [sov].VYTVORENO) > 2023
        AND [sovp].MNOZSTVI > 0 
        AND [afv].ZKRATKA != 'po120'
        AND [p].kod != '10919'
	GROUP BY [p].KOD, [sovp].UID, [m].KOD, [sovp].CENA_ZA_JEDNOTKU,  [sov].DOKLAD_CISLO, 
	[sovp].CELKEM, [sovp].MNOZSTVI, [sovp].JEDNOTKA, [afv].ZKRATKA;
GO

--SELECT DISTINCT
--	tpohl.ITEMID AS [PohltemId],
--	tinv.ITEMID AS [InventItemId],
--	tinv.ITEMNAME
--	FROM #TempPOHLTable AS tpohl
--	LEFT JOIN #TempInventTable AS tinv
--	ON tpohl.ITEMID = tinv.ITEMID

WITH RankedTinv AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ITEMID, PURCHID, QUANTITY
               ORDER BY ITEMID  -- change this if you want a different priority
           ) AS rn
    FROM ##ExcelInventPOTable
)

SELECT 
    pohl.[COMPANY],
    pohl.[CONFIGID],
    pohl.[INVENTCOLORID],
    pohl.[INVENTLOCATIONID],
    pohl.[INVENTREFID],
    pohl.[INVENTREFTRANSID],
    pohl.[INVENTSITEID],
    pohl.[INVENTSIZEID],
    pohl.[ItemId] as POHITEMID,
    pohl.[LEGACYKEY],
    pohl.[PRICECURRENCYCODE],
    pohl.[PRICEUNIT],
    pohl.[PURCHID],
    pohl.[PURCHPRICE],
    pohl.[QUANTITY],
    pohl.[QUANTITYUNITSYMBOL],
    pohl.[VENDACCOUNT],
    --ISNULL(tinv.[ITEMID], '') AS [EXCELITEMID],
    --ISNULL(tinv.[NEWITEMCODE], '') AS [EXCELNEWITEMCODE],
    --ISNULL(tinv.[ITEMNAME], '') AS [EXCELITEMNAME],
    --ISNULL (tinv.[QUANTITY], pohl.[QUANTITY]) as EXCELQTY,
    --ISNULL(tinv.[PURCHID], '') AS [EXCELPURCHID],
    CONVERT(NVARCHAR(30), ISNULL(tinv.ITEMID, pohl.[ItemId]) +
        ISNULL(
            CASE 
                WHEN CHARINDEX('-', tinv.NEWITEMCODE) > 0 THEN
                    RIGHT(tinv.NEWITEMCODE, CHARINDEX('-', REVERSE(tinv.NEWITEMCODE) + '-') - 1)
                ELSE tinv.NEWITEMCODE
            END, ''
        ) +
        ISNULL(
            CASE 
                WHEN LEN(tinv.ITEMNAME) - LEN(REPLACE(tinv.ITEMNAME, '-', '')) >= 2 THEN
                    RIGHT(tinv.ITEMNAME,
                        CHARINDEX('-', REVERSE(tinv.ITEMNAME), CHARINDEX('-', REVERSE(tinv.ITEMNAME)) + 1) - 1
                    )
                ELSE tinv.ITEMNAME
            END, ''
        )
    ) AS ITEMID
INTO ##POHLTable
FROM ##POHLTableStage AS pohl
LEFT JOIN RankedTinv AS tinv
    ON pohl.ItemId = tinv.ITEMID
    AND pohl.QUANTITY = tinv.QUANTITY
    AND pohl.PURCHID = tinv.PURCHID
    --AND tinv.rn = 1  -- <== Only join top-ranked match
GO


-- SOH Table 
SELECT DISTINCT
	[EnumStr_SALESSTATUS] = 'Open order',
	[sop].DOKLAD_CISLO AS [SALESID],
	[afca].ZKRATKA AS [CUSTACCOUNT],
	CONCAT_WS(' ', [afra].ADRESA1, [afra].CISLO_POPISNE_1, [afra].PSC, [afra].MISTO, [st].NAZEV) AS [DELIVERYADDRESS],
	[SALESTAKER] = '002442',
	[PAYMENT] = '',
	[CASHDISC] = '',
	[DLVTERM] = 'DAP',
	RIGHT([sop].DOPRAVNI_DISPOZICE, 10) AS [DLVMODE],
	[afra].NAZEV AS [DELIVERYNAME],
	[CONTACTPERSONID] = '',
	[LANGUAGEID] = 'CZ',
	[SALESRESPONSIBLE] = '002442',
	[DATAAREAID] = 'CZS',
	[sop].UID AS [LEGACYKEY],
	[m].KOD AS [CURRENCYCODE],
	--[CUSTOMERREF] = '',
	--[PURCHORDERFORMNUM] = ''
	[sop].DOPRAVNI_DISPOZICE AS [REMOVE_DLVMODETXT]
	INTO ##SOHTableStage
	FROM SkladovaObjednavkaPrijata AS [sop]
	LEFT JOIN AdresarFirem AS [afca]
	ON [sop].ODBERATEL_UID = [afca].UID
	LEFT JOIN AdresarFirem AS [afra]
	ON [sop].PRIJEMCE_UID = [afra].UID
	LEFT JOIN Stat AS [st]
	ON [afra].STAT_UID = [st].UID
	LEFT JOIN Mena AS [m]
	ON [sop].MENA_UID = [m].UID
	LEFT JOIN SkladovaObjednavkaPrijataPolozka AS [sopp]
	ON [sop].UID = [sopp].LINK_UID
	WHERE [sopp].TYP = 'O'
	ORDER BY [sop].DOKLAD_CISLO
GO


-- Final ##SOHTable
SELECT 
    [EnumStr_SALESSTATUS],
	[SALESID],
	[CUSTACCOUNT],
	[DELIVERYADDRESS],
	[SALESTAKER],
	[PAYMENT],
	[CASHDISC],
	[DLVTERM],
	[DLVMODE],
	[DELIVERYNAME],
	[CONTACTPERSONID],
	[LANGUAGEID],
	[SALESRESPONSIBLE],
	[DATAAREAID],
	[LEGACYKEY],
	[CURRENCYCODE]
    INTO ##SOHTable
    FROM ##SOHTableStage
GO


SELECT --DISTINCT
	CASE 
		WHEN DLVMODE LIKE 'ava zdarma' THEN 10
		WHEN DLVMODE LIKE 'dodavatel' THEN 10
		WHEN DLVMODE LIKE 'ké centrum' THEN 10
		WHEN DLVMODE LIKE 'ně v PELMI' THEN 60
		WHEN DLVMODE LIKE 'na Rubešce' THEN 60
	END AS DLVMODE,
	DATAAREAID,
	CASE
		WHEN DLVMODE LIKE 'ava zdarma' THEN 'DAP'
		WHEN DLVMODE LIKE 'dodavatel' THEN 'DAP'
		WHEN DLVMODE LIKE 'ké centrum' THEN 'DAP'
		WHEN DLVMODE LIKE 'ně v PELMI' THEN 'EXW'
		WHEN DLVMODE LIKE 'na Rubešce' THEN 'EXW' 
	END AS DLVTERM
    INTO ##DeliveryTermsTable
	FROM ##SOHTable


SELECT 
	'CZS' AS DATAAREAID,
	[DLVMODE] AS CODE,
	[REMOVE_DLVMODETXT] AS TXT,
	[DLVMODE] AS LEGACYKEY
	INTO ##DeliveryModesTable
	FROM ##SOHTableStage
	GROUP BY [DLVMODE], [REMOVE_DLVMODETXT]
GO

-- SOL Table
SELECT 
    [EnumStr_SALESSTATUS] = 'Open order',
	[EnumStr_OpsPrintSpareLabel] = 'Yes',
	[EnumStr_OpsPrintSmartLabel] = 'Yes',
	[EnumStr_OPSAGGRESSIVEMODE] = 'No',
	[EnumStr_SCHDELIVERYTYPE] = 'None',
	CONVERT(NVARCHAR(20), [sop].DOKLAD_CISLO) AS [SALESID],
	ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [LineNum],
	--REPLACE(ISNULL([p].KOD, 'Add_' + [sopp].NAZEV), ' ', '') AS [ITEMID],
	--CASE 
	--	WHEN [p].KOD IS NULL THEN HASHBYTES('MD5', 'Add_' + REPLACE([sopp].NAZEV, ' ', ''))
	--	ELSE [p].KOD
	--END AS ITEMID,
	CASE 
		WHEN [p].KOD IS NULL THEN 
			'Add_' + LEFT(CONVERT(NVARCHAR(MAX), HASHBYTES('MD5', 'Add_' + REPLACE([sopp].NAZEV, ' ', '')), 2), 25)
		ELSE [p].KOD
	END AS ITEMID,
	[sopp].NAZEV AS [NAME],
	[EXTERNALITEMID] = '',
	[sopp].CENA_ZA_JEDNOTKU AS [SALESPRICE],
	[sopp].SLEVA_PROCENTNI AS [LINEPERCENT],
	[LINEDISC] = 0.00,
	[sopp].CELKEM AS [LINEAMOUNT],
	[sopp].JEDNOTKA AS [SALESUNIT],
	[PRICEUNIT] = 1,
	[INVENTTRANSID] = '',
	[af].ZKRATKA AS [CUSTACCOUNT],
	[sopp].MNOZSTVI AS [SALESQTY],
	[RECEIPTDATEREQUESTED] = '',
	[CUSTOMERLINENUM] = '',
	FORMAT(ISNULL([sopp].DATUM_EXPEDICE, '19000101'), 'MM/dd/yyyy') AS [RECEIPTDATECONFIRMED],
	FORMAT(ISNULL([sopp].DATUM_DODANI, '19000101'), 'MM/dd/yyyy') AS [SHIPPINGDATEREQUESTED],
	[SHIPPINGDATECONFIRMED] = '',
	[OPSFREETEXTLINE4] = '',
	[OPSFREETEXTLINE3] = '',
	[OPSFREETEXTLINE2] = '',
	[OPSFREETEXTLINE1] = '',
	[INVENTSIZEID] = '',
	[INVENTCOLORID] = '',
	[CONFIGID] = '',
	[SCHLSALESKITID] = '',
	[SCHLKITID] = '',
	[sopp].MNOZSTVI AS [REMAINSALESPHYSICAL],
	[DATAAREAID] = 'CZS',
	[sopp].UID AS [LEGACYKEY]
	INTO ##SOLTableStage
	FROM SkladovaObjednavkaPrijataPolozka AS [sopp]
	LEFT JOIN Produkt AS [p]
	ON [sopp].PRODUKT_UID = [p].UID 
	LEFT JOIN SkladovaObjednavkaPrijata AS [sop]
	ON [sopp].LINK_UID = [sop].UID
	LEFT JOIN AdresarFirem AS [af]
	ON [sop].ODBERATEL_UID = [af].UID
	WHERE [sopp].TYP = 'O' AND [sopp].MNOZSTVI > 0
	ORDER BY [sop].DOKLAD_CISLO
GO

--SELECT DISTINCT
--	tsol.ITEMID AS [SolItemId],
--	tinv.ITEMID AS [InventItemId],
--	tinv.ITEMNAME
--	FROM #TempSOLTable AS tsol
--	LEFT JOIN #TempInventTable AS tinv
--	ON tsol.ITEMID = tinv.ITEMID

--SELECT DISTINCT * FROM #TempInventTable

WITH RankedTinv AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ITEMID, SALESID, QUANTITY
               ORDER BY ITEMID  -- or whatever makes sense as the tiebreaker
           ) AS rn
    FROM ##ExcelInventSOTable
)

SELECT 
    sol.[EnumStr_SALESSTATUS],
    sol.[EnumStr_OpsPrintSpareLabel],
    sol.[EnumStr_OpsPrintSmartLabel],
    sol.[EnumStr_OPSAGGRESSIVEMODE],
    sol.[EnumStr_SCHDELIVERYTYPE],
    sol.[SALESID],
    sol.[LineNum],
    sol.[ITEMID] AS SOLITEMID,
    sol.[NAME],
    sol.[EXTERNALITEMID],
    sol.[SALESPRICE],
    sol.[LINEPERCENT],
    sol.[LINEDISC],
    sol.[LINEAMOUNT],
    sol.[SALESUNIT],
    sol.[PRICEUNIT],
    sol.[INVENTTRANSID],
    sol.[CUSTACCOUNT],
    sol.[SALESQTY],
    ISNULL(tinv.[RECEIPTDATEREQUESTED], sol.[RECEIPTDATEREQUESTED]) AS [RECEIPTDATEREQUESTED],
    sol.[CUSTOMERLINENUM],
    sol.[RECEIPTDATECONFIRMED],
    --ISNULL(tinv.[RECEIPTDATEREQUESTED], sol.[RECEIPTDATECONFIRMED]) AS [RECEIPTDATECONFIRMED],
    ISNULL(tinv.[SHIPPINGDATEREQUESTED], sol.[SHIPPINGDATEREQUESTED]) AS [SHIPPINGDATEREQUESTED],
    sol.[SHIPPINGDATECONFIRMED], 
    sol.[OPSFREETEXTLINE4],
    sol.[OPSFREETEXTLINE3],
    sol.[OPSFREETEXTLINE2],
    sol.[OPSFREETEXTLINE1],
    sol.[INVENTSIZEID],
    sol.[INVENTCOLORID],
    sol.[CONFIGID],
    sol.[SCHLSALESKITID],
    sol.[SCHLKITID],
    sol.[REMAINSALESPHYSICAL],
    sol.[DATAAREAID],
    sol.[LEGACYKEY],
    --ISNULL(tinv.[ITEMID], '') AS [EXCELITEMID],
    --ISNULL(tinv.[NEWITEMCODE], '') AS [EXCELNEWITEMCODE],
    --ISNULL(tinv.[ITEMNAME], '') AS [EXCELITEMNAME],
    --ISNULL(CONVERT(INT, tinv.[QUANTITY]), sol.[SALESQTY]) AS EXCELQTY,
    --ISNULL(tinv.[SALESID], '') AS [EXCELSALESID],
    CONVERT(NVARCHAR(30), ISNULL(tinv.ITEMID, sol.[ITEMID]) +
        ISNULL(
            CASE 
                WHEN CHARINDEX('-', tinv.NEWITEMCODE) > 0 THEN
                    RIGHT(tinv.NEWITEMCODE, CHARINDEX('-', REVERSE(tinv.NEWITEMCODE) + '-') - 1)
                ELSE tinv.NEWITEMCODE
            END, ''
        ) +
        ISNULL(
            CASE 
                WHEN LEN(tinv.ITEMNAME) - LEN(REPLACE(tinv.ITEMNAME, '-', '')) >= 2 THEN
                    RIGHT(tinv.ITEMNAME,
                        CHARINDEX('-', REVERSE(tinv.ITEMNAME), CHARINDEX('-', REVERSE(tinv.ITEMNAME)) + 1) - 1
                    )
                ELSE tinv.ITEMNAME
            END, ''
        )) AS ITEMID
INTO ##SOLTable
FROM ##SOLTableStage AS sol
LEFT JOIN RankedTinv AS tinv
    ON sol.ITEMID = tinv.ITEMID
    AND sol.SALESQTY = tinv.QUANTITY
    AND sol.SALESID = tinv.SALESID
    --AND tinv.rn = 1  -- <-- this filters to only the first match
GO


-- Invent Table
WITH RankedProducts AS (
    SELECT  
        CONVERT(NVARCHAR(30), [p].KOD) AS [ITEMID],
        [EnumStr_ItemType] = CONVERT(NVARCHAR(10), 'Item'),
        [EnumStr_PRODUCTSUBTYPE] = 'ProductMaster',
        [p].NAZEV AS [ITEMNAME],
        [DATAAREAID] = 'CZS',
        CONVERT(NVARCHAR(50), [p].VYROBEK_IDENTIFIKACE) AS [ITEMIDCOMPANY],
        ISNULL([af].ZKRATKA, '') AS [PRIMARYVENDORID],

        RIGHT('0000000000' + 
            CAST(ABS(CAST(CAST(HASHBYTES('MD5', [p].KOD) AS BINARY(8)) AS BIGINT)) % 10000000000 AS NVARCHAR(10)), 
        10) AS [MODELGROUPID],

        RIGHT('0000000000' + 
            CAST(ABS(CAST(CAST(HASHBYTES('MD5', [p].KOD) AS BINARY(8)) AS BIGINT)) % 10000000000 AS NVARCHAR(10)), 
        10) AS [ITEMGROUPID],

        RIGHT('0000000000' + 
            CAST(ABS(CAST(CAST(HASHBYTES('MD5', [p].KOD) AS BINARY(8)) AS BIGINT)) % 10000000000 AS NVARCHAR(10)), 
        10) AS [DIMGROUPID],

        RIGHT('0000000000' + 
            CAST(ABS(CAST(CAST(HASHBYTES('MD5', [p].KOD) AS BINARY(8)) AS BIGINT)) % 10000000000 AS NVARCHAR(10)), 
        10) AS [INTRACODE],

        RIGHT('0000000000' + 
            CAST(ABS(CAST(CAST(HASHBYTES('MD5', [p].KOD) AS BINARY(8)) AS BIGINT)) % 10000000000 AS NVARCHAR(10)), 
        10) AS [PBAInventItemGroupId],

        ROW_NUMBER() OVER (PARTITION BY [p].UID, [p].KOD ORDER BY [ps].MNOZSTVI DESC, [p].KOD) AS RN,

        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS [SCHE_CRMPRODUCTCODE],
        '' AS [BOMUNITID],
        CONVERT(NVARCHAR(128), [p].UID) AS [LEGACYKEY],
        [ps].MNOZSTVI AS [QUANTITY]
    FROM ProduktNaSklade AS [ps]
    LEFT JOIN Produkt AS [p]
        ON [ps].PRODUKT_UID = [p].UID
    LEFT JOIN AdresarFirem AS [af]
        ON [p].FIRMA_UID = [af].UID
    LEFT JOIN DruhProduktu AS [dp]
        ON [p].DRUH_PRODUKTU_UID = [dp].UID
    WHERE 
        ([p].KOD IN (SELECT ItemId FROM ##POHLTableStage)
        OR [p].KOD IN (SELECT ITEMID FROM ##SOLTableStage))
        OR ([ps].MNOZSTVI > 0)
        AND p.KOD NOT IN ('10919', 'N275815065020', 'P271A7023I2B')
    GROUP BY 
        [p].KOD, [p].NAZEV, [p].VYROBEK_IDENTIFIKACE, [af].ZKRATKA, [p].UID, [ps].MNOZSTVI
)
SELECT *
INTO ##InventTableStage
FROM RankedProducts
WHERE RN = 1 AND [PRIMARYVENDORID] NOT IN ('po120', 'd0009')
ORDER BY QUANTITY DESC;
GO


INSERT INTO ##InventTableStage
	(ITEMID, EnumStr_ItemType, EnumStr_PRODUCTSUBTYPE, ITEMNAME, DATAAREAID, ITEMIDCOMPANY, PRIMARYVENDORID, 
 MODELGROUPID, ITEMGROUPID, DIMGROUPID, INTRACODE, SCHE_CRMPRODUCTCODE, BOMUNITID, LEGACYKEY, QUANTITY)

SELECT 
	ITEMID,
	'Service', 
	'Product', 
	[NAME], 
	'CZS',
	ITEMID, -- it might be ITEMIDCOMPANY
	'', 
	RIGHT('0000000000' + 
    CAST(
        ABS(CAST(CAST(HASHBYTES('MD5', ITEMID) AS BINARY(8)) AS BIGINT)) % 10000000000 
        AS NVARCHAR(10)), 
    10),
	RIGHT('0000000000' + 
    CAST(
        ABS(CAST(CAST(HASHBYTES('MD5', ITEMID) AS BINARY(8)) AS BIGINT)) % 10000000000 
        AS NVARCHAR(10)), 
    10),
	RIGHT('0000000000' + 
    CAST(
        ABS(CAST(CAST(HASHBYTES('MD5', ITEMID) AS BINARY(8)) AS BIGINT)) % 10000000000 
        AS NVARCHAR(10)), 
    10),
	RIGHT('0000000000' + 
    CAST(
        ABS(CAST(CAST(HASHBYTES('MD5', ITEMID) AS BINARY(8)) AS BIGINT)) % 10000000000 
        AS NVARCHAR(10)), 
    10), 
	RIGHT('0000000000' + 
    CAST(
        ABS(CAST(CAST(HASHBYTES('MD5', ITEMID) AS BINARY(8)) AS BIGINT)) % 10000000000 
        AS NVARCHAR(10)), 
    10), 
	'',
	ITEMID,
	1
	FROM ##SOLTableStage
	WHERE ITEMID LIKE 'Add_%'
	GROUP BY ITEMID, NAME
GO

WITH RankedTinv AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ITEMID  -- Matching key from JOIN
               ORDER BY ITEMID  -- Adjust if needed
           ) AS rn
    FROM ##ExcelInventTable
)

SELECT 
    inv.[ITEMID] AS OLDITEMID,
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
	CASE 
	WHEN LEN(TRIM(inv.[LEGACYKEY] + CONVERT(NVARCHAR(5), tinv.rn))) > 0 THEN TRIM(inv.[LEGACYKEY] + CONVERT(NVARCHAR(5), tinv.rn))
	ELSE inv.[ITEMID] END as LEGACYKEY,
    inv.[QUANTITY],
    --ISNULL(tinv.[ITEMID], '') AS [ITEMID],
    --ISNULL(tinv.[NEWITEMCODE], '') AS [NEWITEMCODE],
    --ISNULL(tinv.[ITEMNAME], '') AS [ITEMNAME],
	
    CONVERT(NVARCHAR(30), ISNULL(tinv.ITEMID, inv.ITEMID) +
        ISNULL(
            CASE 
                WHEN CHARINDEX('-', tinv.NEWITEMCODE) > 0 THEN
                    RIGHT(tinv.NEWITEMCODE, CHARINDEX('-', REVERSE(tinv.NEWITEMCODE) + '-') - 1)
                ELSE tinv.NEWITEMCODE
            END, ''
        ) +
        ISNULL(
            CASE 
                WHEN LEN(tinv.ITEMNAME) - LEN(REPLACE(tinv.ITEMNAME, '-', '')) >= 2 THEN
                    RIGHT(tinv.ITEMNAME,
                        CHARINDEX('-', REVERSE(tinv.ITEMNAME), CHARINDEX('-', REVERSE(tinv.ITEMNAME)) + 1) - 1
                    )
                ELSE tinv.ITEMNAME
            END, ''
        )
    ) AS ITEMID
INTO ##InventTable
FROM ##InventTableStage AS inv
LEFT JOIN RankedTinv AS tinv
    ON inv.ITEMID = tinv.ITEMID
    --AND tinv.rn = 1  -- Only take one row per ITEMID


--	INSERT INTO ##InventTable 
--(ITEMID, EnumStr_ItemType,  EnumStr_PRODUCTSUBTYPE, ITEMNAME, DATAAREAID, ITEMIDCOMPANY, PRIMARYVENDORID, 
-- MODELGROUPID, ITEMGROUPID, DIMGROUPID, INTRACODE, SCHE_CRMPRODUCTCODE, BOMUNITID, LEGACYKEY, QUANTITY)
--VALUES ('SERVICE/TAX', 'Item', 'TaxCategory', 'Tax Service', 'CZS', 'ITEMIDCOMPANY', 'VENDORID', 9999, 9999, 9999, 9999, 9999, '', 'df6b1a0f-809d-4e47-9fe9-0be9b9e9ca76', 9999);
--GO


-- Invent Table Module
SELECT 
    CONVERT(NVARCHAR(30), ITEMID) AS [ITEMID],
    [EnumStr_MODULETYPE] = 'Invent',
    [UNITID] = 'pcs',
    [TAXITEMGROUPID] = 21,
    [DATAAREAID] = 'CZS',
    'Invent' + [LEGACYKEY] AS [LEGACYKEY]
	INTO ##InventTableModule
	FROM ##InventTable AS [inv]

-- Insert Sales module entries
INSERT INTO ##InventTableModule (ITEMID, EnumStr_MODULETYPE, UNITID, TAXITEMGROUPID, DATAAREAID, LEGACYKEY)
SELECT 
    CONVERT(NVARCHAR(30), ITEMID),
    'Sales',
    'pcs',
    21,
    'CZS',
    'Sales' + [LEGACYKEY] AS [LEGACYKEY]
	FROM ##InventTable


-- Insert Purch module entries
INSERT INTO ##InventTableModule (ITEMID, EnumStr_MODULETYPE, UNITID, TAXITEMGROUPID, DATAAREAID, LEGACYKEY)
	SELECT 
    CONVERT(NVARCHAR(30), ITEMID) AS ITEMID,
    'Purch',
    'pcs',
    21,
    'CZS',
    'Purch' + [LEGACYKEY] AS [LEGACYKEY]
	FROM ##InventTable
GO


-- Invent Txt Table
SELECT 
	CONVERT(NVARCHAR(30), [p].KOD) AS [ITEMID],
	[p].POPIS AS [TXT],
	[LANGUAGEID] = 'CS',
	[INVENTCOLORID] = '',
	[INVENTSIZEID] = '',
	[DATAAREAID] = 'CZS',
	[p].UID AS [LEGACYKEY]
	INTO ##InventTxtTable
	FROM ProduktNaSklade AS [ps]
	JOIN Produkt AS [p]
	ON [ps].PRODUKT_UID = [p].UID
	JOIN AdresarFirem AS [af]
	ON [p].FIRMA_UID = [af].UID
	JOIN DruhProduktu AS [dp]
	ON [p].DRUH_PRODUKTU_UID = [dp].UID
	WHERE [p].KOD IN (
						SELECT DISTINCT 
						[ITEMID]
						FROM ##InventTable
						WHERE (ITEMID IN (SELECT ITEMID FROM ##POHLTable)
						OR ITEMID IN (SELECT ITEMID FROM ##SOLTable)) OR (QUANTITY > 0)
					 ) 
	ORDER BY [ps].MNOZSTVI DESC
GO


-- Vendor Bank Account Table - Avoid duplicates
WITH Ranked AS (
  SELECT
    '' AS BANKCODETYPE,
    RIGHT([bs].BANKOVNI_UCET, 5) AS ACCOUNTID,
    bs.NAZEV AS NAME,
    st.ZKRATKA AS COUNTRYREGIONID,
    bs.BANKOVNI_UCET AS ACCOUNTNUM,
    afv.ZKRATKA AS VENDACCOUNT,
    '' AS SWIFTNO,
    '' AS BANKGROUPID,
    bs.IBAN AS BANKIBAN,
    'CZS' AS DATAAREAID,
    bs.UID AS LEGACYKEY,
    ROW_NUMBER() OVER (
      PARTITION BY bs.BANKOVNI_UCET, afv.ZKRATKA
      ORDER BY bs.UID DESC
    ) AS rn
  FROM AdresarFirem afv
  JOIN BankovniSpojeni bs ON afv.UID = bs.LINK_UID
  LEFT JOIN Stat st ON afv.STAT_UID = st.UID
  WHERE afv.AKTIVNI = 'True' AND afv.ZKRATKA LIKE 'D%' AND bs.BANKOVNI_UCET != ''
)
SELECT 
  BANKCODETYPE,
  ACCOUNTID,
  NAME,
  COUNTRYREGIONID,
  ACCOUNTNUM,
  VENDACCOUNT,
  SWIFTNO,
  BANKGROUPID,
  BANKIBAN,
  DATAAREAID,
  LEGACYKEY
  INTO ##VendBankAccountTable
FROM Ranked
WHERE rn = 1;
GO


-- Vendors Table
SELECT 
    '' AS [BLOCKED],
    '' AS [PURCHAMOUNTPURCHASEORDER],
    '' AS [OFFSETACCOUNTTYPE],
    [afv].ZKRATKA AS [ACCOUNTNUM],
    MAX([afv].NAZEV) AS [NAME],
    MAX(CONCAT_WS(' ', [afv].ADRESA1, [afv].CISLO_POPISNE_1, [afv].PSC, [afv].MISTO, [st].NAZEV)) AS [ADDRESS],
    MAX([afv].TELEFON) AS [PHONE],
    '' AS [VENDGROUP],
    MAX(CONVERT(NVARCHAR(10), [afv].SPLATNOST)) AS [PAYMTERMID],
    MAX([m].KOD) AS [CURRENCY], 
    MAX([afv].DIC) AS [VATNUM],
    '' AS [INVENTLOCATION],
    '' AS [DLVTERM],
    '' AS [DLVMODE],
    MAX([bs].BANKOVNI_KOD) AS [BANKACCOUNT],
    '' AS [PAYMMODE],
    MAX([afv].EMAIL) AS [EMAIL],
    '' AS [TAXGROUP],
    0.00 AS [CREDITMAX],
    '' AS [NAMEALIAS],
    '' AS [ITEMBUYERGROUPID],
    '' AS [LANGUAGEID],
    'CZS' AS [DATAAREAID],
    MAX([afv].UID) AS [LEGACYKEY]
	INTO ##VendorsTable
FROM AdresarFirem [afv]
LEFT JOIN Mena AS [m] ON [afv].MENA_UID = [m].UID
LEFT JOIN BankovniSpojeni AS [bs] ON [afv].UID = [bs].LINK_UID
LEFT JOIN Stat AS [st] ON [afv].STAT_UID = [st].UID
WHERE 
    [afv].AKTIVNI = 'True' 
    AND [afv].ZKRATKA LIKE 'D%' 
    --AND [afv].DIC != '' 
    --AND LEFT([afv].DIC, 2) COLLATE Latin1_General_CS_AS LIKE '[A-Z][A-Z]'
GROUP BY [afv].ZKRATKA
GO