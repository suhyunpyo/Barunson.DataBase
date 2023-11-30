IF OBJECT_ID (N'dbo.up_select_event_happyprice', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_event_happyprice
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		강현주
-- Create date: 2015-01-31
-- Description:	해피프라이스 이벤트 list
-- =============================================
CREATE PROCEDURE [dbo].[up_select_event_happyprice] 
	@company_seq	int,				-- 회사고유코드	
	@brand			nvarchar(20),		-- 고유브랜드 (없을 경우 NULL 값 넘겨 받으면 됨)
	@idx			int,				-- 해피프라이스 코드
	@pagesize		int,				-- 노출 갯수
	@order_num		int					-- 주문 수량
	
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON;		
	
	DECLARE @order_num_discount INT
	IF @order_num > 1000
	BEGIN
		SELECT @order_num_discount = 1000
	END 
	ELSE
	BEGIN
		SELECT @order_num_discount = @order_num
	END
	
	SELECT TOP (@pagesize)				
			 A.hpi_title
			, ISNULL(A.hpi_limit_cnt, 0) hpi_limit_cnt
			--, ISNULL(A.hpi_sale_cnt, 0) hpi_sale_cnt
			, ISNULL(AA.OrderCNT, 0) AS hpi_sale_cnt
			, B.Card_Name
			, B.Card_Code
			, B.CardBrand
			, ISNULL(B.CardSet_Price, 0) CardSet_Price
			, B.card_seq
			, B.RegDate				
			, ISNULL(CONVERT(INTEGER, D.Discount_Rate), 0) AS Discount_Rate 
			, C.Company_Seq			
			, H.IsSample
			, A.hpi_status
			, @order_num AS order_num
	FROM S5_Happy_Price_Item AS A
	INNER JOIN S2_Card AS B ON A.hpi_Card_seq = B.Card_Seq
	INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.card_seq
	INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq
	INNER JOIN S2_CardOption AS H ON B.card_seq = H.card_seq
	INNER JOIN S2_CardKind AS I ON C.card_seq = I.Card_Seq
	INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq
	LEFT OUTER JOIN
	(
		SELECT 
			B.hpi_idx
			, SUM(C.order_count) AS OrderCNT
		FROM S5_Happy_Price_Main AS A
			INNER JOIN S5_Happy_Price_Item AS B
				ON A.hp_idx = B.hpi_hp_idx
			LEFT OUTER JOIN custom_order AS C
				ON B.hpi_Card_seq = C.card_seq
		WHERE C.settle_status = 2
			AND C.company_seq = @company_seq
			AND C.card_seq = B.hpi_Card_seq
			AND C.order_date BETWEEN A.hp_Sdate AND A.hp_Edate
		GROUP BY
			B.hpi_idx
	) AS AA
		ON A.hpi_idx = AA.hpi_idx
	WHERE 1 = 1
	  AND A.hpi_hp_idx = @idx
	  AND B.CardBrand = ISNULL(@brand, B.CardBrand) -- 브랜드 조건
	  AND C.Company_Seq = @company_seq
	  AND C.IsDisplay = 1  
	  AND D.MinCount = @order_num_discount--@order_num 
	  AND J.CardKind_Seq = 1		
	ORDER BY A.hpi_status, A.hpi_idx ASC		
END

GO
