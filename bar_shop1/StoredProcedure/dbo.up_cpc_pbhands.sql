IF OBJECT_ID (N'dbo.up_cpc_pbhands', N'P') IS NOT NULL DROP PROCEDURE dbo.up_cpc_pbhands
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
CREATE PROCEDURE [dbo].[up_cpc_pbhands]
	-- Add the parameters for the stored procedure here
	@company_seq	int,
	@sdate			datetime,
	@edate			datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	select  sdate
	,   sum(case when STT = '21' then cnt else 0 end) '21'
	,   sum(case when STT = '22' then cnt else 0 end) '22'
	,   sum(case when STT = '23' then cnt else 0 end) '23'
	,   sum(case when STT = '24' then cnt else 0 end) '24'


	from
	(
		select  convert(varchar(10),S4_CPC_Sub_Regdate,121) AS sdate, S4_CPC_Sub_Code AS STT, count(S4_CPC_Sub_Code) AS cnt
		from    S4_CPC_Sub_Statics with(nolock)
		where   convert(varchar(10),S4_CPC_Sub_Regdate,121) between @sdate and @edate
		--and status_seq > 0 and status_seq <> '3'
		group by convert(varchar(10),S4_CPC_Sub_Regdate,121),
			  S4_CPC_Sub_Code
	) a 
	group by sdate
	order by sdate

END
GO
