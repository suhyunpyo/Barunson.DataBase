IF OBJECT_ID (N'dbo.SP_S_MAGAZINE_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_S_MAGAZINE_DETAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_S_MAGAZINE_DETAIL]
/***************************************************************
작성자	:	표수현
작성일	:	2022-08-17
DESCRIPTION	:	바른손모바일 - 카드 뉴스 DETAIL
SPECIAL LOGIC	: 
******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
 @SEQ INT,
 @LOGIN_ID	VARCHAR(100)
 AS

 IF @LOGIN_ID = 's4guest' BEGIN 
	
	SELECT SEQ, KIND, IMG_URL, TITLE, CONTENTS, VIEW_CNT, REG_DATE,
	cssclass = (case  kind
		when 'Magazine' then 'type02'
		else 'type01'
	end )
	FROM CARD_NEWS 
	WHERE SEQ = @SEQ  AND VIEW_YN = 'Y'

 END ELSE BEGIN 
 
	SELECT SEQ, KIND, IMG_URL, TITLE, CONTENTS, VIEW_CNT, REG_DATE,
	cssclass = (case  kind
		when 'Magazine' then 'type02'
		else 'type01'
	end )
	FROM CARD_NEWS 
	WHERE SEQ = @SEQ AND VIEW_YN = 'Y'

 END 
  
	SELECT SEQ, KIND, IMG_URL, TITLE, CONTENTS, VIEW_CNT, REG_DATE,
	cssclass = (case  kind
		when 'Magazine' then 'type02'
		else 'type01'
	end )
	FROM CARD_NEWS 
	WHERE SEQ <> @SEQ  AND VIEW_YN = 'Y'
	ORDER BY REG_DATE DESC



GO
