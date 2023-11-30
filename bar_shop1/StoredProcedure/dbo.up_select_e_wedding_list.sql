IF OBJECT_ID (N'dbo.up_select_e_wedding_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_e_wedding_list
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
CREATE Procedure [dbo].[up_select_e_wedding_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@page	int,				-- 페이지넘버
	@pagesize int				-- 페이지사이즈(페이지당 노출갯수)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- total count
	select count(order_seq) AS tot From S2_eCardOrder  with(nolock) where company_seq=@company_seq and isopen='Y' and xmlBackgroundData<>'' and XmlBackgroundData is not null and XmlMovieData is not null and XmlPictureData is not null 
		
	-- select list
	select top (@pagesize)  order_seq,groomname,bridename, convert(varchar(8),XmlPictureModiDate ,112) as XmlPictureModiDate
		
		from S2_eCardOrder AS A with(nolock)
		
		where company_seq=@company_seq 
		and order_seq not in (select top (@pagesize * (@page - 1)) order_seq from S2_eCardOrder with(nolock) where company_seq=@company_seq and isopen='Y' and xmlBackgroundData<>'' and XmlBackgroundData is not null and XmlMovieData is not null and XmlPictureData is not null  order by order_seq DESC)
		and isopen='Y' and xmlBackgroundData<>'' and XmlBackgroundData is not null and XmlMovieData is not null and XmlPictureData is not null 
		order by order_seq DESC
END

GO
