IF OBJECT_ID (N'dbo.up_select_statics_time_sample', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_statics_time_sample
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
CREATE PROCEDURE [dbo].[up_select_statics_time_sample]
	-- Add the parameters for the stored procedure here
	@sDate				datetime,
	@eDate				datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	 
	select  join_division
	,   sum(case when STT = '00' then cnt else 0 end) '0'
	,   sum(case when STT = '01' then cnt else 0 end) '1'
	,   sum(case when STT = '02' then cnt else 0 end) '2'
	,   sum(case when STT = '03' then cnt else 0 end) '3'
	,   sum(case when STT = '04' then cnt else 0 end) '4'
	,   sum(case when STT = '05' then cnt else 0 end) '5'
	,   sum(case when STT = '06' then cnt else 0 end) '6'
	,   sum(case when STT = '07' then cnt else 0 end) '7'
	,   sum(case when STT = '08' then cnt else 0 end) '8'
	,   sum(case when STT = '09' then cnt else 0 end) '9'
	,   sum(case when STT = '10' then cnt else 0 end) '10'
	,   sum(case when STT = '11' then cnt else 0 end) '11'
	,   sum(case when STT = '12' then cnt else 0 end) '12'
	,   sum(case when STT = '13' then cnt else 0 end) '13'
	,   sum(case when STT = '14' then cnt else 0 end) '14'
	,   sum(case when STT = '15' then cnt else 0 end) '15'
	,   sum(case when STT = '16' then cnt else 0 end) '16'
	,   sum(case when STT = '17' then cnt else 0 end) '17'
	,   sum(case when STT = '18' then cnt else 0 end) '18'
	,   sum(case when STT = '19' then cnt else 0 end) '19'
	,   sum(case when STT = '20' then cnt else 0 end) '20'
	,   sum(case when STT = '21' then cnt else 0 end) '21'
	,   sum(case when STT = '22' then cnt else 0 end) '22'
	,   sum(case when STT = '23' then cnt else 0 end) '23'
	,   sum(cnt) 'tt'

	from
	(
		select  join_division, left(CONVERT(VARCHAR, REQUEST_DATE, 8),2) AS STT, count(sample_order_seq) AS cnt
		from    CUSTOM_SAMPLE_ORDER with(nolock)
		where   convert(varchar(10),REQUEST_DATE,121) between @sDate and @eDate
		and company_seq in ('5001', '5006', '5007', '5003')
		group by join_division,
	    
			  left(CONVERT(VARCHAR, REQUEST_DATE, 8),2)
	) a 
	group by join_division
	order by join_division

END
GO
