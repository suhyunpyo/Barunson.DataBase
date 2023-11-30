IF OBJECT_ID (N'dbo.sp_S4BestTotalRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S4BestTotalRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE proc [dbo].[sp_S4BestTotalRanking]  
AS  
  
  
  
  
DECLARE @Gubun_Date varchar(10)  
SET @Gubun_Date = CONVERT(VARCHAR(10), GETDATE(), 21)  
  
  
-- exec sp_S4BestTotalRanking  
--SET @Gubun_Date = '2012-02-25'   
  
--select * from S4_BestTotalRanking_BHands where Gubun_date = '2011-07-15'  
  
--S4_BestTotalRanking_bsmall : 2016.12.07 바른손몰 추가  
  
IF EXISTS (   
   SELECT TOP 1 Gubun_date FROM S4_BestTotalRanking_BHands WHERE Gubun_Date = @Gubun_Date   
   UNION ALL   
   SELECT TOP 1 Gubun_date FROM S4_BestTotalRanking_Thecard WHERE Gubun_Date = @Gubun_Date   
   UNION ALL   
   SELECT TOP 1 Gubun_date FROM S4_BestTotalRanking_Premier WHERE Gubun_Date = @Gubun_Date   
   UNION ALL   
   SELECT TOP 1 Gubun_date FROM S4_BestTotalRanking_Barunson WHERE Gubun_Date = @Gubun_Date   
   UNION ALL   
   SELECT TOP 1 Gubun_date FROM S4_BestTotalRanking_bsmall WHERE Gubun_Date = @Gubun_Date   
 )  
BEGIN   
 DELETE FROM S4_BestTotalRanking_BHands WHERE Gubun_Date = @Gubun_Date  
 DELETE FROM S4_BestTotalRanking_Thecard WHERE Gubun_Date = @Gubun_Date  
 DELETE FROM S4_BestTotalRanking_Premier WHERE Gubun_Date = @Gubun_Date  
 DELETE FROM S4_BestTotalRanking_Barunson WHERE Gubun_Date = @Gubun_Date  
 DELETE FROM S4_BestTotalRanking_bsmall WHERE Gubun_Date = @Gubun_Date  
END  
  
  
  
  
  
--월간 샘플 주문수량 BEGIN  
  
--비핸즈샘플  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'SAMP' AS Gubun, 'SA' AS SubGubun, B.card_seq, COUNT(B.card_seq) as cnt  
INTO #RankMonthSample_BHands  
FROM custom_sample_order A   
JOIN custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq  
WHERE  CONVERT(VARCHAR(10), delivery_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=12   
 AND A.company_seq IN ( 5001, 5002, 5003, 5004, 5005, 5006 )  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
--더카드샘플  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'SAMP' AS Gubun, 'SA' AS SubGubun, B.card_seq, COUNT(B.card_seq) as cnt  
INTO #RankMonthSample_Thecard  
FROM custom_sample_order A   
JOIN custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq  
WHERE  CONVERT(VARCHAR(10), delivery_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=12   
 AND A.company_seq = 5007  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1  )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
--PremierBHands샘플  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'SAMP' AS Gubun, 'SA' AS SubGubun, B.card_seq, COUNT(B.card_seq) as cnt  
INTO #RankMonthSample_Premier  
FROM custom_sample_order A   
JOIN custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq  
WHERE  CONVERT(VARCHAR(10), delivery_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=12   
 AND A.company_seq = 5003  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5003 AND IsDisplay = 1  )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
--바른손몰샘플 BSMall (신규)  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'SAMP' AS Gubun, 'SA' AS SubGubun, B.card_seq, COUNT(B.card_seq) as cnt  
INTO #RankMonthSample_BSMall  
FROM custom_sample_order A   
JOIN custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq  
WHERE  CONVERT(VARCHAR(10), delivery_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=12   
 AND A.Sales_gubun = 'B'  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC   
  
  
--바른손샘플  
-- 매월 1일에 업데이트  
IF (SELECT DATEPART(DAY, GETDATE())) = 1  
BEGIN  
  
  
    SELECT IDENTITY(INT, 1, 1) AS RankNo, 'SAMP' AS Gubun, 'SA' AS SubGubun, B.card_seq, COUNT(B.card_seq) as cnt  
    INTO #RankMonthSample_Barunson  
    FROM custom_sample_order A   
    JOIN custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq  
    WHERE  CONVERT(VARCHAR(10), delivery_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(MONTH, -1,  @Gubun_Date ), 21)  AND  @Gubun_Date  
     AND status_seq=12   
     AND A.company_seq IN ( 5001, 5002, 5003, 5004, 5005, 5006 )  
     AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
     AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
    GROUP BY card_seq  
    ORDER BY cnt DESC  
  
END  
  
--월간 샘플 주문수량 END  
  
  
  
  
  
--##########################################################################  
--주간 주문 수량 BEGIN  
  
--BHands   
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
INTO #RankWeek_BHands  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date ), 21)  AND @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND company_seq = 5006  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq  
  
  
  
--TheCard  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt --COUNT(card_seq) as cnt  
INTO #RankWeek_TheCard  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND company_seq = 5007  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq   
  
  
--PremierBHands  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, COUNT(card_seq) as cnt  
INTO #RankWeek_Premier  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND company_seq = 5003  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5003 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq   
  
  
--바른손몰 BSMall  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
INTO #RankWeek_BSMall  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date ), 21)  AND @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND sales_gubun in ('B','H')  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq  
  
--Barunsoncard   
-- 매주 월요일에 업데이트  
--IF (SELECT DATEPART(DW, GETDATE())) = 2  
--BEGIN  
  
    SELECT IDENTITY(INT, 1, 1) AS RankNo, 'WEEK' AS Gubun, 'WE' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
    INTO #RankWeek_Barunson  
    FROM custom_order WITH(NOLOCK)  
    WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date ), 21)  AND @Gubun_Date  
     AND status_seq=15 AND order_Type in ('1','6','7')  
     AND company_seq = 5001  
     AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
     AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
    GROUP BY card_seq  
    ORDER BY cnt DESC, card_seq  
  
--END  
--주간 주문 수량 END  
--##########################################################################  
  
  
  
--##########################################################################  
--월간 주문 수량 BEGIN  
  
--BHands   
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
INTO #RankMonth_BHands  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND company_seq = 5006  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq  
  
  
  
--TheCard  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, CO.card_seq, CO.cnt -- COUNT(card_seq) as cnt  
INTO #RankMonth_TheCard  
FROM    (  
            SELECT  card_seq, SUM(ISNULL(order_count, 0)) as cnt  
            FROM custom_order WITH(NOLOCK)  
            WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date), 21)  AND  @Gubun_Date  
             AND status_seq=15 AND order_Type in ('1','6','7')  
             AND company_seq = 5007  
             AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1 )  
             AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
            GROUP BY card_seq  
        ) CO  
  
JOIN S2_CARD AS SC ON CO.CARD_SEQ = SC.CARD_SEQ  
LEFT JOIN #RankMonthSample_Thecard AS RMS_T ON CO.CARD_SEQ = RMS_T.CARD_SEQ  
  
