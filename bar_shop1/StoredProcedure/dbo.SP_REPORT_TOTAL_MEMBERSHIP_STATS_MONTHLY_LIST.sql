IF OBJECT_ID (N'dbo.SP_REPORT_TOTAL_MEMBERSHIP_STATS_MONTHLY_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_TOTAL_MEMBERSHIP_STATS_MONTHLY_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

EXEC SP_REPORT_TOTAL_MEMBERSHIP_STATS_MONTHLY_LIST '2020-08-01', '2020-08-31', 'SB'
EXEC SP_REPORT_TOTAL_MEMBERSHIP_STATS_MONTHLY_LIST '2020-08-01', '2020-08-31', ''

*/

CREATE PROCEDURE [dbo].[SP_REPORT_TOTAL_MEMBERSHIP_STATS_MONTHLY_LIST]
		@P_START_DATE		AS VARCHAR(10)
	,	@P_END_DATE			AS VARCHAR(10)
    ,	@P_SITE_DIV			AS VARCHAR(2)

AS
BEGIN
	SET NOCOUNT ON

	DECLARE @V_SRC_SDATE VARCHAR(10) = @P_START_DATE
	DECLARE @V_SRC_EDATE VARCHAR(10) = @P_END_DATE

    BEGIN
	    
		IF @P_SITE_DIV = 'SB'
		
	        SELECT 
	            CASE WHEN GROUPING(CRT_DT.DT) = 1 THEN '합계' ELSE CONVERT(VARCHAR(10), DATEADD(DAY, 0, CRT_DT.DT), 120) END RegDate
	            , SUM(USERINFO.memberCnt) JoinMemCnt
	            , SUM(SAMSUNG.agreeCount) AgreeSamsungCnt
	            , SUM(MEMPLUS.agreeCount) AgreeMemplusCnt
	            , SUM(LG.agreeCount) AgreeLgCnt
	            , CAST(CAST(SUM(SAMSUNG.agreeCount)/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeSamsungPer
	            , CAST(CAST(SUM(MEMPLUS.agreeCount)/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeMemplusPer
	            , CAST(CAST(SUM(LG.agreeCount)/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeLgPer
	            , SUM(SAMSUNG.agreeCount) - SUM(SAMSUNG.LeaveCount) AgreeValidSamsungCnt
	            , SUM(MEMPLUS.agreeCount) - SUM(MEMPLUS.LeaveCount) AgreeValidMemplusCnt
	            , SUM(LG.agreeCount) - SUM(LG.LeaveCount) AgreeValidLgCnt
	            , CAST(CAST((SUM(SAMSUNG.agreeCount) - SUM(SAMSUNG.LeaveCount))/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeValidSamsungper
	            , CAST(CAST((SUM(MEMPLUS.agreeCount) - SUM(MEMPLUS.LeaveCount))/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeValidMemplusPer
	            , CAST(CAST((SUM(LG.agreeCount) - SUM(LG.LeaveCount))/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeValidLgPer
	        FROM (
	            SELECT 
	                CONVERT(VARCHAR, DATEADD(D, NUMBER, @P_START_DATE), 23) AS DT
	            FROM 
	                MASTER..SPT_VALUES 
	            WHERE TYPE = 'P' AND NUMBER <= DATEDIFF(D, @P_START_DATE, @P_END_DATE)
	        ) AS CRT_DT
	        LEFT OUTER JOIN
	        (
	            SELECT	CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) DT
	                    ,	COUNT(ConnInfo) agreeCount 
	                    ,	COUNT(SMEMBERSHIP_LEAVE_DATE) LeaveCount 
	                FROM	(
	                            SELECT	A.ConnInfo
	                                ,	ROW_NUMBER()OVER(PARTITION BY CONNINFO ORDER BY CONNINFO) RM
	                                ,	SMEMBERSHIP_LEAVE_DATE
	                                ,	CONVERT(VARCHAR ,REG_DATE_S   ,  23) REG_DATE_S
	                            FROM	SAMSUNG_DAILY_INFO A
	                            WHERE	A.REG_DATE_S >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)
	                            AND		A.REG_DATE_S < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )
	                            AND		REG_DATE >= '2013-07-01'
	                            AND 	A.site_div <> 'SD'
	                        ) AA
	        
	                WHERE RM = 1
	                GROUP BY REG_DATE_S
	        ) SAMSUNG
	        ON CRT_DT.DT = SAMSUNG.DT
	        
	        LEFT OUTER JOIN
	        (
	            SELECT	CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) DT
	                    ,	COUNT(P_SSN_CI) agreeCount 
	                    ,	COUNT(lgmembership_leave_date) LeaveCount 
	                FROM	(
	                            SELECT	
	                                SUBSTRING(CONVERT(VARCHAR, A.reg_date ,  23) ,1,10) lgmembership_reg_date
	                                , P_SSN_CI
	                                , ROW_NUMBER()OVER(PARTITION BY P_SSN_CI ORDER BY P_SSN_CI) RM
									, A.cancel_date lgmembership_leave_date
	                                , CONVERT(VARCHAR ,A.result_date   ,  23) REG_DATE_S
	                            FROM
	                                S2_Userinfo_HiPlaza_Log A
	                            WHERE
	                                A.result_date < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
	                                AND A.result_date >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)
	                                AND A.result_date < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )				
	                                AND A.P_RQST_FLAG = 'BSON'
	                        ) AA
	                WHERE RM = 1
	                GROUP BY REG_DATE_S 
	        ) LG
	        ON CRT_DT.DT = LG.DT
	        
	        LEFT OUTER JOIN
	        (
	            SELECT	CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) DT
	                    , 	SUM(type1) agreeCount
	                    ,	sum(leave_cnt) LeaveCount
	                FROM	(
	                            SELECT	
	                                A.ConnInfo
	                                , ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
	                                , CASE WHEN A.connInfo is not null AND A.type_code1 = 'Y' THEN 1 ELSE 0 END  type1
	                                , CONVERT(VARCHAR ,A.file_dt   ,  23) REG_DATE_S
	                                , case when c.cancel_dt <> '' then 1 else 0 end leave_cnt
	                            FROM
	                                MEMPLUS_DAILY_INFO A
	                                    left join MEMPLUS_DAILY_INFO_CANCEL C on c.uid = A.uid
	                            WHERE
	                                A.file_dt <= DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
	                                AND A.file_dt >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)
	                                AND A.file_dt < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )
	                                AND (ISNULL(A.site_div, 'AA') = 'AA')
	                        ) AA
	                WHERE RM = 1
	                GROUP BY REG_DATE_S
	        ) AS MEMPLUS
	        ON CRT_DT.DT = MEMPLUS.DT
	        
	        LEFT OUTER JOIN
	        (
	            SELECT	
	                CONVERT(VARCHAR(10), DATEADD(DAY, 0, reg_date), 120) DT
	                , sum(A.memberCnt) memberCnt
	            FROM
	                (
	                SELECT	
	                    CASE WHEN A.connInfo is not null THEN 1 ELSE 0 END memberCnt
	                    , CONVERT(VARCHAR ,A.reg_date   ,  23) reg_date
	                    , ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
	                FROM
	                    S2_UserInfo_BHands A
	                WHERE 
	                    reg_date >= @P_START_DATE
	                    AND REG_DATE < DATEADD(DAY,1, @P_END_DATE)
	                ) AS A
	            WHERE RM = 1
	            GROUP BY reg_date		
	        ) USERINFO
	        ON CRT_DT.DT = USERINFO.DT
	        
	        GROUP BY CRT_DT.DT
	        WITH ROLLUP
	        
		ELSE
		
			SELECT 
				CASE WHEN GROUPING(CRT_DT.DT) = 1 THEN '합계' ELSE CONVERT(VARCHAR(10), DATEADD(DAY, 0, CRT_DT.DT), 120) END RegDate
				, SUM(USERINFO.memberCnt) JoinMemCnt
				, SUM(SAMSUNG.agreeCount) AgreeSamsungCnt
				, SUM(USERINFO_MEMPLUS.memberCnt) AgreeMemplusCnt
				, SUM(USERINFO_LG.memberCnt) AgreeLgCnt
				, CAST(CAST(SUM(SAMSUNG.agreeCount)/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeSamsungPer
				, CAST(CAST(SUM(USERINFO_MEMPLUS.memberCnt)/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeMemplusPer
				, CAST(CAST(SUM(USERINFO_LG.memberCnt)/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeLgPer
				, SUM(SAMSUNG.agreeCount) - SUM(SAMSUNG.LeaveCount) AgreeValidSamsungCnt
				, SUM(MEMPLUS.agreeCount) - SUM(MEMPLUS.LeaveCount) AgreeValidMemplusCnt
				, SUM(LG.agreeCount) - SUM(LG.LeaveCount) AgreeValidLgCnt
				, CAST(CAST((SUM(SAMSUNG.agreeCount) - SUM(SAMSUNG.LeaveCount))/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeValidSamsungper
				, CAST(CAST((SUM(MEMPLUS.agreeCount) - SUM(MEMPLUS.LeaveCount))/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeValidMemplusPer
				, CAST(CAST((SUM(LG.agreeCount) - SUM(LG.LeaveCount))/CAST(SUM(USERINFO.memberCnt) AS FLOAT) AS FLOAT)*100.0 AS DECIMAL) AgreeValidLgPer
			FROM (
				SELECT 
					CONVERT(VARCHAR, DATEADD(D, NUMBER, @P_START_DATE), 23) AS DT
				FROM 
					MASTER..SPT_VALUES 
				WHERE TYPE = 'P' AND NUMBER <= DATEDIFF(D, @P_START_DATE, @P_END_DATE)
			) AS CRT_DT
			LEFT OUTER JOIN
			(
				SELECT	CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) DT
						,	COUNT(ConnInfo) agreeCount 
						,	COUNT(SMEMBERSHIP_LEAVE_DATE) LeaveCount 
					FROM	(
								SELECT	A.ConnInfo
									,	ROW_NUMBER()OVER(PARTITION BY CONNINFO ORDER BY CONNINFO) RM
									,	SMEMBERSHIP_LEAVE_DATE
									,	CONVERT(VARCHAR ,REG_DATE_S   ,  23) REG_DATE_S
								FROM	SAMSUNG_DAILY_INFO A
								WHERE	A.REG_DATE_S >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)
								AND		A.REG_DATE_S < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )
								AND		REG_DATE >= '2013-07-01'
								AND 	A.site_div = 'SD'
							) AA
			
					WHERE RM = 1
					GROUP BY REG_DATE_S
			) SAMSUNG
			ON CRT_DT.DT = SAMSUNG.DT
			
			LEFT OUTER JOIN
			(
				SELECT	CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) DT
						,	COUNT(P_SSN_CI) agreeCount 
						,	COUNT(lgmembership_leave_date) LeaveCount 
					FROM	(
								SELECT	
									SUBSTRING(CONVERT(VARCHAR, A.reg_date ,  23) ,1,10) lgmembership_reg_date
									, P_SSN_CI
									, ROW_NUMBER()OVER(PARTITION BY P_SSN_CI ORDER BY P_SSN_CI) RM
									, A.cancel_date lgmembership_leave_date
									, CONVERT(VARCHAR ,A.result_date   ,  23) REG_DATE_S
								FROM
									S2_Userinfo_HiPlaza_Log A
								WHERE
								    A.result_date < DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
									AND A.result_date >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)
									AND A.result_date < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )				
									AND A.P_RQST_FLAG = 'DEAR'
							) AA
					WHERE RM = 1
					GROUP BY REG_DATE_S 
			) LG
			ON CRT_DT.DT = LG.DT
			
			LEFT OUTER JOIN
			(
				SELECT	CONVERT(VARCHAR(10), DATEADD(DAY, -1, REG_DATE_S), 120) DT
						, 	SUM(type1) agreeCount
						,	sum(leave_cnt) LeaveCount
					FROM	(
								SELECT	
									A.ConnInfo
									, ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
									, CASE WHEN A.connInfo is not null AND A.type_code1 = 'Y' THEN 1 ELSE 0 END  type1
									, CONVERT(VARCHAR ,A.file_dt   ,  23) REG_DATE_S
				                    , case when c.cancel_dt <> '' then 1 else 0 end leave_cnt
								FROM
									MEMPLUS_DAILY_INFO A
										left join MEMPLUS_DAILY_INFO_CANCEL C on c.uid = A.uid
								WHERE
									A.file_dt <= DATEADD(DAY ,  1 , CAST(CONVERT(VARCHAR, getdate()  ,  23) AS DATETIME)  )
									AND A.file_dt >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)
									AND A.file_dt < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )
									AND (ISNULL(A.site_div, 'AA') = 'SD')
							) AA
					WHERE RM = 1
					GROUP BY REG_DATE_S
			) AS MEMPLUS
			ON CRT_DT.DT = MEMPLUS.DT
			
			LEFT OUTER JOIN
			(
				SELECT	
					CONVERT(VARCHAR(10), DATEADD(DAY, 0, reg_date), 120) DT
					, sum(A.memberCnt) memberCnt
				FROM
					(
					SELECT	
						CASE WHEN A.connInfo is not null THEN 1 ELSE 0 END memberCnt
						, CONVERT(VARCHAR ,A.reg_date   ,  23) reg_date
						, ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
					FROM
						S2_UserInfo_Deardeer A
					WHERE 
						reg_date >= @P_START_DATE
						AND REG_DATE < DATEADD(DAY,1, @P_END_DATE)
					) AS A
				WHERE RM = 1
				GROUP BY reg_date		
			) USERINFO
			ON CRT_DT.DT = USERINFO.DT

			LEFT OUTER JOIN
			(
				SELECT	
					CONVERT(VARCHAR(10), DATEADD(DAY, 0, reg_date), 120) DT
					, SUM(A.memberCnt) memberCnt
				FROM
					(
					SELECT	
						CASE WHEN A.connInfo is not null THEN 1 ELSE 0 END memberCnt
						, CONVERT(VARCHAR ,B.agree_date, 23) reg_date
						, ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
					FROM S2_UserInfo_Deardeer AS A WITH(NOLOCK)
				     INNER JOIN S2_UserInfo_Deardeer_Marketing AS B WITH(NOLOCK) ON (A.uid = B.uid AND B.agreement_type = 'MEMPLUS' AND B.chk_agreement = 'Y')
					WHERE B.agree_date >= @P_START_DATE
					  AND B.agree_date < DATEADD(DAY,1, @P_END_DATE)
					) AS A
				WHERE RM = 1
				GROUP BY reg_date		
			) USERINFO_MEMPLUS
			ON CRT_DT.DT = USERINFO_MEMPLUS.DT

			LEFT OUTER JOIN
			(
				SELECT	
					CONVERT(VARCHAR(10), DATEADD(DAY, 0, reg_date), 120) DT
					, SUM(A.memberCnt) memberCnt
				FROM
					(
					SELECT	
						CASE WHEN A.connInfo is not null THEN 1 ELSE 0 END memberCnt
						, CONVERT(VARCHAR ,B.agree_date, 23) reg_date
						, ROW_NUMBER()OVER(PARTITION BY A.ConnInfo ORDER BY A.ConnInfo) RM
					FROM S2_UserInfo_Deardeer AS A WITH(NOLOCK)
				     INNER JOIN S2_UserInfo_Deardeer_Marketing AS B WITH(NOLOCK) ON (A.uid = B.uid AND B.agreement_type = 'LG' AND B.chk_agreement = 'Y')
					WHERE B.agree_date >= @P_START_DATE
					  AND B.agree_date < DATEADD(DAY,1, @P_END_DATE)
					) AS A
				WHERE RM = 1
				GROUP BY reg_date		
			) USERINFO_LG
			ON CRT_DT.DT = USERINFO_LG.DT
			
			GROUP BY CRT_DT.DT
			WITH ROLLUP
	
    END

END
GO
