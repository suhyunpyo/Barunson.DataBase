IF OBJECT_ID (N'dbo.usp_f_event_list', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_f_event_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






CREATE                                PROCEDURE [dbo].[usp_f_event_list]
@CatLCd			as char(2),
@Dv				as char(1)
AS

if @Dv = ''
	select eventidx, banner, itemcd, eventNm, fromDt, convert(int,isnull(templateYN,0)) templateYN, templateUrl
	from tEvent
	where 
		fromDt <= convert(char(10),getdate(),120)
		and toDt >= convert(char(10),getdate(),120)
 		and catLCd = (case when rtrim(@CatLCd) = '' then catLCd else @CatLCd end)
		and viewYN = 'Y'
		and FSEventYN = 'N'
	order by fromDt desc

else 
	select eventidx, banner, itemcd, eventNm, convert(int,isnull(templateYN,0)) templateYN, templateUrl
	from tEvent
	where 
		fromDt <= convert(char(10),getdate(),120)
		and toDt >= convert(char(10),getdate(),120)
		and catLCd = (case when rtrim(@CatLCd) = '' then catLCd else @CatLCd end)
		and viewYN = 'Y'
		and FSEventYN = 'N'
		and EventGb LIKE '%' + @Dv+'%'
	order by fromDt desc
GO