ORDER BY CO.cnt DESC, RMS_T.cnt DESC, SC.RegDate ASC, CO.card_seq   
  
  
  
--PremierBHands  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, card_seq, COUNT(card_seq) as cnt  
INTO #RankMonth_Premier  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND company_seq = 5003  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5003 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq   
  
--바른손몰 BSMall  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
INTO #RankMonth_BSMall  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND sales_gubun ='B'  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq  
  
  
--Barunsoncard  
-- 매월 1일에 업데이트  
--IF (SELECT DATEPART(DAY, GETDATE())) = 1  
--BEGIN  
  
    SELECT IDENTITY(INT, 1, 1) AS RankNo, 'MONT' AS Gubun, 'MO' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
    INTO #RankMonth_Barunson  
    FROM custom_order WITH(NOLOCK)  
    --WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(MONTH, -1,  @Gubun_Date ), 21)  AND  @Gubun_Date  
	WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
     AND status_seq=15 AND order_Type in ('1','6','7')  
     AND company_seq = 5001  
     AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
     AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
    GROUP BY card_seq  
    ORDER BY cnt DESC, card_seq  
  
--END  
--월간 주문 수량 END  
--##########################################################################  
  
  
--##########################################################################  
--비핸즈 Steady(6개월) 주문 수량 BEGIN  
  
--BHands   
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'STEA' AS Gubun, 'ST' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
INTO #RankSteady_BHands  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -180,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND company_seq = 5006  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq  
  
  
--바른손몰 Steady(6개월) 주문 수량 BEGIN  
  
--BSMall  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'STEA' AS Gubun, 'ST' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
INTO #RankSteady_BSMall  
FROM custom_order WITH(NOLOCK)  
WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -180,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND status_seq=15 AND order_Type in ('1','6','7')  
 AND sales_gubun = 'B'  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC, card_seq  
  
  
--바른손 Steady(6개월) 주문 수량 BEGIN  
--Barunsoncard  
  
-- 매년 1월 1일에 업데이트  
IF (SELECT DATEPART(MONTH, GETDATE())) = 1 AND (SELECT DATEPART(DAY, GETDATE())) = 1  
BEGIN  
  
  
    SELECT IDENTITY(INT, 1, 1) AS RankNo, 'STEA' AS Gubun, 'ST' AS SubGubun, card_seq, SUM(ISNULL(order_count, 0)) as cnt  
    INTO #RankSteady_Barunson  
    FROM custom_order WITH(NOLOCK)  
    WHERE CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(YEAR, -1,  @Gubun_Date ), 21)  AND  @Gubun_Date  
     AND status_seq=15 AND order_Type in ('1','6','7')  
     AND company_seq = 5001  
     AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
     AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 )--청첩장인것만  
    GROUP BY card_seq  
    ORDER BY cnt DESC, card_seq  
  
END  
--바른손 스테디(6개월) 주문 수량 END  
--##########################################################################  
  
  
  
  
  
  
  
--이용후기 BEGIN  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PO' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPost_BHands  
FROM S2_UserComment   
WHERE company_seq = 5006  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND reg_date >=  CONVERT(VARCHAR(10), DATEADD(month, -6,  getdate() ), 21)  -- 2017.03.07 6개월 추가  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PO' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPost_Thecard  
FROM S2_UserComment   
WHERE company_seq = 5007  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PO' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPost_Premier  
FROM S2_UserComment   
WHERE company_seq = 5003  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5003 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PO' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPost_BSMall  
FROM S2_UserComment   
WHERE sales_gubun = 'B'  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PO' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPost_Barunson  
FROM S2_UserComment   
WHERE company_seq = 5001 
 AND reg_date >=  CONVERT(VARCHAR(10), DATEADD(month, -6,  getdate() ), 21)  -- 2020.03.23 6개월 추가  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
--이용후기 END  
  
  
  
-- 이용후기 월간, 주간 BEGIN  
-- 비핸즈  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PW' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPostWeek_BHands  
FROM S2_UserComment   
WHERE company_seq = 5006  
 AND CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -21,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PM' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPostMonth_BHands  
FROM S2_UserComment   
WHERE company_seq = 5006  
 AND CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -60,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
-- 바른손카드  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PW' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPostWeek_Barunson  
FROM S2_UserComment   
WHERE company_seq = 5001  
 AND CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -21,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PM' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPostMonth_Barunson  
FROM S2_UserComment   
WHERE company_seq = 5001  
 AND CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -60,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
-- 바른손몰  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PW' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPostWeek_BSMall  
FROM S2_UserComment   
WHERE sales_gubun = 'B'  
 AND CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -21,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT  IDENTITY(INT, 1, 1) AS RankNo, 'POST' AS Gubun, 'PM' AS SubGubun, card_seq, COUNT(card_seq) AS cnt  
INTO #RankPostMonth_BSMall  
FROM S2_UserComment   
WHERE sales_gubun = 'B'  
 AND CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -60,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1)  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY card_seq  
ORDER BY cnt DESC   
  
--이용후기 월간, 주간 END  
  
  
  
--찜베스트 BEGIN  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'ZZIM' AS Gubun, 'ZZ' AS SubGubun, card_seq, count(card_seq) as cnt  
INTO #RankZzim_BHands  
FROM S2_Wishcard  
WHERE  CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND company_seq IN ( 5001, 5002, 5003, 5004, 5005, 5006 )  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'ZZIM' AS Gubun, 'ZZ' AS SubGubun, card_seq, count(card_seq) as cnt  
INTO #RankZzim_Thecard  
FROM S2_Wishcard  
WHERE  CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq= 5007 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND company_seq = 5007  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'ZZIM' AS Gubun, 'ZZ' AS SubGubun, card_seq, count(card_seq) as cnt  
INTO #RankZzim_Premier  
FROM S2_Wishcard  
WHERE  CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq= 5003 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND company_seq = 5003  
GROUP BY card_seq  
ORDER BY cnt DESC  
  
  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'ZZIM' AS Gubun, 'ZZ' AS SubGubun, card_seq, count(card_seq) as cnt  
