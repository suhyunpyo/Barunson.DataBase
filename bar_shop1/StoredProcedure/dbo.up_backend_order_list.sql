IF OBJECT_ID (N'dbo.up_backend_order_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_order_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:08:01    13:13]  JJH: 
	관련페이지 : /coop_admin/C_ORDER/order_list.asp 
	내용	   : 제휴사를 통해서 주문된내용
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_order_list]
	@COMPANY_SEQ		varchar(20)
	,@SRC_SETTLE_METHOD	varchar(20)
	,@SRC_STATUS_SEQ	varchar(20)
	,@S_DAY		varchar(20)
	,@E_DAY			varchar(20)
	,@SRC_ORDER_SEQ	varchar(20)
	,@SRC_ORDER_NAME	varchar(20)
as
	DECLARE 	@SQL		VARCHAR(8000)
	SET @E_DAY = @E_DAY + ' 23:59:59'
SET @SQL = '
	SELECT COM.ORDER_SEQ
		,COM.ORDER_NAME 
		,COM.CARD_SEQ
		,COM.STATUS_SEQ
		,COM.ORDER_COUNT
		,COM.SETTLE_PRICE
		,COM.ORDER_PRICE
		,COM.SETTLE_METHOD
		,ISNULL(COM.ORDER_TOTAL_PRICE,0) as ORDER_TOTAL_PRICE
		,CD.CARD_CATEGORY_SEQ
		 FROM dbo.custom_order_master COM ,dbo.card CD  WHERE
							COM.CARD_SEQ = CD.CARD_SEQ
						AND	COM.COMPANY_SEQ  =' +@COMPANY_SEQ   + '
						AND	COM.ORDER_DATE BETWEEN ''' +  @S_DAY + ''' AND ''' + @E_DAY + ''' '
IF @SRC_SETTLE_METHOD !=''	SET @SQL = @SQL + '	AND	COM.SETTLE_METHOD = ' + @SRC_SETTLE_METHOD
IF @SRC_STATUS_SEQ	 !=''	SET @SQL = @SQL + '	AND	COM.STATUS_SEQ = ' + @SRC_STATUS_SEQ
IF @SRC_ORDER_SEQ 	!=''	SET @SQL = @SQL + '	AND	COM.ORDER_SEQ = ' + @SRC_ORDER_SEQ
IF @SRC_ORDER_NAME 	!=''	SET @SQL = @SQL + '	AND	COM.ORDER_NAME LIKE ''%' + @SRC_ORDER_NAME + '%'''
EXEC(@SQL)

GO
