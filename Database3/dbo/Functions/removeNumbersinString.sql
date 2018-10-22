
-- =============================================
-- Author:		<Chibueze Agu>
-- Create date: <15-NOV-2017>
-- Description:	Remove numbers from string
-- =============================================
CREATE FUNCTION [dbo].[removeNumbersinString]
(
	@str varchar(50)
)
RETURNS varchar(50)
AS
BEGIN
	
	Select @str = REPLACE
(REPLACE
(REPLACE
(REPLACE
(REPLACE
(REPLACE
(REPLACE
(REPLACE
(REPLACE
(REPLACE (@str, '0', ''),
'1', ''),
'2', ''),
'3', ''),
'4', ''),
'5', ''),
'6', ''),
'7', ''),
'8', ''),
'9', '')

return @str

END