IF OBJECT_ID (N'dbo.sp_S4BestTotalRanking_Tiara', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S4BestTotalRanking_Tiara
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[sp_S4BestTotalRanking_Tiara]
AS



DECLARE @Gubun_Date varchar(10)
SET @Gubun_Date = CONVERT(VARCHAR(10), GETDATE(), 21)


-- exec sp_S4BestTotalRanking_Tiara
--SET @Gubun_Date = '2011-07-15' 


--##########################################################################
--주간 주문 수량 BEGIN

--TiaraCard 
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt
INTO #RankWeek_Tiara
FROM custom_order WITH(NOLOCK)
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date ), 21)  AND @Gubun_Date
	AND status_seq=15 AND order_Type in ('1','6','7')
	AND company_seq = 1437	--티아라카드
	AND card_seq IN ( Select card_seq from card A WHERE A.CARD_GROUP = 3 AND CARD_CATE = 'I1' and A.DISPLAY_YES_OR_NO in (1,2)  )
GROUP BY card_seq
ORDER BY cnt DESC, card_seq

--주간 주문 수량 END
--##########################################################################



--##########################################################################
--월간 주문 수량 BEGIN

--BHands 
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt
INTO #RankMonth_Tiara
FROM custom_order WITH(NOLOCK)
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date
	AND status_seq=15 AND order_Type in ('1','6','7')
	AND company_seq = 1437	--티아라카드
	AND card_seq IN ( Select card_seq from card A WHERE A.CARD_GROUP = 3 AND CARD_CATE = 'I1' and A.DISPLAY_YES_OR_NO in (1,2)  )
GROUP BY card_seq
ORDER BY cnt DESC, card_seq

--월간 주문 수량 END
--##########################################################################



--##########################################################################
--베스트 랭킹 업데이트 BEGIN 

UPDATE Card 
SET BestRangking = 999, SALES_RANKING = 999
WHERE CARD_GROUP = 3 AND CARD_CATE = 'I1' and DISPLAY_YES_OR_NO in (1,2) 


-- 티아라 주간베스트 업데이트
UPDATE Card
SET BestRangking = B.RankNo
from Card A
JOIN #RankWeek_Tiara B ON A.card_seq = B.Card_Seq			--주간데이터 입력
WHERE A.CARD_GROUP = 3 AND CARD_CATE = 'I1' and A.DISPLAY_YES_OR_NO in (1,2) 



-- 티아라 월간베스트 업데이트
UPDATE Card
SET SALES_RANKING = B.RankNo
from Card A
JOIN #RankMonth_Tiara B ON A.card_seq = B.Card_Seq			--월간데이터 입력
WHERE A.CARD_GROUP = 3 AND CARD_CATE = 'I1' and A.DISPLAY_YES_OR_NO in (1,2) 

--Select CARD_SEQ , BestRangking, SALES_RANKING from card A
--WHERE A.CARD_GROUP = 3 AND CARD_CATE = 'I1' and A.DISPLAY_YES_OR_NO in (1,2) 
--order by SALES_RANKING 

--begin tran 
--exec sp_S4BestTotalRanking_Tiara
--commit
--베스트 랭킹 업데이트 END
--##########################################################################


GO
