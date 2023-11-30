IF OBJECT_ID (N'dbo.sp_viewPhotoList', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewPhotoList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_viewPhotoList]
@SDate char(8),
@EDate char(8)
As



DROP TABLE erp_data.dbo.view_PhotoList

SELECT 
	sales_gubun,order_seq, order_Date,settle_price,order_name,status_Seq,delivery_date
INTO
	erp_data.dbo.view_PhotoList
FROM
custom_etc_order where status_Seq>=1 
and convert(char(8),delivery_date,112) between @SDate and @EDate
and sales_gubun in ('W','T','U','A','J','B','S','X')  and order_type='P'


SELECT * FROM erp_data.dbo.view_PhotoList
GO
