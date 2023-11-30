IF OBJECT_ID (N'dbo.view_CopyItem', N'V') IS NOT NULL DROP View dbo.view_CopyItem
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[view_CopyItem]
AS
SELECT   A.id, A.item_type, A.item_title, ISNULL(B.plc_code, '0000') AS plc_code, 
                A.item_count, A.item_code, A.item_seq, A.order_seq, A.delivery_seq
FROM      dbo.CUSTOM_ORDER_COPY_DETAIL A LEFT OUTER JOIN
                dbo.CUSTOM_ORDER_COPY_PlcCode B ON A.item_title = B.title
GO
