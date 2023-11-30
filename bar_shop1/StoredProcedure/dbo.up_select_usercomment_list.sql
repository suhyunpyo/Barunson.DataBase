IF OBJECT_ID (N'dbo.up_select_usercomment_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_usercomment_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : product > detail.asp
	내용	   : 상품 이용후기
	
	수정정보   : 20140916 where 조건에 reg_date <= GETDATE() 추가
*/
-- =============================================
CREATE Procedure [dbo].[up_select_usercomment_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@card_seq	AS int,			-- 제품코드
	@page		AS int,				-- 페이지넘버
	@pagesize	AS int,				-- 페이지사이즈(페이지당 노출갯수)
	@isbest		AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	select (select count(seq) from S2_UserComment
		where company_seq=@company_seq and card_seq=@card_seq
		and isDP=1 and reg_date <= GETDATE()) AS tot, 

		(select count(seq) from S2_UserComment
		where company_seq=@company_seq and card_seq=@card_seq
		and isDP=1 and isBest=1 and reg_date <= GETDATE()) AS tot_best

if @isbest = 1
	begin    
		select  top (@pagesize) seq, title, comment, score, isBest, comm_div, uid, uname, reg_date from S2_UserComment with(nolock)
		where company_seq=@company_seq and card_seq=@card_seq
		and isDP=1  and isBest=1 and seq not in (select top (@pagesize * (@page - 1)) seq from S2_UserComment with(nolock)
		where company_seq=@company_seq and card_seq=@card_seq and reg_date <= GETDATE()	
		and isDP=1 and isBest=1 order by seq desc) and reg_date <= GETDATE()	
		order by seq desc
	end
else
	begin
		select  top (@pagesize) seq, title, comment, score, isBest, comm_div, uid, uname, reg_date from S2_UserComment with(nolock)
		where company_seq=@company_seq and card_seq=@card_seq
		and isDP=1 and seq not in (select top (@pagesize * (@page - 1)) seq from S2_UserComment with(nolock)
		where company_seq=@company_seq and card_seq=@card_seq
		and isDP=1 and reg_date <= GETDATE() order by seq desc) and reg_date <= GETDATE()
		order by seq desc
	end

	




END
GO
