IF OBJECT_ID (N'dbo.up_Select_Sum_Digital_Card_Count_For_ChoanWork', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Sum_Digital_Card_Count_For_ChoanWork
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2017-01-10
-- Description:	빠른손 디지털카드 실적 조회
--
/*
	EXEC up_Select_Sum_Digital_Card_Count_For_ChoanWork '2016-01-01', '2017-01-10', '0'
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Select_Sum_Digital_Card_Count_For_ChoanWork]
(  
	  @FromDT VARCHAR(10)
	, @ToDT VARCHAR(10)
	, @Designer CHAR(1)
)  
AS
BEGIN

	-- 전체를 선택한 경우
	IF @Designer = '0'
	BEGIN
		SELECT
			*
		FROM
		(
			SELECT
				ROW_NUMBER() OVER(ORDER BY B.Card_Code) AS RowNum
				, B.Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END AS Designer
				, COUNT(A.order_seq) AS OrderCNT
				, SUM(A.order_count) AS OrderCardCNT
				, SUM(A.last_total_price) AS OrderPrice
			FROM custom_order AS A
				INNER JOIN S2_Card AS B
					ON A.card_seq = B.card_seq
				INNER JOIN S2_CardOption AS C
					ON A.card_seq = C.card_seq
			WHERE 1 = 1
				AND A.status_seq = 15
				AND A.order_type = 6
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
			GROUP BY
				B.Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END

			UNION ALL

			SELECT
				 9999 AS RowNum
				, '총계' AS Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END AS Designer
				, COUNT(A.order_seq) AS OrderCNT
				, SUM(A.order_count) AS OrderCardCNT
				, SUM(A.last_total_price) AS OrderPrice
			FROM custom_order AS A
				INNER JOIN S2_Card AS B
					ON A.card_seq = B.card_seq
				INNER JOIN S2_CardOption AS C
					ON A.card_seq = C.card_seq
			WHERE 1 = 1
				AND A.status_seq = 15
				AND A.order_type = 6
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
			GROUP BY
				CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END
		) AS A
		ORDER BY
			A.RowNum
	END
	-- 바른디자인을 선택한 경우
	ELSE IF @Designer = '1'
	BEGIN
		SELECT
			*
		FROM
		(
			SELECT
				ROW_NUMBER() OVER(ORDER BY B.Card_Code) AS RowNum
				, B.Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END AS Designer
				, COUNT(A.order_seq) AS OrderCNT
				, SUM(A.order_count) AS OrderCardCNT
				, SUM(A.last_total_price) AS OrderPrice
			FROM custom_order AS A
				INNER JOIN S2_Card AS B
					ON A.card_seq = B.card_seq
				INNER JOIN S2_CardOption AS C
					ON A.card_seq = C.card_seq
			WHERE 1 = 1
				AND A.status_seq = 15
				AND A.order_type = 6
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
				AND ISNULL(C.isDesigner, '') <> 'DesignTeam'
			GROUP BY
				B.Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END

			UNION ALL

			SELECT
				 9999 AS RowNum
				, '총계' AS Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END AS Designer
				, COUNT(A.order_seq) AS OrderCNT
				, SUM(A.order_count) AS OrderCardCNT
				, SUM(A.last_total_price) AS OrderPrice
			FROM custom_order AS A
				INNER JOIN S2_Card AS B
					ON A.card_seq = B.card_seq
				INNER JOIN S2_CardOption AS C
					ON A.card_seq = C.card_seq
			WHERE 1 = 1
				AND A.status_seq = 15
				AND A.order_type = 6
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
				AND ISNULL(C.isDesigner, '') <> 'DesignTeam'
			GROUP BY
				CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END
		) AS A
		ORDER BY
			A.RowNum
	END
	-- 초안팀을 선택한 경우
	ELSE IF @Designer = '2'
	BEGIN
		SELECT
			*
		FROM
		(
			SELECT
				ROW_NUMBER() OVER(ORDER BY B.Card_Code) AS RowNum
				, B.Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END AS Designer
				, COUNT(A.order_seq) AS OrderCNT
				, SUM(A.order_count) AS OrderCardCNT
				, SUM(A.last_total_price) AS OrderPrice
			FROM custom_order AS A
				INNER JOIN S2_Card AS B
					ON A.card_seq = B.card_seq
				INNER JOIN S2_CardOption AS C
					ON A.card_seq = C.card_seq
			WHERE 1 = 1
				AND A.status_seq = 15
				AND A.order_type = 6
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
				AND ISNULL(C.isDesigner, '') = 'DesignTeam'
			GROUP BY
				B.Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END

			UNION ALL

			SELECT
				 9999 AS RowNum
				, '총계' AS Card_Code
				, CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END AS Designer
				, COUNT(A.order_seq) AS OrderCNT
				, SUM(A.order_count) AS OrderCardCNT
				, SUM(A.last_total_price) AS OrderPrice
			FROM custom_order AS A
				INNER JOIN S2_Card AS B
					ON A.card_seq = B.card_seq
				INNER JOIN S2_CardOption AS C
					ON A.card_seq = C.card_seq
			WHERE 1 = 1
				AND A.status_seq = 15
				AND A.order_type = 6
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
				AND ISNULL(C.isDesigner, '') = 'DesignTeam'
			GROUP BY
				CASE WHEN ISNULL(C.isDesigner, '') = 'DesignTeam' THEN '초안팀' ELSE '바른디자인' END
		) AS A
		ORDER BY
			A.RowNum
	END


END
GO
