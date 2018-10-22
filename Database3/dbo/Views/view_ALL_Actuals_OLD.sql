

--drop view view_ALL_Actuals;


CREATE view [dbo].[view_ALL_Actuals_OLD] as


/**************************************************************************************************
-- view_PL_Actuals;   40000 - 99999 

Derived FROM view_COGSActuals:  Provides details on all entries that hit any accounts in the 60000 - 70000 range (COGS).

Queries all GP companies

Requirements:
	1. Linked server to Dynamics GP production SQL server, using
		datareader SQL user
	2. Create all views below in any new GP companies
	3. func_DatesInRange must be deployed
	4. view_PENRates must be deployed
	5. LU_COST_ABBRV table must be deployed and pop'd

Note: Using NOLOCKs as per Dynamics GP best practicies to avoid
		table locks.

2014-12-16		TR		Initial development
2014-12-17		TR		Fixed VENDORCODES
2014-12-24		TR		Expanded view to all companies
						Configured conversion calculations and exchange rates
						for all new companies to view
2015-01-28		TR		Added second column to store seg5
2015-08-26		TR		Adding new companies to view, updated requirements
2015-10-26		TR		Commented out companies: Gap Shipping, Planeterra, TJ
2017-03-05		GL		Created view_PL_Actuals from Orig view
2017-04-06		GL		Created view_ALL_Actuals from Orig view
2017-04-10		GL		Added Projects
2017-05-24		TR		Added unions for legal entities 33,51,52,53,55,56,61,86
2017-09-19		TR		Added union for company 65
2018-01-09		LE		Add in DSCRIPTN in addition to REFRENCE as a way to identify a project code

---------------------------------------------------------------------------------------------------------------
-- Views to create in new GP companies
---------------------------------------------------------------------------------------------------------------

create view [dbo].[vw_GL_Open_History_Union] as (
select JRNENTRY,REFRENCE,DSCRIPTN,TRXDATE,SOURCDOC,ORDOCNUM,ORGNTSRC,ACTINDX,CURNCYID,ORDBTAMT,DEBITAMT,ORCRDAMT,CRDTAMNT,ORPSTDDT,DEX_ROW_ID
from GL20000 
UNION
select JRNENTRY,REFRENCE,DSCRIPTN,TRXDATE,SOURCDOC,ORDOCNUM,ORGNTSRC,ACTINDX,CURNCYID,ORDBTAMT,DEBITAMT,ORCRDAMT,CRDTAMNT,ORPSTDDT,DEX_ROW_ID 
from GL30000)

create view [dbo].[vw_GL_Open_History_Union_All] as (
select JRNENTRY,REFRENCE,DSCRIPTN,TRXDATE,SOURCDOC,ORDOCNUM,ORGNTSRC, ORMSTRID, ACTINDX,CURNCYID,ORDBTAMT,DEBITAMT,ORCRDAMT,CRDTAMNT,ORPSTDDT,DEX_ROW_ID
from GL20000 
UNION
select JRNENTRY,REFRENCE,DSCRIPTN,TRXDATE,SOURCDOC,ORDOCNUM,ORGNTSRC, ORMSTRID ,ACTINDX,CURNCYID,ORDBTAMT,DEBITAMT,ORCRDAMT,CRDTAMNT,ORPSTDDT,DEX_ROW_ID 
from GL30000)

CREATE VIEW [dbo].[vw_PM_Open_History_Union]
	AS
(Select		pmopen.*
From		PM20000 pmopen 
Where		(pmopen.TRXSORCE LIKE 'PMTRX%' OR pmopen.TRXSORCE LIKE 'POIVC%')
AND		pmopen.BACHNUMB NOT LIKE 'DM%'
UNION
Select		pmhist.*
From		PM30200 pmhist
Where		(pmhist.TRXSORCE LIKE 'PMTRX%' OR pmhist.TRXSORCE LIKE 'POIVC%')
AND		pmhist.BACHNUMB NOT LIKE 'DM%')

CREATE VIEW [dbo].[vw_PM_Open_History_Union_All]
	AS
(Select		pmopen.*
From		PM20000 pmopen 
Where		(pmopen.TRXSORCE LIKE 'PMTRX%' OR pmopen.TRXSORCE LIKE 'POIVC%')
UNION
Select		pmhist.*
From		PM30200 pmhist
Where		(pmhist.TRXSORCE LIKE 'PMTRX%' OR pmhist.TRXSORCE LIKE 'POIVC%'))

**************************************************************************************************/


