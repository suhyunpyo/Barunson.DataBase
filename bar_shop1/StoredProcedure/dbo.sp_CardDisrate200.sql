IF OBJECT_ID (N'dbo.sp_CardDisrate200', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardDisrate200
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[sp_CardDisrate200]
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
			and MIN_COUNT in (200,300,400,500,600,700,800,900,1000)

	end
	else
	begin
		SELECT ID,CARD_PRICE,MIN_COUNT,MAX_COUNT,DISCOUNT_RATE
			FROM CARD_DISCOUNT_RATE
			WHERE CARD_GROUP=@card_group and COMPANY=@company and CARD_PRICE=@cprice and disrate_type='P' and card_kind=@card_kind 
			and MIN_COUNT in (200,300,400,500,600,700,800,900,1000)
			ORDER BY  min_count

	end
end

GO
