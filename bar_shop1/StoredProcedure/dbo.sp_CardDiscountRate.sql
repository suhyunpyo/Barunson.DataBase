IF OBJECT_ID (N'dbo.sp_CardDiscountRate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardDiscountRate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[sp_CardDiscountRate]
	@card_price 	int,
	@order_count   int
as
begin
	if @order_count=0 
		begin
		SELECT CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM CARD_DISCOUNT_RATE
				WHERE CARD_GROUP='0' and CARD_PRICE=@card_price and disrate_type='P'
				ORDER BY  min_count
		end
	else
		begin
		SELECT CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM CARD_DISCOUNT_RATE
				WHERE CARD_GROUP='0' and CARD_PRICE=@card_price  and disrate_type='P' and MAX_COUNT>=@order_count and MIN_COUNT<=@order_count
		end
end
GO
