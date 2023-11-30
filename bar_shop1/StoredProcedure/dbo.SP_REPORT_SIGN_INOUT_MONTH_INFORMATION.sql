IF OBJECT_ID (N'dbo.SP_REPORT_SIGN_INOUT_MONTH_INFORMATION', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_SIGN_INOUT_MONTH_INFORMATION
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_REPORT_SIGN_INOUT_MONTH_INFORMATION '2020'

*/
CREATE PROCEDURE [dbo].[SP_REPORT_SIGN_INOUT_MONTH_INFORMATION]
        @P_YEAR     AS  VARCHAR(4)
AS
BEGIN

    SET NOCOUNT ON

    DECLARE @P_START_DATE	AS varchar(10)
    DECLARE @P_END_DATE 	AS varchar(10)

    SET @P_START_DATE = 	convert(varchar(10),DATEADD(YEAR, DATEDIFF(YEAR, 0, CONVERT(datetime, @P_YEAR + '-01-01')), 0), 23)
    SET @P_END_DATE	= 		convert(varchar(10),DATEADD(YEAR, DATEDIFF(YEAR, -1, CONVERT(datetime, @P_YEAR + '-01-01')), -1), 23)


    SELECT
		CASE 
			WHEN c.SITE_DIV = 'SB' THEN '바른손카드'
			WHEN c.SITE_DIV = 'SA' THEN '비핸즈카드'
			WHEN c.SITE_DIV = 'ST' THEN '더카드'
			WHEN c.SITE_DIV = 'SS' THEN '프리미어페이퍼'
			WHEN c.SITE_DIV = 'B' THEN '바른손몰'
			WHEN c.SITE_DIV = 'CE' THEN '셀레모'
			WHEN c.SITE_DIV = 'BE' THEN '비웨딩'
			WHEN c.SITE_DIV IS NULL THEN '합계'
			ELSE ''
		END AS RegisterSalesGubunSiteName
		, sum(sign_up_mon1)  AS JoinMonthJanCnt
		, sum(C.WithdrawalCount_mon1)  AS LeaveMonthJanCnt
		, sum(sign_up_mon2) JoinMonthFebCnt
		, sum(c.WithdrawalCount_mon2) LeaveMonthFebCnt
		, sum(sign_up_mon3) JoinMonthMarCnt
		, sum(c.WithdrawalCount_mon3) LeaveMonthMarCnt
		, sum(sign_up_mon4) JoinMonthAprCnt
		, sum(c.WithdrawalCount_mon4) LeaveMonthAprCnt
		, sum(sign_up_mon5) JoinMonthMayCnt
		, sum(c.WithdrawalCount_mon5) LeaveMonthMayCnt
		, sum(sign_up_mon6) JoinMonthJunCnt
		, sum(c.WithdrawalCount_mon6) LeaveMonthJunCnt
		, sum(sign_up_mon7) JoinMonthJulCnt
		, sum(c.WithdrawalCount_mon7) LeaveMonthJulCnt
		, sum(sign_up_mon8) JoinMonthAugCnt
		, sum(c.WithdrawalCount_mon8) LeaveMonthAugCnt
		, sum(sign_up_mon9) JoinMonthSepCnt
		, sum(c.WithdrawalCount_mon9) LeaveMonthSepCnt
		, sum(sign_up_mon10) JoinMonthOctCnt
		, sum(c.WithdrawalCount_mon10) LeaveMonthOctCnt
		, sum(sign_up_mon11) JoinMonthNovCnt
		, sum(c.WithdrawalCount_mon11) LeaveMonthNovCnt
		, sum(sign_up_mon12) JoinMonthDecCnt
		, sum(c.WithdrawalCount_mon12) LeaveMonthDecCnt

		, sum(sign_up_mon1 + sign_up_mon2 + sign_up_mon3 + sign_up_mon4 + sign_up_mon5 + sign_up_mon6 + sign_up_mon7 + sign_up_mon8 + sign_up_mon9 + sign_up_mon10 + sign_up_mon11 + sign_up_mon12) JoinTotCnt
		, sum(c.WithdrawalCount_mon1 + c.WithdrawalCount_mon2 + c.WithdrawalCount_mon3 + c.WithdrawalCount_mon4 + c.WithdrawalCount_mon5 + c.WithdrawalCount_mon6 + c.WithdrawalCount_mon7 + c.WithdrawalCount_mon8 + c.WithdrawalCount_mon9 + c.WithdrawalCount_mon10 + c.WithdrawalCount_mon11 + c.WithdrawalCount_mon12) LeaveTotCnt
	from (
			SELECT 
				B.site_div
				,(CASE WHEN B.mon = 1 THEN B.sign_up_count else 0 end )sign_up_mon1
				,(CASE WHEN B.mon = 1 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon1
				,(CASE WHEN B.mon = 2 THEN B.sign_up_count else 0 end) sign_up_mon2
				,(CASE WHEN B.mon = 2 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon2
				,(CASE WHEN B.mon = 3 THEN B.sign_up_count else 0 end) sign_up_mon3
				,(CASE WHEN B.mon = 3 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon3
				,(CASE WHEN B.mon = 4 THEN B.sign_up_count else 0 end) sign_up_mon4
				,(CASE WHEN B.mon = 4 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon4
				,(CASE WHEN B.mon = 5 THEN B.sign_up_count else 0 end) sign_up_mon5
				,(CASE WHEN B.mon = 5 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon5
				,(CASE WHEN B.mon = 6 THEN B.sign_up_count else 0 end) sign_up_mon6
				,(CASE WHEN B.mon = 6 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon6
				,(CASE WHEN B.mon = 7 THEN B.sign_up_count else 0 end) sign_up_mon7
				,(CASE WHEN B.mon = 7 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon7
				,(CASE WHEN B.mon = 8 THEN B.sign_up_count else 0 end) sign_up_mon8
				,(CASE WHEN B.mon = 8 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon8
				,(CASE WHEN B.mon = 9 THEN B.sign_up_count else 0 end) sign_up_mon9
				,(CASE WHEN B.mon = 9 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon9
				,(CASE WHEN B.mon = 10 THEN B.sign_up_count else 0 end) sign_up_mon10
				,(CASE WHEN B.mon = 10 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon10
				,(CASE WHEN B.mon = 11 THEN B.sign_up_count else 0 end) sign_up_mon11
				,(CASE WHEN B.mon = 11 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon11
				,(CASE WHEN B.mon = 12 THEN B.sign_up_count else 0 end) sign_up_mon12
				,(CASE WHEN B.mon = 12 THEN SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) ELSE 0 END) WithdrawalCount_mon12
			FROM (
				SELECT	CASE 
							WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
								CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
							ELSE 
								CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
						END AS SITE_DIV
					,	SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' THEN 1 ELSE 0 END) AS SIGN_UP_COUNT
					, 	datepart(mm,sut.INTERGRATION_DATE) mon
					
			
				FROM	S2_USERINFO_THECARD SUT
				WHERE	1 = 1
				AND		INTEGRATION_MEMBER_YORN = 'Y'

				and sut.birth <> '' and sut.birth is not null and  sut.birth <> '' and len(sut.birth) = 10

				GROUP BY 
						CASE 
							WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
								CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
							ELSE 
								CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
						END
					, datepart(mm,sut.INTERGRATION_DATE)
								
				) B
				LEFT 
				JOIN	(
						
							SELECT	CASE WHEN SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE SITE_DIV END AS SITE_DIV
								,	COUNT(*) AS WITHDRAWAL_COUNT 
								, datepart(mm,USC.REG_DATE) mon
							FROM	S2_USERBYE_SECESSION_CAUSE  USC 
							WHERE	1 = 1
							AND		REG_DATE >= @P_START_DATE + ' 00:00:00'
							AND		REG_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00'
			
							GROUP BY CASE WHEN SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE SITE_DIV END, datepart(mm,USC.REG_DATE)
						) AS WITHDRAWAL ON CASE WHEN b.SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE b.SITE_DIV END = WITHDRAWAL.SITE_DIV and B.mon = WITHDRAWAL.mon
						
			GROUP BY B.SITE_DIV, B.mon, b.SIGN_UP_COUNT --with rollup
		) C
		group by c.site_div  with rollup
		ORDER BY	
			CASE 
				WHEN C.SITE_DIV = 'SB' THEN 1 
				WHEN C.SITE_DIV = 'SA' THEN 2
				WHEN C.SITE_DIV = 'ST' THEN 3 
				WHEN C.SITE_DIV = 'SS' THEN 4 
				WHEN C.SITE_DIV = 'B' THEN 5 
				WHEN C.SITE_DIV = 'CE' THEN 6 
				WHEN C.SITE_DIV = 'BE' THEN 7 
				WHEN C.SITE_DIV IS NULL THEN 8
				ELSE 1 
			END ASC	
END
GO
