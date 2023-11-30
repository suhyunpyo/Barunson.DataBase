IF OBJECT_ID (N'dbo.sp_viewSumPrice', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewSumPrice
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_viewSumPrice] 
@SDate char(8),
@EDate char(8)
As
Select count(order_seq) as '주문건',sum(last_total_price) as '금액합계',sum(settle_price) as 'PG결제합계',sum(order_count) as '카드합계'
From custom_order where status_Seq=15 
and convert(char(8),src_send_date,112) between @SDate and @EDate
and sales_gubun in ('W','T','U','A','J','B','S','X') 
GO
