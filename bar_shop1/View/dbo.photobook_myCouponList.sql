IF OBJECT_ID (N'dbo.photobook_myCouponList', N'V') IS NOT NULL DROP View dbo.photobook_myCouponList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[photobook_myCouponList]
AS
SELECT   A.uid, B.sales_gubun,B.site_code,A.coupon_code, B.disrate_type, B.disrate, B.coupon_msg, 
                B.Isthrowaway, B.use_yn, B.prod_cate2, B.start_date, B.end_date, A.reg_date 
FROM      dbo.PHOTOBOOK_MYCOUPON A INNER JOIN
                dbo.PHOTOBOOK_COUPON B ON A.coupon_code = B.coupon_code
GO
