IF OBJECT_ID (N'dbo.getDiscountRate', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getDiscountRate', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getDiscountRate', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getDiscountRate', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.getDiscountRate', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.getDiscountRate
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--IC380572

CREATE  Function [dbo].[getDiscountRate] 	(@Order_Seq varchar(30))
Returns numeric(28,8)
as
Begin

	Declare @DiscountRate numeric(28,8)



	select  @DiscountRate= (100-(settle_price/sum((item_count*erp_sobi)))*100)  
		from custom_order a Join custom_order_item b on a.order_seq = b.order_seq
		                  Join card c on b.card_seq = c.card_seq
	     Join erp_price d on c.card_code = d.itemCode
	     where a.pg_tid = @Order_Seq
	     group by settle_price	


	Return  @DiscountRate
End
    


GO
