IF OBJECT_ID (N'dbo.select_season_jaegoable', N'P') IS NOT NULL DROP PROCEDURE dbo.select_season_jaegoable
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[select_season_jaegoable]
 @p_card_seq int
as
begin
	declare @wp_jaego int			--현재고
	declare @wp_ingnum int			--진행중 주문
	
	select @wp_jaego = B.jaego 
	from CARD A inner join CARD_JAEGO B on A.card_code = B.card_code 
	where A.card_seq = @p_card_seq
	
	select @wp_ingnum = ISNULL(SUM(B.item_count),0)
	from custom_order A inner join custom_order_item B on A.order_seq = B.order_seq and B.item_type='C'
	where 
	B.card_seq = @p_card_seq
	and A.company_seq = 1654
	and A.status_seq in (1,6,7,8,9) 
	and A.settle_status in ('0','1')
	and A.order_date>='2013-11-01' 
	
	select @wp_jaego - @wp_ingnum
end


GO
