IF OBJECT_ID (N'dbo.up_cpc_bhands', N'P') IS NOT NULL DROP PROCEDURE dbo.up_cpc_bhands
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
CREATE PROCEDURE [dbo].[up_cpc_bhands]
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
	,   sum(case when STT = '1' then cnt else 0 end) '메인페이지'
	,   sum(case when STT = '2' then cnt else 0 end) '2'
	,   sum(case when STT = '3' then cnt else 0 end) '3'
	,   sum(case when STT = '4' then cnt else 0 end) '4'
	,   sum(case when STT = '5' then cnt else 0 end) '5'
	,   sum(case when STT = '6' then cnt else 0 end) '6'
	,   sum(case when STT = '7' then cnt else 0 end) '7'
	,   sum(case when STT = '8' then cnt else 0 end) '8'
	,   sum(case when STT = '9' then cnt else 0 end) '9'
	,   sum(case when STT = '10' then cnt else 0 end) '10'
	,   sum(case when STT = '11' then cnt else 0 end) '11'
	,   sum(case when STT = '12' then cnt else 0 end) '12'
	,   sum(case when STT = '13' then cnt else 0 end) '13'
	,   sum(case when STT = '14' then cnt else 0 end) '14'
	,   sum(case when STT = '25' then cnt else 0 end) '25'
	,   sum(case when STT = '26' then cnt else 0 end) '26'
	,   sum(case when STT = '27' then cnt else 0 end) '27'
	,   sum(case when STT = '28' then cnt else 0 end) '28'
	,   sum(case when STT = '29' then cnt else 0 end) '29'
	,   sum(case when STT = '30' then cnt else 0 end) '30'
	,   sum(case when STT = '44' then cnt else 0 end) '44'
	,   sum(case when STT = '45' then cnt else 0 end) '45'


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
