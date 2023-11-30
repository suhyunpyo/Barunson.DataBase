IF OBJECT_ID (N'dbo.SP_SELECT_FOR_S2ADMINLIST_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_FOR_S2ADMINLIST_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_SELECT_FOR_S2ADMINLIST_NEW null, 50, 1, '', ''

*/
CREATE PROCEDURE [dbo].[SP_SELECT_FOR_S2ADMINLIST_NEW]
		@P_SEARCH_VALUE				AS VARCHAR(50)
	,	@P_SEARCH_ACCESSFLAG		AS VARCHAR(1)
	,	@P_PAGE_SIZE				AS INT
	,	@P_PAGE_NUMBER				AS INT
	,	@P_ORDER_BY_NAME			AS VARCHAR(50)
	,	@P_ORDER_BY_TYPE			AS VARCHAR(20)
	
AS
BEGIN

	SELECT	*
	FROM	(
				SELECT	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_ID'					THEN C.ID					ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_NAME'				THEN C.NAME					ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_MAIL'				THEN C.EMAIL				ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_LEVEL'				THEN C.LEVEL				ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_HPHONE'				THEN C.HPHONE				ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ACCESS_FLAG'				THEN C.ACCESSFLAG			ELSE '' END ASC
												,	CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REGDATE				ELSE '' END ASC
												,	C.SEQ ASC
													
											) AS ROW_NUM
					,	ROW_NUMBER() OVER	(
												ORDER BY 
													CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_ID'					THEN C.ID					ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_NAME'				THEN C.NAME					ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_MAIL'				THEN C.EMAIL				ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_LEVEL'				THEN C.LEVEL				ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ADMIN_HPHONE'				THEN C.HPHONE				ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'ACCESS_FLAG'				THEN C.ACCESSFLAG			ELSE '' END DESC
												,	CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'					THEN C.REGDATE				ELSE '' END DESC
												,	C.SEQ DESC
													
											) AS ROW_NUM_DESC
					,	*
				FROM	(
							SELECT	DISTINCT  seq					AS Seq
											, admin_id				AS Id
											, admin_pwd				AS Password
											, admin_name			AS Name
											, admin_mail			AS Email
											, admin_level			AS Level
											, company_seq			AS CompanySeq
											, is_reviewMail			AS IsReviewMail
											, is_errorMail			AS IsErrorMail
											, reg_date				AS RegDate
											, is_reviewSMS			AS IsReviewSMS
											, admin_hphone			AS Hphone
											, admin_photo			AS Photo
											, access_flag			AS AccessFlag
											, JOB_NAME				AS JobName	
							FROM	S2_AdminList
							WHERE	1 = 1
							AND		( 
										ISNULL(@P_SEARCH_VALUE, '') = '' 
										OR (admin_id = @P_SEARCH_VALUE)
										OR (admin_name LIKE '%' + @P_SEARCH_VALUE + '%')
									)	
							AND		(
										ISNULL(@P_SEARCH_ACCESSFLAG, '') = '' 
										OR (access_flag = @P_SEARCH_ACCESSFLAG)
									)						
						) C
			) A
	WHERE	1 = 1
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE
	AND		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE
		
	ORDER BY 
		CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC
	
END


GO