INTO #RankZzim_BSMall  
FROM S2_Wishcard  
WHERE  CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND site_div = 'B'  
GROUP BY card_seq  
ORDER BY cnt DESC   
  
  
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'ZZIM' AS Gubun, 'ZZ' AS SubGubun, card_seq, count(card_seq) as cnt  
INTO #RankZzim_Barunson  
FROM S2_Wishcard  
WHERE  CONVERT(VARCHAR(10), reg_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND company_seq IN ( 5001, 5002, 5003, 5004, 5005, 5006 )  
GROUP BY card_seq  
ORDER BY cnt DESC  
--찜베스트 END  
  
  
  
  
  
--####################################################################################################  
--더카드 가격대별 베스트 쿼리 BEGIN  
  
  
SELECT A.Card_Seq  
 , (100-D.DisCount_Rate)/100 * B.CardSet_Price AS Price  
 ,  CASE WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 300 THEN 'P1'  
    WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 300 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 400 THEN 'P2'  
    WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 400 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 700 THEN 'P3'  
    WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 700 THEN 'P4' END AS SubGubun  
    --WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 600 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price < 1200 THEN 'P4'  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #PriceBestTemp  
FROM custom_order A  with(nolock)  
JOIN S2_Card B ON A.Card_seq = B.Card_seq  
JOIN S2_CardSalesSite C ON A.Card_seq = C.Card_seq AND C.company_seq = 5007  
JOIN ( select CardDisCount_Seq, DisCount_Rate from S2_CardDiscount where 400 BETWEEN Mincount AND MaxCount ) D ON C.CardDisCount_Seq = D.CardDisCount_Seq  
WHERE CONVERT(VARCHAR(10), A.src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7, @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND A.status_seq=15 AND order_Type in ('1','6','7')  
 AND A.company_seq = 5007  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY  A.Card_Seq, D.DisCount_Rate, B.CardSet_Price  
ORDER BY SubGubun, Cnt DESC, Price DESC, A.Card_Seq  
  
  
  
SELECT identity(int, 1, 1) AS SerNo  
 , SubGubun AS SubGubun, Cnt, Card_Seq, Price  
INTO #PriceBestSerNoTemp  
FROM #PriceBestTemp  
ORDER BY  SubGubun, Cnt DESC, Price DESC, Card_Seq  
  
  
  
SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
 , 'PRIC' AS Gubun,  A.SubGubun  
 , A.Card_Seq, A.Cnt, A.Price  
INTO #RankPrice  
from #PriceBestSerNoTemp A  
JOIN ( SELECT SubGubun, MIN(SerNo) AS MinSeq  
   FROM #PriceBestSerNoTemp  
   GROUP BY SubGubun  
) B ON A.SubGubun = B.SubGubun  
WHERE A.SerNo - B.MinSeq + 1 <= 10  
ORDER BY A.SubGubun, A.Cnt DESC, Price DESC, Card_Seq  
  
  
--가격대별 베스트 쿼리 END  
--####################################################################################################  
  
  
  
--####################################################################################################  
--비핸즈 가격대별 베스트 쿼리 BEGIN  
  
SELECT A.Card_Seq  
    ,B.CardSet_Price AS Price  
 ,  CASE WHEN B.CardSet_Price <= 699 THEN 'P1'  
   WHEN B.CardSet_Price > 699 AND  B.CardSet_Price <= 799 THEN 'P2'  
   WHEN B.CardSet_Price > 799 AND  B.CardSet_Price <= 899 THEN 'P3'  
   WHEN B.CardSet_Price > 899 THEN 'P4' END AS SubGubun  
 --, (100-D.DisCount_Rate)/100 * B.CardSet_Price AS Price  
 --,  CASE WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 699 THEN 'P1'  
 --   WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 699 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 799 THEN 'P2'  
 --   WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 799 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 899 THEN 'P3'  
 --   WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 899 THEN 'P4' END AS SubGubun  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
  
INTO #BhandsPriceBestTemp  
FROM custom_order A  with(nolock)  
JOIN S2_Card B ON A.Card_seq = B.Card_seq  
JOIN S2_CardSalesSite C ON A.Card_seq = C.Card_seq AND C.company_seq = 5006  
JOIN ( select CardDisCount_Seq, DisCount_Rate from S2_CardDiscount where 400 BETWEEN Mincount AND MaxCount ) D ON C.CardDisCount_Seq = D.CardDisCount_Seq  
WHERE CONVERT(VARCHAR(10), A.src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90, @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND A.status_seq=15 AND order_Type in ('1','6','7')  
 AND A.company_seq = 5006  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY  A.Card_Seq, D.DisCount_Rate, B.CardSet_Price  
ORDER BY SubGubun, Cnt DESC, Price DESC, A.Card_Seq  
  
  
  
SELECT identity(int, 1, 1) AS SerNo  
 , SubGubun AS SubGubun, Cnt, Card_Seq, Price  
INTO #BhandsPriceBestSerNoTemp  
FROM #BhandsPriceBestTemp  
ORDER BY  SubGubun, Cnt DESC, Price DESC, Card_Seq  
  
  
  
SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
 , 'PRIC' AS Gubun,  A.SubGubun  
 , A.Card_Seq, A.Cnt, A.Price  
INTO #BhandsRankPrice  
from #BhandsPriceBestSerNoTemp A  
JOIN ( SELECT SubGubun, MIN(SerNo) AS MinSeq  
   FROM #BhandsPriceBestSerNoTemp  
   GROUP BY SubGubun  
) B ON A.SubGubun = B.SubGubun  
WHERE A.SerNo - B.MinSeq + 1 <= 10  
ORDER BY A.SubGubun, A.Cnt DESC, Price DESC, Card_Seq  
  
  
--비핸즈 가격대별 베스트 쿼리 END  
--####################################################################################################  
  
  
--####################################################################################################  
--바른손몰 가격대별 베스트 쿼리 BEGIN  
  
SELECT A.Card_Seq  
    ,B.CardSet_Price AS Price  
 ,  CASE WHEN B.CardSet_Price <= 699 THEN 'P1'  
   WHEN B.CardSet_Price > 699 AND  B.CardSet_Price <= 799 THEN 'P2'  
   WHEN B.CardSet_Price > 799 AND  B.CardSet_Price <= 899 THEN 'P3'  
   WHEN B.CardSet_Price > 899 THEN 'P4' END AS SubGubun  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
INTO #BSMallPriceBestTemp  
FROM custom_order A  with(nolock)  
JOIN S2_Card B ON A.Card_seq = B.Card_seq  
JOIN S2_CardSalesSite C ON A.Card_seq = C.Card_seq AND C.company_seq = 5000  
JOIN ( select CardDisCount_Seq, DisCount_Rate from S2_CardDiscount where 400 BETWEEN Mincount AND MaxCount ) D ON C.CardDisCount_Seq = D.CardDisCount_Seq  
WHERE CONVERT(VARCHAR(10), A.src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90, @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND A.status_seq=15 AND order_Type in ('1','6','7')  
 AND A.sales_gubun ='B'  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY  A.Card_Seq, D.DisCount_Rate, B.CardSet_Price  
ORDER BY SubGubun, Cnt DESC, Price DESC, A.Card_Seq  
  
  
  
SELECT identity(int, 1, 1) AS SerNo  
 , SubGubun AS SubGubun, Cnt, Card_Seq, Price  
INTO #BSMallPriceBestSerNoTemp  
FROM #BSMallPriceBestTemp  
ORDER BY  SubGubun, Cnt DESC, Price DESC, Card_Seq  
  
  
  
SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
 , 'PRIC' AS Gubun,  A.SubGubun  
 , A.Card_Seq, A.Cnt, A.Price  
INTO #BSMallRankPrice  
from #BSMallPriceBestSerNoTemp A  
JOIN ( SELECT SubGubun, MIN(SerNo) AS MinSeq  
   FROM #BSMallPriceBestSerNoTemp  
   GROUP BY SubGubun  
) B ON A.SubGubun = B.SubGubun  
WHERE A.SerNo - B.MinSeq + 1 <= 10  
ORDER BY A.SubGubun, A.Cnt DESC, Price DESC, Card_Seq  
  
  
--바른손몰 가격대별 베스트 쿼리 END  
--####################################################################################################  
  
  
  
--####################################################################################################  
--바른손 가격대별 베스트 쿼리 BEGIN  
  
SELECT A.Card_Seq  
 , (100-D.DisCount_Rate)/100 * B.CardSet_Price AS Price  
 ,  CASE WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 399 THEN 'P1'  
    WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 399 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 599 THEN 'P2'  
    WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 599 AND (100-D.DisCount_Rate)/100 * B.CardSet_Price <= 699 THEN 'P3'  
    WHEN (100-D.DisCount_Rate)/100 * B.CardSet_Price > 699 THEN 'P4' END AS SubGubun  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.order_count) AS Cnt  
  
INTO #BarunsonPriceBestTemp  
FROM custom_order A  with(nolock)  
JOIN S2_Card B ON A.Card_seq = B.Card_seq  
JOIN S2_CardSalesSite C ON A.Card_seq = C.Card_seq AND C.company_seq = 5001  
JOIN ( select CardDisCount_Seq, DisCount_Rate from S2_CardDiscount where 400 BETWEEN Mincount AND MaxCount ) D ON C.CardDisCount_Seq = D.CardDisCount_Seq  
WHERE CONVERT(VARCHAR(10), A.src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -90, @Gubun_Date ), 21)  AND  @Gubun_Date  
 AND A.status_seq=15 AND order_Type in ('1','6','7')  
 AND A.company_seq = 5001  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY  A.Card_Seq, D.DisCount_Rate, B.CardSet_Price  
ORDER BY SubGubun, Cnt DESC, Price DESC, A.Card_Seq  
  
  
  
SELECT identity(int, 1, 1) AS SerNo  
 , SubGubun AS SubGubun, Cnt, Card_Seq, Price  
INTO #BarunsonPriceBestSerNoTemp  
FROM #BarunsonPriceBestTemp  
ORDER BY  SubGubun, Cnt DESC, Price DESC, Card_Seq  
  
  
  
SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
 , 'PRIC' AS Gubun,  A.SubGubun  
 , A.Card_Seq, A.Cnt, A.Price  
INTO #BarunsonRankPrice  
from #BarunsonPriceBestSerNoTemp A  
JOIN ( SELECT SubGubun, MIN(SerNo) AS MinSeq  
   FROM #BarunsonPriceBestSerNoTemp  
   GROUP BY SubGubun  
) B ON A.SubGubun = B.SubGubun  
WHERE A.SerNo - B.MinSeq + 1 <= 10  
ORDER BY A.SubGubun, A.Cnt DESC, Price DESC, Card_Seq  
  
  
--바른손 가격대별 베스트 쿼리 END  
--####################################################################################################  
  
--이상민 20120319  
  
  
  
  
--####################################################################################################################################################  
--####################################################################################################################################################  
--비핸즈 브랜드별 베스트 쿼리 BEGIN  --20110826 - 이상민  
  
--DECLARE @Gubun_Date varchar(10)  
--SET @Gubun_Date = '2011-07-15'   
  
  
--비핸즈 전체(주간 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrandWeek_Bhands  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5006  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
--비핸즈 전체(월간 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrandMonth_Bhands  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5006  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
  
--비핸즈 전체(스테디 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrandSteady_Bhands  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -180,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5006  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5006 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
  
  
  --################################################################################################################################  
  --바른손카드 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_Bhands  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Bhands   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_Bhands WHERE CardBrand = 'B' )  
   and CardBrand = 'B'  
  ORDER BY Cnt DESC  
  
  --위시메이드 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_Bhands  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Bhands   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_Bhands WHERE CardBrand = 'W' )  
   and CardBrand = 'W'  
  ORDER BY Cnt DESC  
  
  --스토리오브러브 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_Bhands  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Bhands   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_Bhands WHERE CardBrand = 'S' )  
   and CardBrand = 'S'  
  ORDER BY Cnt DESC  
  
    
  --주간 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandWeek_Bhands  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandWeek_Bhands A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq    
    
    
    
  --주간 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BhandsBrand_WeekSerNo  
  FROM #RankBrandWeek_Bhands  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRWE' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BhandsBrand_Week  
  from #BhandsBrand_WeekSerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BhandsBrand_WeekSerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --주간 시리얼No 재정리 END  
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BhandsBrand_Week WHERE Rankno > 20  
    
  --################################################################################################################################  
  
  
  --################################################################################################################################  
  --월간 바른손카드 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_Bhands  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Bhands   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_Bhands WHERE CardBrand = 'B' )  
   and CardBrand = 'B'  
  ORDER BY Cnt DESC  
  
  
  --월간 위시메이드 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_Bhands  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Bhands   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_Bhands WHERE CardBrand = 'W' )  
   and CardBrand = 'W'  
  ORDER BY Cnt DESC  
  
  
  --월간 스토리오브러브 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_Bhands  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Bhands   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_Bhands WHERE CardBrand = 'S' )  
   and CardBrand = 'S'  
  ORDER BY Cnt DESC  
  
  
  --월간 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandMonth_Bhands  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandMonth_Bhands A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq   
    
  
  
  --월간 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BhandsBrand_MonthSerNo  
  FROM #RankBrandMonth_Bhands  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRMO' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BhandsBrand_Month  
  from #BhandsBrand_MonthSerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BhandsBrand_MonthSerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --월간 시리얼No 재정리 END  
    
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BhandsBrand_Month WHERE Rankno > 20  
  --################################################################################################################################  
   
   
    
  --################################################################################################################################  
  
  --스테디 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandSteady_Bhands  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandSteady_Bhands A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq   
    
  
  --스테디 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BhandsBrand_SteadySerNo  
  FROM #RankBrandSteady_Bhands  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRST' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BhandsBrand_Steady  
  from #BhandsBrand_SteadySerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BhandsBrand_SteadySerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --스테디 시리얼No 재정리 END  
    
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BhandsBrand_Steady WHERE Rankno > 20  
  --################################################################################################################################  
  
  
  
