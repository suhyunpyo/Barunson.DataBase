IF OBJECT_ID (N'dbo.up_Select_Sum_Job_Card_Count_For_ChoanWork', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Sum_Job_Card_Count_For_ChoanWork
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2016-03-09
-- Description:	빠른손 초안작업자별/카드별 작업건수 조회
--
/*
	EXEC up_Select_Sum_Job_Card_Count_For_ChoanWork '2016-04-01', '2016-04-18'
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Select_Sum_Job_Card_Count_For_ChoanWork]
(  
	  @FromDT VARCHAR(10)
	, @ToDT VARCHAR(10)
)  
AS
BEGIN
	
	SELECT
		*
	FROM
	(
		SELECT  
			  A.Admin_ID
			, A.Admin_Name + '(' + A.Admin_ID + ')' AS Admin_Name
			, A.Admin_Level
			, SUM(SingleSideCard) AS SingleSideCard
			, SUM(PhotoCard) AS PhotoCard
			, SUM(InitialCard) AS InitialCard
			, SUM(DoubleSideCard) AS DoubleSideCard
			, SUM(LaserCard) AS LaserCard
			, SUM(RespectCard) AS RespectCard
			, SUM(AddOrder_Original) AS AddOrder_Original
			, SUM(AddOrder_Edited) AS AddOrder_Edited
			, SUM(SingleSideCard + PhotoCard + InitialCard + LaserCard + DoubleSideCard + RespectCard + AddOrder_Original + AddOrder_Edited) AS TotalCount
		FROM
		(
			SELECT  
				  A.src_compose_admin_id AS Admin_ID
				, E.Admin_Name
				, E.Admin_Level
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type NOT IN (2, 6, 7) AND (C.isLaser <> 1 AND C.master_2color <> 1 AND D.isfprint <> 1) THEN 1 ELSE 0 END AS SingleSideCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type = 2 THEN 1 ELSE 0 END AS RespectCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type = 6 THEN 1 ELSE 0 END AS PhotoCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type = 7 THEN 1 ELSE 0 END AS InitialCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type NOT IN (2, 6, 7) AND C.isLaser = 1 THEN 1 ELSE 0 END AS LaserCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type NOT IN (2, 6, 7) AND C.isLaser <> 1 AND (C.master_2color = 1 OR D.isfprint = 1) THEN 1 ELSE 0 END AS DoubleSideCard
				, CASE WHEN A.up_order_seq IS NOT NULL AND A.order_type <> 2 AND A.order_add_flag = 0 THEN 1 ELSE 0 END AS AddOrder_Original
				, CASE WHEN A.up_order_seq IS NOT NULL AND A.order_type <> 2 AND A.order_add_flag = 1 THEN 1 ELSE 0 END AS AddOrder_Edited
			FROM custom_order AS A
				INNER JOIN s2_card AS B 
					ON A.card_seq = B.card_seq
				INNER JOIN s2_cardoption AS C 
					ON A.card_seq = C.card_seq
				INNER JOIN card_corel AS D 
					ON B.card_code = D.card_code
				LEFT OUTER JOIN Admin_Lst AS E
					ON A.src_compose_admin_id = E.Admin_ID
			WHERE 1 = 1 
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
				--AND A.status_seq = 15
				AND ISNULL(A.src_compose_admin_id, '') <> ''
				AND E.isCS = 0
		) AS A
		GROUP BY 
			  A.Admin_ID 
			, A.Admin_Name
			, A.Admin_Level

		UNION ALL

		SELECT  
			  NULL AS Admin_ID
			, '총계' AS Admin_Name
			, 9999 AS Admin_Level
			, ISNULL(SUM(SingleSideCard), 0) AS SingleSideCard
			, ISNULL(SUM(PhotoCard), 0) AS PhotoCard
			, ISNULL(SUM(InitialCard), 0) AS InitialCard
			--, ISNULL(SUM(Master2Card), 0) AS Master2Card
			, ISNULL(SUM(DoubleSideCard), 0) AS DoubleSideCard
			, ISNULL(SUM(LaserCard), 0) AS LaserCard
			, ISNULL(SUM(RespectCard), 0) AS RespectCard
			, ISNULL(SUM(AddOrder_Original), 0) AS AddOrder_Original
			, ISNULL(SUM(AddOrder_Edited), 0) AS AddOrder_Edited
			, ISNULL(SUM(SingleSideCard + PhotoCard + InitialCard + LaserCard + DoubleSideCard + RespectCard + AddOrder_Original + AddOrder_Edited), 0) AS TotalCount
		FROM
		(
			SELECT  
				  CASE WHEN A.up_order_seq IS NULL AND A.order_type NOT IN (2, 6, 7) AND (C.isLaser <> 1 AND C.master_2color <> 1 AND D.isfprint <> 1) THEN 1 ELSE 0 END AS SingleSideCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type = 2 THEN 1 ELSE 0 END AS RespectCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type = 6 THEN 1 ELSE 0 END AS PhotoCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type = 7 THEN 1 ELSE 0 END AS InitialCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type NOT IN (2, 6, 7) AND C.isLaser = 1 THEN 1 ELSE 0 END AS LaserCard
				, CASE WHEN A.up_order_seq IS NULL AND A.order_type NOT IN (2, 6, 7) AND C.isLaser <> 1 AND (C.master_2color = 1 OR D.isfprint = 1) THEN 1 ELSE 0 END AS DoubleSideCard
				, CASE WHEN A.up_order_seq IS NOT NULL AND A.order_type <> 2 AND A.order_add_flag = 0 THEN 1 ELSE 0 END AS AddOrder_Original
				, CASE WHEN A.up_order_seq IS NOT NULL AND A.order_type <> 2 AND A.order_add_flag = 1 THEN 1 ELSE 0 END AS AddOrder_Edited
			FROM custom_order AS A
				INNER JOIN s2_card AS B 
					ON A.card_seq = B.card_seq
				INNER JOIN s2_cardoption AS C 
					ON A.card_seq = C.card_seq
				INNER JOIN card_corel AS D 
					ON B.card_code = D.card_code
				LEFT OUTER JOIN Admin_Lst AS E
					ON A.src_compose_admin_id = E.Admin_ID
			WHERE 1 = 1 
				AND A.src_compose_date BETWEEN @FromDT + ' 00:00:00' AND @ToDT + ' 23:59:59'
				--AND A.status_seq = 15
				AND ISNULL(A.src_compose_admin_id, '') <> ''
				AND E.isCS = 0
		) AS A
	) AS A
	ORDER BY
		  A.Admin_Level
		, A.Admin_Name

END
GO
