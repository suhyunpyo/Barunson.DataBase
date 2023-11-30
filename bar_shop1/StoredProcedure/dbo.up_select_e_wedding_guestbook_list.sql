IF OBJECT_ID (N'dbo.up_select_e_wedding_guestbook_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_e_wedding_guestbook_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : 
	내용	   : E-청첩장 방명록 리스트 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_e_wedding_guestbook_list]
	-- Add the parameters for the stored procedure here
	@order_seq AS int,		-- 회사고유코드
	@page	int,				-- 페이지넘버
	@pagesize int				-- 페이지사이즈(페이지당 노출갯수)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- total count
	select count(board_seq) AS tot From S2_eCardBoard  with(nolock) where Order_Seq=@order_seq
		
	-- select list
	select top (@pagesize)  Board_Seq, order_seq, name, content, convert(varchar(10), RegDate, 121) AS regdate, Pwd
		
		from S2_eCardBoard AS A with(nolock)
		
		where Order_Seq=@order_seq
		and Board_Seq not in (select top (@pagesize * (@page - 1)) order_seq from S2_eCardOrder with(nolock) where Order_Seq=@order_seq  order by Board_Seq DESC)
		
		 order by Board_Seq DESC
END

GO
