IF OBJECT_ID (N'dbo.up_select_FAQ_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_FAQ_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : custom > faq_list_proc.asp
	내용	   : FAQ리스트 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_FAQ_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@search_mode nvarchar(20),		-- 검색조건
	@search_string	nvarchar(50),	-- 검색어
	@faq_div	nvarchar(10)		-- FAQ종류 (값 0이면 전체)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- total count
	if len(@search_string) > 0
		begin
		select COUNT(seq) AS TOT from S2_FAQ AS A with(nolock) 
			where company_seq=@company_seq
			and
			(
				CASE @faq_div
				WHEN '0' THEN blank_
				ELSE faq_div
				END
			) = @faq_div
			and title like '%'+@search_string+'%'
		
		-- select list
		select top (@pagesize) seq, sales_gubun, company_seq, writer, title, contents, viewcnt, faq_div, display_order, reg_date
		
			from S2_FAQ AS A with(nolock)
		
			where Company_Seq=@company_seq and
			(
				CASE @faq_div
				WHEN '0' THEN blank_
				ELSE faq_div
				END
			) = @faq_div
		
			-- ============ not in start =============
			and seq not in 
			(select top (@pagesize * (@page - 1)) seq from S2_FAQ AS A
			where Company_Seq=@company_seq and
		
			(
				CASE @faq_div
				WHEN '0' THEN blank_
				ELSE faq_div
				END
			) = @faq_div
			and title like '%'+@search_string+'%'
			--정렬기준
			order by 
			seq desc
			) 
			and title like '%'+@search_string+'%'
			-- ============= not in end ===============
		
			order by 
			seq desc
		end 

	else
			begin
		select COUNT(seq) AS TOT from S2_FAQ AS A with(nolock) 
			where company_seq=@company_seq
			and
			(
				CASE @faq_div
				WHEN '0' THEN blank_
				ELSE faq_div
				END
			) = @faq_div
		
		-- select list
		select top (@pagesize) seq, sales_gubun, company_seq, writer, title, contents, viewcnt, faq_div, display_order, reg_date
		
			from S2_FAQ AS A with(nolock)
		
			where Company_Seq=@company_seq and
			(
				CASE @faq_div
				WHEN '0' THEN blank_
				ELSE faq_div
				END
			) = @faq_div
		
			-- ============ not in start =============
			and seq not in 
			(select top (@pagesize * (@page - 1)) seq from S2_FAQ AS A
			where Company_Seq=@company_seq and
		
			(
				CASE @faq_div
				WHEN '0' THEN blank_
				ELSE faq_div
				END
			) = @faq_div
		
			--정렬기준
			order by 
			seq desc
			) 
			-- ============= not in end ===============
		
			order by 
			seq desc
		end 
END
GO
