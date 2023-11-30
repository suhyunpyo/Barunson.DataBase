IF OBJECT_ID (N'dbo.up_backend_coop_settle_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_coop_settle_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:31    23:01]  JJH: 
	관련페이지 : /shopadm/custom/settle/coop_settle_info.asp
	내용	   : 제휴사 결제 정보보기
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_coop_settle_list]
	@SDAY			varchar(10)
,	@EDAY			varchar(10)
,	@COMPANY_SEQ		varchar(10)
,	@COMM_STAT		varchar(10)
as
	DECLARE	@SQL		varchar(2000)
SET 	@SQL = '
	SELECT CPY.COMPANY_NAME
		,CST.IID
		,CST.COMPANY_SEQ
		,CST.SETTLE_DT
		,CST.TOTAL_SELL_PRICE
		,CST.COMM_PRICE
		,CST.SETTLE_PRICE
		,CST.COMM_STAT
		,CST.COMM_STAT_S2_DT
		,CST.COMM_STAT_S3_DT
		,CST.COMM_STAT_S4_DT
		,CST.KIND
		,CST.REG_DT
		FROM dbo.coop_settle_tbl CST, dbo.company CPY
		WHERE 	CST.COMPANY_SEQ = CPY.COMPANY_SEQ 
		AND	CST.SETTLE_DT BETWEEN ''' + @SDAY + ''' AND ''' + @EDAY + '''
		AND	CST.ONOFF = ''Y'' '
IF @COMM_STAT = 'S1'	SET @SQL = @SQL + ' AND CST.COMM_STAT IN (''S1'',''S10'')'		-- 결제 대기일경우  결제대기 + 이전에 결제거부한건
IF @COMM_STAT = 'S5'	SET @SQL = @SQL + ' AND CST.COMM_STAT = ''S5'''			-- 결제 대기일경우  결제대기 + 이전에 결제거부한건
		SET @SQL = @SQL + ' ORDER BY CST.SETTLE_DT , CST.KIND'
EXEC(@SQL)

GO
