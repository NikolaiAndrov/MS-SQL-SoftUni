----------------------------------------------------------------------------------
-- Consistency check PO ItemId if exist in Invent Table !!!!!
SELECT
	po.POHITEMID,
	inv.OLDITEMID
	FROM ##POHLTable as po
	LEFT JOIN ##InventTable as inv
	ON po.POHITEMID = inv.OLDITEMID
	WHERE inv.OLDITEMID IS NULL
	GROUP BY po.POHITEMID, inv.OLDITEMID
GO
----------------------------------------------------------------------------------


SELECT
	po.ITEMID AS PoItemId,
	inv.ITEMID AS InvItemId
	FROM ##POHLTable as po
	LEFT JOIN ##InventTable as inv
	ON po.ITEMID = inv.ITEMID
	WHERE inv.ITEMID IS NULL
	GROUP BY po.ITEMID, inv.ITEMID
GO

SELECT
	po.ITEMID AS PoItemId,
	inv.ITEMID AS InvItemId, 
	invt.*
	FROM ##POHLTable as po
	LEFT JOIN ##InventTable as inv
	ON po.ITEMID = inv.ITEMID
	LEFT JOIN ##InventTable invt
	ON po.POHITEMID = invt.OLDITEMID
	WHERE inv.ITEMID IS NULL
GO


-- Insert missing records into invent table
INSERT INTO ##InventTable (
	OLDITEMID,
	EnumStr_ItemType,
	EnumStr_PRODUCTSUBTYPE,
	ITEMNAME,
	DATAAREAID,
	ITEMIDCOMPANY,
	PRIMARYVENDORID,
	MODELGROUPID,
	ITEMGROUPID,
	DIMGROUPID,
	INTRACODE,
	SCHE_CRMPRODUCTCODE,
	BOMUNITID,
	LEGACYKEY,
	QUANTITY,
	ITEMID
)
SELECT
	invt.*
	FROM ##POHLTable as po
	LEFT JOIN ##InventTable as inv
	ON po.ITEMID = inv.ITEMID
	LEFT JOIN ##InventTable invt
	ON po.POHITEMID = invt.OLDITEMID
	WHERE inv.ITEMID IS NULL


----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check PO ItemId if equal to SERVICE/TAX
-- No result should be found
SELECT *
	FROM ##POHLTable
	WHERE [ItemId] = 'SERVICE/TAX'
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check PO VendorId if exist in Vendors Table
-- !!!!!!!!!!!!
-- PO Vendor 'd0841' on found in Vendors Table due to missing DIC/VATNUM field
-- WE also have a vendor with Id "po120" which might be an error
SELECT 
	po.VENDACCOUNT AS PoVendorId,
	vend.ACCOUNTNUM AS VendorId
	FROM ##POHLTable as po
	LEFT JOIN ##VendorsTable as vend
	ON po.VENDACCOUNT = vend.ACCOUNTNUM
	WHERE ISNULL(po.VENDACCOUNT, '') != ''
	and vend.ACCOUNTNUM is null
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check SOH CustomerId if exist in Customers Table
SELECT 
	soh.CUSTACCOUNT AS SohCustId,
	cust.ACCOUNTNUM AS CustomerId
	FROM ##SOHTable as soh
	LEFT JOIN ##CustomersTable as cust
	ON soh.CUSTACCOUNT = cust.ACCOUNTNUM
		WHERE soh.CUSTACCOUNT != ''
	and cust.ACCOUNTNUM is null
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check SOL ItemId if exist in Invent Table !!!!!
SELECT 
	sol.SOLITEMID,
	inv.OLDITEMID
	FROM ##SOLTable AS sol
	LEFT JOIN ##InventTable AS inv
	ON sol.SOLITEMID = inv.OLDITEMID
	WHERE inv.OLDITEMID IS NULL
	GROUP BY sol.SOLITEMID, inv.OLDITEMID
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check SOL ItemId if exist in Invent Table
--select * from ##inventtable
--select * from ##SOLTable

SELECT 
	sol.ITEMID AS SolItemId,
	inv.ITEMID AS InvItemId,
	invOld.*
	FROM ##SOLTable AS sol
	LEFT JOIN ##InventTable AS inv
	ON sol.ITEMID = inv.ITEMID
	LEFT JOIN ##Inventtable as invOLD
	on invOLD.OLDITEMID = sol.SOLITEMID
	WHERE inv.ITEMID is NULL
GO


