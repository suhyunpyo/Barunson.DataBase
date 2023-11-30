IF OBJECT_ID (N'dbo.sp_viewSumcard', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewSumcard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_viewSumcard] 
@SDate char(8),
@EDate char(8)
As
Select sum(item_count) as '카드합계'
From custom_order A inner join custom_order_item B on A.order_seq = B.order_seq and B.item_type='C'
where status_Seq=15 
and convert(char(8),src_send_date,112) between @SDate and @EDate
and sales_gubun in ('W','T','U','A','J','B','S','X') 
GO
