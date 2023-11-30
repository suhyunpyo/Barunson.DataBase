IF OBJECT_ID (N'dbo.SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****************************************************************************************************************
-- SP Name       : SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST_EVENT
-- Author        : 박혜림
-- Create date   : 2022-09-16
-- Description   : LG 멤버십 리스트 이벤트 통계
-- Update History: 
-- Comment       : SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST 참고
--
--
-- EXEC SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST_EVENT '2022-09-01', '2022-09-30','SD'
--
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST_EVENT]
	@P_START_DATE VARCHAR(10),
	@P_END_DATE   VARCHAR(10),
	@P_SITE_DIV   VARCHAR(2)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

BEGIN

	DECLARE @V_SRC_SDATE VARCHAR(10) = @P_START_DATE
	DECLARE @V_SRC_EDATE VARCHAR(10) = @P_END_DATE

	IF @P_SITE_DIV = 'SB' OR @P_SITE_DIV = 'AA'
	BEGIN

		SELECT RegDate
		     , SiteNm
			 , TotalCnt
		  FROM (
				SELECT CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계'
					   ELSE CONVERT(VARCHAR(10), DATEADD(DAY, 0, REG_DATE_S), 120) END AS RegDate
					 , CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계' 
							ELSE (CASE WHEN GROUPING(SiteNm) = 1 THEN '소계' ELSE SiteNm END)
					   END AS SiteNm
					 , COUNT([uid]) AS TotalCnt
				  FROM (
						SELECT [uid]
							 , sales_gubun
							 , CASE WHEN sales_gubun = 'SB' THEN '바른손카드'
									WHEN sales_gubun = 'B' THEN '바른손몰'
									WHEN sales_gubun = 'ST' THEN '더카드'
									WHEN sales_gubun = 'SS' THEN '프리미어페이퍼'
							   ELSE '' END AS SiteNm
							 , CONVERT(CHAR(10), created_tmstmp, 23) AS REG_DATE_S
							 , jehu_gubun
						  FROM EVTPAGE_MARKETING_AGREEMENT_LOG WITH(NOLOCK)
						 WHERE created_tmstmp < DATEADD(DAY, 0, CAST(CONVERT(VARCHAR, getdate(),23) AS DATETIME))
						   AND created_tmstmp >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
						   AND created_tmstmp < DATEADD(DAY, 1, CAST(CONVERT(VARCHAR, @V_SRC_EDATE, 23) AS DATETIME))
						   AND jehu_gubun = 'LG'
					) AS T
					GROUP BY ROLLUP(REG_DATE_S, SiteNm)
				) AS T2
				WHERE SiteNm <> '소계' 

	END
	ELSE	--디얼디어
	BEGIN

		SELECT RegDate
		     , SiteNm
			 , TotalCnt
		  FROM (
				SELECT CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계'
					   ELSE CONVERT(VARCHAR(10), DATEADD(DAY, 0, REG_DATE_S), 120) END AS RegDate
					 , CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계' 
							ELSE (CASE WHEN GROUPING(SiteNm) = 1 THEN '소계' ELSE SiteNm END)
					   END AS SiteNm
					 , COUNT([uid]) AS TotalCnt
				  FROM (
						SELECT T2.uid
							 , 'SD' AS sales_gubun
							 , '디얼디어' AS SiteNm
							 , CONVERT(CHAR(10), T2.agree_date, 23) AS REG_DATE_S
							 , T2.agreement_type
						  FROM S2_UserInfo_Deardeer AS T1 WITH(NOLOCK)
						 INNER JOIN S2_UserInfo_Deardeer_Marketing AS T2 WITH(NOLOCK) ON (T1.uid = T2.uid
						                                                              AND T2.agreement_step = 'E'
																					  AND T2.agreement_type = 'LG'
																					  AND T2.chk_agreement = 'Y'
																					  AND T2.agree_date < DATEADD(DAY, 0, CAST(CONVERT(VARCHAR, getdate(),23) AS DATETIME))
																					  AND T2.agree_date >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
																					  AND T2.agree_date < DATEADD(DAY, 1, CAST(CONVERT(VARCHAR, @V_SRC_EDATE, 23) AS DATETIME))
																					  )
					) AS T
					GROUP BY ROLLUP(REG_DATE_S, SiteNm)
				) AS T2
				WHERE SiteNm <> '소계' 

	END
END
GO
