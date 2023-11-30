IF OBJECT_ID (N'dbo.SP_SELECT_FOR_S2ADMINLIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_FOR_S2ADMINLIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_SELECT_FOR_S2ADMINLIST null, 50, 1

*/
CREATE PROCEDURE [dbo].[SP_SELECT_FOR_S2ADMINLIST]
		@P_SEARCH_VALUE				AS VARCHAR(50)
	,	@P_PAGE_SIZE				AS INT
	,	@P_PAGE_NUMBER				AS INT

	
AS
BEGIN


DECLARE @TOTALCNT AS INT

	SELECT	@TOTALCNT =  COUNT(*) 
	FROM	S2_AdminList
	WHERE	1 = 1
	AND		( 
				ISNULL(@P_SEARCH_VALUE, '') = '' 
				OR (admin_id = @P_SEARCH_VALUE)
				OR (admin_name LIKE '%' + @P_SEARCH_VALUE + '%')
			)
	
;WITH ADMINLIST_A AS
(

	SELECT		seq						AS Seq
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

	ORDER BY reg_date DESC

	OFFSET (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE ROWS
	FETCH NEXT @P_PAGE_SIZE ROWS ONLY
)

	SELECT A. * , @TOTALCNT AS TotalCnt
	FROM   ADMINLIST_A A
	WHERE 1 = 1

END
GO
