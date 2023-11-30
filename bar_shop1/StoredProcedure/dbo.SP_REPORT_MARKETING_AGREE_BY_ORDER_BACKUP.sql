IF OBJECT_ID (N'dbo.SP_REPORT_MARKETING_AGREE_BY_ORDER_BACKUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_MARKETING_AGREE_BY_ORDER_BACKUP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  

/*
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  

[SP_REPORT_MARKETING_AGREE_BY_ORDER_NAM] '2020-03-13','2020-03-13'


[SP_REPORT_MARKETING_AGREE_BY_ORDER] '2020-03-13','2020-03-13'

-- Author:  nam  
-- Create date: 2020-03-25  
-- Description: 동의 카운트를 #T - > #T2로 노출회원 기준의 동의 카운트로 변경 by.김보미 조건 정의 해줌


예를들어
총 회원가입 100중
- 동의 : 30명,  비동의 : 70명 일 경우

회원가입단에서 동의한 30명에 통계는 본창에서 나오고 있고,

비동의 70명 중에,  샘플에도 노출하고, 결제단에도
노출하는데 그 70명중에 동의율이 얼마냐에 대한 내용

-- =============================================  
*/

CREATE PROCEDURE [dbo].[SP_REPORT_MARKETING_AGREE_BY_ORDER_BACKUP]  
 @p_start_date nvarchar(10),  
 @p_end_date nvarchar(10)  
AS  
BEGIN  
  
 select distinct  
  case  
   when sales_Gubun = 'B' OR sales_Gubun = 'H' OR sales_Gubun = 'C'  then 'B'  
   else sales_Gubun  
  end as sales_gubun,   
  member_id  
  INTO   
  #T  
 from custom_order as co  
  inner join s2_userinfo_thecard as ui  
   on co.member_id = ui.uid  
 where co.settle_date >= @p_start_date + ' 00:00:00'  
  and co.settle_date <= @p_end_date + ' 23:59:59'  
  and co.member_id is not null  
  and co.settle_date is not null  
  and sales_Gubun <> 'SD'  
  and co.member_id <> 's4guest'  
 group by sales_Gubun,  
  member_id;  


  -- 노출회원 추출
  select distinct  
  case  
   when a.sales_Gubun = 'B' OR a.sales_Gubun = 'H' OR a.sales_Gubun = 'C'  then 'B'  
   else a.sales_Gubun  
  end as sales_gubun,   
  a.member_id  
  INTO   
  #T2
  from
	(  
		select sales_Gubun
		from #T as a  
		group by sales_Gubun  
	  ) as o  
     
	  left outer join 
	  --------------------------------------------------------------------------------------------------------------------
	  -- 노출 회원 
	  (  
	   select sales_Gubun,  
		a.member_id  
	   from #T AS a  
		inner join S2_UserInfo_TheCard as ui on ui.uid = a.member_id  
	   where  dbo.fn_datediff(smembership_reg_date, INTERGRATION_DATE) > 2  
		or (  
		 smembership_reg_date is null  
		)  
	   group by sales_Gubun  , member_id
	   union
	   select sales_Gubun,  
		a.member_id  
	   from #T AS a  
		inner join S2_UserInfo_TheCard as ui on ui.uid = a.member_id  
	   where  dbo.fn_datediff(lgmembership_reg_date, INTERGRATION_DATE) > 2  
		or (  
		 lgmembership_reg_date is null  
		)  
	   group by sales_Gubun  , member_id
	  ) as a on o.sales_Gubun = a.sales_Gubun  
	  --------------------------------------------------------------------------------------------------------------------
 
 
  
SELECT  
 A.sales_Gubun AS RegisterSalesGubun  
 , CASE   
   WHEN A.sales_Gubun = 'SB' THEN '바른손카드'  
   WHEN A.sales_Gubun = 'SA' THEN '비핸즈카드'  
   WHEN A.sales_Gubun = 'ST' THEN '더카드'  
   WHEN A.sales_Gubun = 'SS' THEN '프리미어페이퍼'  
   WHEN A.sales_Gubun = 'B' THEN '바른손몰'  
   WHEN A.sales_Gubun = 'CE' THEN '셀레모'  
   WHEN A.sales_Gubun = 'BE' THEN '비웨딩'  
   WHEN A.sales_Gubun IS NULL THEN '합계'  
   ELSE ''  
  END AS RegisterSalesGubunSiteName  -- 사이트

  
 , ISNULL(SUM(order_mem_count),0) AS OrderMemberCnt		-- 결제회원
 , ISNULL(SUM(show_count),0) AS ShowMarketingCnt		-- 노출회원

 , ISNULL(SUM(s_count),0) AS SamsungMembershipCnt   -- 삼성동의
 , CASE WHEN SUM(s_count) > 0 THEN 
	convert(numeric(10,1), ISNULL(SUM(convert(float, s_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) 
   ELSE 0 	
   END as SamsungMembershipRate  -- 삼성 %
 
 
 , ISNULL(SUM(i_count),0) AS IloomMembershipCnt  -- 일룸
 , CASE WHEN SUM(i_count) > 0 THEN 
	convert(numeric(10,1), ISNULL(SUM(convert(float, i_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) 
   ELSE 0 
   END as IloomMembershipRate  -- 일룸 %


 , ISNULL(SUM(third_party_comm_count),0) AS ThirdPartyCommunicationCnt  -- 보험
 , CASE WHEN SUM(third_party_comm_count) > 0 THEN 
	convert(numeric(10,1), ISNULL(SUM(convert(float, third_party_comm_count)),0)  * 100 / ISNULL(SUM(convert(float, show_count)),0)) 
   ELSE 0 
   END as ThirdPartyCommunicationRate  -- 보험 %


 ,	ISNULL(SUM(third_party_insure_count),0) AS ThirdPartyInsuranceCnt  -- 통신
 ,	CASE WHEN SUM(third_party_insure_count) > 0 THEN 
	convert(numeric(10,1), ISNULL(SUM(convert(float, third_party_insure_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) 
	ELSE 0 
	END as ThirdPartyInsuranceRate  

 ,	ISNULL(SUM(third_party_shinhan_count),0) AS ThirdPartyShinhanCnt  -- 신한
 ,	CASE WHEN SUM(third_party_shinhan_count) > 0 THEN 
	convert(numeric(10,1), ISNULL(SUM(convert(float, third_party_shinhan_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) 
	ELSE 0 
	END as ThirdPartyShinhanRate  

 , ISNULL(SUM(l_count),0) AS LgMembershipCnt   -- LG동의
 , CASE WHEN SUM(l_count) > 0 THEN 
	convert(numeric(10,1), ISNULL(SUM(convert(float, l_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) 
   ELSE 0 	
   END as LgMembershipRate  -- LG %

FROM 
(  
  select   
   o.sales_Gubun,   -- 사이트 
   o.order_mem_count,  -- 결제회원
   a.show_count,  -- 노출 회원 
   b.s_count,  -- 삼성
   c.i_count,  -- 일룸 
   d.third_party_comm_count, -- 보험   
   e.third_party_insure_count,   -- 통신 
   f.third_party_shinhan_count	-- 신한
   , g.l_count	-- LG
  from 
	  (  
		select sales_Gubun,  
		 count(1) as order_mem_count  
		from #T as a  
		group by sales_Gubun  
	  ) as o  
     
	  left outer join 
	  --------------------------------------------------------------------------------------------------------------------
	  -- 노출 회원 
	  (  
	   select sales_Gubun,  
		count(1) show_count  
	   from #T AS a  
		inner join S2_UserInfo_TheCard as ui on ui.uid = a.member_id  
	   where  dbo.fn_datediff(smembership_reg_date, INTERGRATION_DATE) > 2  
		or (  
		 smembership_reg_date is null  
		)  
	   group by sales_Gubun  
	  ) as a on o.sales_Gubun = a.sales_Gubun  
	  --------------------------------------------------------------------------------------------------------------------
  
	  left outer join 
	  (  
		--------------------------------------------------------------------------------------------------------------------
		--// 삼성
	   select a.sales_Gubun, count(1) as s_count  
	   from #T2 as a  
	   inner join S2_UserInfo_TheCard as ui on a.member_id = ui.uid  
	   inner join EVENT_MARKETING_AGREEMENT ema on ui.uid = ema.uid  
	   group by a.sales_Gubun  
		 --------------------------------------------------------------------------------------------------------------------

	  ) as b on a.sales_Gubun = b.sales_Gubun  
    
	  left outer join 
	  (
		--------------------------------------------------------------------------------------------------------------------
		--// 일룸
	   select a.sales_Gubun, count(1) as i_count  
	   from #T2 as a  
	   inner join S2_UserInfo_TheCard as ui on a.member_id = ui.uid  
	   inner join EVENT_MARKETING_AGREEMENT ema on ui.uid = ema.uid  
	   group by a.sales_Gubun  
	  ) as c on a.sales_Gubun = c.sales_Gubun  
	  --------------------------------------------------------------------------------------------------------------------
  
	  left outer join 
	  (
		--------------------------------------------------------------------------------------------------------------------
		--// 보험
	   select a.sales_Gubun, count(1) as third_party_comm_count  
	   from #T2 as a  
		inner join (  
		 select uid,  
		  isnull(max(case when marketing_type_code = '119001' then 1 else 0 end), 0) as third_party_comm,  
		  max(case when marketing_type_code = '119001' then REG_DATE else null end) as third_party_comm_reg_date,  
		  isnull(max(case when marketing_type_code = '119005' then 1  else 0  end), 0) as third_party_insure,  
		  max(case when marketing_type_code = '119005' then REG_DATE else 0 end) as third_party_insure_reg_date  
		 from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT  
		 group by uid  
		) as b on a.member_id = b.UID  
		inner join EVENT_MARKETING_AGREEMENT ema on a.member_id= ema.uid  
	   group by a.sales_Gubun  
		 --------------------------------------------------------------------------------------------------------------------

	  )  as d on a.sales_Gubun = d.sales_Gubun  
  
	  left outer join 
	  (
		--------------------------------------------------------------------------------------------------------------------
		--// 통신
	   select a.sales_Gubun
			, count(1) as third_party_insure_count  
	   from #T2 as a  
		inner join (  
		 select   
		  uid,  
		  isnull(max(case when marketing_type_code = '119001' then 1 else 0 end), 0) as third_party_comm,  
		  max(case when marketing_type_code = '119001' then REG_DATE else null end) as third_party_comm_reg_date,  
		  isnull(max(case when marketing_type_code = '119005' then 1  else 0  end), 0) as third_party_insure,  
		  max(case when marketing_type_code = '119005' then REG_DATE else 0 end) as third_party_insure_reg_date  
		 from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT  
		 group by uid  
		) as b  
		 on a.member_id = b.UID  
		inner join EVENT_MARKETING_AGREEMENT ema  
		 on a.member_id= ema.uid  
	   group by a.sales_Gubun  
	  --------------------------------------------------------------------------------------------------------------------

	  ) as e on a.sales_Gubun = e.sales_Gubun  
   
	  left outer join 
	  (
		--------------------------------------------------------------------------------------------------------------------
		--// 신한
	   select a.sales_Gubun
			, count(1) as third_party_shinhan_count  
	   from #T2 as a  
		inner join (  
		 select   
		  uid,  
		  isnull(max(case when marketing_type_code = '119006' then 1  else 0  end), 0) as third_party_shinhan,  
		  max(case when marketing_type_code = '119006' then REG_DATE else 0 end) as third_party_shinhan_reg_date  
		 from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT  
		 group by uid  
		) as b  
		 on a.member_id = b.UID  
		inner join EVENT_MARKETING_AGREEMENT ema  
		 on a.member_id= ema.uid  
	   group by a.sales_Gubun  
	  --------------------------------------------------------------------------------------------------------------------

	  ) as f on a.sales_Gubun = f.sales_Gubun  
	  
	  left outer join 
	  (  
		--------------------------------------------------------------------------------------------------------------------
		--// LG
	   select a.sales_Gubun, count(1) as l_count  
	   from #T2 as a  
	   inner join S2_UserInfo_TheCard as ui on a.member_id = ui.uid  
	   inner join EVENT_MARKETING_AGREEMENT ema on ui.uid = ema.uid  
	   group by a.sales_Gubun  
		 --------------------------------------------------------------------------------------------------------------------

	  ) as g on a.sales_Gubun = g.sales_Gubun  
	  
	 ) as A  
  
GROUP BY A.sales_Gubun WITH ROLLUP   
ORDER BY   
  CASE   
   WHEN A.sales_Gubun = 'SB' THEN 1   
   WHEN A.sales_Gubun = 'SA' THEN 2  
   WHEN A.sales_Gubun = 'ST' THEN 3   
   WHEN A.sales_Gubun = 'SS' THEN 4   
   WHEN A.sales_Gubun = 'B' THEN 5   
   WHEN A.sales_Gubun = 'CE' THEN 6  
   WHEN A.sales_Gubun = 'BE' THEN 7   
   WHEN A.sales_Gubun IS NULL THEN 8  
   ELSE 1   
  END ASC  
  
  
  
END  
  












GO
