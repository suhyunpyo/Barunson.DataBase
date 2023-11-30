IF OBJECT_ID (N'invtmng.sp_orderJaego', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_orderJaego
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE      PROC [invtmng].[sp_orderJaego]
@card_code varchar(20),
@order_num int
AS
begin

	update card_jaego set jaego=jaego-@order_num where card_code=@card_code
	
	DECLARE @jaego int
	select  @jaego = jaego from card_jaego where card_code=@card_code

	if @jaego < 2000	-- 업데이트 후의 재고수량이 2000 이하일 경우 전시를 모두 내린다.
	begin
		update card set display_yes_or_no='0',jumun_yes_or_no='3' where card_code=@card_code 
		and card_group in (0,1,2,3,5,7,15,237,532,553,587,1186,1272,1377,2107)
		
		
	end
end




GO
