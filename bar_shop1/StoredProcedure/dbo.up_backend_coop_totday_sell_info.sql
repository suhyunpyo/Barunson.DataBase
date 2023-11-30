IF OBJECT_ID (N'dbo.up_backend_coop_totday_sell_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_totday_sell_info
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:08:03    14:29]  JJH: 
	관련페이지 : coop_admin/first.asp
	내용	   : 제휴사당일 판매정보 
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_totday_sell_info]
	@COMPANY_SEQ		int
as
	DECLARE	@TODAY		DATETIME
	SET	@TODAY	= 	CONVERT(VARCHAR(8),GETDATE(),112)
	SELECT  COUNT(*) AS ORDER_COUNT
		,ISNULL(SUM(ORDER_PRICE),0) AS ORDER_PRICE
	FROM dbo.CUSTOM_ORDER_MASTER  WHERE ORDER_DATE > @TODAY

GO