--비핸즈 브랜드별 베스트 쿼리 END  
--####################################################################################################################################################  
--####################################################################################################################################################  
  
  
  
  
--####################################################################################################################################################  
--####################################################################################################################################################  
--바른손몰 브랜드별 베스트 쿼리 BEGIN    
  
--바른손몰 전체(주간 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
INTO #RankBrandWeek_BSMall  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.sales_gubun = 'B'  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
--바른손몰 전체(월간 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
INTO #RankBrandMonth_BSMall  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.sales_gubun = 'B'  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
  
--비핸즈 전체(스테디 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
INTO #RankBrandSteady_BSMall  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -180,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.sales_gubun = 'B'  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5000 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
  
  
  --################################################################################################################################  
  --바른손카드 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_BSMall  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_BSMall   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_BSMall WHERE CardBrand = 'B' )  
   and CardBrand = 'B'  
  ORDER BY Cnt DESC  
  
  --스토리오브러브 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_BSMall  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_BSMall   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_BSMall WHERE CardBrand = 'S' )  
   and CardBrand = 'S'  
  ORDER BY Cnt DESC  
  
    
  --주간 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandWeek_BSMall  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandWeek_BSMall A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq    
    
    
    
  --주간 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BSMallBrand_WeekSerNo  
  FROM #RankBrandWeek_BSMall  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRWE' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BSMallBrand_Week  
  from #BSMallBrand_WeekSerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BSMallBrand_WeekSerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --주간 시리얼No 재정리 END  
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BSMallBrand_Week WHERE Rankno > 20  
    
  --################################################################################################################################  
  
  
  --################################################################################################################################  
  --월간 바른손카드 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_BSMall  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_BSMall   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_BSMall WHERE CardBrand = 'B' )  
   and CardBrand = 'B'  
  ORDER BY Cnt DESC  
  
  
  --월간 스토리오브러브 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_BSMall  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_BSMall   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_BSMall WHERE CardBrand = 'S' )  
   and CardBrand = 'S'  
  ORDER BY Cnt DESC  
  
  
  --월간 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandMonth_BSMall  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandMonth_BSMall A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq   
    
  
  
  --월간 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BSMallBrand_MonthSerNo  
  FROM #RankBrandMonth_BSMall  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRMO' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BSMallBrand_Month  
  from #BSMallBrand_MonthSerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BSMallBrand_MonthSerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --월간 시리얼No 재정리 END  
    
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BSMallBrand_Month WHERE Rankno > 20  
  --################################################################################################################################  
   
   
    
  --################################################################################################################################  
  
  --스테디 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandSteady_BSMall  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandSteady_BSMall A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq   
    
  
  --스테디 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BSMallBrand_SteadySerNo  
  FROM #RankBrandSteady_BSMall  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRST' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BSMallBrand_Steady  
  from #BSMallBrand_SteadySerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BSMallBrand_SteadySerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --스테디 시리얼No 재정리 END  
    
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BSMallBrand_Steady WHERE Rankno > 20  
  --################################################################################################################################  
  
  
  
