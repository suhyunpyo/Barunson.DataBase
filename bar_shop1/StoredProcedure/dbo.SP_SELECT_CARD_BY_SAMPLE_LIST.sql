IF OBJECT_ID (N'dbo.SP_SELECT_CARD_BY_SAMPLE_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CARD_BY_SAMPLE_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***

EXEC SP_SELECT_CARD_BY_SAMPLE_LIST '', '2017-01-01', '2017-01-31', 'B'

***/
CREATE Procedure [dbo].[SP_SELECT_CARD_BY_SAMPLE_LIST]  
	  @P_SEARCH_VALUE AS VARCHAR(200)
    , @P_START_DATE AS VARCHAR(20)
    , @P_END_DATE AS VARCHAR(20)
    , @P_BRAND_GUBUN AS VARCHAR(10)
AS  

BEGIN
    
    SET NOCOUNT ON;


	--카드별 누적건수
	SELECT		CARD_CODE as CardCode
			,	mc.code_value as Brand
			,   SC.RegDate
			,	CASE WHEN ISNULL(SC.CARD_IMAGE, '') = '' THEN '' ELSE 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + SC.CARD_IMAGE END AS CardImage
			,	SC.Card_Name as CardName
			,   DATEDIFF(DAY, SC.RegDate, GETDATE()) AS SaleDay
			,	CASE WHEN CardSet_Price IS NULL THEN 0 ELSE CardSet_Price END CardSetPrice
			,   CASE WHEN T_CSO.CARD_SEQ IS NULL THEN SC.CARD_SEQ ELSE T_CSO.CARD_SEQ END as CardSeq
			,   CASE WHEN T_CSO.barunsonCnt IS NULL THEN 0 ELSE T_CSO.barunsonCnt END as BarunsonCnt
			,   CASE WHEN T_CSO.bhandsCnt IS NULL THEN 0 ELSE T_CSO.bhandsCnt END as BhandsCnt
			,   CASE WHEN T_CSO.thecardCnt IS NULL THEN 0 ELSE T_CSO.thecardCnt END as ThecardCnt
			,   CASE WHEN T_CSO.mallCnt IS NULL THEN 0 ELSE T_CSO.mallCnt END as MallCnt
			,   CASE WHEN T_CSO.premierCnt IS NULL THEN 0 ELSE T_CSO.premierCnt END as PremierCnt
	FROM	S2_CARD SC
		LEFT JOIN  (		
						SELECT	*
						FROM
						(
							SELECT CARD_SEQ
								, SUM(CASE WHEN SALES_GUBUN IN ('SB') THEN Cnt ELSE 0 END ) AS barunsonCnt
								, SUM(CASE WHEN SALES_GUBUN IN ('ST') THEN Cnt ELSE 0 END ) AS thecardCnt
								, SUM(CASE WHEN SALES_GUBUN IN ('SA') THEN Cnt ELSE 0 END )  AS bhandsCnt
								, SUM(CASE WHEN SALES_GUBUN IN ('B','H','C') THEN Cnt ELSE 0 END )  AS mallCnt
								, SUM(CASE WHEN SALES_GUBUN IN ('SS') THEN Cnt ELSE 0 END )  AS premierCnt
							FROM (
								SELECT  CSO.SALES_GUBUN, CSOI.CARD_SEQ, COUNT(*) AS Cnt
								FROM	 CUSTOM_SAMPLE_ORDER CSO
									JOIN CUSTOM_SAMPLE_ORDER_ITEM  CSOI ON CSO.SAMPLE_ORDER_SEQ = CSOI.SAMPLE_ORDER_SEQ
								WHERE	1 = 1
								AND		CSO.STATUS_SEQ = 12
								AND		CSO.SETTLE_DATE IS NOT NULL
								AND		CSO.DELIVERY_DATE BETWEEN @P_START_DATE AND @P_END_DATE
								GROUP BY CSO.SALES_GUBUN, CSOI.CARD_SEQ
							) A
							GROUP BY A.CARD_SEQ
						) T
				) T_CSO ON SC.CARD_SEQ = T_CSO.CARD_SEQ
		LEFT JOIN manage_code MC ON SC.CardBrand = MC.code AND CODE_TYPE = 'cardbrand'
	WHERE	1 = 1
	AND		SC.CARD_GROUP = 'I'
	AND		SC.Card_Div = 'A01'
	AND		(SC.CARD_CODE LIKE '%' + @P_SEARCH_VALUE + '%' OR SC.CARD_NAME LIKE '%' + @P_SEARCH_VALUE + '%')
	AND		( CASE WHEN @P_BRAND_GUBUN = '' THEN '' ELSE SC.CardBrand END = @P_BRAND_GUBUN )

	ORDER BY SC.Card_Seq DESC		

End
GO
