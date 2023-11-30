IF OBJECT_ID (N'dbo.sp_CardDisrate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardDisrate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[sp_CardDisrate]
	@card_group	char(1),
	@disrate_type	char(1),
	@card_kind	char(1),
	@company	int,
	@cid		int,	
	@cprice		int,	
	@order_count	int

as
begin
	if @disrate_type = 'I'			-- 개별할인율인 경우
	begin
		if @order_count = 0 
			begin
				SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
					FROM CARD_DISCOUNT_RATE
					WHERE CARD_PRICE=@cid and disrate_type='I' and card_kind=@card_kind
					ORDER BY min_count
			end
		else	
			begin
				SELECT  ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
					FROM CARD_DISCOUNT_RATE
					WHERE CARD_PRICE=@cid and disrate_type='I' and card_kind=@card_kind and MAX_COUNT>=@order_count 
					and MIN_COUNT<=@order_count

			end
	end
	else
	begin
		if @order_count = 0 
			begin
				SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
					FROM CARD_DISCOUNT_RATE
					WHERE CARD_GROUP=@card_group and COMPANY=@company and CARD_PRICE=@cprice and disrate_type='P' and card_kind=@card_kind
					ORDER BY  min_count

			end

		else	
			begin
				SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
					FROM CARD_DISCOUNT_RATE
					WHERE CARD_GROUP=@card_group and COMPANY=@company and CARD_PRICE=@cprice and disrate_type='P' and card_kind=@card_kind 
					and MAX_COUNT>=@order_count and MIN_COUNT<=@order_count
					ORDER BY  min_count

			end
	end
end
GO
