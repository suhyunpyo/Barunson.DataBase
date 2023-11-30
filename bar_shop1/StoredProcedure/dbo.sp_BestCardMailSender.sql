IF OBJECT_ID (N'dbo.sp_BestCardMailSender', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BestCardMailSender
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_BestCardMailSender
CREATE PROC [dbo].[sp_BestCardMailSender]
AS
	--바른손카드 
	SELECT TOP 20   IDENTITY(int, 1,1)  as Rank ,a.sales_gubun,a.card_seq, b.card_code, count(*) as cnt, display_yes_or_no
	INTO #Rank1
	FROM
	custom_order a JOIN card b ON a.card_seq = b.card_seq 
	WHERE sales_gubun = 'W' and DATEDIFF(mm,src_send_date,getdate()) = 1   --and display_yes_or_no='1' 
		  and  b.is100='1' 
	GROUP BY a.sales_gubun,a.card_seq, b.card_code, a.status_seq, b.card_img_ms, display_yes_or_no
	ORDER BY cnt DESC

	--더카드
	SELECT TOP 20   IDENTITY(int, 1,1)  as Rank ,a.sales_gubun,a.card_seq, b.card_code, count(*) as cnt, display_yes_or_no
	INTO #Rank2
	FROM
	custom_order a JOIN card b ON a.card_seq = b.card_seq 
	WHERE sales_gubun = 'T' and DATEDIFF(mm,src_send_date,getdate()) = 1   --and display_yes_or_no='1' 
		  and  b.is100='1' 
	GROUP BY a.sales_gubun,a.card_seq, b.card_code, a.status_seq, b.card_img_ms, display_yes_or_no
	ORDER BY cnt DESC

	--투유카드
	SELECT TOP 20   IDENTITY(int, 1,1)  as Rank ,a.sales_gubun,a.card_seq, b.card_code, count(*) as cnt, display_yes_or_no
	INTO #Rank3
	FROM
	custom_order a JOIN card b ON a.card_seq = b.card_seq 
	WHERE sales_gubun = 'U' and DATEDIFF(mm,src_send_date,getdate()) = 1   --and display_yes_or_no='1' 
		  and  b.is100='1' 
	GROUP BY a.sales_gubun,a.card_seq, b.card_code, a.status_seq, b.card_img_ms, display_yes_or_no
	ORDER BY cnt DESC

	--티아라
	SELECT TOP 20   IDENTITY(int, 1,1)  as Rank ,a.sales_gubun,a.card_seq, b.card_code, count(*) as cnt, display_yes_or_no
	INTO #Rank4
	FROM
	custom_order a JOIN card b ON a.card_seq = b.card_seq 
	WHERE sales_gubun = 'A' and DATEDIFF(mm,src_send_date,getdate()) = 1   --and display_yes_or_no='1' 
		  and  b.is100='1' 
	GROUP BY a.sales_gubun,a.card_seq, b.card_code, a.status_seq, b.card_img_ms, display_yes_or_no
	ORDER BY cnt DESC

	--제휴
	SELECT TOP 20   IDENTITY(int, 1,1)  as Rank ,a.sales_gubun,a.card_seq, b.card_code, count(*) as cnt, display_yes_or_no
	INTO #Rank5
	FROM
	custom_order a JOIN card b ON a.card_seq = b.card_seq 
	WHERE sales_gubun = 'B' and DATEDIFF(mm,src_send_date,getdate()) = 1   --and display_yes_or_no='1' 
		  and  b.is100='1' 
	GROUP BY a.sales_gubun,a.card_seq, b.card_code, a.status_seq, b.card_img_ms, display_yes_or_no
	ORDER BY cnt DESC
	
	--스토리
	SELECT TOP 20   IDENTITY(int, 1,1)  as Rank ,a.sales_gubun,a.card_seq, b.card_code, count(*) as cnt, display_yes_or_no
	INTO #Rank6
	FROM
	custom_order a JOIN card b ON a.card_seq = b.card_seq 
	WHERE sales_gubun = 'S' and DATEDIFF(mm,src_send_date,getdate()) = 1   --and display_yes_or_no='1' 
		  and  b.is100='1' 
	GROUP BY a.sales_gubun,a.card_seq, b.card_code, a.status_seq, b.card_img_ms, display_yes_or_no
	ORDER BY cnt DESC



	SELECT  *
	INTO #TotalRank
	FROM #Rank1 
		  UNION
		  SELECT * FROM #Rank2
		  UNION
		  SELECT * FROM #Rank3
		  UNION
		  SELECT * FROM #Rank4
		  UNION
		  SELECT * FROM #Rank5
		  UNION
		  SELECT * FROM #Rank6
		  
	SELECT * FROM #TotalRank ORDER BY sales_gubun, rank	  
		
GO
