IF OBJECT_ID (N'dbo.sp_S2BestTotalRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2BestTotalRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_S2BestTotalRanking]
AS



DECLARE @Gubun_Date varchar(10)
SET @Gubun_Date = CONVERT(VARCHAR(10), GETDATE(), 21)

--exec sp_S2BestTotalRanking
--SET @Gubun_Date = '2010-07-19' 

IF EXISTS ( SELECT TOP 1 Gubun_date FROM S2_BestTotalRanking WHERE Gubun_Date = @Gubun_Date )
BEGIN 
	DELETE FROM S2_BestTotalRanking WHERE Gubun_Date = @Gubun_Date
END



--주간 주문 수량
SELECT TOP 30  identity(int, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, sum(order_count) as cnt
INTO #RankWeek
FROM custom_order
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date ), 21)  AND  @Gubun_Date
	AND status_seq=15 AND order_Type in ('1','6','7')
	AND company_seq IN ( 5001, 5002, 5003, 5004, 5005)
group by sales_gubun,card_seq
order by cnt desc



--월간 주문수량
SELECT TOP 30  identity(int, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, card_seq, sum(order_count) as cnt
INTO #RankMonth
FROM custom_order
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date
	AND status_seq=15 AND order_Type in ('1','6','7')
	AND company_seq IN ( 5001, 5002, 5003, 5004, 5005)
group by sales_gubun,card_seq
order by cnt desc



--누적 주문수량
SELECT TOP 30  identity(int, 1, 1) AS RankNo, 'ACCR' AS Gubun, 'AC' AS SubGubun, card_seq, sum(order_count) as cnt
INTO #RankAccrue
FROM custom_order
WHERE status_seq=15 and order_Type in ('1','6','7')	
	AND company_seq IN ( 5001, 5002, 5003, 5004, 5005)
group by sales_gubun,card_seq
order by cnt desc



--월간 샘플 주문수량
SELECT TOP 30  identity(int, 1, 1) AS RankNo, 'SAMP' AS Gubun, 'SA' AS SubGubun, B.card_seq, count(B.card_seq) as cnt
INTO #RankMonthSample
FROM custom_sample_order A 
INNER JOIN custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq
WHERE  CONVERT(VARCHAR(10), delivery_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date
	AND status_seq=12 
	AND A.company_seq IN ( 5001, 5002, 5003, 5004, 5005)
group by card_seq
order by cnt desc



--이용후기
SELECT TOP 30  identity(int, 1, 1) AS RankNo, 'POST' AS Gubun, 'PO' AS SubGubun, card_seq, count(card_seq) as cnt
INTO #RankPost
FROM S2_UserComment 
WHERE company_seq IN ( 5001, 5002, 5003, 5004, 5005)
group by card_seq
order by cnt desc



--찜베스트
SELECT TOP 30  identity(int, 1, 1) AS RankNo, 'ZZIM' AS Gubun, 'ZZ' AS SubGubun, card_seq, count(card_seq) as cnt
INTO #RankZzim
FROM S2_Wishcard
WHERE  CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date
group by card_seq
order by cnt desc




--####################################################################################################
--가격대별 베스트 쿼리 BEGIN


SELECT A.Card_Seq
	, (100-D.DisCount_Rate)/100 * B.CardSet_Price AS Price
	,  CASE WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price < 300 THEN 'P1'
				WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price >= 300 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price < 600 THEN 'P2'
				WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price >= 600 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price < 900 THEN 'P3'
				WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price >= 900 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price < 1200 THEN 'P4'
				WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price >= 1200 THEN 'P5' END AS SubGubun
	, COUNT(A.Card_Seq) AS Cnt
INTO #PriceBestTemp
FROM custom_order A  with(nolock)
JOIN S2_Card B ON A.Card_seq = B.Card_seq
JOIN S2_CardSalesSite C ON A.Card_seq = C.Card_seq
JOIN ( select CardDisCount_Seq, DisCount_Rate from S2_CardDiscount where 400 BETWEEN Mincount AND MaxCount ) D ON C.CardDisCount_Seq = D.CardDisCount_Seq
WHERE CONVERT(VARCHAR(10), A.src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30, @Gubun_Date ), 21)  AND  @Gubun_Date
	AND A.status_seq=15 AND order_Type in ('1','6','7')
	AND A.company_seq IN ( 5001, 5002, 5003, 5004, 5005)
	
GROUP BY  A.Card_Seq, D.DisCount_Rate, B.CardSet_Price
ORDER BY SubGubun, Cnt DESC, Price DESC, A.Card_Seq



SELECT identity(int, 1, 1) AS SerNo
	, SubGubun, Cnt, Card_Seq, Price
INTO #PriceBestSerNoTemp
FROM #PriceBestTemp
ORDER BY  SubGubun, Cnt DESC, Price DESC, Card_Seq
	
	
	

SELECT A.SerNo - B.MinSeq + 1 AS RankNo
	, 'PRIC' AS Gubun,  A.SubGubun
	, A.Card_Seq, A.Cnt, A.Price
INTO #RankPrice
from #PriceBestSerNoTemp A
JOIN (	SELECT SubGubun, MIN(SerNo) AS MinSeq
			FROM #PriceBestSerNoTemp
			GROUP BY SubGubun
) B ON A.SubGubun = B.SubGubun
WHERE A.SerNo - B.MinSeq + 1 <= 10
ORDER BY A.SubGubun, A.Cnt DESC, Price DESC, Card_Seq


--가격대별 베스트 쿼리 END
--####################################################################################################





--####################################################################################################
--S2_BestTotalRanking 베스트 랭킹 순위 Insert

INSERT INTO S2_BestTotalRanking( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt) 
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankWeek
UNION ALL
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankMonth
UNION ALL
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankAccrue
UNION ALL
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankMonthSample
UNION ALL
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankPost
UNION ALL
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankZzim
UNION ALL
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt 
FROM #RankPrice

--####################################################################################################


DROP TABLE #RankWeek
DROP TABLE #RankMonth
DROP TABLE #RankAccrue
DROP TABLE #RankMonthSample
DROP TABLE #RankPost
DROP TABLE #RankZzim
DROP TABLE #RankPrice

DROP TABLE #PriceBestTemp
DROP TABLE #PriceBestSerNoTemp



--DROP TABLE S2_BestTotalRanking

----S2_BestTotalRanking CREATE
--CREATE TABLE  S2_BestTotalRanking (
--		Gubun_date     varchar(10)  NOT NULL ,
--		Gubun     char(4)  NOT NULL ,              
--		SubGubun CHAR(2) NOT NULL,
--		RankNo     smallint  NOT NULL ,
--		Card_Seq     int  NOT NULL ,
--		Cnt     int  NOT NULL ,
--		RankChangeGubun     varchar(5)  NULL ,
--		RankChangeNo     varchar(2)  NULL ,
--		RegDate     smalldatetime  NOT NULL    default getdate(),                         
--PRIMARY KEY(Gubun_date, Gubun, SubGubun, RankNo )
--)
--go






GO
