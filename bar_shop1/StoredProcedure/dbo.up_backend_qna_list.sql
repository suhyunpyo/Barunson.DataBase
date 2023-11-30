IF OBJECT_ID (N'dbo.up_backend_qna_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_backend_qna_list
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
	작성정보   : [2003:07:26    14:10]  JJH: 
	관련페이지 : shopadm/custom/SQM/cust_qa_mng.asp
	내용	   :Q&A 조회 결과
	
	수정정보   : 
*/
CREATE Procedure [dbo].[up_backend_qna_list]
	@S_DAY			VARCHAR(20)
,	@E_DAY			VARCHAR(20)
,	@COMPANY_SEQ		varchar(10)
,	@STAT			varchar(10)
,	@LINE_COUNT		varchar(10)
as
	DECLARE	@SQL	VARCHAR(8000)
	SET 	@E_DAY = @E_DAY + ' 23:59:59'
	IF 	@LINE_COUNT = ''  	SET @LINE_COUNT = '1000'
	
	SET @SQL = '	SELECT TOP ' + @LINE_COUNT + ' QA.* 
				, (SELECT CP.COMPANY_NAME  FROM dbo.company CP WHERE CP.COMPANY_SEQ = QA.COMPANY_SEQ) AS COMPANY_NAME
				FROM dbo.sqm_qa_tbl QA 
				WHERE 	QA.REG_DT BETWEEN ''' + @S_DAY + ''' AND ''' + @E_DAY + ''' 
				AND	QA.A_STAT = ''' + @STAT + ''' '
IF	@COMPANY_SEQ != '' 	SET @SQL = @SQL + ' 	AND	QA.COMPANY_SEQ = ' + @COMPANY_SEQ
	EXEC(@SQL)

GO
