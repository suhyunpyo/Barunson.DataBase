IF OBJECT_ID (N'dbo.SP_REPORT_MARKETING_AGREE_BY_ALL_DEARDEER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_MARKETING_AGREE_BY_ALL_DEARDEER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************************
-- SP Name       : SP_REPORT_MARKETING_AGREE_BY_ALL_DEARDEER
-- Author        : 박혜림
-- Create date   : 2022-09-15
-- Description   : 디얼디어 마케팅 동의 통계(회원가입일)
-- Update History: 
-- Comment       : SP_REPORT_MARKETING_AGREE_BY_ALL 참고
--
--
-- EXEC SP_REPORT_MARKETING_AGREE_BY_ALL_DEARDEER '2022-07-01','2022-07-31'
--
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_REPORT_MARKETING_AGREE_BY_ALL_DEARDEER]
	@P_START_DATE NVARCHAR(10),
	@P_END_DATE   NVARCHAR(10)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

BEGIN

	-------------------------------------------------------
	-- 가입회원 추출
	-------------------------------------------------------
	SELECT site_div AS Sales_Gubun
	     , uid AS member_id
		 , reg_date AS reg_date
	  INTO #TT
	  FROM S2_UserInfo_Deardeer WITH(NOLOCK)
	 WHERE (reg_date >= @p_start_date + ' 00:00:00' AND reg_date <= @p_end_date + ' 23:59:59')

	-------------------------------------------------------
	-- 통계
	-------------------------------------------------------
	SELECT 'SD' AS RegisterSalesGubun
		 , CASE WHEN A.sales_Gubun = 'SD' THEN '디얼디어'
		        WHEN A.sales_Gubun IS NULL THEN '합계'
		   ELSE '' END AS RegisterSalesGubunSiteName
		 , SUM(A.SIGN_UP_COUNT) AS SignUpCnt
		 , ISNULL(SUM(THIRD_PARTY_COMMUNICATION_COUNT),0) AS ThirdPartyCommunicationCnt
		 , 0 AS ThirdPartyInsuranceCnt		
		 , 0 AS SamsungMembershipCnt
		 , 0 AS IloomMembershipCnt
		 , ISNULL(SUM(THIRD_PARTY_SHINHAN_COUNT),0) AS ThirdPartyShinhanCnt
		 , ISNULL(SUM(LGMEMBERSHIP_COUNT), 0) AS LgMembershipCnt

		 , CASE WHEN SUM(THIRD_PARTY_COMMUNICATION_COUNT) > 0 THEN
		   CONVERT(NUMERIC(10,1), ISNULL(SUM(CONVERT(FLOAT, THIRD_PARTY_COMMUNICATION_COUNT)),0) * 100 / ISNULL(SUM(CONVERT(FLOAT, A.SIGN_UP_COUNT)),0))
		   ELSE 0.0 END as ThirdPartyCommunicationRate
		 , 0.0 AS ThirdPartyInsuranceRate
		 , 0.0 AS SamsungMembershipRate
		 , 0.0 AS IloomMembershipRate

		 , CASE WHEN SUM(THIRD_PARTY_SHINHAN_COUNT) > 0 THEN
		   CONVERT(NUMERIC(10,1), ISNULL(SUM(CONVERT(FLOAT, THIRD_PARTY_SHINHAN_COUNT)),0) * 100 / ISNULL(SUM(CONVERT(FLOAT, A.SIGN_UP_COUNT)),0)) 
		   ELSE 0.0 END as ThirdPartyShinhanRate
		 , CASE WHEN SUM(LGMEMBERSHIP_COUNT) > 0 THEN 
		   CONVERT(NUMERIC(10,1), ISNULL(SUM(CONVERT(FLOAT, LGMEMBERSHIP_COUNT)),0) * 100 / ISNULL(SUM(CONVERT(FLOAT, A.SIGN_UP_COUNT)),0)) 
		   ELSE 0.0 END AS LgMembershipRate
	  FROM (
			SELECT a.sales_Gubun 						-- 사이트
				 , a.SIGN_UP_COUNT						-- 가입회원
				 , b.THIRD_PARTY_COMMUNICATION_COUNT	-- 통신
				 , c.THIRD_PARTY_SHINHAN_COUNT			-- 신한생명
				 , d.LGMEMBERSHIP_COUNT					-- LG
			  FROM (  
					--주문건
					SELECT sales_Gubun
					     , COUNT(1) AS SIGN_UP_COUNT
					  FROM #TT AS a
					 GROUP BY sales_Gubun  
					) AS a

			  -------------------------------------------------------
			  -- 통신 
			  -------------------------------------------------------
			  LEFT OUTER JOIN (
								SELECT T1.sales_Gubun
								     , COUNT(1) AS THIRD_PARTY_COMMUNICATION_COUNT
								  FROM #TT AS T1
								 INNER JOIN (  
											 SELECT uid
											      , MAX(agree_date) AS agree_date
											   FROM S2_UserInfo_Deardeer_Marketing
											  WHERE agreement_type = 'MEMPLUS_COMM'
											    AND agreement_step = 'M'
											  GROUP BY uid  
											 ) AS T2 ON (T1.member_id = T2.UID)
								 WHERE T2.agree_date >= @P_START_DATE + ' 00:00:00' and T2.agree_date <= @P_END_DATE + ' 23:59:59'
								 GROUP BY T1.sales_Gubun 
							  ) AS b ON (a.sales_Gubun = b.sales_Gubun)

			  -------------------------------------------------------
			  -- 신한생명
			  -------------------------------------------------------
			  LEFT OUTER JOIN (
								SELECT T1.sales_Gubun
								     , COUNT(1) AS THIRD_PARTY_SHINHAN_COUNT  
								  FROM #TT AS T1 
								 INNER JOIN (  
											  SELECT uid
											      , MAX(agree_date) AS agree_date
											   FROM S2_UserInfo_Deardeer_Marketing
											  WHERE agreement_type = 'MEMPLUS_INSURA'
											    AND agreement_step = 'M'
											  GROUP BY uid  
											 ) AS T2 ON (T1.member_id = T2.UID)
								 WHERE T2.agree_date >= @P_START_DATE + ' 00:00:00' and T2.agree_date <= @P_END_DATE + ' 23:59:59'
								 GROUP BY T1.sales_Gubun
							   ) AS c ON (a.sales_Gubun = c.sales_Gubun)

			  -------------------------------------------------------
			  -- LG
			  -------------------------------------------------------
			  LEFT OUTER JOIN (
								SELECT T1.sales_Gubun
								     , COUNT(1) AS LGMEMBERSHIP_COUNT  
								  FROM #TT AS T1 
								 INNER JOIN (  
											  SELECT uid
											      , MAX(agree_date) AS agree_date
											   FROM S2_UserInfo_Deardeer_Marketing
											  WHERE agreement_type = 'LG'
											    AND agreement_step = 'M'
											  GROUP BY uid  
											 ) AS T2 ON (T1.member_id = T2.UID)
								 WHERE T2.agree_date >= @P_START_DATE + ' 00:00:00' and T2.agree_date <= @P_END_DATE + ' 23:59:59'
								 GROUP BY T1.sales_Gubun
							   ) AS d ON (a.sales_Gubun = d.sales_Gubun)
			) AS A		
	GROUP BY A.sales_Gubun WITH ROLLUP 
	ORDER BY	
			CASE 
				WHEN A.sales_Gubun = 'SD' THEN 1 
				WHEN A.sales_Gubun IS NULL THEN 2
				ELSE 1 END ASC

END
GO
