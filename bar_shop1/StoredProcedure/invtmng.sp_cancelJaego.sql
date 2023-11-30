IF OBJECT_ID (N'invtmng.sp_cancelJaego', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_cancelJaego
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [invtmng].[sp_cancelJaego]
@card_code varchar(20),
@order_num int
AS
begin

	update card_jaego set jaego=jaego+@order_num where card_code=@card_code
	
	--DECLARE @jaego int
	--SET  select @jaego= jaego from card_jaego where card_code=@card_code
end
GO
