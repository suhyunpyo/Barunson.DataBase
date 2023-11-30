IF OBJECT_ID (N'dbo.up_select_product_list_plus', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_plus
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-15
-- Description:	플러스 상품 list
-- =============================================
CREATE Procedure [dbo].[up_select_product_list_plus]
	-- Add the parameters for the stored procedure here
	@category int,   -- 카테고리 코드
	@page	int,				-- 페이지넘버
	@pagesize int				-- 페이지사이즈(페이지당 노출갯수)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
    -- Insert statements for procedure here
	-- total count
	SELECT COUNT(A.RK_Card_Code) AS TOT 
	FROM S4_Ranking_Sort_Table_Plus AS A
		INNER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq		
		INNER JOIN S2_CardDetailEtc AS C ON B.Card_Seq = C.Card_Seq  
	WHERE 1 = 1
	  AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건
	  AND C.IsDisplay = 1	-- 사용여부  
		
	-- goods list
	SELECT * 
	FROM
	(
		SELECT  ROW_NUMBER() OVER (ORDER BY RK_IDX ASC) AS RowNum, 				
			B.card_seq, B.card_code, B.card_name, B.cardset_price, B.card_price, B.card_image
		FROM S4_Ranking_Sort_Table_Plus AS A
			INNER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq
			INNER JOIN S2_CardDetailEtc AS C ON B.Card_Seq = C.Card_Seq	
		WHERE 1 = 1
			AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건
			AND C.IsDisplay = 1	-- 사용여부  
	) AS RESULT
	WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )	
END
GO
