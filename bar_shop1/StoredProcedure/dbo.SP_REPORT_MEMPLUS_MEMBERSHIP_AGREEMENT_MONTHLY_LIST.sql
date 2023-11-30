IF OBJECT_ID (N'dbo.SP_REPORT_MEMPLUS_MEMBERSHIP_AGREEMENT_MONTHLY_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_MEMPLUS_MEMBERSHIP_AGREEMENT_MONTHLY_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_REPORT_MEMPLUS_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2020-08-01', '2020-08-31', '', 'STATS'
EXEC SP_REPORT_MEMPLUS_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2020-08-01', '2020-08-31', '', 'LIST'

*/

CREATE PROCEDURE [dbo].[SP_REPORT_MEMPLUS_MEMBERSHIP_AGREEMENT_MONTHLY_LIST]
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
				--,	COUNT(ConnInfo) Cnt 
				,	sum(leave_cnt) LeaveCount --정보삭제요청고객
				, 	SUM(type1) typecode1Cnt
				,	SUM(type6) typecode6Cnt
			FROM	(
				SELECT	
					A.ConnInfo
					, ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
					, CASE WHEN A.connInfo is not null AND A.type_code1 = 'Y' THEN 1 ELSE 0 END  type1
					, CASE WHEN A.connInfo is not null AND A.type_code6 = 'Y' THEN 1 ELSE 0 END  type6
					, CONVERT(VARCHAR ,A.file_dt   ,  23) REG_DATE_S
                    , case when c.cancel_dt <> '' then 1 else 0 end leave_cnt
				FROM
					MEMPLUS_DAILY_INFO A
						left join MEMPLUS_DAILY_INFO_CANCEL C on c.uid = A.uid
				WHERE
					A.file_dt <= DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
					AND A.file_dt >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@V_SRC_SDATE),120)
					AND A.file_dt < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
					AND (
								(@P_SITE_DIV = 'SD') AND (ISNULL(A.site_div, 'AA') = 'SD')
								OR (@P_SITE_DIV = 'SB') AND (ISNULL(A.site_div, 'AA') = 'AA')
								OR (@P_SITE_DIV = 'AA') AND (ISNULL(A.site_div, 'AA') <> '')
						)

					) AA
			WHERE RM = 1
			GROUP BY REG_DATE_S 
			WITH ROLLUP
								

		END

	ELSE
		BEGIN

            SELECT	ConnInfo 
            , LIST_GB1 AS ListGB1
            , LIST_GB6 AS ListGB6
            FROM	(
                    SELECT 
                        A.ConnInfo
                        , ROW_NUMBER() OVER(PARTITION BY a.ConnInfo ORDER BY a.ConnInfo) RM
                        , A.regdate
                        ,	CASE 
                                WHEN A.ConnInfo is not null AND A.type_code1 = 'Y' THEN 'Y'
                                ELSE 'N' 
                            END LIST_GB1
                        , 	CASE
                        		WHEN A.ConnInfo is not null AND A.type_code6 = 'Y' THEN 'Y'
                        		ELSE 'N'
                        	END LIST_GB6
                    FROM
                        MEMPLUS_DAILY_INFO A
                    WHERE
                        A.file_dt <= DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
					AND A.file_dt >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@V_SRC_SDATE),120)
					AND A.file_dt < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
                    AND NOT EXISTS (select 1 from MEMPLUS_DAILY_INFO_CANCEL B where b.uid = a.uid)
                    AND (
								(@P_SITE_DIV = 'SD') AND (ISNULL(A.site_div, 'AA') = 'SD')
								OR (@P_SITE_DIV = 'SB') AND (ISNULL(A.site_div, 'AA') = 'AA')
								OR (@P_SITE_DIV = 'AA') AND (ISNULL(A.site_div, 'AA') <> '')
						)
                    ) AA
            WHERE	RM = 1
            AND LIST_GB1 = 'Y'
            AND LIST_GB6 = 'Y'
            ORDER BY regdate									

		END

END
GO
