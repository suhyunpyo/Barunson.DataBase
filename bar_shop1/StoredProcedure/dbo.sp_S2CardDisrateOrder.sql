IF OBJECT_ID (N'dbo.sp_S2CardDisrateOrder', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardDisrateOrder
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE Proc [dbo].[sp_S2CardDisrateOrder]
	@Company_Seq	int,
	@Card_Seq	    int,
	@Order_Count	int,
	@min_Count	int,
	@unit_Count int
AS
	IF @Order_Count = ''
		BEGIN
			SELECT d.CardDiscount_Seq,d.MinCount,d.MaxCount,d.Discount_Rate, ISNULL(d.Discount_Price, 0) AS Discount_Price
			FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq
						JOIN S2_CardSalesSite c ON a.Card_Seq = c.Card_Seq
						JOIN S2_CardDiscount d ON c.CardDiscount_Seq = d.CardDiscount_Seq
			WHERE d.MinCount >= @min_count and d.MinCount%@unit_count = 0	--주문최소수량 및 주문단위 수량 Sort	
				  and c.Company_Seq = @Company_Seq and a.Card_Seq = @Card_Seq	
				  order by MinCount asc
		END			
	ELSE
		BEGIN
			SELECT d.CardDiscount_Seq,d.MinCount,d.MaxCount,d.Discount_Rate, ISNULL(d.Discount_Price, 0) AS Discount_Price
			FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq
						JOIN S2_CardSalesSite c ON a.Card_Seq = c.Card_Seq
						JOIN S2_CardDiscount d ON c.CardDiscount_Seq = d.CardDiscount_Seq
			WHERE d.MinCount <= @Order_Count and d.MaxCount >= @Order_Count
				  and c.Company_Seq = @Company_Seq and a.Card_Seq = @Card_Seq	
				  order by MinCount asc
		END
GO
