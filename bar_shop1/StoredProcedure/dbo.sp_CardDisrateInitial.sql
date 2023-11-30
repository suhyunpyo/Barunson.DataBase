IF OBJECT_ID (N'dbo.sp_CardDisrateInitial', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardDisrateInitial
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create  Procedure [dbo].[sp_CardDisrateInitial]
	@card_group	char(1),
	@disrate_type	char(1),
	@card_kind	char(1),
	@company	int,
	@cid		int,	
	@cprice		int

as
begin
	if @disrate_type = 'I'			-- 개별할인율인 경우
	begin

		SELECT  ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
			FROM CARD_DISCOUNT_RATE
			WHERE CARD_PRICE=@cid and disrate_type='I' and card_kind=@card_kind 
			and MIN_COUNT >=200

	end
	else
	begin
		SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
			FROM CARD_DISCOUNT_RATE
			WHERE CARD_GROUP=@card_group and COMPANY=@company and CARD_PRICE=@cprice and disrate_type='P' and card_kind=@card_kind 
			and MIN_COUNT >=200
			ORDER BY  min_count

	end
end


GO
