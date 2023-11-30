IF OBJECT_ID (N'dbo.sp_viewOrderList_ZZico', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewOrderList_ZZico
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_viewOrderList_ZZico] 
@SDate char(8),
@EDate char(8)
AS

Drop table erp_data.dbo.view_OrderList_ZZico

SELECT 
	*
INTO erp_data.dbo.view_OrderList_ZZico
FROM photobook_order 
WHERE status_seq = 12 
	and src_erp_date is null 
	and Convert(char(8),delivery_date,112) between @SDate and @EDate
	
	
SELECT * FROM 	erp_data.dbo.view_OrderList_ZZico
GO
