IF OBJECT_ID (N'dbo.sp_theInitialDiscountRate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_theInitialDiscountRate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   Procedure [dbo].[sp_theInitialDiscountRate]
	@ptype char(1),
	@company int,
	@order_count   int
as
begin
	if @order_count = 0 
		begin
		SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM CARD_DISCOUNT_RATE
				WHERE CARD_GROUP='1' and COMPANY=@company and disrate_type=@ptype
				ORDER BY  min_count
		end
	else
		begin
		SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM CARD_DISCOUNT_RATE
				WHERE CARD_GROUP='1' and COMPANY=@company and disrate_type=@ptype and MIN_COUNT<=@order_count and MAX_COUNT>=@order_count
		end
end


GO
