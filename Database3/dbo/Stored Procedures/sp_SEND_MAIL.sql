

-- =============================================
-- Author:		Chibueze Agu
-- Create date: 7th
-- Description:	SPROC used for sending out emails
-- =============================================
CREATE PROCEDURE [dbo].[sp_SEND_MAIL]
	-- Add the parameters for the stored procedure here
	  @subject varchar(250),
	  @body varchar(5000),
	  @recipients varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

EXEC msdb.dbo.sp_send_dbmail 
  @profile_name = 'datalytics',
  @recipients = @recipients,
  @subject = @subject,
  @body = @body,
  @body_format='HTML';

END