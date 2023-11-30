IF OBJECT_ID (N'dbo.up_select_comment_event', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_comment_event
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
CREATE PROCEDURE [dbo].[up_select_comment_event]
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
	DECLARE	@SQL	nvarchar(1000)
	DECLARE	@SQL2	nvarchar(1000)
	
	IF @company_seq IS NULL or @company_seq=''
		begin
			set @company_seq='1'
		end
	
	if @txt_card_seq = 0
		begin
			if (@company_seq = '5001' or @company_seq = '5003')	--바른손
				begin
				set @SQL2 = ' select count(ER_Idx) from S4_Event_Review with(nolock) where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and ER_Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+' and ER_View=0 '
				exec (@SQL2)
				

				set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, isnull(ER_Review_Title, '''') AS ER_Review_Title, isnull(ER_Review_Url, '''') AS ER_Review_Url , '
				set @SQL = @SQL + ' ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, '
				set @SQL = @SQL + ' ERA_Status, ERA_Coupon_Status, isnull(ERA_Comment,'''') AS ERA_Comment, ERA_Coupon_Code, isnull(ERA_Comment_Cancel,'''') AS ERA_Comment_Cancel from S4_Event_Review AS A with(nolock) left outer join  S4_Event_Review_Status AS B with(nolock) on A.ER_Idx = B.ERA_ER_idx '
				set @SQL = @SQL + ' where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and  ER_Idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' ER_Idx from S4_Event_Review with(nolock) where ER_Company_Seq ='+CONVERT(VARCHAR(50),@company_seq)+' and ER_View=0  order by '+@sort_desc+' desc  ) '
				set @SQL = @SQL + ' and ER_Company_Seq ='+CONVERT(VARCHAR(50),@company_seq)+'  and ER_View=0 order by '+@sort_desc+' desc'
				
				exec (@SQL)
				end
			else		--바른손 외 모든 사이트(제휴포함)
				begin
					if @ER_Type = 0
						begin
							set @SQL2 = ' select (select count(seq) from S2_UserComment with(nolock) where Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+' and isDP=1),  (select count(seq) from S2_UserComment with(nolock) where isBest=1 and Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1)  '
							exec (@SQL2)

							set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' seq, sales_gubun, company_seq, card_seq, card_code, order_seq, uid, uname, isnull(title, '''') AS title, isnull(b_url, '''') AS b_url , '
							set @SQL = @SQL + ' score, reg_date, isnull(comment,'''') AS comment, (select uc_comment from S2_UserComment_reply where uc_seq=A.seq) AS reply_comment  from S2_UserComment AS A with(nolock)  '
							set @SQL = @SQL + ' where seq not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' seq from S2_UserComment with(nolock) where Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1 order by '+@sort_desc+' desc   ) '
							set @SQL = @SQL + ' and Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1 order by '+@sort_desc+' desc '
					
							exec (@SQL)
						end
					else
						begin
							--set @SQL2 = ' select (select count(seq) from S2_UserComment with(nolock) where Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+' and isDP=1),  (select count(seq) from S2_UserComment with(nolock) where isBest='+CONVERT(VARCHAR(2),@ER_Type)+' and Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1)  '
							set @SQL2 = ' select (select count(seq) from S2_UserComment with(nolock) where Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+' and isDP=1),  (select count(seq) from S2_UserComment with(nolock) where isBest=1 and Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1)  '
							exec (@SQL2)

							set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' seq, sales_gubun, company_seq, card_seq, card_code, order_seq, uid, uname, isnull(title, '''') AS title, isnull(b_url, '''') AS b_url , '
							set @SQL = @SQL + ' score, reg_date, isnull(comment,'''') AS comment, (select uc_comment from S2_UserComment_reply where uc_seq=A.seq) AS reply_comment from S2_UserComment AS A with(nolock)  '
							set @SQL = @SQL + ' where isBest='+CONVERT(VARCHAR(2),@ER_Type)+' and  seq not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' seq from S2_UserComment with(nolock) where  isBest='+CONVERT(VARCHAR(2),@ER_Type)+' and Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1 order by '+@sort_desc+' desc   ) '
							set @SQL = @SQL + ' and Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+'  and isDP=1 order by '+@sort_desc+' desc '
					
							exec (@SQL)
						end
					

					
				end
		end
	else
		begin
			set @SQL2 = ' select count(ER_Idx) from S4_Event_Review with(nolock) where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and ER_Company_Seq='+CONVERT(VARCHAR(50),@company_seq)+' and ER_card_seq='+CONVERT(VARCHAR(10),@txt_card_seq)+' '
			exec (@SQL2)
			

			set @SQL = 'select top '+ CONVERT(VARCHAR(50),@pagesize) +' ER_Idx, ER_Company_Seq, ER_Order_Seq, ER_Type, ER_Userid, ER_Regdate, ER_Recom_Cnt, isnull(ER_Review_Title, '''') AS ER_Review_Title, isnull(ER_Review_Url, '''') AS ER_Review_Url , '
			set @SQL = @SQL + ' ER_Review_Star, ER_Status, ER_View, ER_Review_Content, ER_card_seq, ER_Card_code, ER_UserName, '
			set @SQL = @SQL + ' ERA_Status, ERA_Coupon_Status, isnull(ERA_Comment,'''') AS ERA_Comment, ERA_Coupon_Code, isnull(ERA_Comment_Cancel,'''') AS ERA_Comment_Cancel from S4_Event_Review AS A with(nolock) left outer join  S4_Event_Review_Status AS B with(nolock) on A.ER_Idx = B.ERA_ER_idx '
			set @SQL = @SQL + ' where ER_Type='+CONVERT(VARCHAR(2),@ER_Type)+' and  ER_Idx not in (select top '+ CONVERT(VARCHAR(50), @pagesize * (@page - 1)) +' ER_Idx from S4_Event_Review with(nolock) where ER_Company_Seq ='+CONVERT(VARCHAR(50),@company_seq)+' and ER_card_seq='+CONVERT(VARCHAR(10),@txt_card_seq)+'  and ER_View=0 order by '+@sort_desc+' desc  ) '
			set @SQL = @SQL + ' and ER_Company_Seq ='+CONVERT(VARCHAR(50),@company_seq)+' and ER_card_seq='+CONVERT(VARCHAR(10),@txt_card_seq)+'  and ER_View=0 order by '+@sort_desc+' desc'
			
			exec (@SQL)
		end

END
GO
