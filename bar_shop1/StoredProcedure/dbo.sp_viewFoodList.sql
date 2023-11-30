IF OBJECT_ID (N'dbo.sp_viewFoodList', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewFoodList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_viewFoodList]
@SDate char(8),
@EDate char(8)
As


DROP TABLE erp_data.dbo.view_FoodList

SELECT 
	sales_gubun,order_seq, order_Date,settle_price,order_name,status_Seq,delivery_date
INTO
	erp_data.dbo.view_FoodList
FROM
custom_etc_order where status_Seq = 12 
and convert(char(8),delivery_date,112) between @SDate and @EDate
and sales_gubun in ('W','T','U','A','J','B','S','X')  and order_type in ('F','C','S')


SELECT * FROM erp_data.dbo.view_FoodList

GO
