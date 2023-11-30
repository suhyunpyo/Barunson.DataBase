IF OBJECT_ID (N'dbo.SP_S_WEDDINGMAGAZINE_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_WEDDINGMAGAZINE_DETAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_WEDDINGMAGAZINE_DETAIL]
/***************************************************************
작성자	:	표수현
작성일	:	2022-08-17
DESCRIPTION	:	바른손모바일 - 카드 뉴스 DETAIL
SPECIAL LOGIC	: 
************************* *****************************************
MODIFICATION SP_S_WEDDINGMAGAZINE_DETAIL 16
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @SEQ INT--,
 --@LOGIN_ID	VARCHAR(100)
 AS

 SET NOCOUNT ON  

 SELECT SEQ, KIND = ISNULL(KIND, 'Magazine'), 
		IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/' + IMG_URL, 
		PC_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/PC/' + IMG_URL,  
		MO_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/Mobile/' + MO_IMG_URL,  
		LINK_URL = (case when Link_Url is null or Link_Url = ''  then '/magazine/magazine_view.asp?seq=' +  CAST(SEQ AS varchar)
						    else Link_Url
							end ),
			 VIEW_YN, TITLE, CONTENTS, VIEW_CNT,
		REG_DATE, SORTINGNUM, LIST_VIEW_YN, CATEGORY, LINKTARGET, 
		--CSSCLASS = 'type03'
		  CSSCLASS = (CASE  KIND  
			WHEN 'Event' THEN 'type03'  
			WHEN 'Brand' THEN 'type03' 
			WHEN 'Curation' THEN 'type01'  
			WHEN 'Magazine' THEN 'type02'  
			ELSE 'type04'  
			END ) 

 FROM WEDDINGMAGAZINE 
 WHERE SEQ = @SEQ AND VIEW_YN = 'Y'

 	
 SELECT SEQ, KIND, IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/' + IMG_URL,
		PC_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/PC/' + IMG_URL,  
		MO_IMG_URL = '//file.barunsoncard.com/common_img/WeddingMagazine/Mobile/' + MO_IMG_URL,  
		LINK_URL = (
					CASE WHEN LINK_URL IS NULL OR LINK_URL = ''  THEN '/magazine/magazine_view.asp?seq=' +  CAST(SEQ AS VARCHAR)
					else Link_Url
					end ),
		VIEW_YN, TITLE, CONTENTS, VIEW_CNT,
		REG_DATE, SORTINGNUM, LIST_VIEW_YN, CATEGORY, LINKTARGET, 
		--CSSCLASS = 'type03'
		  CSSCLASS = (CASE  KIND  
         WHEN 'Event' THEN 'type03'  
		 WHEN 'Brand' THEN 'type03' 
         WHEN 'Curation' THEN 'type01'  
         WHEN 'Magazine' THEN 'type02'  
         ELSE 'type04'  
		    END ) 
 FROM WEDDINGMAGAZINE 
 WHERE SEQ <> @SEQ  AND VIEW_YN = 'Y' AND CATEGORY = '2'
 ORDER BY REG_DATE DESC

 SET NOCOUNT OFF



GO
