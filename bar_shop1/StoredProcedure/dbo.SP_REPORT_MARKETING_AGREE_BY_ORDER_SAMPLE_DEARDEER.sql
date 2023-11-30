IF OBJECT_ID (N'dbo.SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE_DEARDEER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE_DEARDEER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE
-- Author        : 박혜림
-- Create date   : 2022-09-01
-- Description   : 디얼디어 마케팅 동의 통계(샘플주문일)
-- Update History: 
-- Comment       : SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE 참고
--
--
-- EXEC SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE_DEARDEER '2022-09-01','2022-09-30'
--
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE_DEARDEER]  
	@p_start_date NVARCHAR(10),
	@p_end_date   NVARCHAR(10)  
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

BEGIN  
  
	-------------------------------------------------------
	-- 샘플주문건 추출
	-------------------------------------------------------
	SELECT DISTINCT T1.SALES_GUBUN AS Sales_Gubun
	     , T1.MEMBER_ID AS member_id
	  INTO #TT
	  FROM CUSTOM_SAMPLE_ORDER       AS T1 WITH(NOLOCK)
	 INNER JOIN S2_UserInfo_Deardeer AS T2 WITH(NOLOCK) ON (T1.member_id = T2.uid)
	 WHERE T1.sales_Gubun = 'SD'
	   AND (T1.MEMBER_ID IS NOT NULL AND T1.MEMBER_ID <> 's4guest')
	   AND (T1.REQUEST_DATE IS NOT NULL AND T1.REQUEST_DATE >= @p_start_date + ' 00:00:00' AND T1.REQUEST_DATE <= @p_end_date + ' 23:59:59')
	   AND T1.SETTLE_DATE IS NOT NULL
     GROUP BY T1.SALES_GUBUN, T1.MEMBER_ID


	-------------------------------------------------------
	-- 노출회원 추출
	-------------------------------------------------------
	SELECT DISTINCT 'SD' AS Sales_Gubun
	     , T1.uid AS member_id
		 , MAX(T2.mod_date) AS mod_date
	  INTO #TT2
	  FROM S2_UserInfo_Deardeer                     AS T1 WITH(NOLOCK)
	 INNER JOIN S2_UserInfo_Deardeer_Marketing_View AS T2 WITH(NOLOCK) ON (T1.uid = T2.uid AND T2.agreement_step = 'S')
	 WHERE (T2.mod_date >= @p_start_date + ' 00:00:00' AND T2.mod_date <= @p_end_date + ' 23:59:59' )
	 GROUP BY T1.uid
 
  
	-------------------------------------------------------
	-- 통계
	-------------------------------------------------------
	SELECT 'SD' AS RegisterSalesGubun
	     , CASE WHEN A.sales_Gubun = 'SD' THEN '디얼디어'
		        WHEN A.sales_Gubun IS NULL THEN '합계'
		   ELSE '' END AS RegisterSalesGubunSiteName  -- 사이트
		 , ISNULL(SUM(order_mem_count),0) AS OrderMemberCnt	-- 결제회원
		 , ISNULL(SUM(show_count),0) AS ShowMarketingCnt	-- 노출회원
		 , 0 AS SamsungMembershipCnt		-- 삼성
		 , 0.0 AS SamsungMembershipRate		-- 삼성 %
		 , 0 AS IloomMembershipCnt			-- 일룸
		 , 0.0 AS IloomMembershipRate		-- 일룸 %
		 , 0 AS ThirdPartyInsuranceCnt		-- 보험
		 , 0.0 AS ThirdPartyInsuranceRate	-- 보험 %
		 , ISNULL(SUM(third_party_comm_count),0) AS ThirdPartyCommunicationCnt  -- 통신
		 , CASE WHEN SUM(third_party_comm_count) > 0 THEN 
		   CONVERT(numeric(10,1), ISNULL(SUM(convert(float, third_party_comm_count)),0) * 100 / ISNULL(SUM(CONVERT(float, show_count)),0)) 
		   ELSE 0.0 END as ThirdPartyCommunicationRate
		 , ISNULL(SUM(third_party_shinhan_count),0) AS ThirdPartyShinhanCnt  -- 신한
		 , CASE WHEN SUM(third_party_shinhan_count) > 0 THEN
		   CONVERT(numeric(10,1), ISNULL(SUM(convert(float, third_party_shinhan_count)),0) * 100 / ISNULL(SUM(CONVERT(float, show_count)),0)) 
		   ELSE 0.0 END as ThirdPartyShinhanRate
		 , ISNULL(SUM(l_count),0) AS LgMembershipCnt   -- LG동의
		 , CASE WHEN SUM(l_count) > 0 THEN 
		   CONVERT(numeric(10,1), ISNULL(SUM(convert(float, l_count)),0) * 100 / ISNULL(SUM(CONVERT(float, show_count)),0)) 
		   ELSE 0.0 END as LgMembershipRate  -- LG %
	  FROM (  
			SELECT o.sales_Gubun				-- 사이트
			     , o.order_mem_count			-- 결제회원
				 , a.show_count					-- 노출 회원
				 , b.third_party_comm_count		-- 통신
				 , c.third_party_shinhan_count	-- 신한생명
				 , d.l_count					-- LG
			  FROM (  
					--주문건
					SELECT sales_Gubun
					     , COUNT(1) AS order_mem_count
					  FROM #TT AS a
					 GROUP BY sales_Gubun  
					) AS o

			  -------------------------------------------------------
			  -- 노출 회원 
			  -------------------------------------------------------
			  LEFT OUTER JOIN (  
								SELECT sales_Gubun
								     , COUNT(1) show_count
								  FROM #TT2 AS T1
								 GROUP BY sales_Gubun
							   ) AS a ON (o.sales_Gubun = a.sales_Gubun)
			  -------------------------------------------------------
			  -- 통신 
			  -------------------------------------------------------
			  LEFT OUTER JOIN (
								SELECT T1.sales_Gubun
								     , COUNT(1) AS third_party_comm_count
								  FROM #TT2 AS T1
								 INNER JOIN (  
											 SELECT uid
											      , MAX(agree_date) AS agree_date
											   FROM S2_UserInfo_Deardeer_Marketing
											  WHERE agreement_type = 'MEMPLUS_COMM'
											    AND agreement_step = 'S'
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
								     , COUNT(1) as third_party_shinhan_count  
								  FROM #TT2 AS T1 
								 INNER JOIN (  
											  SELECT uid
											      , MAX(agree_date) AS agree_date
											   FROM S2_UserInfo_Deardeer_Marketing
											  WHERE agreement_type = 'MEMPLUS_INSURA'
											    AND agreement_step = 'S'
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
								     , COUNT(1) AS l_count  
								  FROM #TT2 AS T1 
								 INNER JOIN (  
											  SELECT uid
											      , MAX(agree_date) AS agree_date
											   FROM S2_UserInfo_Deardeer_Marketing
											  WHERE agreement_type = 'LG'
											    AND agreement_step = 'S'
											  GROUP BY uid  
											 ) AS T2 ON (T1.member_id = T2.UID)
								 WHERE T2.agree_date >= @P_START_DATE + ' 00:00:00' and T2.agree_date <= @P_END_DATE + ' 23:59:59'
								 GROUP BY T1.sales_Gubun
							   ) AS d ON (a.sales_Gubun = d.sales_Gubun)
			) AS A  
  
	 GROUP BY A.sales_Gubun WITH ROLLUP   
	 ORDER BY CASE WHEN A.sales_Gubun = 'SD' THEN 1
		           WHEN A.sales_Gubun IS NULL THEN 2
			  ELSE 1 END ASC  
  
END
GO
