﻿CREATE TABLE [dbo].[ALL_ACTUALS_UPDATES] (
    [ROW_KEY]     NVARCHAR (54) NULL,
    [VENDOR_NAME] CHAR (65)     NULL,
    [REFRENCE]    CHAR (31)     NOT NULL,
    [DSCRIPTN]    CHAR (31)     NOT NULL,
    [PROJ]        VARCHAR (50)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_ROW_KEY]
    ON [dbo].[ALL_ACTUALS_UPDATES]([ROW_KEY] ASC);

