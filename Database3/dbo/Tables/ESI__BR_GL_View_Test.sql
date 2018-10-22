CREATE TABLE [dbo].[ESI__BR_GL_View_Test] (
    [JRNENTRY]   INT             NOT NULL,
    [REFRENCE]   CHAR (31)       NOT NULL,
    [DSCRIPTN]   CHAR (31)       NOT NULL,
    [TRXDATE]    DATETIME        NOT NULL,
    [SOURCDOC]   CHAR (11)       NOT NULL,
    [ORDOCNUM]   CHAR (21)       NOT NULL,
    [ORGNTSRC]   CHAR (15)       NOT NULL,
    [ACTINDX]    INT             NOT NULL,
    [CURNCYID]   CHAR (15)       NOT NULL,
    [ORDBTAMT]   NUMERIC (19, 5) NOT NULL,
    [DEBITAMT]   NUMERIC (19, 5) NOT NULL,
    [ORCRDAMT]   NUMERIC (19, 5) NOT NULL,
    [CRDTAMNT]   NUMERIC (19, 5) NOT NULL,
    [ORPSTDDT]   DATETIME        NOT NULL,
    [DEX_ROW_ID] INT             NOT NULL,
    [USWHPSTD]   CHAR (15)       NOT NULL
);

