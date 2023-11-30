IF OBJECT_ID (N'dbo.sp_CardDisrateTiara', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardDisrateTiara
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   Procedure [dbo].[sp_CardDisrateTiara]
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
		select disrate100,disrate120,disrate150,disrate160,disrate170,disrate200,disrate250,disrate300,disrate350,disrate400,disrate450,disrate500,disrate550,disrate600,disrate650,disrate700,disrate750,disrate800,disrate850,disrate900,disrate950,disrate1000
			from card_discount
			where CARD_PRICE=@cid and disrate_type='I' and card_kind=@card_kind
	end
	else
	begin
		select disrate100,disrate120,disrate150,disrate160,disrate170,disrate200,disrate250,disrate300,disrate350,disrate400,disrate450,disrate500,disrate550,disrate600,disrate650,disrate700,disrate750,disrate800,disrate850,disrate900,disrate950,disrate1000
			FROM CARD_DISCOUNT
			WHERE CARD_GROUP=@card_group and COMPANY=@company and CARD_PRICE=@cprice and disrate_type='P' and card_kind=@card_kind
	end
end
GO
