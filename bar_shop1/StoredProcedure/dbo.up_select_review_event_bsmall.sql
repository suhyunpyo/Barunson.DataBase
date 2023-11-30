IF OBJECT_ID (N'dbo.up_select_review_event_bsmall', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_review_event_bsmall
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--[up_select_review_event] 5006,1,15,0,'ER_Regdate',''
--select top 100 * from S4_Event_Review order by ER_Regdate
-- 바른손몰, 프페제휴 포함 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_review_event_bsmall]
	-- Add the parameters for the stored procedure here
	@company_seq		int,
	@page				int=1,
	@pagesize			int=15,
	@ER_Type			int=0,
	@sort_desc			nvarchar(20),
	@txt_card_seq		int=0	--특정카드만 조회
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	nvarchar(4000)
	DECLARE	@SQL2	nvarchar(4000)
	
	IF @company_seq IS NULL or @company_seq=''
		begin
			set @company_seq='1'
		end
	
	if @txt_card_seq = 0
		begin
		begin
			set @SQL2 = ' select count(ER_Idx) from S4_Event_Review a with(nolock) , company c where a.er_company_Seq = c.company_seq  and ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and sales_gubun in (''B'',''C'',''H'') and ER_View=0 '
			exec (@SQL2)
			

			set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, isnull(ER_Review_Title, '''') AS ER_Review_Title, isnull(ER_Review_Url, '''') AS ER_Review_Url , '
			set @SQL = @SQL + ' ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, '
			set @SQL = @SQL + ' ERA_Status, ERA_Coupon_Status, isnull(ERA_Comment,'''') AS ERA_Comment, ERA_Coupon_Code, isnull(ERA_Comment_Cancel,'''') AS ERA_Comment_Cancel, isnull(ER_Review_Url_a, '''') AS ER_Review_Url_a, isnull(ER_Review_Url_b, '''') AS ER_Review_Url_b, isnull(ER_Review_Url2, '''') AS ER_Review_Url2'
			set @SQL = @SQL + ' from S4_Event_Review AS A with(nolock) left outer join  S4_Event_Review_Status AS B with(nolock) on A.ER_Idx = B.ERA_ER_idx '
			set @SQL = @SQL + ' join company AS C on A.er_company_Seq = C.company_Seq '
			set @SQL = @SQL + ' where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and  ER_Idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' ER_Idx from S4_Event_Review a with(nolock) , company c  where a.er_company_Seq = c.company_seq and C.sales_gubun  in (''B'',''C'',''H'') and ER_View=0  order by '+@sort_desc+' desc  ) '
			set @SQL = @SQL + ' and C.sales_gubun in (''B'',''C'',''H'') and ER_View=0 order by '+@sort_desc+' desc'
			
			exec (@SQL)
			print(@SQL)
		end
		end
	else
		begin
			set @SQL2 = ' select count(ER_Idx) from S4_Event_Review with(nolock) where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and ER_Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+' and ER_card_seq='+CONVERT(VARCHAR(10),@txt_card_seq)+' '
			exec (@SQL2)
			

			set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, isnull(ER_Review_Title, '''') AS ER_Review_Title, isnull(ER_Review_Url, '''') AS ER_Review_Url , '
			set @SQL = @SQL + ' ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, '
			set @SQL = @SQL + ' ERA_Status, ERA_Coupon_Status, isnull(ERA_Comment,'''') AS ERA_Comment, ERA_Coupon_Code, isnull(ERA_Comment_Cancel,'''') AS ERA_Comment_Cancel, isnull(ER_Review_Url_a, '''') AS ER_Review_Url_a, isnull(ER_Review_Url_b, '''') AS ER_Review_Url_b, isnull(ER_Review_Url2, '''') AS ER_Review_Url2 '
			 set @SQL = @SQL + ' from S4_Event_Review AS A with(nolock) left outer join  S4_Event_Review_Status AS B with(nolock) on A.ER_Idx = B.ERA_ER_idx '
			set @SQL = @SQL + ' where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and  ER_Idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' ER_Idx from S4_Event_Review with(nolock) where ER_Company_Seq ='+CONVERT(VARCHAR(50),@company_seq)+' and ER_card_seq='+CONVERT(VARCHAR(10),@txt_card_seq)+'  and ER_View=0 order by '+@sort_desc+' desc  ) '
			set @SQL = @SQL + ' and ER_Company_Seq ='+CONVERT(VARCHAR(50),@company_seq)+' and ER_card_seq='+CONVERT(VARCHAR(10),@txt_card_seq)+'  and ER_View=0 order by '+@sort_desc+' desc'
			
			exec (@SQL)
			print(@SQL)
		end

END

GO
