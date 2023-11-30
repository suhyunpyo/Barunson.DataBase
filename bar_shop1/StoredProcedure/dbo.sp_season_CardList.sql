IF OBJECT_ID (N'dbo.sp_season_CardList', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_season_CardList
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
CREATE Procedure [dbo].[sp_season_CardList]
	@CAT_SEQ		varchar(20)
	,@pagesize		varchar(10)
	,@cpage		varchar(10)
as
	DECLARE	@SQL	VARCHAR(2000)
	
	SET @SQL = '	SELECT  TOP '+@pagesize+'  CARD_SEQ,CARD_CODE,CARD_PRICE_CUSTOMER,CARD_IMG_S FROM CARD 
				WHERE DISPLAY_YES_OR_NO=1  '
IF	@CAT_SEQ != '' 	SET @SQL = @SQL + ' AND CARD_CATEGORY_SEQ='+@CAT_SEQ
	SET @SQL = @SQL + ' 	 NOT IN (SELECT TOP '+((cast(@cpage as int)-1)*cast(@pagesize as int))+' CARD_SEQ FROM CARD 
				WHERE DISPLAY_YES_OR_NO=1  '
IF	@CAT_SEQ != '' 	SET @SQL = @SQL + ' AND CARD_CATEGORY_SEQ='+@CAT_SEQ
SET @SQL = @SQL + ' 	ORDER BY CARD_PRICE_CUSTOMER DESC) '
SET @SQL = @SQL + ' 	ORDER BY CARD_PRICE_CUSTOMER DESC'
	EXEC(@SQL)


GO
