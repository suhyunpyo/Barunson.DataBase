IF OBJECT_ID (N'dbo.photobook_order_detailV', N'V') IS NOT NULL DROP View dbo.photobook_order_detailV
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[photobook_order_detailV]
AS
select A.order_id,A.product_order_id,A.prod_code,A.prod_page,A.item_count,A.item_sale_price,A.item_option,A.thumbnail_url
,B.prdt_name as prod_name,B.cover_name,B.coating_yn,B.prdt_type as prod_cate,'' as prod_cate2,'' as cover_style,B.makecom_code,B.size as prod_size,A.delivery_code,A.p_delivery_date
from photobook_order_detail A inner join vPB_PROD B on A.prod_code = B.oasis_idx where len(A.prod_code)>11
union all
select A.order_id,A.product_order_id,A.prod_code,A.prod_page,A.item_count,A.item_sale_price,A.item_option,A.thumbnail_url
,B.prod_name,prod_name as cover_name,'' as COATING_YN,B.prod_cate,B.prod_cate2,B.cover_style,B.makecom_code,B.prod_size,A.delivery_code,A.p_delivery_date
from photobook_order_detail A inner join photobook_prod B on A.prod_code = B.prod_code where len(A.prod_code)<=11
GO