--바른손몰 브랜드별 베스트 쿼리 END  
--####################################################################################################################################################  
--####################################################################################################################################################  
  
  
  
  
--####################################################################################################################################################  
--####################################################################################################################################################  
--Barunson 브랜드별 베스트 쿼리 BEGIN  --20120319 - 이상민  
  
--DECLARE @Gubun_Date varchar(10)  
--SET @Gubun_Date = '2011-07-15'   
  
  
--Barunson 전체(주간 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrandWeek_Barunson  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5001  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
--Barunson 전체(월간 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrandMonth_Barunson  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -30,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5001  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
  
--Barunson 전체(스테디 브랜드별 순위)  
SELECT identity(int, 1, 1) AS InsertNo, convert(varchar(3), B.CardBrand) AS CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrandSteady_Barunson  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -180,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5001  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5001 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
  
  
  --################################################################################################################################  
  --바른손카드 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_Barunson  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Barunson  
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_Barunson WHERE CardBrand = 'B' )  
   and CardBrand = 'B'  
  ORDER BY Cnt DESC  
  
  --위시메이드 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_Barunson  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Barunson  
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_Barunson WHERE CardBrand = 'W' )  
   and CardBrand = 'W'  
  ORDER BY Cnt DESC  
  
  --스토리오브러브 주간판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandWeek_Barunson  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Barunson  
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandWeek_Barunson WHERE CardBrand = 'S' )  
   and CardBrand = 'S'  
  ORDER BY Cnt DESC  
  
    
  --주간 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandWeek_Barunson  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandWeek_Barunson A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq    
    
    
    
  --주간 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BarunsonBrand_WeekSerNo  
  FROM #RankBrandWeek_Barunson  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRWE' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BarunsonBrand_Week  
  from #BarunsonBrand_WeekSerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BarunsonBrand_WeekSerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --주간 시리얼No 재정리 END  
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BarunsonBrand_Week WHERE Rankno > 20  
    
  --################################################################################################################################  
  
  
  --################################################################################################################################  
  --월간 바른손카드 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_Barunson  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Barunson   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_Barunson WHERE CardBrand = 'B' )  
   and CardBrand = 'B'  
  ORDER BY Cnt DESC  
  
  
  --월간 위시메이드 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_Barunson  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Barunson   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_Barunson WHERE CardBrand = 'W' )  
   and CardBrand = 'W'  
  ORDER BY Cnt DESC  
  
  
  --월간 스토리오브러브 판매 종수가 20종이 안될때 스테디베스트에서 나머지 종수 채워주기 위한 Insert문.  
  INSERT INTO #RankBrandMonth_Barunson  
  select  CardBrand, Card_Seq, 0  
  from #RankBrandSteady_Barunson   
  WHERE card_seq NOT IN ( SELECT DISTINCT Card_Seq  FROM #RankBrandMonth_Barunson WHERE CardBrand = 'S' )  
   and CardBrand = 'S'  
  ORDER BY Cnt DESC  
  
  
  --월간 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandMonth_Barunson  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandMonth_Barunson A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq   
    
  
  
  --월간 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BarunsonBrand_MonthSerNo  
  FROM #RankBrandMonth_Barunson  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRMO' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BarunsonBrand_Month  
  from #BarunsonBrand_MonthSerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BarunsonBrand_MonthSerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --월간 시리얼No 재정리 END  
    
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BarunsonBrand_Month WHERE Rankno > 20  
  --################################################################################################################################  
   
   
    
  --################################################################################################################################  
  
  --스테디 브랜드별 전체 베스트 순위  
  INSERT INTO #RankBrandSteady_Barunson  
  SELECT 'ALL' AS CardBrand  
   , A.Card_Seq, A.Cnt  
  FROM #RankBrandSteady_Barunson A  
  ORDER BY  Cnt DESC, InsertNo, Card_seq   
    
  
  --스테디 시리얼No 재정리 BEGIN  
  SELECT identity(int, 1, 1) AS SerNo  
   , CardBrand, Cnt, Card_Seq  
  INTO #BarunsonBrand_SteadySerNo  
  FROM #RankBrandSteady_Barunson  
  ORDER BY  CardBrand, InsertNo, Cnt DESC, Card_Seq  
    
     
  SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
   , 'BRST' AS Gubun  
   , CASE A.CardBrand WHEN 'ALL' THEN 'AL' WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'S' THEN 'BS' ELSE 'XX' END AS SubGubun   
   , A.Card_Seq, A.Cnt  
  INTO #BarunsonBrand_Steady  
  from #BarunsonBrand_SteadySerNo A  
  JOIN (   
    SELECT CardBrand, MIN(SerNo) AS MinSeq  
    FROM #BarunsonBrand_SteadySerNo  
    GROUP BY CardBrand  
  ) B ON A.CardBrand = B.CardBrand  
  WHERE A.SerNo - B.MinSeq + 1 <= 999  
  ORDER BY A.CardBrand, A.SerNo  
    
  --스테디 시리얼No 재정리 END  
    
    
  --탑 20개씩만 나오도록...  
  DELETE FROM #BarunsonBrand_Steady WHERE Rankno > 20  
  --################################################################################################################################  
  
  
  
--Barunson 브랜드별 베스트 쿼리 END  
--####################################################################################################################################################  
--####################################################################################################################################################  
  
  
  
  
  
  
  
--####################################################################################################  
--더카드 브랜드별 베스트 쿼리 BEGIN  
--20110212 - 이상민  
  
--TheCard(브랜드별 순위)  
SELECT B.CardBrand, A.Card_Seq  
 , SUM(ISNULL(A.order_count, 0)) AS Cnt  
 --, COUNT(A.Card_Seq) AS Cnt  
INTO #RankBrand_TheCard  
FROM custom_order A WITH(NOLOCK)  
JOIN S2_Card B ON A.card_seq = B.Card_Seq   
WHERE  A.status_seq=15 AND A.order_Type in ('1','6','7')  
 AND CONVERT(VARCHAR(10), src_send_date, 21) BETWEEN CONVERT(VARCHAR(10), DATEADD(D, -7,  @Gubun_Date), 21)  AND  @Gubun_Date  
 AND A.company_seq = 5007  
 AND A.card_seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1 )  
 AND A.card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
