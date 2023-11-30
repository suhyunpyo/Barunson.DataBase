IF OBJECT_ID (N'dbo.sp_viewEcard', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_viewEcard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_viewEcard]
@SDate char(8),
@EDate char(8)
As


DROP TABLE erp_data.dbo.view_Ecard

SELECT 
	*
INTO
	erp_data.dbo.view_Ecard
FROM
( SELECT '' as idx, order_id, reg_date, settle_date, pg_resultinfo, settle_price, productID, order_name ,Sales_Gubun
FROM DBO.THE_EWED_ORDER 
WHERE AC_STATE = 'P' AND SETTLE_STATUS = 2 AND STATUS_SEQ = 2 AND ORDER_RESULT IN ( 3, 4 ) 
and Sales_gubun in ('W','T','U','A','J','B','S','X') 
AND convert(char(8),SETTLE_DATE,112) between @SDAte and @EDate
union 
SELECT idx, '' as order_id
, settle_date, settle_date, pg_resultinfo, settle_price, bgm_id, order_name ,Sales_Gubun
FROM DBO.THE_EWED_MYBGM 
WHERE MY_STATE = 'P' AND SETTLE_PRICE = 500 and Sales_Gubun in ('W','T','U','A','J','B','S','X') 
AND convert(char(8),SETTLE_DATE,112) between @SDAte and @EDate) A 
ORDER BY SETTLE_DATE DESC

SELECT * FROM erp_data.dbo.view_Ecard

GO
