IF OBJECT_ID (N'dbo.up_select_collaboration_thecard_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_collaboration_thecard_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================  
-- Author : 김현기
-- Create date : 2016-12-27
-- Description : 
-- up_select_collaboration_thecard_list 5007, null, 71, 1, 40, '', 'ASC', 100  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_collaboration_thecard_list]
	
	@company_seq	int,				-- 회사고유코드	
	@brand			nvarchar(20),		-- 고유브랜드 (없을 경우 NULL 값 넘겨 받으면 됨)
	@category		int,				-- 카테고리 코드	
	@page			int,				-- 페이지 번호
	@pagesize		int,				-- 페이지 사이즈 (페이지당 노출 갯수)	
	@orderby		nvarchar(20),		-- 정렬 컬럼
	@Sequence		nvarchar(20),		-- 정렬 조건(ASC, DESC)
	@order_num		int					-- 주문 수량
	
AS
BEGIN
		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;		
	
	BEGIN
	
		-- Count Query 시작 --	
		SELECT COUNT(A.RK_Card_Code) AS CNT 
		FROM S4_Ranking_Sort_Table  AS A WITH(NOLOCK)
		INNER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq							
		INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq									 
		INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq
		INNER JOIN S2_CardImage AS E ON A.RK_Card_Code = E.Card_Seq 
		INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq								 
		INNER JOIN S2_cardkind AS I ON C.Card_Seq = I.Card_Seq
		INNER JOIN S2_cardkindinfo AS J ON I.CardKind_Seq = J.CardKind_Seq
		WHERE 1 = 1
		  AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건
		  AND B.CardBrand = ISNULL(@brand, B.CardBrand) -- 브랜드 조건
		  AND C.Company_Seq = @company_seq
		  AND C.IsDisplay = 1	-- 사용여부  
		  AND D.MinCount = @order_num 
		  AND E.CardImage_WSize = '210' 
		  AND E.CardImage_HSize = '210' 
		  AND E.cardimage_div = 'E'		  
		  AND E.Company_Seq = @company_seq 
		  AND J.CardKind_Seq = 1	-- 청첩장												
		-- Count Query 끝 --	
		
		-- List Paging Query 시작 --
		SELECT * 
		FROM
		(
			SELECT  ROW_NUMBER() OVER (ORDER BY /*(
													CASE @Sequence WHEN 'ASC' THEN 
																					CASE @orderby WHEN 'REGDATE' THEN B.RegDate
																								  WHEN 'PRICE' THEN B.CardSet_Price 
																					END
													END	
												 ) ASC,
												 (
													CASE @Sequence WHEN 'DESC' THEN 
																					CASE @orderby WHEN 'REGDATE' THEN B.RegDate
																								  WHEN 'PRICE' THEN B.CardSet_Price
																								  WHEN 'DISCOUNT_RATE' THEN D.Discount_Rate	--할인율 높은 순																							  
																								  WHEN 'COMMENT' THEN CM.Cnt --상품평 순
																					END
													END	
												 ) DESC ) AS RowNum*/
												 A.RK_IDX ASC) AS RowNum				
					, A.RK_ST_SEQ
					, A.RK_Card_Code
					, A.RK_Title
					, B.Card_Name
					, B.Card_Code
					, B.CardBrand
					, B.CardSet_Price
					, B.Card_Seq
					, B.RegDate				
					, CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate 
					, E.CardImage_FileName
					, C.IsJumun
					, C.IsNew
					, C.IsBest
					, C.IsExtra
					, C.IsSale
					, C.IsExtra2
					, C.isRecommend
					, C.isSSPre
					, C.Company_Seq
					, H.IsSample
					, ISNULL(CM.cnt, 0) AS Comment_Cnt
					, (ISNULL(CM.StarPoints, 0) / ISNULL(CM.cnt, 1)) AS StarPoints
					, H.IsEnvInsert
					--,RK_Idx
					, NULL AS Gubun
					, (B.CardSet_Price * 400 * (100 - D.Discount_Rate) * 0.01) AS Discount_Card_Price
					, NULL AS Sales_CNT
					, ISNULL(H.isFSC, '0') AS isFSC
					, ISNULL(H.isNewEvent, '0') AS isNewEvent
					, ISNULL(H.isRepinart, '0') AS isRepinart
					, ISNULL(H.isHappyPrice, '0') AS isHappyPrice
					, ISNULL(H.isSpringYN, '0') AS isSpringYN
					, ISNULL(H.isnewGubun, '0') AS isnewGubun
					, ISNULL(C.isBgcolor,'') AS isBgcolor
			FROM S4_Ranking_Sort_Table AS A  WITH(NOLOCK)
			LEFT OUTER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq
			LEFT OUTER JOIN (
								SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt, SUM(ER_Review_Star) AS StarPoints 
								FROM S4_Event_Review  WITH(NOLOCK)
								WHERE ER_Company_Seq = @company_seq
								GROUP BY ER_Card_Seq
							) CM ON B.Card_Seq = CM.Card_Seq 
			INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq
			INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq
			INNER JOIN S2_CardImage AS E ON A.RK_Card_Code = E.Card_Seq 
			INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq
			INNER JOIN S2_CardKind AS I ON C.Card_Seq = I.Card_Seq
			INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq	
			WHERE 1 = 1
			  AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건
			  AND B.CardBrand = ISNULL(@brand, B.CardBrand) -- 브랜드 조건
			  AND C.Company_Seq = @company_seq
			  AND C.IsDisplay = 1  
			  AND D.MinCount = @order_num 
			  AND E.CardImage_WSize = '210' 
			  AND E.CardImage_HSize = '210' 
			  AND E.cardimage_div = 'E'		  
			  AND E.Company_Seq = @company_seq 
			  AND J.CardKind_Seq = 1		  
		) AS RESULT
		WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )	
		-- List Paging Query 끝 --
		
	END
				
END

GO
