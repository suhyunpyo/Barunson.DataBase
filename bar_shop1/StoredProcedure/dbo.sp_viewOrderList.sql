IF OBJECT_ID (N'dbo.sp_viewOrderList', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewOrderList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_viewOrderList '20081105','20081105','B'

CREATE PROCEDURE [dbo].[sp_viewOrderList] 
@SDate char(8),
@EDate char(8),
@Gubun char(1)   --J:주문일 기준, B:배송일기준
As

DROP TABLE erp_data.dbo.view_OrderList

IF @Gubun = 'B'
	SELECT 
		*
	INTO
		erp_data.dbo.view_OrderList
	FROM
		--order_seq,sales_gubun,up_order_seq,order_date,settle_date,src_print_date,src_send_Date,src_printer_seq, settle_method,settle_price, 
		--	   last_total_price,status_seq,order_name, order_type, company_seq, card_seq, order_count, isinpaper, jebon_price, iscontadd,
		custom_order where status_Seq=15 
		and convert(char(8),src_send_date,112) between @SDate and @EDate
		and sales_gubun in ('W','T','U','A','J','B','S','X') 
ELSE
	SELECT 
		*
	INTO
		erp_data.dbo.view_OrderList
	FROM
		--order_seq,sales_gubun,up_order_seq,order_date,settle_date,src_print_date,src_send_Date,src_printer_seq, settle_method,settle_price, 
		--	   last_total_price,status_seq,order_name, order_type, company_seq, card_seq, order_count, isinpaper, jebon_price, iscontadd,
		custom_order 
		where 
		status_Seq >= 1 
		and convert(char(8),order_date,112) between @SDate and @EDate
		and sales_gubun in ('W','T','U','A','J','B','S','X') 

	SELECT * FROM erp_data.dbo.view_OrderList
GO
