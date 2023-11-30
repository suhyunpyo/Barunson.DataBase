IF OBJECT_ID (N'dbo.up_select_QNA_list_boton', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_QNA_list_boton
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
CREATE Procedure [dbo].[up_select_QNA_list_boton]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@member_id nvarchar(50)		-- 회원아이디
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- total count
	select count(QA_IID) AS tot, (select count(QA_IID) from S2_UserQnA_Boton with(nolock) where company_seq=@company_seq and member_id=@member_id and a_stat='S3') AS tot_comp, (select count(QA_IID) from S2_UserQnA_Boton with(nolock) where company_seq=@company_seq and member_id=@member_id and a_stat!='S3') AS tot_temp
	from S2_UserQnA_Boton
	where company_seq=@company_seq and member_id=@member_id
		
	-- select list
	select top (@pagesize) QA_IID, SALES_GUBUN, COMPANY_SEQ, isnull(CARD_CODE, '') AS CARD_CODE, isnull(ORDER_SEQ, '') AS ORDER_SEQ , MEMBER_ID, MEMBER_NAME, REG_DT, A_STAT, isnull(A_DT, '') AS A_DT, isnull(A_CONTENT, '') AS A_CONTENT, A_ID, Q_CONTENT, Q_TITLE, Q_KIND,ISNULL(a_research1,'0') as a_research, user_upfile1, user_upfile2, isMail, isSMS, isSecret
		
		from S2_UserQnA_Boton AS A with(nolock)
		
		where company_seq=@company_seq and member_id=@member_id 
		and QA_IID not in (select top (@pagesize * (@page - 1)) QA_IID from S2_UserQnA_Boton with(nolock) where company_seq=@company_seq and member_id=@member_id order by reg_dt DESC)
		order by reg_dt DESC
END
GO
