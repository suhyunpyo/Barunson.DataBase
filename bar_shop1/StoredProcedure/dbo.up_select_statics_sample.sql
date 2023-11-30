IF OBJECT_ID (N'dbo.up_select_statics_sample', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_statics_sample
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
CREATE PROCEDURE [dbo].[up_select_statics_sample]
	-- Add the parameters for the stored procedure here
	@sDate				datetime,
	@eDate				datetime
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	 
	select  SDD
	,   sum(case when join_division = 'web' then cnt else 0 end) 'web'
	,   sum(case when join_division = 'mobile' then cnt else 0 end) 'mobile'
	,   sum(cnt) 'tt'

	from
	(
		select  join_division, convert(varchar(10),REQUEST_DATE,121) AS SDD, count(sample_order_seq) AS cnt
		from    CUSTOM_SAMPLE_ORDER with(nolock)
		where   convert(varchar(10),REQUEST_DATE,121) between @sDate and @eDate
		and company_seq in ('5001', '5006', '5007', '5003')
		group by join_division,
	    
			  convert(varchar(10),REQUEST_DATE,121)
	) a 
	group by SDD
	order by SDD

END
GO
