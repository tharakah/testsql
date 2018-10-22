-- =============================================
-- Author:		Chaminda Hewamana
-- Create date: 16 August 2018
-- Description:	Return the earliest date data should be retrieved based on no of days defined in ETL_DATA_CONTROL
-- =============================================
CREATE FUNCTION [dbo].[GET_STARTDATE]
(
)
RETURNS DATETIME
AS
BEGIN
	RETURN (SELECT GETDATE()- (SELECT MAX([NO_OF_DAYS]) FROM [dbo].[ETL_DATA_CONTROL]))
END