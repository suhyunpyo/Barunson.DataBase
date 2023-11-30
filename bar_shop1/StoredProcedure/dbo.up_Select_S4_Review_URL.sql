IF OBJECT_ID (N'dbo.up_Select_S4_Review_URL', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_S4_Review_URL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		시스템지원팀, yoon
-- Create date: 2015-12-07
-- Description:	이벤트 참여 리스트, S4_Review_URL

-- EXEC up_Select_S4_Review_URL 2, 1, 100, 0
-- EXEC up_Select_S4_Review_URL 2, 1, 100, 0, 'Y'
-- EXEC up_Select_S4_Review_URL 2, 1, 100, 0, 'N'
-- =============================================
/*
	EXEC up_Select_S4_Review_URL 84, 1, 10
	EXEC up_Select_S4_Review_URL 104, 1, 10, 5001
*/

CREATE proc [dbo].[up_Select_S4_Review_URL]

		@REVIEW_GROUP			INT
	,	@PAGE					SMALLINT
	,	@PAGE_SIZE			SMALLINT
	,	@COMPANY_SEQ		INT = 0
	,	@VIEW_FLAG			VARCHAR = NULL
AS

SET NOCOUNT ON;

DECLARE @STARTROWNUM SMALLINT, @ENDROWNUM SMALLINT, @TOTALCNT INT

SET @STARTROWNUM = (@PAGE - 1) * @PAGE_SIZE + 1
SET @ENDROWNUM   = @PAGE * @PAGE_SIZE

SELECT	@TOTALCNT = COUNT(Review_Id)
FROM	S4_Review_URL S2ER
LEFT JOIN VIEW_USRINFO VU ON VU.UID = S2ER.User_Id AND (VU.COMPANY_SEQ IS NULL OR VU.COMPANY_SEQ = S2ER.COMPANY_SEQ)
WHERE	Review_Group = @REVIEW_GROUP
--AND		(CASE WHEN @VIEW_FLAG IS NOT NULL THEN View_Flag ELSE 'Y' END) = (CASE WHEN @VIEW_FLAG IS NOT NULL THEN @VIEW_FLAG ELSE 'Y' END) 
AND		(ISNULL(@VIEW_FLAG, '') = '' OR View_Flag = @VIEW_FLAG)
AND		CASE WHEN @COMPANY_SEQ = 0 THEN 0 ELSE S2ER.COMPANY_SEQ END = @COMPANY_SEQ
AND		CASE WHEN @COMPANY_SEQ = 0 THEN '' ELSE VU.TBL_NAME END 
		=
		CASE	
				WHEN @COMPANY_SEQ = 0 THEN '' 
				ELSE 
						CASE	
								WHEN @COMPANY_SEQ = 5006 THEN 's2_userinfo_bhands'
								WHEN @COMPANY_SEQ = 5007 THEN 's2_userinfo_thecard'
								ELSE 's2_userinfo'
						END

		END 

SELECT	@TOTALCNT AS TOTALCNT
	,	@TOTALCNT - ROWNUM + 1 AS ROWINDEX
	,	*
FROM 
(
	SELECT	ROW_NUMBER() OVER(ORDER BY S2ER.Review_Date DESC) AS ROWNUM
		,	S2ER.Review_Id
		,	S2ER.Review_Url
		,	S2ER.Review_Url2
		,	S2ER.User_Id
		,	CONVERT(VARCHAR(10), S2ER.Review_Date, 102) AS REG_DATE
		,	S2ER.User_Name
		,	S2ER.View_Flag
		,   Evaluate_Tag
		,   Evaluate_Content
		,	Evaluate_Comment
		,	(SELECT TOP 1 order_seq FROM custom_order where member_id = S2ER.user_id and up_order_seq is null and order_type <> '2' and settle_status='2' order by order_seq asc) as ORDER_SEQ
	FROM	S4_Review_URL S2ER
	LEFT OUTER JOIN VIEW_USRINFO VU
	ON VU.UID = S2ER.User_Id AND (VU.COMPANY_SEQ IS NULL OR VU.COMPANY_SEQ = S2ER.COMPANY_SEQ)
	WHERE	S2ER.Review_Group = @REVIEW_GROUP
	--AND		(CASE WHEN @VIEW_FLAG IS NOT NULL THEN View_Flag ELSE 'Y' END) = (CASE WHEN @VIEW_FLAG IS NOT NULL THEN @VIEW_FLAG ELSE 'Y' END) 
	AND		(ISNULL(@VIEW_FLAG, '') = '' OR View_Flag = @VIEW_FLAG)
	AND		CASE WHEN @COMPANY_SEQ = 0 THEN 0 ELSE S2ER.COMPANY_SEQ END = @COMPANY_SEQ
	AND		CASE WHEN @COMPANY_SEQ = 0 THEN '' ELSE VU.TBL_NAME END 
			=
			CASE	
					WHEN @COMPANY_SEQ = 0 THEN '' 
					ELSE 
							CASE	
									WHEN @COMPANY_SEQ = 5006 THEN 's2_userinfo_bhands'
									WHEN @COMPANY_SEQ = 5007 THEN 's2_userinfo_thecard'
									ELSE 's2_userinfo'
							END

			END 

) AS T
WHERE	T.ROWNUM BETWEEN @STARTROWNUM AND @ENDROWNUM
GO
