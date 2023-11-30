IF OBJECT_ID (N'dbo.UP_SELECT_REVIEW_EVENT_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_SELECT_REVIEW_EVENT_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UP_SELECT_REVIEW_EVENT_NEW]
/***************************************************************
작성자	:	표수현
작성일	:	2022-06-15
DESCRIPTION	:	
SPECIAL LOGIC	: 
EXEC UP_SELECT_REVIEW_EVENT_NEW @COMPANY_SEQ='5001', @SORT_DESC='ER_REGDATE', @ER_TYPE='0', @PAGE=1, @PAGESIZE=10, @TXT_CARD_SEQ=0
****************************************************************** 
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
	@COMPANY_SEQ	INT,
	@PAGE			INT=1,
	@PAGESIZE		INT=15,
	@ER_TYPE		INT=0,
	@SORT_DESC		NVARCHAR(20),
	@TXT_CARD_SEQ	INT=0	--특정카드만 조회
AS
BEGIN
	-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
	-- INTERFERING WITH SELECT STATEMENTS.
	SET NOCOUNT ON;
	
	DECLARE	@T_CNT	INT
	DECLARE	@SQL	NVARCHAR(4000)
	DECLARE	@SQL2	NVARCHAR(4000)
	
	IF @COMPANY_SEQ IS NULL OR @COMPANY_SEQ='' BEGIN
			SET @COMPANY_SEQ='1'
	END
	
	IF @TXT_CARD_SEQ = 0 BEGIN
			
			IF (@COMPANY_SEQ = '5001' OR @COMPANY_SEQ = '5003' OR @COMPANY_SEQ = '5007' OR @COMPANY_SEQ = '5006') BEGIN	--바른손

					SET @SQL2 = ' SELECT COUNT(ER_IDX) FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND ER_COMPANY_SEQ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_VIEW=0 '
					EXEC (@SQL2)
				
					SET @SQL = 'SELECT TOP '+ CONVERT(VARCHAR(50),@PAGESIZE) +' ER_IDX, ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_USERID, ER_REGDATE, ER_RECOM_CNT, ISNULL(ER_REVIEW_TITLE, '''') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '''') AS ER_REVIEW_URL , '
					SET @SQL = @SQL + ' ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_CARD_SEQ, ER_CARD_CODE, ER_USERNAME, '
					SET @SQL = @SQL + ' ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'''') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'''') AS ERA_COMMENT_CANCEL, ISNULL(ER_REVIEW_URL_A, '''') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '''') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '''') AS ER_REVIEW_URL2, '
					SET @SQL = @SQL + ' ER_EMAIL = isnull(ER_EMAIL, ''''), AGAIN_CONFIRM = isnull(AGAIN_CONFIRM, '''') '
					SET @SQL = @SQL + ' FROM S4_EVENT_REVIEW AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS AS B WITH(NOLOCK) ON A.ER_IDX = B.ERA_ER_IDX '
					SET @SQL = @SQL + ' WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND  ER_IDX NOT IN (SELECT TOP '+ CONVERT(VARCHAR(50), @PAGESIZE * (@PAGE - 1)) +' ER_IDX FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_COMPANY_SEQ ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+'AND ER_VIEW=0 AND ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' ORDER BY '+@SORT_DESC+' DESC  ) '
					SET @SQL = @SQL + ' AND ER_COMPANY_SEQ ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC'
				
					EXEC (@SQL)
				END ELSE BEGIN		--바른손 외 모든 사이트(제휴포함)

					SET @SQL2 = ' SELECT COUNT(ER_IDX) FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND ER_COMPANY_SEQ NOT IN (5001, 5003, 5007, 5006) AND ER_VIEW=0 '
					EXEC (@SQL2)
					
					SET @SQL = 'SELECT TOP '+ CONVERT(VARCHAR(50),@PAGESIZE) +' ER_IDX, ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_USERID, ER_REGDATE, ER_RECOM_CNT, ISNULL(ER_REVIEW_TITLE, '''') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '''') AS ER_REVIEW_URL , '
					SET @SQL = @SQL + ' ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_CARD_SEQ, ER_CARD_CODE, ER_USERNAME, '
					SET @SQL = @SQL + ' ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'''') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'''') AS ERA_COMMENT_CANCEL, ISNULL(ER_REVIEW_URL_A, '''') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '''') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '''') AS ER_REVIEW_URL2'
					SET @SQL = @SQL + ' ER_EMAIL = isnull(ER_EMAIL, ''''), AGAIN_CONFIRM = isnull(AGAIN_CONFIRM, '''')'
					SET @SQL = @SQL + ' FROM S4_EVENT_REVIEW AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS AS B WITH(NOLOCK) ON A.ER_IDX = B.ERA_ER_IDX '
					SET @SQL = @SQL + ' WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND  ER_IDX NOT IN (SELECT TOP '+ CONVERT(VARCHAR(50), @PAGESIZE * (@PAGE - 1)) +' ER_IDX FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_COMPANY_SEQ NOT IN (5001, 5003, 5007, 5006) AND ER_VIEW=0  ORDER BY '+@SORT_DESC+' DESC  ) '
					SET @SQL = @SQL + ' AND ER_COMPANY_SEQ  NOT IN ( 5001 , 5003 , 5007, 5006) AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC'
					
					EXEC (@SQL)
					PRINT(@SQL)
				END
		END ELSE BEGIN
			SET @SQL2 = ' SELECT COUNT(ER_IDX) FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND ER_COMPANY_SEQ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+' '
			EXEC (@SQL2)
			
			SET @SQL = 'SELECT TOP '+ CONVERT(VARCHAR(50),@PAGESIZE) +' ER_IDX, ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_USERID, ER_REGDATE, ER_RECOM_CNT, ISNULL(ER_REVIEW_TITLE, '''') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '''') AS ER_REVIEW_URL , '
			SET @SQL = @SQL + ' ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_CARD_SEQ, ER_CARD_CODE, ER_USERNAME, '
			SET @SQL = @SQL + ' ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'''') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'''') AS ERA_COMMENT_CANCEL, ISNULL(ER_REVIEW_URL_A, '''') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '''') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '''') AS ER_REVIEW_URL2, ER_EMAIL = isnull(ER_EMAIL,''''), AGAIN_CONFIRM = isnull(AGAIN_CONFIRM, '''') '
			 SET @SQL = @SQL + ' FROM S4_EVENT_REVIEW AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS AS B WITH(NOLOCK) ON A.ER_IDX = B.ERA_ER_IDX '
			SET @SQL = @SQL + ' WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND  ER_IDX NOT IN (SELECT TOP '+ CONVERT(VARCHAR(50), @PAGESIZE * (@PAGE - 1)) +' ER_IDX FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_COMPANY_SEQ ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC  ) '
			SET @SQL = @SQL + ' AND ER_COMPANY_SEQ ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC'
			
			EXEC (@SQL)
			PRINT(@SQL)
		END

END

GO
