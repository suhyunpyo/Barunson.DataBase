IF OBJECT_ID (N'dbo.SP_SELECT_CARD_BY_SAMPLE_TOTAL_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CARD_BY_SAMPLE_TOTAL_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/***

EXEC SP_SELECT_CARD_BY_SAMPLE_TOTAL_LIST_HG '', '2018-01-08', '2018-01-15', ''

***/
CREATE Procedure [dbo].[SP_SELECT_CARD_BY_SAMPLE_TOTAL_LIST]  
	  @P_SEARCH_VALUE AS VARCHAR(200)
    , @P_START_DATE AS VARCHAR(20)
    , @P_END_DATE AS VARCHAR(20)
    , @P_BRAND_GUBUN AS VARCHAR(10)
AS  

BEGIN
    
    SET NOCOUNT ON;

	--토탈건수
	SELECT 
		max(statsname) as StatsName, 
		SUM(BRC) AS BarunsonCnt, 
		SUM(NBRC) AS NBarunsonCnt, 
		SUM(BHC) AS  BhandsCnt, 
		SUM(THC) AS ThecardCnt,
		SUM(NTHC) AS NThecardCnt, 
		SUM(JHC) AS MallCnt, 
		SUM(PRC) AS PremierCnt, 
		SUM(BRC+THC+BHC+JHC+PRC+NBRC+NTHC) AS SumTotalCnt
	FROM
	(
		SELECT
		 '총샘플수량' as statsName
		, CASE WHEN CardSet_Price IS NULL THEN 0 ELSE CardSet_Price END CardSetPrice
		, CASE WHEN T_CSO.CARD_SEQ IS NULL THEN SC.CARD_SEQ ELSE T_CSO.CARD_SEQ END as CardSeq
		, CASE WHEN T_CSO.barunsoncard IS NULL THEN 0 ELSE T_CSO.barunsoncard END as BRC
        , CASE WHEN T_CSO.n_barunsoncard IS NULL THEN 0 ELSE T_CSO.n_barunsoncard END AS NBRC
		, CASE WHEN T_CSO.bhandscard IS NULL THEN 0 ELSE T_CSO.bhandscard END as BHC
		, CASE WHEN T_CSO.thecard IS NULL THEN 0 ELSE T_CSO.thecard END as THC
		, CASE WHEN T_CSO.n_thecard IS NULL THEN 0 ELSE T_CSO.n_thecard END as NTHC
		, CASE WHEN T_CSO.mall IS NULL THEN 0 ELSE T_CSO.mall END as JHC
		, CASE WHEN T_CSO.premier IS NULL THEN 0 ELSE T_CSO.premier END as PRC
		FROM S2_CARD SC
			LEFT JOIN ( 
						SELECT *
						FROM
						(

							SELECT CARD_SEQ
							, SUM(CASE WHEN SALES_GUBUN IN ('SB') AND A.MEMBER_ID <> '' THEN Cnt ELSE 0 END ) AS barunsoncard
                            , SUM(CASE WHEN SALES_GUBUN IN ('SB') AND A.MEMBER_ID = '' THEN Cnt Else 0 END ) AS N_barunsoncard
							, SUM(CASE WHEN SALES_GUBUN IN ('SA') THEN Cnt ELSE 0 END ) AS bhandscard
							, SUM(CASE WHEN SALES_GUBUN IN ('ST') AND A.MEMBER_ID <> '' THEN Cnt ELSE 0 END ) AS thecard 
							, SUM(CASE WHEN SALES_GUBUN IN ('ST') AND A.MEMBER_ID = '' THEN Cnt ELSE 0 END ) AS n_thecard 
							, SUM(CASE WHEN SALES_GUBUN IN ('B','H','C') THEN Cnt ELSE 0 END ) AS mall
							, SUM(CASE WHEN SALES_GUBUN IN ('SS') THEN Cnt ELSE 0 END ) AS premier
							FROM (
									SELECT CSO.SALES_GUBUN, CSOI.CARD_SEQ, CSO.MEMBER_ID AS MEMBER_ID, COUNT(*) AS Cnt
									FROM CUSTOM_SAMPLE_ORDER CSO
									JOIN CUSTOM_SAMPLE_ORDER_ITEM CSOI ON CSO.SAMPLE_ORDER_SEQ = CSOI.SAMPLE_ORDER_SEQ
									WHERE 1 = 1
									AND CSO.STATUS_SEQ = 12
									AND CSO.SETTLE_DATE IS NOT NULL
									AND CSO.DELIVERY_DATE BETWEEN @P_START_DATE AND @P_END_DATE + ' 23:59:59'
									GROUP BY CSO.SALES_GUBUN, CSOI.CARD_SEQ, CSO.MEMBER_ID
								) A
							GROUP BY A.CARD_SEQ
						) T
			) T_CSO ON SC.CARD_SEQ = T_CSO.CARD_SEQ
			LEFT JOIN manage_code MC ON SC.CardBrand = MC.code AND MC.CODE_TYPE = 'cardbrand'
		WHERE 1 = 1
		AND SC.CARD_GROUP = 'I'
		AND SC.Card_Div = 'A01' 
		--ORDER BY SC.Card_Seq DESC
	) Z

	UNION ALL
	(
		SELECT max(statsName) , max(barunsonCnt), max(n_barunsonCnt), max(bhandsCnt), max(thecardCnt), max(n_thecardCnt), max(mallCnt), max(premierCnt)
			, SUM(barunsonCnt + n_barunsonCnt + bhandsCnt + thecardCnt + n_thecardCnt + mallCnt + premierCnt) totalCnt
		FROM (
			SELECT 
			'총신청건수' as statsName
			, SUM(CASE WHEN SALES_GUBUN IN ('SB') and MEMBER_ID <> '' THEN 1 ELSE 0 END ) AS barunsonCnt
			, SUM(CASE WHEN SALES_GUBUN IN ('SB') and MEMBER_ID = '' THEN 1 ELSE 0 END ) AS n_barunsonCnt
			, SUM(CASE WHEN SALES_GUBUN IN ('SA') THEN 1 ELSE 0 END ) AS bhandsCnt
			, SUM(CASE WHEN SALES_GUBUN IN ('ST') and MEMBER_ID <> '' THEN 1 ELSE 0 END ) AS thecardCnt
			, SUM(CASE WHEN SALES_GUBUN IN ('ST') and MEMBER_ID = '' THEN 1 ELSE 0 END ) AS n_thecardCnt
			, SUM(CASE WHEN SALES_GUBUN IN ('B','H','C') THEN 1 ELSE 0 END ) AS mallCnt
			, SUM(CASE WHEN SALES_GUBUN IN ('SS') THEN 1 ELSE 0 END ) AS  premierCnt
			--, SUM(CASE WHEN SALES_GUBUN IN ('SB','ST','SA''B','H','C','SS') THEN 1 ELSE 0 END ) AS totalCnt
			FROM CUSTOM_SAMPLE_ORDER
			WHERE 1 = 1
			AND STATUS_SEQ = 12
			AND SETTLE_DATE IS NOT NULL
			AND DELIVERY_DATE BETWEEN @P_START_DATE AND @P_END_DATE + ' 23:59:59'
		) A
	)



End
GO