GROUP BY B.CardBrand, A.card_seq  
ORDER BY B.CardBrand, cnt DESC, A.card_seq  
  
  
--주간판매 종수가 10종이 안될때 10종까지 채워주기 위한 Insert문.  
INSERT INTO #RankBrand_TheCard  
select  CardBrand, Card_Seq, 0  
from S2_Card   
WHERE Card_Seq IN ( SELECT DISTINCT card_seq  FROM S2_CardSalesSite WHERE Company_Seq = 5007 AND IsDisplay = 1  )   
 AND card_seq IN ( SELECT DISTINCT Card_Seq  FrOM S2_CardKind WHERE CardKind_Seq = 1 ) --청첩장인것만  
 AND card_seq NOT IN ( SELECT DISTINCT Card_Seq  FrOM #RankBrand_TheCard )  
 and CardBrand = 'A'  
   
  
  
  
SELECT identity(int, 1, 1) AS SerNo  
 , CardBrand, Cnt, Card_Seq  
INTO #BrandBestSerNoTemp  
FROM #RankBrand_TheCard  
ORDER BY  CardBrand, Cnt DESC, Card_Seq  
  
--drop table #RankBrand  
  
SELECT A.SerNo - B.MinSeq + 1 AS RankNo  
 , 'BRAN' AS Gubun  
 , CASE A.CardBrand WHEN 'B' THEN 'BB' WHEN 'W' THEN 'BW' WHEN 'H' THEN 'BH' WHEN 'A' THEN 'BA' ELSE 'XX' END AS SubGubun   
 , A.Card_Seq, A.Cnt  
INTO #RankBrand  
from #BrandBestSerNoTemp A  
JOIN ( SELECT CardBrand, MIN(SerNo) AS MinSeq  
   FROM #BrandBestSerNoTemp  
   GROUP BY CardBrand  
) B ON A.CardBrand = B.CardBrand  
WHERE A.SerNo - B.MinSeq + 1 <= 30  
ORDER BY A.CardBrand, A.Cnt DESC, Card_Seq  
  
  
  
--더카드 브랜드별 베스트 쿼리 END  
--##########################################################################  
  
  
  
--##########################################################################  
--비핸즈 클릭순위 BEGIN  
  
--BHands   
SELECT IDENTITY(INT, 1, 1) AS RankNo, 'CLIC' AS Gubun, 'CL' AS SubGubun, A.card_seq, A.Click_count as cnt  
INTO #RankClick_BHands  
FROM s4_cardclickcount A WITH(NOLOCK)  
JOIN S2_CardKind B ON A.card_seq = B.Card_Seq AND B.CardKind_Seq = 1 --청첩장만 베스트에 들어가도록...  
WHERE  A.company_seq = 5006  
ORDER BY A.Click_count DESC, A.card_seq   
  
  
--비핸즈 클릭순위 END  
--##########################################################################  
  
  
  
--####################################################################################################  
--S4_BestTotalRanking_BHands 베스트 랭킹 순위 Insert  
  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankWeek_BHands  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonth_BHands  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonthSample_BHands  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPost_BHands  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankZzim_BHands  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankClick_BHands  
ORDER BY RankNo  
  
  
--비핸즈 가격대별 베스트 추가-20110712  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BhandsRankPrice   
ORDER BY RankNo  
  
  
--비핸즈 Steady(6개월) 베스트 추가-20110712  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankSteady_BHands   
ORDER BY RankNo  
  
  
--비핸즈 주간 이용후기베스트 -20110727  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPostWeek_BHands  
ORDER BY RankNo  
  
  
--비핸즈 월간 이용후기베스트 -20110727  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPostMonth_BHands  
ORDER BY RankNo  
  
  
  
--비핸즈 브랜드별 주간베스트 --20110826  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BhandsBrand_Week  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--비핸즈 브랜드별 월간베스트 --20110826  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BhandsBrand_Month  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--비핸즈 브랜드별 스테디베스트 --20110826  
INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BhandsBrand_Steady  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--####################################################################################################  
  
  
--S4_BestTotalRanking_BSMall (바른손몰) 베스트 랭킹 순위 Insert  
  
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankWeek_BSMall  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonth_BSMall  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonthSample_BSMall  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPost_BSMall  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankZzim_BSMall  
ORDER BY RankNo  
  
--INSERT INTO S4_BestTotalRanking_BHands( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
--SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
--FROM #RankClick_BHands  
--ORDER BY RankNo  
  
  
--바른손몰 가격대별 베스트 추가-20110712  
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BSMallRankPrice   
ORDER BY RankNo  
  
  
--바른손몰 Steady(6개월) 베스트   
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankSteady_BSMall   
ORDER BY RankNo  
  
  
--바른손몰 주간 이용후기베스트   
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPostWeek_BSMall  
ORDER BY RankNo  
  
  
--바른손몰 월간 이용후기베스트   
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPostMonth_BSMall  
ORDER BY RankNo  
  
  
  
--바른손몰 브랜드별 주간베스트   
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BSMallBrand_Week  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--바른손몰 브랜드별 월간베스트   
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BSMallBrand_Month  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--바른손몰 브랜드별 스테디베스트   
INSERT INTO S4_BestTotalRanking_BSMall( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BSMallBrand_Steady  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--####################################################################################################  
  
  
--####################################################################################################  
--S4_BestTotalRanking_TheCard 베스트 랭킹 순위 Insert  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankWeek_TheCard  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonth_TheCard  
ORDER BY RankNo  
  
--UNION ALL  
--SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
--FROM #RankAccrue_TheCard  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonthSample_TheCard  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPost_Thecard  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankZzim_TheCard  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPrice #BhandsRankPrice  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_TheCard( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankBrand  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--####################################################################################################  
  
  
  
--####################################################################################################  
--S4_BestTotalRanking_Premier 베스트 랭킹 순위 Insert  
  
INSERT INTO S4_BestTotalRanking_Premier( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankWeek_Premier  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_Premier( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonth_Premier  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_Premier( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankMonthSample_Premier  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_Premier( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPost_Premier  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_Premier( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 40 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankZzim_Premier  
ORDER BY RankNo  
  
  
--####################################################################################################  
  
  
  
--####################################################################################################  
--S4_BestTotalRanking_Barunson 베스트 랭킹 순위 Insert  
  
  
IF (SELECT DATEPART(DW, GETDATE())) = 2  
BEGIN  
  
    INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
    SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
    FROM #RankWeek_Barunson  
    ORDER BY RankNo  
  
END  
  
  
  
IF (SELECT DATEPART(DAY, GETDATE())) = 1  
BEGIN  
  
    INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
    SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
  FROM #RankMonth_Barunson  
    ORDER BY RankNo  
  
END  
--INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
--SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
--FROM #RankAccrue_Barunson  
  
  
  
IF (SELECT DATEPART(DAY, GETDATE())) = 1  
BEGIN  
  
    INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
    SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
    FROM #RankMonthSample_Barunson  
    ORDER BY RankNo  
  
END  
  
  
  
  
  
-- 2015-06-08 바른손 이용후기 베스트 기준 변경(소스와 기준 맞춤).  
-- 시스템지원팀 장형일 과장  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPost_Barunson  
ORDER BY RankNo  
  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankZzim_Barunson  
ORDER BY RankNo  
  
  
--Barunson 가격대별 베스트 추가-20110712  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BarunsonRankPrice   
ORDER BY RankNo  
  
  
--Barunson Steady(1년) 베스트 추가-20110712  
IF (SELECT DATEPART(MONTH, GETDATE())) = 1 AND (SELECT DATEPART(DAY, GETDATE())) = 1  
BEGIN  
  
    INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
    SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
    FROM #RankSteady_Barunson   
    ORDER BY RankNo  
  
END  
  
--Barunson 주간 이용후기베스트 -20110727  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPostWeek_Barunson  
ORDER BY RankNo  
  
  
--Barunson 월간 이용후기베스트 -20110727  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT TOP 30 @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #RankPostMonth_Barunson  
ORDER BY RankNo  
  
  
  
--Barunson 브랜드별 주간베스트 --20110826  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BarunsonBrand_Week  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--Barunson 브랜드별 월간베스트 --20110826  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BarunsonBrand_Month  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--Barunson 브랜드별 스테디베스트 --20110826  
INSERT INTO S4_BestTotalRanking_Barunson( Gubun_date, Gubun, SubGubun, RankNo, Card_Seq, Cnt)   
SELECT @Gubun_Date, Gubun, SubGubun, RankNo, Card_Seq, Cnt   
FROM #BarunsonBrand_Steady  
WHERE SubGubun <> 'XX'  
ORDER BY RankNo  
  
  
--####################################################################################################  
  
  
  
  
--####################################################################################################  
--S2_CardSalesSite 베스트 랭킹 순위 Update  BEGIN   
  
UPDATE s2_cardsalessite   
SET Ranking = 999, Ranking_w = 999, Ranking_m = 999  
WHERE Company_Seq = 5007   
  
  
-- 더카드 Ranking_w 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_w = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankWeek_TheCard B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5007  
  
-- 더카드 Ranking_m 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_m = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_TheCard B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5007  
  
  
  
-- 더카드 수동Best 테이블 Insert BEGIN   
SELECT *   
INTO #S2_CardSalesBest_Temp  
FROM S2_CardSalesBest  
WHERE Company_Seq = 5007   
  
DELETE FROM S2_CardSalesBest WHERE Company_Seq = 5007   
  
INSERT INTO S2_CardSalesBest ( Company_Seq, Card_seq, Ranking_w, Ranking_m, NewProduct, SpecialPrice, BestWeek, BestMonth )  
SELECT Company_Seq, Card_seq, 999, 999, 999, 999, 999, 999   
FROM S2_CardSalesSite  
WHERE Company_Seq = 5007   
  
  
  
  
-- 더카드 Ranking_w 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_w = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankWeek_TheCard B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5007  
  
-- 더카드 Ranking_m 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_m = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankMonth_TheCard B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5007  
  
  
UPDATE S2_CardSalesBest  
SET NewProduct = B.NewProduct  
 , SpecialPrice = B.SpecialPrice  
 , BestWeek = B.BestWeek  
 , BestMonth = B.BestMonth  
FROM S2_CardSalesBest A  
JOIN #S2_CardSalesBest_Temp B ON A.Company_Seq = B.Company_seq AND A.card_seq = B.Card_seq  
WHERE A.Company_Seq = 5007  
  
  
-- 더카드 수동Best 테이블 Insert END  
  
  
  
UPDATE s2_cardsalessite   
SET Ranking = 999, Ranking_w = 999, Ranking_m = 999  
WHERE Company_Seq  = 5006  
  
  
-- 비핸즈 Ranking_w 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_w = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_BHands B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5006  
  
-- 비핸즈 Ranking_m 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_m = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_BHands B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5006  
  
  
  
-- 비핸즈 수동Best 테이블 Insert BEGIN  
  
SELECT *   
INTO #S2_CardSalesBest_Bhands  
FROM S2_CardSalesBest  
WHERE Company_Seq = 5006   
  
DELETE FROM S2_CardSalesBest WHERE Company_Seq = 5006  
  
INSERT INTO S2_CardSalesBest ( Company_Seq, Card_seq, Ranking_w, Ranking_m, NewProduct, SpecialPrice, BestWeek, BestMonth )  
SELECT Company_Seq, Card_seq, 999, 999, 999, 999, 999, 999   
FROM S2_CardSalesSite  
WHERE Company_Seq = 5006  
  
  
  
-- 비핸즈 Ranking_w 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_w = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankWeek_Bhands B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5006  
  
-- 비핸즈 Ranking_m 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_m = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankMonth_Bhands B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5006  
  
  
UPDATE S2_CardSalesBest  
SET NewProduct = B.NewProduct  
 , SpecialPrice = B.SpecialPrice  
 , BestWeek = B.BestWeek  
 , BestMonth = B.BestMonth  
FROM S2_CardSalesBest A  
JOIN #S2_CardSalesBest_Bhands B ON A.Company_Seq = B.Company_seq AND A.card_seq = B.Card_seq  
WHERE A.Company_Seq = 5006  
  
-- 비핸즈 수동Best 테이블 Insert END  
  
  
  
  
UPDATE s2_cardsalessite   
SET Ranking = 999, Ranking_w = 999, Ranking_m = 999  
WHERE Company_Seq  = 5006  
  
  
-- 비핸즈 Ranking_w 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_w = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_BHands B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5006  
  
-- 비핸즈 Ranking_m 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_m = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_BHands B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5006  
  
  
  
-- 바른손몰 수동Best 테이블 Insert BEGIN  
  
  
UPDATE s2_cardsalessite   
SET Ranking = 999, Ranking_w = 999, Ranking_m = 999  
WHERE Company_Seq  = 5000  
  
  
-- 바른손몰 Ranking_w 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_w = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_BSMall B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5000  
  
-- 바른손몰 Ranking_m 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_m = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_BSMall B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5000  
  
  
SELECT *   
INTO #S2_CardSalesBest_BSMall  
FROM S2_CardSalesBest  
WHERE Company_Seq = 5000   
  
DELETE FROM S2_CardSalesBest WHERE Company_Seq = 5000  
  
INSERT INTO S2_CardSalesBest ( Company_Seq, Card_seq, Ranking_w, Ranking_m, NewProduct, SpecialPrice, BestWeek, BestMonth )  
SELECT Company_Seq, Card_seq, 999, 999, 999, 999, 999, 999   
FROM S2_CardSalesSite  
WHERE Company_Seq = 5000  
  
  
  
-- 바른손몰 Ranking_w 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_w = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankWeek_BSMall B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5000  
  
-- 바른손몰 Ranking_m 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_m = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankMonth_BSMall B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5000  
  
  
UPDATE S2_CardSalesBest  
SET NewProduct = B.NewProduct  
 , SpecialPrice = B.SpecialPrice  
 , BestWeek = B.BestWeek  
 , BestMonth = B.BestMonth  
FROM S2_CardSalesBest A  
JOIN #S2_CardSalesBest_BSMall B ON A.Company_Seq = B.Company_seq AND A.card_seq = B.Card_seq  
WHERE A.Company_Seq = 5000  
  
-- 바른손몰 수동Best 테이블 Insert END  
  
  
  
  
  
  
-- 바른손카드 수동Best 테이블 Insert BEGIN  
  
SELECT *   
INTO #S2_CardSalesBest_Barunson  
FROM S2_CardSalesBest  
WHERE Company_Seq = 5001   
  
DELETE FROM S2_CardSalesBest WHERE Company_Seq = 5001  
  
INSERT INTO S2_CardSalesBest ( Company_Seq, Card_seq, Ranking_w, Ranking_m, NewProduct, SpecialPrice, BestWeek, BestMonth )  
SELECT Company_Seq, Card_seq, 999, 999, 999, 999, 999, 999   
FROM S2_CardSalesSite  
WHERE Company_Seq = 5001   
  
  
  
  
UPDATE S2_CARDSALESSITE   
SET  RANKING_W = 999  
WHERE COMPANY_SEQ = 5001  
AND  RANKING_W IS NULL  
  
UPDATE S2_CARDSALESSITE   
SET  RANKING_M = 999  
WHERE COMPANY_SEQ = 5001  
AND  RANKING_M IS NULL  
  
  
-- 바른손카드 Ranking_w 업데이트  
IF (SELECT DATEPART(DW, GETDATE())) = 2  
    BEGIN  
  
  -- 바른손카드 Ranking_w 업데이트  
  UPDATE S2_CardSalesSite  
  SET  Ranking_w = B.RankNo  
  from S2_CardSalesSite A  
  JOIN #RankWeek_Barunson B ON A.card_seq = B.Card_Seq  
  WHERE A.Company_Seq = 5001  
  
        UPDATE S2_CardSalesBest  
        SET Ranking_w = B.RankNo  
        from S2_CardSalesBest A  
        JOIN #RankWeek_Barunson B ON A.card_seq = B.Card_Seq   
        WHERE A.Company_Seq = 5001  
    END  
  
  
  
-- 바른손카드 Ranking_m 업데이트  
IF (SELECT DATEPART(DAY, GETDATE())) = 1  
    BEGIN  
  
  -- 바른손카드 Ranking_m 업데이트  
  UPDATE S2_CardSalesSite  
  SET Ranking_m = B.RankNo  
  from S2_CardSalesSite A  
  JOIN #RankMonth_Barunson B ON A.card_seq = B.Card_Seq  
  WHERE A.Company_Seq = 5001  
  
        UPDATE S2_CardSalesBest  
        SET Ranking_m = B.RankNo  
        from S2_CardSalesBest A  
        JOIN #RankMonth_Barunson B ON A.card_seq = B.Card_Seq   
        WHERE A.Company_Seq = 5001  
    END  
  
  
UPDATE S2_CardSalesBest  
SET NewProduct = B.NewProduct  
 , SpecialPrice = B.SpecialPrice  
 , BestWeek = B.BestWeek  
 , BestMonth = B.BestMonth  
FROM S2_CardSalesBest A  
JOIN #S2_CardSalesBest_Barunson B ON A.Company_Seq = B.Company_seq AND A.card_seq = B.Card_seq  
WHERE A.Company_Seq = 5001  
  
-- 바른손카드 수동Best 테이블 Insert END  
  
  
  
  
  
  
/* 20111028 업데이트 막음  
UPDATE s2_cardsalessite   
SET Ranking = 999, Ranking_w = 999, Ranking_m = 999  
WHERE Company_Seq  = 5003  
  
-- Premier Ranking_w 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_w = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_Premier B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5003  
  
-- Premier Ranking_m 업데이트  
UPDATE S2_CardSalesSite  
SET Ranking_m = B.RankNo  
from S2_CardSalesSite A  
JOIN #RankMonth_Premier B ON A.card_seq = B.Card_Seq   --월간데이터 입력  
WHERE A.Company_Seq = 5003  
  
*/  
  
  
  
  
-- 프리미어 수동Best 테이블 Insert BEGIN   
  
  
  
SELECT *   
INTO #S2_CardSalesBest_Premier_Temp  
FROM S2_CardSalesBest  
WHERE Company_Seq = 5003   
  
DELETE FROM S2_CardSalesBest WHERE Company_Seq = 5003   
  
INSERT INTO S2_CardSalesBest ( Company_Seq, Card_seq, Ranking_w, Ranking_m, NewProduct, SpecialPrice, BestWeek, BestMonth )  
SELECT Company_Seq, Card_seq, 999, 999, 999, 999, 999, 999   
FROM S2_CardSalesSite  
WHERE Company_Seq = 5003   
  
  
  
  
  
-- 프리미어 Ranking_w 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_w = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankMonth_Premier B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5003  
  
-- 프리미어 Ranking_m 업데이트  
UPDATE S2_CardSalesBest  
SET Ranking_m = B.RankNo  
from S2_CardSalesBest A  
JOIN #RankMonth_Premier B ON A.card_seq = B.Card_Seq   
WHERE A.Company_Seq = 5003  
  
  
UPDATE S2_CardSalesBest  
SET NewProduct = B.NewProduct  
 , SpecialPrice = B.SpecialPrice  
 , BestWeek = B.BestWeek  
 , BestMonth = B.BestMonth  
FROM S2_CardSalesBest A  
JOIN #S2_CardSalesBest_Premier_Temp B ON A.Company_Seq = B.Company_seq AND A.card_seq = B.Card_seq  
WHERE A.Company_Seq = 5003  
  
  
-- 프리미어 수동Best 테이블 Insert END  
  
  
--S2_CardSalesSite 베스트 랭킹 순위 Update  END   
--####################################################################################################  
  
GO
