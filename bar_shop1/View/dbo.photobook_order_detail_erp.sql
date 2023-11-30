IF OBJECT_ID (N'dbo.photobook_order_detail_erp', N'V') IS NOT NULL DROP View dbo.photobook_order_detail_erp
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [dbo].[photobook_order_detail_erp]
AS
SELECT   A.order_id, A.product_order_id, A.prod_code, A.item_count,a.item_price, a.item_sale_price, B.erp_code
FROM      dbo.PHOTOBOOK_ORDER_DETAIL A INNER JOIN
                invtmng.PHOTOBOOK_PROD_ERP B ON A.prod_code = B.prod_code AND 
                A.prod_page = B.prod_page


GO
