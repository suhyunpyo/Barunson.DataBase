IF OBJECT_ID (N'dbo.sp_branch_CardDiscountRate_ex', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_branch_CardDiscountRate_ex
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	'대리점 가격 정책
*/

CREATE PROCEDURE [dbo].[sp_branch_CardDiscountRate_ex]
	@company_seq	int,
	@card_price 	int,
	@order_count   int,
    @company    tinyint
as
begin
	if @order_count=0 
		begin
		SELECT ID, CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM BRANCH_CARD_DISCOUNT_RATE
				WHERE COMPANY_SEQ=@company_seq and CARD_PRICE=@card_price and disrate_type='P' and company=@company
				ORDER BY  min_count
		end
	else
		begin
		SELECT ID, CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM BRANCH_CARD_DISCOUNT_RATE
				WHERE  COMPANY_SEQ=@company_seq and CARD_PRICE=@card_price  and disrate_type='P' and MAX_COUNT>=@order_count and MIN_COUNT<=@order_count and company=@company
		end
end
GO