-- Insert above missing items into invent table
INSERT INTO ##InventTable (
	OLDITEMID,
	EnumStr_ItemType,
	EnumStr_PRODUCTSUBTYPE,
	ITEMNAME,
	DATAAREAID,
	ITEMIDCOMPANY,
	PRIMARYVENDORID,
	MODELGROUPID,
	ITEMGROUPID,
	DIMGROUPID,
	INTRACODE,
	SCHE_CRMPRODUCTCODE,
	BOMUNITID,
	LEGACYKEY,
	QUANTITY,
	ITEMID
)
SELECT 
	invOld.*
	FROM ##SOLTable AS sol
	LEFT JOIN ##InventTable AS inv
	ON sol.ITEMID = inv.ITEMID
	LEFT JOIN ##Inventtable as invOLD
	on invOLD.OLDITEMID = sol.SOLITEMID
	WHERE inv.ITEMID is NULL
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Invent Table PRIMARYVENDORID if exist in Vendors Table

select * from ##VendorsTable where name like '%sch%'

SELECT 
	inv.PRIMARYVENDORID AS InventVendorId,
	vend.ACCOUNTNUM AS VendorsVendId
	FROM ##InventTable AS inv
	LEFT JOIN ##VendorsTable AS vend
	ON inv.PRIMARYVENDORID = vend.ACCOUNTNUM
	WHERE inv.PRIMARYVENDORID <> '' AND vend.ACCOUNTNUM IS NULL
	GROUP BY inv.PRIMARYVENDORID, vend.ACCOUNTNUM
GO


-- Insert missing vendors into vendors table
INSERT INTO ##VendorsTable (
	BLOCKED,
	PurchAmountPurchaseOrder,
	OFFSETACCOUNTTYPE,
	ACCOUNTNUM,
	NAME,
	ADDRESS,
	PHONE,
	VENDGROUP,
	PAYMTERMID,
	CURRENCY,
	VATNUM,
	INVENTLOCATION,
	DLVTERM,
	DLVMODE,
	BANKACCOUNT,
	PAYMMODE,
	EMAIL,
	TAXGROUP,
	CREDITMAX,
	NAMEALIAS,
	ITEMBUYERGROUPID,
	LANGUAGEID,
	DATAAREAID,
	LEGACYKEY
)
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
	FROM AdresarFirem [afv]
	LEFT JOIN Mena AS [m] ON [afv].MENA_UID = [m].UID
	LEFT JOIN BankovniSpojeni AS [bs] ON [afv].UID = [bs].LINK_UID
	LEFT JOIN Stat AS [st] ON [afv].STAT_UID = [st].UID
	WHERE [afv].ZKRATKA IN (
		SELECT 
			inv.PRIMARYVENDORID AS InventVendorId
		FROM ##InventTable AS inv
		LEFT JOIN ##VendorsTable AS vend
		ON inv.PRIMARYVENDORID = vend.ACCOUNTNUM
		WHERE inv.PRIMARYVENDORID <> '' AND vend.ACCOUNTNUM IS NULL
		GROUP BY inv.PRIMARYVENDORID, vend.ACCOUNTNUM
	)
	GROUP BY [afv].ZKRATKA
GO

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Consistency check Invent Table LEGACYKEY duplicates
SELECT LEGACYKEY
	FROM ##InventTable
	GROUP BY LEGACYKEY
	HAVING COUNT(1) > 1 
GO

SELECT ITEMID
	FROM ##InventTable
	GROUP BY ITEMID
	HAVING COUNT(1) > 1 
GO

-- Consistency check Invent Table LEGACYKEY duplicates
SELECT *
	FROM ##InventTable
	WHERE LEGACYKEY IS NULL
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Invent Table Module ItemId if exist in Invent Table
--select * from ##InventTable
--select * from ##InventTableStage

SELECT 
	invm.ITEMID AS InvmItemId,
	inv.ITEMID AS InvItemId
	FROM ##InventTableModule AS invm
	LEFT JOIN ##InventTable AS inv
	ON invm.ITEMID = inv.ITEMID
	WHERE  inv.ITEMID IS NULL
	GROUP BY invm.ITEMID, inv.ITEMID
GO

----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Invent Table Txt ItemId if exist in Invent Table
select * FROM ##InventTxtTable
SELECT 
	invtxt.ITEMID AS InvTxtItemId,
	inv.ITEMID AS InvItemId
	FROM ##InventTxtTable AS invtxt
	LEFT JOIN ##InventTable AS inv
	ON invtxt.ITEMID = inv.ITEMID
	WHERE inv.ITEMID IS NULL 
	GROUP BY invtxt.ITEMID, inv.ITEMID
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Cust Bank Account CustId if exist in Customers Table
SELECT 
	custbank.CUSTACCOUNT AS CustIdBank,
	custtbl.ACCOUNTNUM AS CustId
	FROM ##CustBankAccountTable AS custbank
	LEFT JOIN ##CustomersTable AS custtbl
	ON custbank.CUSTACCOUNT = custtbl.ACCOUNTNUM
	WHERE custtbl.ACCOUNTNUM is NULL
		GROUP BY custbank.CUSTACCOUNT, custtbl.ACCOUNTNUM
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Cust Address CustId if exist in Customers Table
SELECT 
	custadd.ACCOUNTNUM AS CustIdAdd,
	custtbl.ACCOUNTNUM AS CustId
	FROM ##CustAddressTable AS custadd
	LEFT JOIN ##CustomersTable AS custtbl
	ON custadd.ACCOUNTNUM = custtbl.ACCOUNTNUM
	WHERE custtbl.ACCOUNTNUM is NULL
	GROUP BY custadd.ACCOUNTNUM, custtbl.ACCOUNTNUM
