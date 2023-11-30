IF OBJECT_ID (N'dbo.SP_REPORT_CUCKOO_MEMBERSHIP_AGREEMENT_MONTHLY_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_CUCKOO_MEMBERSHIP_AGREEMENT_MONTHLY_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_REPORT_CUCKOO_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2020-08-01', '2020-08-31', 'STATS'
EXEC SP_REPORT_CUCKOO_MEMBERSHIP_AGREEMENT_MONTHLY_LIST '2020-08-01', '2020-08-31', 'LIST'

*/

CREATE PROCEDURE [dbo].[SP_REPORT_CUCKOO_MEMBERSHIP_AGREEMENT_MONTHLY_LIST]
		@P_START_DATE		AS VARCHAR(10)
	,	@P_END_DATE			AS VARCHAR(10)
	,	@P_LIST_TYPE		AS VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @V_SRC_SDATE VARCHAR(10) = @P_START_DATE
	DECLARE @V_SRC_EDATE VARCHAR(10) = @P_END_DATE

	IF @P_LIST_TYPE = 'STATS'
		BEGIN

			SELECT	CASE WHEN GROUPING(REG_DATE_S) = 1 THEN '합계' ELSE CONVERT(VARCHAR(10), DATEADD(DAY, 0, REG_DATE_S), 120) END RegDate
				,	COUNT(ConnInfo) Cnt --예식일없는고객까지 전부
				,	sum(leave_cnt) CuckooMembershipLeaveDate --정보삭제요청고객
				,	SUM(WEDD_YEAR)  TotalCnt --예식일 있는회원만
				,	(SUM(WEDD_YEAR) - sum(leave_cnt))  WeddingYear
			FROM	(
				SELECT	
					A.ConnInfo
					, ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
					, CASE WHEN A.wedding_day <> '' THEN 1 ELSE 0 END WEDD_YEAR
					, CONVERT(VARCHAR ,A.file_dt   ,  23) REG_DATE_S
                    , case when c.cancel_dt <> '' then 1 else 0 end leave_cnt
				FROM
					CUCKOOS_DAILY_INFO A
					left join CUCKOOS_DAILY_INFO_CANCEL C on c.uid = A.uid
				WHERE
					A.file_dt <= DATEADD(DAY ,  0 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
					AND A.file_dt >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
					AND A.file_dt < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )

					) AA
			WHERE RM = 1
			GROUP BY REG_DATE_S 
			WITH ROLLUP	
								

		END

	ELSE
		BEGIN

            SELECT	ConnInfo 
            , LIST_GB AS ListGB
            FROM	(
                    SELECT 
                        A.ConnInfo
                        , ROW_NUMBER() OVER(PARTITION BY a.ConnInfo ORDER BY a.ConnInfo) RM
                        , A.wedding_day WEDD_YEAR_AA
                        , CASE WHEN A.wedding_day <> '' THEN 1 ELSE 0 END WEDD_YEAR
                        ,	CASE 
                                WHEN A.wedding_day <> '' THEN 'Y'
                                ELSE 'N' 
                            END LIST_GB
                    FROM
                        CUCKOOS_DAILY_INFO A
                    WHERE
                        A.file_dt <= DATEADD(DAY ,  0 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
					AND A.file_dt >= CONVERT(VARCHAR(10),DATEADD(DAY,0,@V_SRC_SDATE),120)
					AND A.file_dt < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, @V_SRC_EDATE  ,  23) AS DATETIME)  )
                    AND NOT EXISTS (select 1 from CUCKOOS_DAILY_INFO_CANCEL B where b.uid = a.uid)
                    ) AA
            WHERE	RM = 1
            AND		LIST_GB IN( 'Y')
            ORDER BY WEDD_YEAR_AA									

		END

END
GO
