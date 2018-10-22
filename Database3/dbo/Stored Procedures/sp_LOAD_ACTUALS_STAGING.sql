-- =============================================
-- Author:		Chaminda Hewamana
-- Create date: 16 August 2018
-- Description:	Do a full sweep of for selected field that change even though ROW_KEY remain unchanged and create a table for update process to pick up and update.
-- =============================================
--
CREATE PROCEDURE [dbo].[sp_LOAD_ACTUALS_STAGING]
AS
BEGIN
BEGIN TRY
	IF OBJECT_ID('dbo.ALL_ACTUALS_UPDATES', 'U') IS NOT NULL DROP TABLE [dbo].[ALL_ACTUALS_UPDATES] 
	IF OBJECT_ID('dbo.ALL_ACTUALS_STAGING', 'U') IS NOT NULL DROP TABLE [dbo].[ALL_ACTUALS_STAGING] 
	SELECT [ROW_KEY]
		  ,[VENDOR_NAME]
		  ,[REFRENCE]
		  ,[DSCRIPTN]
		  ,PROJ
		  ,DEX_ROW_TS
	INTO ALL_ACTUALS_STAGING
	FROM [dbo].view_ALL_ACTUALS

	SELECT [ROW_KEY]
			,[VENDOR_NAME]
			,[REFRENCE]
			,[DSCRIPTN]
			,PROJ
	INTO ALL_ACTUALS_UPDATES
	FROM ALL_ACTUALS_STAGING
	EXCEPT
	SELECT [ROW_KEY]
			,[VENDOR_NAME]
			,[REFRENCE]
			,[DSCRIPTN]
			,PROJ
	FROM [TORDCFINPLAN01].[PlanStage_DB].[dbo].[ALL_ACTUALS]
	WHERE ISNULL(IS_DELETED,0)=0
	CREATE NONCLUSTERED INDEX IX_ROW_KEY ON ALL_ACTUALS_UPDATES
	(
		[ROW_KEY] ASC
	)
END TRY
BEGIN CATCH
	INSERT  INTO [dbo].[ETL_ERROR_LOG] 
	SELECT	GETDATE(),
			SYSTEM_USER,
			OBJECT_NAME(@@PROCID),
			ERROR_NUMBER(),
			ERROR_MESSAGE()
END CATCH
END