SELECT 
* ,

CASE WHEN REFRENCE  like '%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin AND fiscaldate < '2018M01'
AND dbo.isvalidProjectCode(dbo.removenumbersinstring(SUBSTRING(REFRENCE,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%'collate latin1_general_bin, REFRENCE),6))) = 1 
THEN dbo.removenumbersinstring(SUBSTRING(REFRENCE,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, REFRENCE),6)) 
WHEN REFRENCE like '%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin AND fiscaldate in ('2018M01','2018M02','2018M03')
AND dbo.isvalidProjectCode(dbo.removenumbersinstring(SUBSTRING(REFRENCE,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%'collate latin1_general_bin, REFRENCE),6))) = 1 
THEN dbo.removenumbersinstring(SUBSTRING(REFRENCE,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, REFRENCE),6)) 
WHEN REFRENCE like '%[A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin AND fiscaldate >= '2018M01'
AND dbo.isvalidProjectCode(SUBSTRING(REFRENCE,PATINDEX('%[A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, REFRENCE),4)) = 1 
THEN SUBSTRING(REFRENCE,PATINDEX('%[A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, REFRENCE),4)

WHEN DSCRIPTN  like '%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin AND fiscaldate < '2018M01'
AND dbo.isvalidProjectCode(dbo.removenumbersinstring(SUBSTRING(DSCRIPTN,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, DSCRIPTN),6))) = 1 
THEN dbo.removenumbersinstring(SUBSTRING(DSCRIPTN,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, DSCRIPTN),6)) 
WHEN DSCRIPTN like '%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin AND fiscaldate in ('2018M01','2018M02','2018M03')
AND dbo.isvalidProjectCode(dbo.removenumbersinstring(SUBSTRING(DSCRIPTN,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, DSCRIPTN),6))) = 1 
THEN dbo.removenumbersinstring(SUBSTRING(DSCRIPTN,PATINDEX('%[1-2][0-9][A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, DSCRIPTN),6)) 
WHEN DSCRIPTN like '[A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin AND fiscaldate >= '2018M01'
AND dbo.isvalidProjectCode(SUBSTRING(DSCRIPTN,PATINDEX('%[A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, DSCRIPTN),4)) = 1 
THEN SUBSTRING(DSCRIPTN,PATINDEX('%[A-Z][A-Z][A-Z][A-Z]%' collate latin1_general_bin, DSCRIPTN),4)
ELSE 'NoProject' END as Proj
FROM 
(
Select        
            '10' AS [COMPANY_MEMBERKEY],

            'Canada' AS [COMPANY],

            'GAPCA' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPCA.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT,  

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            1.0000000 AS CAD_XCHGRATE, cast(1/exch.XCHGRATE as numeric(18,7)) AS USD_XCHGRATE

From        TORFIN03.GAPCA.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPCA.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
												
/*Left Join	TORFIN03.GAPCA.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPCA.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPCA.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'CAD-USD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPCA.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
----AND glheader.REFRENCE <> 'Balance Brought Forward'

/*
UNION ALL

Select        
            '20' AS [COMPANY_MEMBERKEY],

            'Barbados' AS [COMPANY],

            'GAPBR' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPBR.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAPBR.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPBR.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPBR.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPBR.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPBR.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPBR.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'
*/


UNION ALL

Select        
            '30' AS [COMPANY_MEMBERKEY],

            'Austrailia' AS [COMPANY],

            'GAPAU' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPAU.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT,

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch1.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch2.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			exch1.XCHGRATE AS CAD_XCHGRATE, exch2.XCHGRATE AS USD_XCHGRATE

From         TORFIN03.GAPAU.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPAU.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPAU.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPAU.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPAU.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch1 WITH (NOLOCK) ON (exch1.EXGTBLID = 'AUD-CAD-AVG'
								   AND Month(exch1.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch1.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch2 WITH (NOLOCK) ON (exch2.EXGTBLID = 'AUD-USD-AVG'
								   AND Month(exch2.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch2.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPAU.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL

Select        
            '70' AS [COMPANY_MEMBERKEY],

            'Expedition' AS [COMPANY],

            'EXPSH' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.EXPSH.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT,

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.EXPSH.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.EXPSH.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.EXPSH.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.EXPSH.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.EXPSH.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.EXPSH.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

/*
UNION ALL


Select        
            '72' AS [COMPANY_MEMBERKEY],

            'GAP Shipping' AS [COMPANY],

            'GAPSH' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03..dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From        TORFIN03.GAPSH.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    TORFIN03.GAPSH.dbo.vw_PM_Open_History_Union_All pmview WITH (NOLOCK) ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPSH.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPSH.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPSH.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join    TORFIN03.GAPSH.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'
*/

/*
UNION ALL

Select        
            '95' AS [COMPANY_MEMBERKEY],

            'Planeterra' AS [COMPANY],

            'PLANE' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03..dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			1.0000000 AS CAD_XCHGRATE, cast(1/exch.XCHGRATE as numeric(18,7)) AS USD_XCHGRATE

From        TORFIN03.PLANE.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    TORFIN03.PLANE.dbo.vw_PM_Open_History_Union_All pmview WITH (NOLOCK) ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.PLANE.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.PLANE.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.PLANE.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'CAD-USD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join    TORFIN03.PLANE.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'
*/

UNION ALL

Select        
            '34' AS [COMPANY_MEMBERKEY],

            'US' AS [COMPANY],

            'GAPUS' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPUS.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From        TORFIN03.GAPUS.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPUS.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPUS.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPUS.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPUS.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPUS.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

/*
UNION ALL

Select        
            '90' AS [COMPANY_MEMBERKEY],

            'TJ' AS [COMPANY],

            'TJGLB' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03..dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			1.0000000 AS CAD_XCHGRATE, exch.XCHGRATE AS USD_XCHGRATE

From        TORFIN03.TJGLB.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    TORFIN03.TJGLB.dbo.vw_PM_Open_History_Union_All pmview WITH (NOLOCK) ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.TJGLB.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.TJGLB.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.TJGLB.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join    TORFIN03.TJGLB.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'
*/

UNION ALL

Select        
            '32' AS [COMPANY_MEMBERKEY],

            'UK' AS [COMPANY],

            'GAPUK' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPUK.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch1.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch2.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			cast(1/exch1.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, cast(1/exch2.XCHGRATE as numeric(18,7)) AS USD_XCHGRATE

From         TORFIN03.GAPUK.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPUK.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPUK.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPUK.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPUK.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch1 WITH (NOLOCK) ON (exch1.EXGTBLID = 'GBP-CAD-AVG'
								   AND Month(exch1.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch1.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch2 WITH (NOLOCK) ON (exch2.EXGTBLID = 'GBP-USD-AVG'
								   AND Month(exch2.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch2.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPUK.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL

Select        
            '54' AS [COMPANY_MEMBERKEY],

            'Costa Rica' AS [COMPANY],

            'GAPCR' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPCR.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT,

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From        TORFIN03.GAPCR.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPCR.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPCR.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPCR.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPCR.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	 TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPCR.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL

Select        
            '50' AS [COMPANY_MEMBERKEY],

            'Peru' AS [COMPANY],

            'GAPPE' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPPE.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((CASE WHEN cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) IS NULL 
				THEN
					cast(((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/(select TOP 1 XCHGRATE from PlanStage_DB.dbo.view_PENRates ORDER BY EXCHDATE ASC)) AS NUMERIC(18,5))
				ELSE
					cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5))
				END) * 1/cadexch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
			[USDNET] =  
				CASE WHEN cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) IS NULL 
				THEN
					cast(((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/(select TOP 1 XCHGRATE from PlanStage_DB.dbo.view_PENRates ORDER BY EXCHDATE ASC)) AS NUMERIC(18,5))
				ELSE
					cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5))
				END,

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
			cast((1/cadexch.XCHGRATE * 1/exch.XCHGRATE) as numeric(18,7)) AS CAD_XCHGRATE,
			CASE WHEN exch.XCHGRATE IS NULL
				THEN
					cast(1/(select TOP 1 XCHGRATE from PlanStage_DB.dbo.view_PENRates ORDER BY EXCHDATE ASC) as numeric(18,7))
				ELSE
					cast(1/exch.XCHGRATE as numeric(18,7))
				END AS USD_XCHGRATE

From        TORFIN03.GAPPE.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPPE.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPPE.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPPE.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPPE.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	PlanStage_DB.dbo.view_PENRates exch WITH (NOLOCK) ON (exch.EXGTBLID = 'PEN-USD-AVG'
								   AND Day(exch.EXCHDATE) = Day(glheader.TRXDATE)
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join	TORFIN03.DYNAMICS.dbo.MC00100 cadexch WITH (NOLOCK) ON (cadexch.EXGTBLID = 'USD-CAD-AVG'
								   AND Month(cadexch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(cadexch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPPE.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

--------------------------------------------------------------------------------------------------------------
-- New companies add 2015-08-26		TR
--------------------------------------------------------------------------------------------------------------

UNION ALL

Select        
            '80' AS [COMPANY_MEMBERKEY],

            '2244270 Ontario Inc' AS [COMPANY],

            'ALINC' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.ALINC.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            1.0000000 AS CAD_XCHGRATE, cast(1/exch.XCHGRATE as numeric(18,7)) AS USD_XCHGRATE

From        TORFIN03.ALINC.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.ALINC.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINC.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.ALINC.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.ALINC.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'CAD-USD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.ALINC.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL

Select        
            '82' AS [COMPANY_MEMBERKEY],

            'Altun Group LTD' AS [COMPANY],

            'ALGRP' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.ALGRP.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            1.0000000 AS CAD_XCHGRATE, cast(1/exch.XCHGRATE as numeric(18,7)) AS USD_XCHGRATE

From        TORFIN03.ALGRP.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.ALGRP.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALGRP.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.ALGRP.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.ALGRP.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'CAD-USD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.ALGRP.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL

Select        
            '84' AS [COMPANY_MEMBERKEY],

            'Altun Investments Inc' AS [COMPANY],

            'ALINV' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.ALINV.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.ALINV.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.ALINV.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.ALINV.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.ALINV.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.ALINV.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

/*

--Placeholder for new Ontario company
--Change first three items on select and database name for froms/joins

UNION ALL

Select        
            '82' AS [COMPANY_MEMBERKEY],

            'Altun Group LTD' AS [COMPANY],

            'ALGRP' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03..dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [CADNET],
			cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            1.0000000 AS CAD_XCHGRATE, cast(1/exch.XCHGRATE as numeric(18,7)) AS USD_XCHGRATE

From        TORFIN03.ALGRP.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    TORFIN03.ALGRP.dbo.vw_PM_Open_History_Union_All pmview WITH (NOLOCK) ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALGRP.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.ALGRP.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.ALGRP.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join	TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'CAD-USD-AVG'
								   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
								   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
Left Join    TORFIN03.ALGRP.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

*/

UNION ALL


Select        
            '33' AS [COMPANY_MEMBERKEY],

            'G Adventures GmbH' AS [COMPANY],

            'GADVG' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GADVG.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GADVG.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GADVG.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GADVG.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GADVG.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GADVG.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '51' AS [COMPANY_MEMBERKEY],

            'G Adventures BA S.R.L (Argentina)' AS [COMPANY],

            'GAVBA' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAVBA.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAVBA.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAVBA.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAVBA.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAVBA.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAVBA.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '58' AS [COMPANY_MEMBERKEY],

            'G Adventures South Africa (PTY) Ltd' AS [COMPANY],

            'GAPSA' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPSA.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAPSA.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPSA.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPSA.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPSA.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPSA.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '52' AS [COMPANY_MEMBERKEY],

            'G Adventures S.A. Gadsador' AS [COMPANY],

            'GAPEC' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPEC.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAPEC.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPEC.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPEC.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPEC.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPEC.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '53' AS [COMPANY_MEMBERKEY],

            'G ADVENTURES (II) PTY. LTD' AS [COMPANY],

            'GAVAU' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAVAU.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAVAU.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAVAU.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAVAU.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAVAU.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAVAU.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '56' AS [COMPANY_MEMBERKEY],

            'G Adventures Kenya Ltd' AS [COMPANY],

            'GAVKA' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAVKA.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT,

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAVKA.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAVKA.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAVKA.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAVKA.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAVKA.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '55' AS [COMPANY_MEMBERKEY],

            'G Adventures Asia Company Limited' AS [COMPANY],

            'GAPAS' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPAS.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAPAS.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPAS.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPAS.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPAS.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPAS.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '61' AS [COMPANY_MEMBERKEY],

            'G Adventures Holding Company limited' AS [COMPANY],

            'GAPAH' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GAPAH.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT,

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GAPAH.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GAPAH.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPAH.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GAPAH.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GAPAH.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL


Select        
            '86' AS [COMPANY_MEMBERKEY],

            '2381895 Ontario Inc.' AS [COMPANY],

            'ONINC' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.ONINC.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.ONINC.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.ONINC.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.ALINV.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.ONINC.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.ONINC.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.ONINC.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

UNION ALL

Select        
            '65' AS [COMPANY_MEMBERKEY],

            'G Cruising and Expeditions Limited' AS [COMPANY],

            'GCEXP' AS [DATNAME],

            (select funcurr.FUNLCURR from TORFIN03.GCEXP.dbo.MC40000 funcurr) AS [FUNCTIONAL_CURNCYID],

			/*DOSSIER = CASE WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 19 and glheader.DSCRIPTN is not NULL) THEN
					
				substring(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2), 4, Len(LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2))-12 )

            WHEN (glheader.DSCRIPTN LIKE '%-O[0-9]' AND len(rtrim(ltrim(glheader.DSCRIPTN))) >= 15  and glheader.DSCRIPTN is not NULL) THEN

				substring(rtrim(ltrim(glheader.DSCRIPTN)), 4, LEN(rtrim(ltrim(glheader.DSCRIPTN)))-12)

			ELSE
                'N-A'
            END,*/

            TRIPCODE = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
                            LEFT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) + 2)
                        WHEN glheader.DSCRIPTN LIKE '%-O[0-9]' AND substring(glheader.DSCRIPTN, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							rtrim(ltrim(glheader.DSCRIPTN))
						/*WHEN rlines.ITEMDESC LIKE '%-O[0-9] -%' AND substring(rlines.ITEMDESC, 1, 3) in
						('AHR','AVC','CUC','CUS','DES','DIA','DPF','FAM','FIT',
						'FLI','GAB','GAP','GAS','GAZ','GDP','GFI','GFP','GGF',
						'GIP','GNA','GPA','GPD','GPE','GPF','GPG','GPI','GPO',
						'GPS','GPX','GRF','GTD','ILM','ITS','JRB','PAA','PEE',
						'PHM','PHP','PIM','PRO','RCH','RPL','SAP','SEG','SOL',
						'SPP','STR','TGA','TSA','TSE','TXC',
						'ACA','AMD','ATA','DIA','EXL','EXO','GAP','GCG',
						'GGF','GLO','GNA','GPA','GPE','GPF','GPI','GPO',
						'GPX','GRB','GWW','ITR','LTA','OTG','QRK','SUN',
						'TKA','TOZ') THEN
							LEFT(LTrim(RTrim(Cast(rlines.ITEMDESC As varchar))), CharIndex('-', LTrim(RTrim(Cast(rlines.ITEMDESC As varchar)))) + 2)*/
						ELSE
                            'N-A'
                        END,
            CATEGORY = CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            (Select abbr.COST_TYPE_NAME from LU_COST_ABBRV abbr where abbr.COST_TYPE_ABBREV =                            
RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3))
                        ELSE
                            gl100.ACTDESCR
                        END,

            PAID_BY = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN

                            CASE WHEN glheader.ORGNTSRC LIKE '%COGS%' THEN
                                CASE WHEN glheader.ORGNTSRC LIKE '%TO%' THEN
                                    'TO'
                                WHEN glheader.ORGNTSRC LIKE '%LO%' THEN
                                    'LO'
                                ELSE
                                    'N-A'
                                END
                            ELSE
                                'N-A'
                            END

						WHEN pmview.BACHNUMB LIKE '%COGS%' THEN
                            CASE WHEN pmview.BACHNUMB LIKE '%LO%' THEN
                                'LO'
                            WHEN pmview.BACHNUMB LIKE '%TO%' THEN
                                'TO'
                            END
                        WHEN pmview.BACHNUMB LIKE '%ICTRX%' THEN
                            'TO'
                        WHEN pmview.BACHNUMB LIKE 'DM-%-C' THEN
							'Ldr'
						WHEN glheader.SOURCDOC = 'RECVG' OR glheader.SOURCDOC = 'POIVC' THEN
							'TO'
						ELSE
                            'N-A'
                        END,

            VENDOR_CODE = CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'GJ' THEN
                                CASE WHEN rtrim(ltrim(glheader.REFRENCE)) LIKE 'OV-%' OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'TL-%'OR rtrim(ltrim(glheader.REFRENCE)) LIKE 'GV-%' THEN
                                    left(rtrim(ltrim(glheader.REFRENCE)), 11) + '-' + rtrim(ltrim(glheader.CURNCYID))
                                ELSE
                                    'N-A'
                                END
							/*WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'RECVG' THEN
								rtrim(ltrim(rdist.VENDORID))*/
                            ELSE
                                CASE WHEN rtrim(ltrim(glheader.SOURCDOC)) = 'PMTRX' THEN
                                    rtrim(ltrim(pmview.VENDORID))
                                ELSE
                                    'N-A'
                                END
                            END,


            CAST(CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            YEAR(glheader.TRXDATE) + 1
                    ELSE 
                            YEAR(glheader.TRXDATE)
                    END as VARCHAR(5))

            + 'M' +

            CASE WHEN MONTH(glheader.TRXDATE) > 7 THEN
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,-7,glheader.TRXDATE), 112),5,2)
                    ELSE
                            SUBSTRING(CONVERT(nvarchar(6),DATEADD(month,+5,glheader.TRXDATE), 112),5,2)
                    END AS [FISCALDATE],

            glheader.ORDBTAMT - glheader.ORCRDAMT AS [ORGNET],

            glheader.DEBITAMT - glheader.CRDTAMNT AS [FUNCNET],

            --Chart of Accounts
            gl100.ACTINDX, gl100.ACTNUMBR_1 AS [SEG1_COMPANY], gl100.ACTNUMBR_2 AS [SEG2_TERRITORY], gl100.ACTNUMBR_3 AS [SEG3_DEPT], gl100.ACTNUMBR_4 AS [SEG4_OFFICE], gl100.ACTNUMBR_5 AS [SEG5_MAIN], gl100.ACTNUMBR_5 AS [SEG5_SERV], gl100.ACTDESCR,

            --General Ledger
            glheader.JRNENTRY, glheader.TRXDATE, glheader.REFRENCE, glheader.DSCRIPTN, glheader.SOURCDOC,    glheader.ORDOCNUM,
            glheader.ORGNTSRC, glheader.CURNCYID AS [GLCURNCYID], glheader.ORDBTAMT, glheader.DEBITAMT, glheader.ORCRDAMT,
            glheader.CRDTAMNT, glheader.ORPSTDDT, 

            --Calculations
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1/exch.XCHGRATE AS NUMERIC(18,5)) AS [CADNET],
            cast((glheader.DEBITAMT - glheader.CRDTAMNT) * 1.0000000 AS NUMERIC(18,5)) AS [USDNET],

            --Payables
            pmview.VCHRNMBR, pmview.VENDORID, pmview.DOCTYPE, pmview.DOCDATE, pmview.DOCNUMBR,
            pmview.DOCAMNT, pmview.CURTRXAM, pmview.DISTKNAM, pmview.DISCAMNT, pmview.DSCDLRAM,
            pmview.BACHNUMB, pmview.TRXSORCE, pmview.BCHSOURC, pmview.DISCDATE, pmview.DUEDATE,
            pmview.PORDNMBR, pmview.TEN99AMNT, pmview.WROFAMNT, pmview.DISAMTAV, pmview.TRXDSCRN,
            pmview.UN1099AM, pmview.BKTPURAM, pmview.BKTFRTAM, pmview.BKTMSCAM, pmview.VOIDED,
            pmview.HOLD, pmview.CHEKBKID, pmview.DINVPDOF, pmview.PPSAMDED,
            pmview.PGRAMSBJ, pmview.GSTDSAMT, pmview.POSTEDDT, pmview.PTDUSRID, pmview.MODIFDT,
            pmview.MDFUSRID, pmview.PYENTTYP, pmview.CARDNAME, pmview.PRCHAMNT, pmview.TRDISAMT,
            pmview.MSCCHAMT, pmview.FRTAMNT, pmview.TAXAMNT, pmview.TTLPYMTS, pmview.CURNCYID,
            pmview.PYMTRMID, pmview.SHIPMTHD, pmview.TAXSCHID, pmview.PCHSCHID, pmview.FRTSCHID,
            pmview.MSCSCHID, pmview.PSTGDATE, pmview.DISAVTKN, pmview.CNTRLTYP, pmview.NOTEINDX,
            pmview.PRCTDISC, pmview.RETNAGAM, pmview.ICTRX, pmview.Tax_Date, pmview.PRCHDATE,
            pmview.CORRCTN, pmview.SIMPLIFD, pmview.BNKRCAMT, pmview.APLYWITH, pmview.Electronic,
            pmview.ECTRX, pmview.DocPrinted, pmview.TaxInvReqd, pmview.VNDCHKNM, pmview.BackoutTradeDisc,
            pmview.CBVAT, pmview.VADCDTRO, pmview.TEN99TYPE, pmview.TEN99BOXNUMBER, pmview.DEX_ROW_TS,
            pmview.DEX_ROW_ID,

			--rlines.*, rdist.*,

            --Exchange Rates
            cast(1/exch.XCHGRATE as numeric(18,7)) AS CAD_XCHGRATE, 1.0000000 AS USD_XCHGRATE

From         TORFIN03.GCEXP.dbo.vw_GL_Open_History_Union glheader WITH (NOLOCK)
Left Join    (Select * from (
Select *, RN = ROW_NUMBER()OVER(PARTITION BY DOCNUMBR,TRXSORCE ORDER BY DUEDATE DESC)
from TORFIN03.GCEXP.dbo.vw_PM_Open_History_Union_All WITH (NOLOCK) ) x where RN = 1) pmview ON (glheader.ORGNTSRC = pmview.TRXSORCE
                                                AND  glheader.ORDOCNUM = pmview.DOCNUMBR)
/*Left Join	TORFIN03.GAPBR.dbo.POP10500 rdist  -- receipt distros
				on rdist.POPRCTNM = glheader.ORDOCNUM
				and rdist.INVINDX = glheader.ACTINDX
				and glheader.SOURCDOC = 'RECVG'
Left Join	TORFIN03.GAPBR.dbo.POP10110 rlines  -- receipt lines
				on rdist.POPRCTNM = rlines.PONUMBER
				and rdist.OLDCUCST = rlines.OREXTCST*/
Left Join    TORFIN03.GCEXP.dbo.GL00100 gl100 WITH (NOLOCK) ON glheader.ACTINDX = gl100.ACTINDX
Left Join    TORFIN03.DYNAMICS.dbo.MC00100 exch WITH (NOLOCK) ON (exch.EXGTBLID = 'USD-CAD-AVG'
                                   AND Month(exch.EXCHDATE) = MONTH(glheader.TRXDATE)
                                   AND YEAR(exch.EXCHDATE) = YEAR(glheader.TRXDATE))
--Left Join    TORFIN03.GCEXP.dbo.MC40000 funcurr WITH (NOLOCK) ON (1=1) 
/*Left Join    PlanStage_DB.dbo.LU_COST_ABBRV abbr ON CASE WHEN glheader.DSCRIPTN LIKE '%-O[0-9]-%' THEN
                            RIGHT(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))), (Len(LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar)))) - CharIndex('-', LTrim(RTrim(Cast(glheader.DSCRIPTN As varchar))))) - 3)
                        ELSE
                            'N-A'
                        END = abbr.COST_TYPE_ABBREV */
WHERE        (LTrim(gl100.ACTNUMBR_5) >= 10000 AND LTrim(gl100.ACTNUMBR_5) < 99999)
--AND glheader.REFRENCE <> 'Balance Brought Forward'

) T -- END MAIN SELECT