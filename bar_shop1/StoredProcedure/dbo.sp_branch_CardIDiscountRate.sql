IF OBJECT_ID (N'dbo.sp_branch_CardIDiscountRate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_branch_CardIDiscountRate
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

/*  
 작성정보   :   [2005:03:17    12:00]  김수경:   
 관련페이지 :상품 DP
 내용    :   상품 개별 할인율 정보
   
 수정정보   :   
*/  

CREATE Procedure [dbo].[sp_branch_CardIDiscountRate]
	@company_seq int,
	@card_seq 	int,
	@order_count   int
as
begin
	if @order_count=0 
		begin
		SELECT ID, CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM BRANCH_CARD_DISCOUNT_RATE
				WHERE COMPANY_SEQ=@company_seq and CARD_PRICE=@card_seq and disrate_type='I'
				ORDER BY min_count
		end
	else
		begin
		SELECT ID, CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM BRANCH_CARD_DISCOUNT_RATE
				WHERE COMPANY_SEQ=@company_seq and CARD_PRICE=@card_seq  and disrate_type='I' and MAX_COUNT>=@order_count and MIN_COUNT<=@order_count
		end
end
GO
