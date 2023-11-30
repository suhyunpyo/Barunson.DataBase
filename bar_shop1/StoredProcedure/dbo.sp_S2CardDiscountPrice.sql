IF OBJECT_ID (N'dbo.sp_S2CardDiscountPrice', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardDiscountPrice
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--Exec sp_S2CardStyle 'T',30755
CREATE Proc [dbo].[sp_S2CardDiscountPrice]
	@Min_Price int,
	@Max_Price int
AS
	SELECT top 5 a.Card_Seq, a.Card_Code,a.Card_Name, a.CardSet_Price, b.Ranking,dbo.S2_getDiscountPrice(a.card_seq,400) as disPrice, discount_Rate
	FROM S2_Card a JOIN S2_CardSalesSite b ON a.Card_Seq = b.Card_Seq 
	JOIN S2_CardDiscount c ON b.CardDiscount_Seq = c.CardDiscount_Seq 
	WHERE a.CardBrand ='W' and b.Company_Seq = 5002 and c.MinCount = 400   
	and dbo.S2_getDiscountPrice(a.card_seq,400) between @Min_Price and @Max_Price
	ORDER BY IsNull(b.Ranking,1000)
GO
