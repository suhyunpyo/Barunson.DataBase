IF OBJECT_ID (N'dbo.up_select_review_starpoints', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_review_starpoints
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-11-17
-- Description:	상품평, 평점 가져오기

-- =============================================
CREATE PROCEDURE [dbo].[up_select_review_starpoints]
	
	@company_seq	INT,	-- 회사 고유코드	
	@card_seq		INT,	-- 카드번호
	@isType			INT		-- 후기 종류 (0 : 샘플, 1 : 구매)
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	--1. 상품평 3개 제목
	SELECT   T3.top3 AS Num
			,R.ER_Idx AS idx
			,ISNULL(R.ER_Review_Title, '') AS title  
	FROM
	(
		SELECT 1 AS top3
		UNION ALL
		SELECT 2 AS top3
		UNION ALL
		SELECT 3 AS top3
	) T3 LEFT OUTER JOIN
	( 
		SELECT   ROW_NUMBER() OVER (ORDER BY ER_Regdate DESC) AS RowNum
				,ER_Idx
				,ER_Review_Title		     
		FROM S4_Event_Review
		WHERE ER_Company_Seq = @company_seq
		  AND ER_Card_Seq = @card_seq
		  AND ER_Type = @isType
		  AND ER_Status = 0	--삭제 여부
	      AND ER_View = 0	--전시 여부 
	) R ON T3.top3 = R.RowNum 
	 
	  
	--2. 상품평 갯수, 평점 
	SELECT   COUNT(ER_Idx) AS Cnt
			,ISNULL(AVG(ER_Review_Star), 0) AS Points
			,ISNULL(AVG(ER_Review_Price), 0) AS Price
			,ISNULL(AVG(ER_Review_Design), 0) AS Design
			,ISNULL(AVG(ER_Review_Quality), 0) AS Quality
			,ISNULL(AVG(ER_Review_Satisfaction), 0) AS Satisfaction 
	FROM S4_Event_Review
	WHERE ER_Company_Seq = @company_seq
	  AND ER_Card_Seq = @card_seq
	  AND ER_Type = @isType
	  AND ER_Status = 0	--삭제 여부
	  AND ER_View = 0	--전시 여부 

END

GO
