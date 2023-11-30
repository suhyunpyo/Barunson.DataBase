IF OBJECT_ID (N'dbo.SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2020-08-01', '2020-08-31','SB', 'STATS'
EXEC SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2020-08-01', '2020-08-31','SB', 'LIST'

*/

CREATE PROCEDURE [dbo].[SP_REPORT_LG_MEMBERSHIP_AGREEMENT_MONTHLY_LIST]
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

			SELECT	CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계' ELSE CONVERT(VARCHAR(10), DATEADD(DAY, 0, REG_DATE_S), 120) END RegDate
				,	COUNT(P_SSN_CI) Cnt --예식일없는고객까지 전부"
				,	COUNT(lgmembership_leave_date) LgMembershipLeaveDate --정보삭제요청고객"
				,	SUM(WEDD_YEAR) WeddingYear --예식일 있는회원만"
				,	(SUM(WEDD_YEAR) - COUNT(lgmembership_leave_date)) TotalCnt
			FROM	(
				SELECT	
					SUBSTRING(CONVERT(VARCHAR, A.reg_date ,  23) ,1,10) lgmembership_reg_date
					, P_SSN_CI
					, ROW_NUMBER()OVER(PARTITION BY P_SSN_CI ORDER BY P_SSN_CI) RM
					, A.cancel_date lgmembership_leave_date
					, CASE WHEN A.P_WEDDING_DATE <> '' THEN 1 ELSE 0 END WEDD_YEAR
					, CONVERT(VARCHAR ,A.reg_date   ,  23) REG_DATE_S
				FROM
					S2_Userinfo_HiPlaza_Log A
				WHERE
				    A.reg_date < DATEADD(DAY ,  0 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
					AND A.reg_date >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
					AND A.reg_date < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
					AND (@P_SITE_DIV <> 'AA' OR P_RQST_FLAG <> '')
					AND (@P_SITE_DIV <> 'SD' OR P_RQST_FLAG = 'DEAR')
					AND (@P_SITE_DIV <> 'SB' OR P_RQST_FLAG = 'BSON')
					AND NOT EXISTS (
										SELECT 
											P_SSN_CI
										FROM
											S2_Userinfo_HiPlaza_Log
										WHERE	
											P_SSN_CI = A.P_SSN_CI
											AND reg_date < CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
											AND P_WEDDING_DATE <> ''
									)
					) AA
			WHERE RM = 1
			GROUP BY REG_DATE_S 
			WITH ROLLUP					

		END

	ELSE
		BEGIN

            SELECT	P_SSN_CI AS ConnInfo
                ,	LIST_GB AS ListGB
            FROM	(
                    SELECT 
                        A.P_SSN_CI
                        , ROW_NUMBER() OVER(PARTITION BY P_SSN_CI ORDER BY P_SSN_CI) RM
                        , A.cancel_date lgmembership_leave_date
                        , A.P_WEDDING_DATE WEDD_YEAR_AA
                        , CASE WHEN A.P_WEDDING_DATE <> '' THEN 1 ELSE 0 END WEDD_YEAR
                        ,	CASE 
                                WHEN A.P_WEDDING_DATE <> '' THEN 'Y'
                                WHEN ((A.P_WEDDING_DATE = '' OR A.P_WEDDING_DATE IS NULL) AND A.cancel_date IS NOT NULL)  THEN 'E'
                                ELSE 'N' 
                            END LIST_GB
                    FROM
                        S2_Userinfo_HiPlaza_Log A
                    WHERE
                        A.reg_date < DATEADD(DAY ,  0 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
                        AND A.reg_date >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
                        AND A.reg_date < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
						AND (@P_SITE_DIV <> 'AA' OR P_RQST_FLAG <> '')
						AND (@P_SITE_DIV <> 'SD' OR P_RQST_FLAG = 'DEAR')
						AND (@P_SITE_DIV <> 'SB' OR P_RQST_FLAG = 'BSON')
                        AND NOT EXISTS (
                                                SELECT 
                                                    P_SSN_CI
                                                FROM
                                                    S2_Userinfo_HiPlaza_Log
                          WHERE	
                                                    P_SSN_CI = A.P_SSN_CI
                                                    AND reg_date < CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
                                                    AND P_WEDDING_DATE <> ''
                                        )
                    ) AA
            WHERE	RM = 1
            AND		LIST_GB IN( 'Y')
            ORDER BY WEDD_YEAR_AA									

		END

END
GO
