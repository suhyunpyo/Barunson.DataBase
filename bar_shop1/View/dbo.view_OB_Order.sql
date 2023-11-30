IF OBJECT_ID (N'dbo.view_OB_Order', N'V') IS NOT NULL DROP View dbo.view_OB_Order
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE       VIEW [dbo].[view_OB_Order]
AS

SELECT   a.order_seq, a.order_name, a.order_date, a.order_price, a.settle_price, a.settle_status, a.settle_method,a.last_total_price,a.posflag,
                a.order_hphone, a.settle_date,a.isReceipt, a.pg_resultinfo, a.pg_fee, a.company_Seq,
	/*
	(delivery_price+jebon_price+sticker_price+mini_price+etc_price+env_price+cont_price+option_price+reduce_price +fticket_price+print_price+sasik_price) as etc_Total_Price,
		
	 (
	'배송비' + cast(a.delivery_price as varchar(50))+', 제본비' +cast(a.jebon_price as varchar(50))+ 
	',유료스티커' +  cast(sticker_price as varchar(50))+ 
	',미니청첩장' + cast(mini_price as varchar(50))+  
	',기타비용' +  cast(etc_price as varchar(50)) +
	',봉투비용'+ cast(env_price as varchar(50))+
	',내지비용'+ cast(cont_price as varchar(50))+
	',인쇄판추가비용'+ cast(option_price as varchar(50))+ 
	',쿠폰할인금액'+ cast(reduce_price as varchar(50)) +
	',식권비용'+ cast(fticket_price as varchar(50)) +
	',인쇄비'+ cast(print_price as varchar(50))+ 
	',사식비'+ cast(sasik_price as varchar(50))) as etc_Detail,
	*/
	delivery_price,jebon_price,
	'0'  as sticker_price,
	mini_price,etc_price,env_price,cont_price,option_price,reduce_price,
	'0' as fticket_price,
	print_price,sasik_price,

	b.card_seq, b.item_type, b.item_count, b.item_price, b.item_sale_price
FROM      dbo.custom_order a JOIN dbo.custom_order_item b
	on a.order_seq = b.order_seq 
WHERE   (status_seq >= 1) AND (status_seq <> 3) AND (sales_Gubun = 'P') AND 
                (company_seq <> 15)  AND Convert(char(8), order_date, 112) > '20071115'

GO
