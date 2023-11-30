IF OBJECT_ID (N'dbo.SP_S_USER_CHECK_DEPOSITOR_COUNT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_USER_CHECK_DEPOSITOR_COUNT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_S_USER_CHECK_DEPOSITOR_COUNT]
		@USER_ID VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select  
	count(1) error_cnt,
	datediff(second, max(Request_DateTime), getdate()) check_second,
	max(Request_DateTime) last_request_date,
	getdate() now_date,
	case 
		when count(1) <> 0 and count(1) % 3 = 0 and datediff(second, max(Request_DateTime), getdate()) <= 60 then 'CHECK_DELAY'
		else 'PASS'
	end hits_check
from TB_Depositor_Hits
where Depositor_Hits_ID > (
		select max(Depositor_Hits_ID) id
		from TB_Depositor_Hits
		where user_id = @USER_ID
			and (error_code not in ('D055','D041') or error_code is null)
			and Depositor = hits_depositor
	)

END
GO
