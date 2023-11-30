IF OBJECT_ID (N'dbo.up_cpc_barunson', N'P') IS NOT NULL DROP PROCEDURE dbo.up_cpc_barunson
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
CREATE PROCEDURE [dbo].[up_cpc_barunson]
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
	,   sum(case when STT = '15' then cnt else 0 end) '15'
	,   sum(case when STT = '16' then cnt else 0 end) '16'
	,   sum(case when STT = '17' then cnt else 0 end) '17'
	,   sum(case when STT = '18' then cnt else 0 end) '18'
	,   sum(case when STT = '19' then cnt else 0 end) '19'
	,   sum(case when STT = '20' then cnt else 0 end) '20'
	,   sum(case when STT = '31' then cnt else 0 end) '31'
	,   sum(case when STT = '32' then cnt else 0 end) '32'
	,   sum(case when STT = '33' then cnt else 0 end) '33'
	,   sum(case when STT = '34' then cnt else 0 end) '34'
	,   sum(case when STT = '35' then cnt else 0 end) '35'
	,   sum(case when STT = '36' then cnt else 0 end) '36'
	,   sum(case when STT = '37' then cnt else 0 end) '37'
	,   sum(case when STT = '38' then cnt else 0 end) '38'
	,   sum(case when STT = '39' then cnt else 0 end) '39'
	,   sum(case when STT = '40' then cnt else 0 end) '40'


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
