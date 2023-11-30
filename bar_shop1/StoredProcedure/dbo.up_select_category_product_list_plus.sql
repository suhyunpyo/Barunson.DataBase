IF OBJECT_ID (N'dbo.up_select_category_product_list_plus', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_category_product_list_plus
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-15
-- Description:	플러스 상품 category 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_category_product_list_plus]
	@category		int,				-- 카테고리 코드	
	@page			int,				-- 페이지 번호
	@pagesize		int					-- 페이지 사이즈 (페이지당 노출 갯수)		
AS
BEGIN
		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;		
	
	
	-- Count Query 시작 --	
	SELECT COUNT(A.RK_Card_Code) AS CNT 
	FROM S4_Ranking_Sort_Table AS A
	INNER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq							
	INNER JOIN S2_CardDetailEtc AS C ON B.Card_Seq = C.Card_Seq							
	WHERE 1 = 1
	  AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건
	  AND C.IsDisplay = 1	-- 사용여부  
	-- Count Query 끝 --	
	
	
	-- List Paging Query 시작 --
	SELECT * 
	FROM
	(
		SELECT  ROW_NUMBER() OVER (ORDER BY RK_IDX ASC) AS RowNum				
				, A.RK_ST_SEQ
				, A.RK_Card_Code
				, A.RK_Title
				, B.Card_Name
				, B.Card_Code
				, B.Card_Price
				, B.CardSet_Price
				, B.card_seq
				, B.RegDate				
		FROM S4_Ranking_Sort_Table AS A
			INNER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq
			INNER JOIN S2_CardDetailEtc AS C ON B.Card_Seq = C.Card_Seq								
		WHERE 1 = 1
		  AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건
		  AND C.IsDisplay = 1  	  
	) AS RESULT
	WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )	
	-- List Paging Query 끝 --
				
END
GO
