IF OBJECT_ID (N'dbo.sp_season_CardInfo', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_season_CardInfo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : [2003:11:6] 김수경
	관련페이지 : card/display/card_det.asp
	내용	   :상품 정보 가져오기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[sp_season_CardInfo]
	@card_seq	int
as
begin
	SELECT * FROM CARD
			WHERE CARD_SEQ=@card_seq  
end


GO
