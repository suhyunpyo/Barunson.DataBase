IF OBJECT_ID (N'dbo.SP_S_MAGAZINE_LIST_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_MAGAZINE_LIST_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_MAGAZINE_LIST_TEST]
/***************************************************************
작성자	:	표수현
작성일	:	2022-08-17
DESCRIPTION	:	바른손모바일 - 카드 뉴스 전체 리스트 
SPECIAL LOGIC	: SP_S_MAGAZINE_LIST 1
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @PAGE_NO INT = 1,
 @PAGE_SIZE INT = 10

 AS

	SELECT TOP 5 SEQ, KIND, IMG_URL, TITLE, CONTENTS, VIEW_CNT, 
		   REG_DATE, CSSCLASS = (CASE  KIND
									   WHEN 'MAGAZINE' THEN 'type02'
										ELSE 'type01'
								 END )
	FROM	CARD_NEWS
	WHERE VIEW_YN = 'Y'
	ORDER BY SORTINGNUM ASC


	SELECT	SEQ, KIND, IMG_URL, TITLE, CONTENTS, VIEW_CNT, 
			REG_DATE, CSSCLASS = (CASE  KIND
									WHEN 'MAGAZINE' THEN 'type02'
									ELSE 'type01'
								  END )
	FROM	CARD_NEWS
	WHERE VIEW_YN = 'Y'
	ORDER BY SORTINGNUM ASC
	
	OFFSET (@PAGE_NO-1) * @PAGE_SIZE ROW
	FETCH NEXT @PAGE_SIZE ROW ONLY

	DECLARE @TOTAL_COUNT INT
	DECLARE @TOTAL_PAGE INT

	SELECT @TOTAL_COUNT = COUNT(*)
	FROM	CARD_NEWS 

	SET @TOTAL_PAGE = @TOTAL_COUNT / @PAGE_SIZE 

	--SELECT TOTAL_PAGE = @TOTAL_PAGE-- + 1

	IF @TOTAL_PAGE = 0 BEGIN 
		SELECT TOTAL_PAGE = 1
	END ELSE BEGIN 
		SELECT TOTAL_PAGE = @TOTAL_PAGE

	END 

GO
