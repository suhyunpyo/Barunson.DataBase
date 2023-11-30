IF OBJECT_ID (N'invtmng.invtmng.sp_photobookBack', N'P') IS NOT NULL DROP PROCEDURE invtmng.invtmng.sp_photobookBack
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [invtmng].[invtmng.sp_photobookBack]
@oid integer
as
begin
	declare @member_id varchar(20),@product_order_id varchar(50),@prod_code varchar(20),@prod_page integer,@item_count integer
	
	select @member_id = member_id,@product_order_id = B.product_order_id,@prod_code = B.prod_code,@prod_page = B.prod_page,@item_count = B.item_count 
	from photobook_order A inner join photobook_order_item B on A.id = B.order_id
	where A.id = @oid

	insert into photobook_basket(member_id,prod_code,prod_page,prod_order_id,item_count) 
	values(@member_id,@prod_code,@prod_page,@product_order_id,@item_count)
end
GO
