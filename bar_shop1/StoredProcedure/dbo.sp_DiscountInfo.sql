IF OBJECT_ID (N'dbo.sp_DiscountInfo', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DiscountInfo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	작성정보   : [2003:11:11] 김수경
	관련페이지 : card/display/card_det.asp
	내용	   :상품 할인 정보 가져오기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[sp_DiscountInfo]
	@cat_seq	int,
	@card_price 	int,
	@order_count   int
as
begin
	if @order_count=0 
		begin
		SELECT MIN_PRICE,MAX_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM DISCOUNT_POLICY
				WHERE CARD_CATEGORY_SEQ=@cat_seq 
				AND MIN_PRICE<=@card_price
				AND MAX_PRICE>=@card_price
				ORDER BY  MIN_COUNT
		end
	else
		begin
		SELECT MIN_PRICE,MAX_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
				FROM DISCOUNT_POLICY
				WHERE CARD_CATEGORY_SEQ=@cat_seq 
				AND MIN_PRICE<=@card_price
				AND MAX_PRICE>=@card_price
				AND MIN_COUNT<=@order_count
				AND MAX_COUNT>=@order_count
				ORDER BY  MIN_COUNT
		end
end

GO
