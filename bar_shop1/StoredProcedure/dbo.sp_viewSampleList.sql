IF OBJECT_ID (N'dbo.sp_viewSampleList', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewSampleList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_viewSampleList]
@SDate char(8),
@EDate char(8),
@Gubun char(1)
As

DROP TABLE erp_data.dbo.view_SampleList

IF @Gubun = 'B'
	SELECT 
		sales_gubun,sample_order_seq,request_date,settle_price,member_name,status_Seq,delivery_date
	INTO
		erp_data.dbo.view_SampleList
	FROM
	custom_sample_order where status_Seq>=1 
	and convert(char(8),delivery_date,112)  between @SDate and @EDate
	and sales_gubun in ('W','T','U','A','J','B','S','X') 
ELSE
	SELECT 
		sales_gubun,sample_order_seq,request_date,settle_price,member_name,status_Seq,delivery_date
	INTO
		erp_data.dbo.view_SampleList
	FROM
	custom_sample_order where status_Seq>=1 
	and convert(char(8),request_date,112)  between @SDate and @EDate
	and sales_gubun in ('W','T','U','A','J','B','S','X') 

SELECT * FROM erp_data.dbo.view_SampleList
GO
