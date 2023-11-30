IF OBJECT_ID (N'dbo.sp_season_CardList_cnt', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_season_CardList_cnt
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : [2003:10:27] 김수경
	관련페이지 : card/display/card_list.asp
	내용	   :상품 리스트 정보 가져오기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[sp_season_CardList_cnt]
	@CAT_SEQ	varchar(20)
as
begin
	
	SELECT COUNT(*)  FROM CARD 
		WHERE DISPLAY_YES_OR_NO=1 
		 AND CARD_CATEGORY_SEQ=@CAT_SEQ
end


GO
