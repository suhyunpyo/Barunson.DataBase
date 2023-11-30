IF OBJECT_ID (N'dbo.up_select_review_starpoints_total', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_review_starpoints_total
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/*
 작성정보   : 황새롬    
 관련페이지 : product > detail.asp    
 내용    : 상품 이용후기(바/비/더/프 전부 다 가져오는)  
 바/비/프는 이용후기 테이블이 다름  
*/

-- =============================================
CREATE PROCEDURE [dbo].[up_select_review_starpoints_total]
	
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
            ,    A.*
        FROM    (
                    SELECT  ER_Idx
                        ,   ER_Review_Title
                        ,   ER_Regdate
                    FROM    S4_Event_Review
                    WHERE   ER_Company_Seq = @company_seq
                    AND     ER_Card_Seq = @card_seq
		            AND     ER_Type = @isType
		            AND     ER_Status = 0	--삭제 여부
	                AND     ER_View = 0	--전시 여부 

                    UNION ALL

                    SELECT  SEQ AS ER_Idx
                        ,   TITLE AS ER_Review_Title  
                        ,   REG_DATE AS ER_Regdate  
                    FROM    S2_USERCOMMENT  
                    WHERE   CARD_SEQ = @card_seq  
                ) A
	) as R ON T3.top3 = R.RowNum 
	 
	  
	--2. 상품평 갯수, 평점 
	SELECT   COUNT(A.ER_IDX) AS CNT
		,   ISNULL(AVG(ER_Review_Star), 0) AS Points
		,   ISNULL(AVG(ER_Review_Price), 0) AS Price
		,   ISNULL(AVG(ER_Review_Design), 0) AS Design
		,   ISNULL(AVG(ER_Review_Quality), 0) AS Quality
		,   ISNULL(AVG(ER_Review_Satisfaction), 0) AS Satisfaction   
    FROM    (
                SELECT  ER_IDX
			        ,   ER_Review_Star
			        ,   ER_Review_Price
			        ,   ER_Review_Design
			        ,   ER_Review_Quality
			        ,   ER_Review_Satisfaction
                FROM    S4_Event_Review
	            WHERE   ER_Company_Seq = @company_seq
                AND     ER_Card_Seq = @card_seq
                AND     ER_Type = @isType
                AND     ER_Status = 0	--삭제 여부
                AND     ER_View = 0	--전시 여부 

                UNION

                SELECT  SEQ AS ER_IDX
                    ,   SCORE * 4 AS ER_Review_Star
                    ,   SCORE AS ER_Review_Price
                    ,   SCORE AS ER_Review_Design
                    ,   SCORE AS ER_Review_Quality
                    ,   SCORE AS ER_Review_Satisfaction
                FROM    S2_USERCOMMENT  
                WHERE   CARD_SEQ = @card_seq 
            ) A
END

GO
