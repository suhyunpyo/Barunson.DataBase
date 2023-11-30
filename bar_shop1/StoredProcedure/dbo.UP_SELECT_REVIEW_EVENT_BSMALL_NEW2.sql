IF OBJECT_ID (N'dbo.UP_SELECT_REVIEW_EVENT_BSMALL_NEW2', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_SELECT_REVIEW_EVENT_BSMALL_NEW2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=============================================
-- AUTHOR:		<AUTHOR,,NAME>
-- CREATE DATE: <CREATE DATE,,>
-- DESCRIPTION:	<DESCRIPTION,,>34216^BH3205^BH3205_130.jpg

--[UP_SELECT_REVIEW_EVENT] 5006,1,15,0,'ER_REGDATE',''
--SELECT TOP 100 * FROM S4_EVENT_REVIEW ORDER BY ER_REGDATE
-- 바른손몰, 프페제휴 포함 
--EXEC UP_SELECT_REVIEW_EVENT_BSMALL_NEW2 @COMPANY_SEQ='5000', @SORT_DESC='ER_REGDATE', @ER_TYPE='0', @PAGE=1, @PAGESIZE=10, @TXT_CARD_SEQ=34216

=================================================*/
CREATE PROCEDURE [dbo].[UP_SELECT_REVIEW_EVENT_BSMALL_NEW2]
	-- ADD THE PARAMETERS FOR THE STORED PROCEDURE HERE
	@COMPANY_SEQ		INT,
	@PAGE				INT=1,
	@PAGESIZE			INT=15,
	@ER_TYPE			INT=0,
	@SORT_DESC			NVARCHAR(20),
	@TXT_CARD_SEQ		INT=0	--특정카드만 조회
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
		
		BEGIN
			SET @SQL2 = ' SELECT COUNT(ER_IDX) FROM S4_EVENT_REVIEW A WITH(NOLOCK) , COMPANY C WHERE A.ER_COMPANY_SEQ = C.COMPANY_SEQ  AND ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND SALES_GUBUN IN (''B'',''C'',''H'') AND ER_VIEW=0 '
			--SET @SQL2 = @SQL2 + ' AND ER_IDX <> 168774 '
			EXEC (@SQL2)
			
			SET @SQL = 'SELECT TOP '+ CONVERT(VARCHAR(50),@PAGESIZE) +' ER_IDX, ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_USERID, ER_REGDATE, ER_RECOM_CNT, ISNULL(ER_REVIEW_TITLE, '''') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '''') AS ER_REVIEW_URL , '
			SET @SQL = @SQL + ' ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_USERNAME, '
			SET @SQL = @SQL + ' ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'''') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'''') AS ERA_COMMENT_CANCEL, ISNULL(ER_REVIEW_URL_A, '''') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '''') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '''') AS ER_REVIEW_URL2,' 
			SET @SQL = @SQL + ' ER_COMMENT = ISNULL(ER_COMMENT,ER_REVIEW_URL), DEVICE_TYPE, ER_ISPHOTO,'
			SET @SQL = @SQL + ' ER_CARD_SEQ =	CASE WHEN ISNULL(ER_CARD_SEQ,0) = 0 '
			SET @SQL = @SQL + ' 				THEN  ( '
			SET @SQL = @SQL + ' 						SELECT TOP 1 A.CARD_SEQ FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + ' 						WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ   '
			SET @SQL = @SQL + '						  ) '
			SET @SQL = @SQL + ' 				ELSE ER_CARD_SEQ '
			SET @SQL = @SQL + ' 				END , '
			SET @SQL = @SQL + ' ER_CARD_CODE =	CASE WHEN ER_CARD_CODE = ''0000''  '
			SET @SQL = @SQL + '								THEN  ( '
			SET @SQL = @SQL + '										SELECT TOP 1 B.CARD_CODE FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + '										WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ   '
			SET @SQL = @SQL + '									)  '
			SET @SQL = @SQL + '								ELSE ER_CARD_CODE '
			SET @SQL = @SQL + '								END , '
			SET @SQL = @SQL + '				ER_CARDIMAGE = ISNULL(  '
			SET @SQL = @SQL + '										(  '
			SET @SQL = @SQL + '										 SELECT  B.CARD_IMAGE  FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + '										 WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ  AND B.CARD_SEQ = ER_CARD_SEQ '
			SET @SQL = @SQL + '										 ), '
			SET @SQL = @SQL + '										 ( '
			SET @SQL = @SQL + '										  SELECT TOP 1 B.CARD_IMAGE FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + '										  WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ   '
			SET @SQL = @SQL + '										)  '
			SET @SQL = @SQL + '									), '
			SET @SQL = @SQL + ' CARDCODE_CARDIMAGE = ( '
			SET @SQL = @SQL + ' SELECT TOP 1 CONCAT(A.CARD_SEQ ,''^'' , B.CARD_CODE , ''^'' , B.CARD_IMAGE ) FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ '
			SET @SQL = @SQL + ' WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ  '
			SET @SQL = @SQL + ' ), '
			SET @SQL = @SQL + '	FIRST_UPLOAD_PHOTO = ( SELECT TOP 1 UPIMG_NAME  FROM S4_EVENT_REVIEW_PHOTO WHERE SEQ =  A.ER_IDX ORDER BY 1 ) '
			SET @SQL = @SQL + ' FROM S4_EVENT_REVIEW AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS AS B WITH(NOLOCK) ON A.ER_IDX = B.ERA_ER_IDX '
			SET @SQL = @SQL + ' JOIN COMPANY AS C ON A.ER_COMPANY_SEQ = C.COMPANY_SEQ '
			SET @SQL = @SQL + ' WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND  ER_IDX NOT IN (SELECT TOP '+ CONVERT(VARCHAR(50), @PAGESIZE * (@PAGE - 1)) +' ER_IDX FROM S4_EVENT_REVIEW A WITH(NOLOCK) , COMPANY C  WHERE A.ER_COMPANY_SEQ = C.COMPANY_SEQ AND C.SALES_GUBUN  IN (''B'',''C'',''H'') AND ER_VIEW=0  ORDER BY '+@SORT_DESC+' DESC  ) '
			SET @SQL = @SQL + ' AND C.SALES_GUBUN IN (''B'',''C'',''H'') AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC'
			
			--SET @SQL = @SQL + ' AND ER_IDX <> 168774 ORDER BY '+@SORT_DESC+' DESC' 

			EXEC (@SQL)
			PRINT(@SQL)
		END
		END
	ELSE
		BEGIN
			SET @SQL2 = ' SELECT COUNT(ER_IDX) FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ) +  'AND ER_VIEW=0 ' 
			--SET @SQL2 = ' SELECT COUNT(ER_IDX) FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND ER_COMPANY_SEQ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ) +  'AND ER_VIEW=0 ' 
			EXEC (@SQL2)
			
			SET @SQL = 'SELECT TOP '+ CONVERT(VARCHAR(50),@PAGESIZE) +' ER_IDX, ER_COMPANY_SEQ, ER_ORDER_SEQ, ER_TYPE, ER_USERID, ER_REGDATE, ER_RECOM_CNT, ISNULL(ER_REVIEW_TITLE, '''') AS ER_REVIEW_TITLE, ISNULL(ER_REVIEW_URL, '''') AS ER_REVIEW_URL , '
			SET @SQL = @SQL + ' ER_REVIEW_STAR, ER_STATUS, ER_VIEW, ER_REVIEW_CONTENT, ER_USERNAME, '
			SET @SQL = @SQL + ' ERA_STATUS, ERA_COUPON_STATUS, ISNULL(ERA_COMMENT,'''') AS ERA_COMMENT, ERA_COUPON_CODE, ISNULL(ERA_COMMENT_CANCEL,'''') AS ERA_COMMENT_CANCEL, ISNULL(ER_REVIEW_URL_A, '''') AS ER_REVIEW_URL_A, ISNULL(ER_REVIEW_URL_B, '''') AS ER_REVIEW_URL_B, ISNULL(ER_REVIEW_URL2, '''') AS ER_REVIEW_URL2 ,  ER_COMMENT = ISNULL(ER_COMMENT,ER_REVIEW_URL), DEVICE_TYPE, ER_ISPHOTO, '
			SET @SQL = @SQL + ' ER_CARD_SEQ =	CASE WHEN ISNULL(ER_CARD_SEQ,0) = 0 '
			SET @SQL = @SQL + ' 				THEN  ( '
			SET @SQL = @SQL + ' 						SELECT TOP 1 A.CARD_SEQ FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + ' 						WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ   '
			SET @SQL = @SQL + '						  ) '
			SET @SQL = @SQL + ' 				ELSE ER_CARD_SEQ '
			SET @SQL = @SQL + ' 				END , '
			SET @SQL = @SQL + ' ER_CARD_CODE =	CASE WHEN ER_CARD_CODE = ''0000''  '
			SET @SQL = @SQL + '								THEN  ( '
			SET @SQL = @SQL + '										SELECT TOP 1 B.CARD_CODE FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + '										WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ   '
			SET @SQL = @SQL + '									)  '
			SET @SQL = @SQL + '								ELSE ER_CARD_CODE '
			SET @SQL = @SQL + '								END , '
			SET @SQL = @SQL + ' ER_CARDIMAGE = ISNULL(  '
			SET @SQL = @SQL + '										(  '
			SET @SQL = @SQL + '										 SELECT  B.CARD_IMAGE  FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + '										 WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ  AND B.CARD_SEQ = ER_CARD_SEQ '
			SET @SQL = @SQL + '										 ), '
			SET @SQL = @SQL + '										 ( '
			SET @SQL = @SQL + '										  SELECT TOP 1 B.CARD_IMAGE FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ  '
			SET @SQL = @SQL + '										  WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ   '
			SET @SQL = @SQL + '										)  '
			SET @SQL = @SQL + '									), '
			SET @SQL = @SQL + ' CARDCODE_CARDIMAGE = ( '
			SET @SQL = @SQL + ' SELECT TOP 1 CONCAT(A.CARD_SEQ ,''^'' , B.CARD_CODE , ''^'' , B.CARD_IMAGE ) FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ '
			SET @SQL = @SQL + ' WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ  '
			SET @SQL = @SQL + ' ) ,'
			SET @SQL = @SQL + '	FIRST_UPLOAD_PHOTO = ( SELECT TOP 1 UPIMG_NAME  FROM S4_EVENT_REVIEW_PHOTO WHERE SEQ =  A.ER_IDX ORDER BY 1 ) '
			--SET @SQL = @SQL + ' CARDSEQ = ( '
			--SET @SQL = @SQL + ' SELECT TOP 1 CARD_SEQ FROM CUSTOM_SAMPLE_ORDER_ITEM A LEFT OUTER JOIN S2_CARD B ON A.CARD_SEQ = B.CARD_SEQ '
			--SET @SQL = @SQL + ' WHERE A.SAMPLE_ORDER_SEQ=  ER_ORDER_SEQ  '
			--SET @SQL = @SQL + ' ) '
			SET @SQL = @SQL + ' FROM S4_EVENT_REVIEW AS A WITH(NOLOCK) LEFT OUTER JOIN  S4_EVENT_REVIEW_STATUS AS B WITH(NOLOCK) ON A.ER_IDX = B.ERA_ER_IDX '
						SET @SQL = @SQL + ' WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND  ER_IDX NOT IN (SELECT TOP '+ CONVERT(VARCHAR(50), @PAGESIZE * (@PAGE - 1)) +' ER_IDX FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC  ) '
			--SET @SQL = @SQL + ' WHERE ER_TYPE='+CONVERT(VARCHAR(2),@ER_TYPE)+' AND  ER_IDX NOT IN (SELECT TOP '+ CONVERT(VARCHAR(50), @PAGESIZE * (@PAGE - 1)) +' ER_IDX FROM S4_EVENT_REVIEW WITH(NOLOCK) WHERE ER_COMPANY_SEQ ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC  ) '
			SET @SQL = @SQL + ' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC'
			--SET @SQL = @SQL + ' AND ER_COMPANY_SEQ ='+CONVERT(VARCHAR(50),@COMPANY_SEQ)+' AND ER_CARD_SEQ='+CONVERT(VARCHAR(10),@TXT_CARD_SEQ)+'  AND ER_VIEW=0 ORDER BY '+@SORT_DESC+' DESC'
			
			EXEC (@SQL)
			select @SQL
			PRINT(@SQL)
		END

END



GO