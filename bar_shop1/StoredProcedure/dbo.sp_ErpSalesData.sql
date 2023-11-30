IF OBJECT_ID (N'dbo.sp_ErpSalesData', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_ErpSalesData
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- ERP중간테이블 넘기는 Data Query
-- =============================================
CREATE PROCEDURE [dbo].[sp_ErpSalesData] 
	@BDate 		char(8)
	,@EDate		char(8)
AS
	Set NoCount On

	SELECT a.company_seq,A.sales_gubun,a.order_Seq,up_order_seq,order_Type,order_Add_type,order_date,
	src_send_date,order_name ,delivery_price,option_price,jebon_price,fticket_price,mini_price,sasik_price,etc_price,
	print_price,order_count ,order_price,settle_price,last_total_price, B.company_name,B.erp_code,B.up_tae,a.pay_type,
	c.card_seq, c.item_type, c.item_count, c.item_price, c.item_sale_price, c.discount_rate 
	FROM 
	CUSTOM_ORDER A JOIN COMPANY B ON A.company_seq = b.company_seq 
	JOIN Custom_order_item c ON a.order_seq = c.order_seq
	WHERE 
	a.status_seq = 15 and Convert(char(8),a.src_send_date,112) >= @BDate and Convert(char(8),a.src_send_date,112) <= @EDate 
	and pay_type <> '4' 
	and a.sales_gubun in ('W','T','U','A','J','B') 
	and (not A.company_seq in (224,232,1137,1250) or (A.company_seq in (232,1137,1250) and reduce_price = 0 and settle_price > 0)) 
	ORDER BY a.order_seq 

GO
