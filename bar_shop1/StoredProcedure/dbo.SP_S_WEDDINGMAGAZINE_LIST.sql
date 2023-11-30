USE [bar_shop1]
GO
/****** Object:  StoredProcedure [dbo].[SP_S_WEDDINGMAGAZINE_LIST]    Script Date: 2023-08-24 오후 2:12:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SP_S_WEDDINGMAGAZINE_LIST]
/***************************************************************
작성자	:	표수현
작성일	:	2023-02-02
DESCRIPTION	:	웨딩매거진 EXEC SP_S_WEDDINGMAGAZINE_LIST @PAGE_NO=1
SPECIAL LOGIC	: SP_S_WEDDINGMAGAZINE_LIST 1
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @PAGE_NO INT = 1,
 @PAGE_SIZE INT = 12

 AS
	
	SET NOCOUNT ON  
	-- 1. 메인배너 
	SELECT TOP 5 SEQ, KIND, --IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/' + IMG_URL, 
				PC_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/PC/' + IMG_URL,
				MO_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/Mobile/' + MO_IMG_URL,
				LINK_URL = (case when Link_Url is null or Link_Url = ''  then '/magazine/magazine_view.asp?seq=' + CAST(SEQ AS varchar)
						    else Link_Url
							end )
				 , VIEW_YN, TITLE,
				 CONTENTS, VIEW_CNT, REG_DATE, SORTINGNUM, CATEGORY
	FROM WEDDINGMAGAZINE
	WHERE	VIEW_YN = 'Y' AND
			CATEGORY = '1'
	ORDER BY SORTINGNUM ASC


	-- 2. 서브카테고리 배너 
	SELECT	SEQ, KIND,  --IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/' + IMG_URL, 
			PC_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/PC/' + IMG_URL,
			MO_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/Mobile/' + MO_IMG_URL,
			LINK_URL = '/magazine/magazine_view.asp?seq=' + CAST(SEQ AS VARCHAR), VIEW_YN, TITLE,
			CONTENTS, VIEW_CNT, REG_DATE, SORTINGNUM, CATEGORY, LinkTarget = isnull(LinkTarget, '_self') 
	FROM WEDDINGMAGAZINE
	WHERE	VIEW_YN = 'Y' AND
			CATEGORY = '3'
	ORDER BY SORTINGNUM ASC


	IF OBJECT_ID('#TB_TEMP') IS NOT NULL
	 DROP TABLE #TB_TEMP

	-- 3. 리스트배너
	CREATE TABLE #TB_TEMP (SEQ INT IDENTITY(1,1), NUM INT, KIND VARCHAR(20),-- IMG_URL VARCHAR(200),
							PC_IMG_URL VARCHAR(200), MO_IMG_URL VARCHAR(200),
							TITLE VARCHAR(200), CSSCLASS VARCHAR(10), LINKURL  VARCHAR(100), SubTitle varchar(100), BrandName varchar(100))

	--INSERT INTO #TB_TEMP(NUM, KIND, IMG_URL, PC_IMG_URL,MO_IMG_URL,  TITLE, CSSCLASS, LINKURL)
	--SELECT	TOP 6 SEQ, KIND, IMG_URL = '//file.barunsoncard.com/common_img/Card_News/' + IMG_URL , 
	--			PC_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/PC/' + IMG_URL,
	--			MO_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/Mobile/' + IMG_URL,
	--		TITLE, 
	--		 CSSCLASS = (CASE  KIND
	--								WHEN 'MAGAZINE' THEN 'type02'
	--								ELSE 'type01'
	--							  END ),
	--		LINKURL = 'https://m.barunsoncard.com/notice/cardnews_view.asp?seq=' + CAST(SEQ AS varchar)
	--FROM	CARD_NEWS
	--WHERE	VIEW_YN = 'Y'
	--ORDER BY SORTINGNUM ASC
	
	INSERT INTO #TB_TEMP(NUM, KIND, --IMG_URL,
				PC_IMG_URL, MO_IMG_URL, TITLE, CSSCLASS, LINKURL, SubTitle, BrandName)
	SELECT	/*TOP 6*/  SEQ, KIND,-- IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/' + IMG_URL, 
			PC_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/PC/' + IMG_URL,
			MO_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/Mobile/' + MO_IMG_URL,
			TITLE, 
			 --CSSCLASS = 'type03',
			 CSSCLASS = (CASE  KIND
									WHEN 'Event' THEN 'type03'
									WHEN 'Curation' THEN 'type01'
									WHEN 'Magazine' THEN 'type02'
									ELSE 'type04'
								  END ),
			 LINKURL = (case when Link_Url is null or Link_Url = ''  then '/magazine/magazine_view.asp?seq=' + CAST(SEQ AS varchar)
						    else Link_Url
							end ),
			SubTitle,
			BrandName
			
			
	FROM	WEDDINGMAGAZINE
	WHERE	VIEW_YN = 'Y' AND
			CATEGORY = '2'
	ORDER BY SORTINGNUM ASC


	SELECT SEQ ,
			NUM,
			KIND,
			--IMG_URL,
			PC_IMG_URL,
			MO_IMG_URL,
			TITLE,
			CSSCLASS,
			LINKURL,
			SubTitle,
			BrandName
	FROM #TB_TEMP
	ORDER BY SEQ ASC
	OFFSET (@PAGE_NO-1) * @PAGE_SIZE ROW
	FETCH NEXT @PAGE_SIZE ROW ONLY
	--FETCH NEXT @PAGE_SIZE + 1 ROW ONLY

	DECLARE @TOTAL_COUNT INT
	DECLARE @TOTAL_PAGE INT

	SELECT @TOTAL_COUNT = COUNT(*)
	FROM	#TB_TEMP 

	SET @TOTAL_PAGE = CEILING(CONVERT(FLOAT,@TOTAL_COUNT) / @PAGE_SIZE)
	
	SELECT TOTAL_PAGE = @TOTAL_PAGE


 SET NOCOUNT OFF