GO


-- Isnert missing customers in customer table
INSERT INTO ##CustomersTable (
	ACCOUNTNUM,
	NAME,
	ADDRESS,
	INVOICEACCOUNT,
	CUSTGROUP,
	CURRENCY,
	PAYMMODE,
	DATAAREAID,
	LEGACYKEY,
	PAYMTERMID,
	DLVTERM,
	DLVMODE,
	CASHDISC,
	VATNUM
)
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
	FROM AdresarFirem AS [af]
	LEFT JOIN Stat AS [st]
	ON [af].STAT_UID = [st].UID
	LEFT JOIN Mena AS [m]
	ON [af].MENA_UID = [m].UID
	WHERE [af].ZKRATKA IN (
		SELECT 
			custadd.ACCOUNTNUM AS CustIdAdd
		FROM ##CustAddressTable AS custadd
		LEFT JOIN ##CustomersTable AS custtbl
		ON custadd.ACCOUNTNUM = custtbl.ACCOUNTNUM
		WHERE custtbl.ACCOUNTNUM is NULL
		GROUP BY custadd.ACCOUNTNUM, custtbl.ACCOUNTNUM
	)
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Customers VATNUM if exist in TaxVatNum Table
-- !!!!!!!!!!!!
-- Errors caused by missing Customer VatNum fields, they are empty
-- Errors caused by missing Customer "100106546'
SELECT 
	cst.VATNUM AS CustVatNum,
	taxv.VATNUM AS TaxVatNum
	FROM ##CustomersTable as cst
	LEFT JOIN ##TaxVatNumTable as taxv
	ON cst.VATNUM = taxv.VATNUM
	WHERE taxv.VATNUM IS NULL AND cst.VATNUM <> ''
	GROUP BY cst.VATNUM, taxv.VATNUM
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Vendors VATNUM if exist in TaxVatNum Table
SELECT 
	vend.VATNUM AS VendVatNum,
	taxv.VATNUM AS TaxVatNum
	FROM ##VendorsTable as vend
	LEFT JOIN ##TaxVatNumTable as taxv
	ON vend.VATNUM = taxv.VATNUM
	WHERE taxv.VATNUM IS NULL AND vend.VATNUM <> ''
	GROUP BY vend.VATNUM, taxv.VATNUM
GO


-- Insert missing VATs into vat table
INSERT INTO ##TaxVatNumTable (
	COUNTRYREGIONID,
	NAME,
	VATNUM,
	DATAAREAID,
	LEGACYKEY
)
SELECT 
    LEFT([af].DIC, 2) AS [COUNTRYREGIONID],
    MAX([af].NAZEV) AS [NAME],
    [af].DIC AS [VATNUM],
    'CZS' AS [DATAAREAID],
    MAX(af.UID) AS [LEGACYKEY]
    FROM AdresarFirem AS [af]
    WHERE [af].DIC IN (
		SELECT 
			vend.VATNUM AS VendVatNum
		FROM ##VendorsTable as vend
		LEFT JOIN ##TaxVatNumTable as taxv
		ON vend.VATNUM = taxv.VATNUM
		WHERE taxv.VATNUM IS NULL AND vend.VATNUM <> ''
		GROUP BY vend.VATNUM, taxv.VATNUM
	)
    GROUP BY [af].DIC
GO
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
-- Consistency check Vendors Bank Account VendorId if exist in Vendors Table
-- !!!!!!!!!!!!
-- Bank VendorsId not found in Vendors Table due to filter in ##VendorsTable DIC/VATNUM
SELECT 
	vbank.VENDACCOUNT AS VendIdBank,
	vend.ACCOUNTNUM AS VendId
	FROM ##VendBankAccountTable AS vbank
	LEFT JOIN ##VendorsTable AS vend
	ON vbank.VENDACCOUNT = vend.ACCOUNTNUM
	WHERE vend.ACCOUNTNUM IS NULL
	GROUP BY vbank.VENDACCOUNT, vend.ACCOUNTNUM
GO
----------------------------------------------------------------------------------