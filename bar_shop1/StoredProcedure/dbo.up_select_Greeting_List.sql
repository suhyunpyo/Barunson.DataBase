IF OBJECT_ID (N'dbo.up_select_Greeting_List', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_Greeting_List
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김덕중
-- Create date: 2014-06-30
-- Description:	인사말 리스트 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_Greeting_List]
	-- Add the parameters for the stored procedure here
	@greeting AS int,
	@page	AS int,
	@pagesize AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		if @greeting = 12
			begin
				select COUNT(greeting_seq) from GREETING AS A with(nolock) 
				--join S2_cardOption D on a.card_Seq = D.card_seq 
				where greeting_category_seq in (11,12)
		
				select  top (@pagesize) GREETING_SEQ, GREETING_NAME, GREETING_CONTENT, DISPLAY_YES_OR_NO, USED_COUNT, REGIST_DATE, LAST_UPDATE, RECOMEND_YES_OR_NO, USE_IMAGE, GREETING_CATEGORY_SEQ 
				from GREETING with(nolock)
				where greeting_category_seq in (11,12) 
				and GREETING_SEQ not in (select top (@pagesize * (@page - 1)) GREETING_SEQ from GREETING with(nolock)
				where greeting_category_seq in (11,12) order by GREETING_SEQ ASC)
				order by GREETING_SEQ ASC
			end
		else
			begin
				select COUNT(greeting_seq) from GREETING AS A with(nolock) 
				--join S2_cardOption D on a.card_Seq = D.card_seq 
				where  greeting_category_seq=@greeting 
		
				select  top (@pagesize) GREETING_SEQ, GREETING_NAME, GREETING_CONTENT, DISPLAY_YES_OR_NO, USED_COUNT, REGIST_DATE, LAST_UPDATE, RECOMEND_YES_OR_NO, USE_IMAGE, GREETING_CATEGORY_SEQ 
				from GREETING with(nolock)
				where greeting_category_seq=@greeting 
				and GREETING_SEQ not in (select top (@pagesize * (@page - 1)) GREETING_SEQ from GREETING with(nolock)
				where greeting_category_seq=@greeting order by GREETING_SEQ ASC)
				order by GREETING_SEQ ASC
			end
END

GO
