IF OBJECT_ID (N'dbo.up_select_notice_list_Boton', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_notice_list_Boton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : custom > notice_list_proc.asp
	내용	   : 공지리스트 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_notice_list_Boton]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@search_mode nvarchar(20),		-- 검색조건
	@search_string	nvarchar(50),	-- 검색어
	@notice_dev	nvarchar(10)		-- 공지종류 (값 0이면 전체)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @search_value nvarchar(50)

	if @search_string <> ''
		begin
			set @search_value = @search_string
		end
	else
		begin
			set @search_value = '0'
		end
    -- Insert statements for procedure here
	-- total count
	
			select COUNT(seq) AS TOT from S2_Notice AS A with(nolock) 
				where company_seq=@company_seq
				and
				(
					CASE @notice_dev
					WHEN '0' THEN blank_
					ELSE notice_div
					END
				) = @notice_dev
				and 
				(
					CASE @search_mode
					WHEN 'title' THEN title
					WHEN 'contents' THEN contents
					WHEN 'all' THEN contents
					ELSE blank_
					END
				) like '%'+@search_value+'%'


		
			-- select list
			select top (@pagesize) seq, sales_gubun, company_seq, writer, title, contents, viewcnt, notice_div, start_date, end_date, reg_date
		
				from S2_Notice AS A with(nolock)
		
				where Company_Seq=@company_seq and
				(
					CASE @notice_dev
					WHEN '0' THEN blank_
					ELSE notice_div
					END
				) = @notice_dev
				and 
				(
					CASE @search_mode
					WHEN 'title' THEN title
					WHEN 'contents' THEN contents
					WHEN 'all' THEN contents
					ELSE blank_
					END
				) like '%'+@search_value+'%'

				-- ============ not in start =============
				and seq not in 
				(select top (@pagesize * (@page - 1)) seq from S2_Notice AS A
				where Company_Seq=@company_seq and
		
				(
					CASE @notice_dev
					WHEN '0' THEN blank_
					ELSE notice_div
					END
				) = @notice_dev
				and 
				(
					CASE @search_mode
					WHEN 'title' THEN title
					WHEN 'contents' THEN contents
					WHEN 'all' THEN contents
					ELSE blank_
					END
				) like '%'+@search_value+'%'

		
				--정렬기준
				order by 
				seq desc
				) 
				-- ============= not in end ===============
		
				order by 
				seq desc
		
END
GO
