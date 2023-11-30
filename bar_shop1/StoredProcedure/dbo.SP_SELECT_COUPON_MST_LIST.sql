IF OBJECT_ID (N'dbo.SP_SELECT_COUPON_MST_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_COUPON_MST_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_SELECT_COUPON_MST_LIST '5001|5003|5006|5007|5000', '', 20, 1

*/
CREATE PROCEDURE [dbo].[SP_SELECT_COUPON_MST_LIST]
		@P_SEARCH_COMPANY_SEQ		AS VARCHAR(200)
	,	@P_SEARCH_VALUE				AS VARCHAR(50)
	,	@P_PAGE_SIZE				AS INT
	,	@P_PAGE_NUMBER				AS INT
	
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;  

WITH	COUPON_MST_CTE AS
(
	SELECT CM.COUPON_MST_SEQ AS CouponMstSeq
		,	STUFF((
				SELECT	'/' 
					+	CASE 
								WHEN COMPANY_SEQ = 5001 THEN '바'
								WHEN COMPANY_SEQ = 5006 THEN '비'
								WHEN COMPANY_SEQ = 5007 THEN '더'
								WHEN COMPANY_SEQ = 5003 THEN '프'
								WHEN COMPANY_SEQ = 5000 THEN '몰'
								ELSE '바'
						END
				FROM	COUPON_APPLY_SITE 
				WHERE	COUPON_MST_SEQ = CM.COUPON_MST_SEQ
				FOR XML PATH('')
			), 1, 1, '') AS [Site]	
		,	CM.COUPON_NAME AS CouponName
		,	CM.DISCOUNT_VALUE AS DiscountValue
		,	CM.DISCOUNT_FIXED_RATE_TYPE AS DiscountFixedRateType
		,	ISNULL(CONVERT(VARCHAR(10), CM.COUPON_ISSUE_START_DATE, 120), '') +	' ~ ' +	ISNULL(CONVERT(VARCHAR(10), CM.COUPON_ISSUE_END_DATE, 120), '') AS IssueDateRange
		,	ISNULL(CONVERT(VARCHAR(10), CM.EXPIRY_START_DATE, 120), '') +	' ~ ' +	ISNULL(CONVERT(VARCHAR(10), CM.EXPIRY_END_DATE, 120), '') AS ExpiryDateRange
		,	CASE WHEN CM.COUPON_ISSUE_END_DATE	IS NOT NULL AND GETDATE() > CM.COUPON_ISSUE_END_DATE	THEN '종료'
				 WHEN CM.COUPON_ISSUE_START_DATE IS NOT NULL AND GETDATE() < CM.COUPON_ISSUE_START_DATE	THEN '대기'
				 ELSE '진행'
				END AS [Status]
		,	CM.REG_DATE AS RegDate
		,	CM.STATUS_ACTIVE_YN AS StatusActiveYN
		,   (SELECT COUNT(1) FROM COUPON_DETAIL With(nolock) WHERE COUPON_MST_SEQ = CM.COUPON_MST_SEQ) AS IssueCount
		,   ISNULL(CNT.DownloadCount, 0) AS DownloadCount
		,   ISNULL(CNT.UseCount,0) as UseCount
	FROM	COUPON_MST AS CM With(nolock)
	Left Join (
			Select COUPON_MST_SEQ, 
				count(*) as DownloadCount,  
				sum(case when b.ACTIVE_YN = 'N' then 1 else 0 end) AS UseCount
			from COUPON_DETAIL a With(nolock)
				join COUPON_ISSUE b With(nolock) on a.COUPON_DETAIL_SEQ = b.COUPON_DETAIL_SEQ
            Where COUPON_MST_SEQ in (Select COUPON_MST_SEQ From COUPON_APPLY_SITE With(nolock) Where COMPANY_SEQ IN (SELECT CAST(value AS INT) FROM dbo.[ufn_SplitTable] (@P_SEARCH_COMPANY_SEQ, '|')))
			Group by COUPON_MST_SEQ
	) AS CNT
		On CM.COUPON_MST_SEQ = CNT.COUPON_MST_SEQ
	WHERE   CM.COUPON_MST_SEQ in (Select COUPON_MST_SEQ From COUPON_APPLY_SITE With(nolock) Where COMPANY_SEQ IN (SELECT CAST(value AS INT) FROM dbo.[ufn_SplitTable] (@P_SEARCH_COMPANY_SEQ, '|')))
	/* 쿠폰 이름 검색 */
	AND		CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 0 THEN CM.COUPON_NAME ELSE '' END
			LIKE
			CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 0 THEN '%' + @P_SEARCH_VALUE + '%' ELSE '' END
	/* 할인 금액 검색 */
	AND		CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 1 THEN CM.DISCOUNT_VALUE ELSE 1 END
			=
			CASE WHEN ISNUMERIC(@P_SEARCH_VALUE) = 1 THEN @P_SEARCH_VALUE ELSE 1 END
)

SELECT	*
	,	(SELECT COUNT(1) FROM COUPON_MST_CTE) AS TotalListCount
FROM	COUPON_MST_CTE
ORDER BY COUPON_MST_CTE.RegDate DESC
OFFSET (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE ROWS
FETCH NEXT @P_PAGE_SIZE ROWS ONLY

END
GO
