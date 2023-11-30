IF OBJECT_ID (N'dbo.photobook_prod_price', N'V') IS NOT NULL DROP View dbo.photobook_prod_price
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[photobook_prod_price]
AS
SELECT   A.prod_code, A.makecom_code, A.prod_name, A.prod_cate2, A.prod_size, 
                A.reg_date, A.prod_price, A.disrate_type, A.fix_disrate, A.prod_price AS src_price, 
                B.prod_option, B.add_price, B.mc_prod_name, B.p
FROM      dbo.PHOTOBOOK_PROD A INNER JOIN
                dbo.PHOTOBOOK_PROD_OPTION B ON A.id = B.prod_id
WHERE   (A.site_code = '2')
GO
