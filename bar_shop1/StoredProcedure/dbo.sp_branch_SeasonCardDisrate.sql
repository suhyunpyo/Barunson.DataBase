IF OBJECT_ID (N'dbo.sp_branch_SeasonCardDisrate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_branch_SeasonCardDisrate
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[sp_branch_SeasonCardDisrate]
	@produce_year	char(4),
	@disrate_type	char(1),
	@company	int,
	@cid		int,	
	@cprice		int
as
begin
	if @disrate_type = 'I'			-- 개별할인율인 경우
	begin
		select * from branch_card_discount_season
			where CARD_PRICE=@cid and disrate_type='I' and produce_year=@produce_year
	end
	else
	begin
		select * 	FROM branch_CARD_DISCOUNT_season
			WHERE CARD_PRICE=@cprice and disrate_type='P' and produce_year=@produce_year and COMPANY=@company
	end
end
GO
