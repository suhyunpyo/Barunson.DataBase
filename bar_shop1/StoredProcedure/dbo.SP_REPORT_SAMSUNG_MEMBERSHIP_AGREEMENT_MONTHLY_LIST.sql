IF OBJECT_ID (N'dbo.SP_REPORT_SAMSUNG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_SAMSUNG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_REPORT_SAMSUNG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2017-01-01', '2017-05-01', 'SB',  'STATS'
EXEC SP_REPORT_SAMSUNG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2017-01-01', '2017-05-01', 'SB',  'LIST'

*/

CREATE PROCEDURE [dbo].[SP_REPORT_SAMSUNG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST]
		@P_START_DATE		AS VARCHAR(10)
	,	@P_END_DATE			AS VARCHAR(10)
	,	@P_SITE_DIV			AS VARCHAR(2)
	,	@P_LIST_TYPE		AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @V_SRC_SDATE VARCHAR(10) = @P_START_DATE
	DECLARE @V_SRC_EDATE VARCHAR(10) = @P_END_DATE

	IF @P_LIST_TYPE = 'STATS'
		BEGIN

			SELECT	CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계' ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) END RegDate
				,	COUNT(CONNINFO) Cnt --예식일없는고객까지 전부"
				,	COUNT(SMEMBERSHIP_LEAVE_DATE) SamsungMembershipLeaveDate --정보삭제요청고객"
				,	SUM(WEDD_YEAR) WeddingYear --예식일 있는회원만"
				,	(SUM(WEDD_YEAR) - COUNT(SMEMBERSHIP_LEAVE_DATE)) TotalCnt

			FROM	(
						SELECT	CASE WHEN SMEMBERSHIP_REG_DATE <> MOD_DATE THEN 'Y' ELSE 'N' END FF
							,	SUBSTRING(CONVERT(VARCHAR, SMEMBERSHIP_REG_DATE  ,  23) ,1,10) SMEMBERSHIP_REG_DATE
							,	MOD_DATE
							,	DATEDIFF(DAY, SMEMBERSHIP_REG_DATE, MOD_DATE) SS
							,	CONNINFO
							,	ROW_NUMBER()OVER(PARTITION BY CONNINFO ORDER BY CONNINFO) RM
							,	SMEMBERSHIP_LEAVE_DATE
							,	CASE WHEN WEDD_YEAR <> '' THEN 1 ELSE 0 END WEDD_YEAR
							,	CONVERT(VARCHAR ,REG_DATE_S   ,  23) REG_DATE_S
						FROM	SAMSUNG_DAILY_INFO A
						WHERE	A.REG_DATE_S >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@V_SRC_SDATE),120)
						AND		A.REG_DATE_S < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
						AND		REG_DATE >= '2013-07-01'
						AND (
								(@P_SITE_DIV = 'SD') AND (A.site_div = 'SD')
								OR (@P_SITE_DIV = 'SB') AND (A.site_div <> 'SD')
								OR (@P_SITE_DIV = 'AA') AND (A.site_div <> 'AA')
						)
						AND		NOT EXISTS	(
												SELECT	CONNINFO 
												FROM	DBO.SAMSUNG_DAILY_INFO
												WHERE	CONNINFO = A.CONNINFO
												AND		REG_DATE_S < CONVERT(VARCHAR(10),DATEADD(DAY,1,@V_SRC_SDATE),120)
												AND		WEDD_YEAR <> ''
												AND		REG_DATE >= '2013-07-01'
											)
					) AA
	
			WHERE RM = 1

			GROUP BY REG_DATE_S 
	
			WITH ROLLUP

		END

	ELSE
		BEGIN

			SELECT	CONNINFO AS ConnInfo
				,	LIST_GB AS ListGB

			FROM	(
						SELECT   CONNINFO
							,	ROW_NUMBER() OVER(PARTITION BY CONNINFO ORDER BY CONNINFO) RM
							,	SMEMBERSHIP_LEAVE_DATE
							,	WEDD_YEAR WEDD_YEAR_AA
							,	CASE WHEN WEDD_YEAR <> '' THEN 1 ELSE 0 END WEDD_YEAR
							,	CASE 
									WHEN WEDD_YEAR <> '' THEN 'Y'
									WHEN ((WEDD_YEAR = '' OR WEDD_YEAR IS NULL) AND SMEMBERSHIP_LEAVE_DATE IS NOT NULL)  THEN 'E'
									ELSE 'N' 
								END LIST_GB
						FROM	SAMSUNG_DAILY_INFO A
						WHERE	A.REG_DATE_S >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@V_SRC_SDATE),120)
						AND		A.REG_DATE_S < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
						AND		REG_DATE >= '2013-07-01'
						AND (
								(@P_SITE_DIV = 'SD') AND (A.site_div = 'SD')
								OR (@P_SITE_DIV = 'SB') AND (A.site_div <> 'SD')
								OR (@P_SITE_DIV = 'AA') AND (A.site_div <> 'AA')
						)
						AND		NOT EXISTS	(
												SELECT	CONNINFO 
												FROM	DBO.SAMSUNG_DAILY_INFO
												WHERE	CONNINFO = A.CONNINFO
												AND		REG_DATE_S < CONVERT(VARCHAR(10),DATEADD(DAY,1,@V_SRC_SDATE),120)
												AND		WEDD_YEAR <> ''
												AND		REG_DATE >= '2013-07-01'
											)
				  ) AA

			WHERE	RM = 1
			AND		LIST_GB IN( 'Y')
			
			ORDER BY WEDD_YEAR_AA

		END

END
GO