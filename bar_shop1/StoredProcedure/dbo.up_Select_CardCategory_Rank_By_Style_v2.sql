IF OBJECT_ID (N'dbo.up_Select_CardCategory_Rank_By_Style_v2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_CardCategory_Rank_By_Style_v2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2016-03-15
-- Description:	카드 카테고리별 랭크 반영 카드 조회
-- 2017.04.05 쿼리 튜닝
--
/*
	exec up_Select_CardCategory_Rank_By_Style 5006, 400, 1
*/
-- =============================================
create PROCEDURE [dbo].[up_Select_CardCategory_Rank_By_Style_v2]
(  
	  @Company_Seq		INT
	, @Order_Num		INT
	, @CardStyle_Num	INT
	, @WSize	varchar(3)
	, @HSize	varchar(3)
)	
AS
BEGIN 

	SELECT    CARD_NAME
			, CARD_CODE
			, CARDSET_PRICE
			, A.CARD_SEQ
			, REGDATE
			, DISCOUNT_RATE
			, CARDIMAGE_FILENAME
			, ISNEW
			, COMPANY_SEQ
			, ISSAMPLE
			, ISFSC
			, COUNT (*) OVER () TOTALCARD_CNT
			, ISNULL(CNT , 1) CNT
			, ROW_NUMBER()OVER(ORDER BY ISNULL(CNT , 1) DESC , REGDATE DESC) RM
	FROM (
			SELECT DISTINCT
				  A.CARD_SEQ
				, A.CARD_CODE
				, A.CARD_NAME
				, A.CARDSET_PRICE
				, A.REGDATE
				, CONVERT(INT, F.DISCOUNT_RATE) AS DISCOUNT_RATE
				, G.CARDIMAGE_FILENAME
				, E.ISNEW
				, E.COMPANY_SEQ
				, H.ISSAMPLE
				, ISNULL(H.ISFSC, '0') AS ISFSC
			FROM S2_CARD AS A
				INNER JOIN S2_CARDSTYLE AS B
					ON A.CARD_SEQ = B.CARD_SEQ
				INNER JOIN S2_CARDSTYLEITEM AS C
					ON B.CARDSTYLE_SEQ = C.CARDSTYLE_SEQ
				INNER JOIN S2_CARDSALESSITE AS E
					ON A.CARD_SEQ = E.CARD_SEQ
				INNER JOIN S2_CARDDISCOUNT AS F
					ON E.CARDDISCOUNT_SEQ = F.CARDDISCOUNT_SEQ
				INNER JOIN S2_CARDIMAGE AS G
					ON A.CARD_SEQ = G.CARD_SEQ 
				INNER JOIN S2_CARDOPTION AS H
					ON A.CARD_SEQ = H.CARD_SEQ
				INNER JOIN S2_CARDKIND AS I 
					ON A.CARD_SEQ = I.CARD_SEQ
				INNER JOIN S2_CARDKINDINFO AS J
					ON I.CARDKIND_SEQ = J.CARDKIND_SEQ
			WHERE 1 = 1
				AND C.CARDSTYLE_SITE = 'A'
				AND C.CARDSTYLE_CATEGORY = 'H'
				AND C.CARDSTYLE_NUM = @CardStyle_Num
				AND F.MINCOUNT = @Order_Num 
				AND G.CARDIMAGE_WSIZE = @WSize
				AND G.CARDIMAGE_HSIZE = @HSize
				AND G.CARDIMAGE_DIV = 'E' 
				AND E.ISDISPLAY = '1' 
				AND E.COMPANY_SEQ = @Company_Seq 
				AND J.CARDKIND_SEQ = 1
				AND E.ISJEHYU <> '1' 
			) A
			LEFT OUTER JOIN
			(
				SELECT CNT,CARD_SEQ FROM S4_BESTTOTALRANKING_BHANDS WHERE GUBUN = 'WEEK' AND GUBUN_DATE > DATEADD(D, -1, GETDATE())
			) B
			ON A.CARD_SEQ = B.CARD_SEQ
		

END
GO
