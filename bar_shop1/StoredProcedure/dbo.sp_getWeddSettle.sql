IF OBJECT_ID (N'dbo.sp_getWeddSettle', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_getWeddSettle
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[sp_getWeddSettle] 
@sdate [varchar](10),
@edate [varchar](10)
as
declare @sql [varchar](500)
set @sql = 'select count(B.order_seq),sum(B.settle_price) 
from custom_order_master A inner join custom_Settle_info B
on A.order_seq = B.order_seq,Card C
where A.card_seq = C.card_seq and B.settle_date>="'+@sdate+'" and B.settle_date <=" '+@edate+' 23:59:59"
and (A.status_seq = 4 or A.status_Seq>5 ) and C.card_kind="1" and A.up_order_seq is null'
EXEC(@sql)

GO
