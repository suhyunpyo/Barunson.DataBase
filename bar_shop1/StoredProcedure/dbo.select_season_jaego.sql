IF OBJECT_ID (N'dbo.select_season_jaego', N'P') IS NOT NULL DROP PROCEDURE dbo.select_season_jaego
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[select_season_jaego]
 @p_card_code as varchar(20)
as
begin

	select jaego
	from card_jaebon 
	where card_code = @p_card_code
end


GO
