


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[isvalidProjectCode]
(
	@str varchar(50)
)
RETURNS bit
AS
BEGIN
	Declare @counter int
	
	Select @counter = count(*) from dbo.BUD_PROJECT_CODES where ltrim(rtrim(Projectcode)) = ltrim(rtrim(@str))
	If (@counter > 0)
	begin 
	return 1
	end
	else
	begin 
	return 0
	end
	
	return 0

END