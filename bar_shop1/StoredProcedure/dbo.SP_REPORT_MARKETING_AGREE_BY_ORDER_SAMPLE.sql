IF OBJECT_ID (N'dbo.SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- EXEC [SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE] '2020-02-06','2020-02-06'  
-- EXEC [SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE_NAM] '2020-02-06','2020-02-06'  

-- =============================================  
CREATE PROCEDURE [dbo].[SP_REPORT_MARKETING_AGREE_BY_ORDER_SAMPLE]  
 @p_start_date nvarchar(10),  
 @p_end_date nvarchar(10)  
AS  
BEGIN  
  
 select   
  case  
   when sales_Gubun = 'B' OR sales_Gubun = 'H' OR sales_Gubun = 'C'  then 'B'  
   else sales_Gubun  
  end as sales_gubun,   
  member_id  
  INTO   
  #T  
 from CUSTOM_SAMPLE_ORDER as co  
  inner join s2_userinfo_thecard as ui  
   on co.member_id = ui.uid  
 where co.REQUEST_DATE >= @p_start_date + ' 00:00:00'  
  and co.REQUEST_DATE <= @p_end_date + ' 23:59:59'  
  and co.member_id is not null  
  and co.settle_date is not null  
  and sales_Gubun <> 'SD'  
 group by sales_Gubun,  
  member_id;  
  
  
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
  END AS RegisterSalesGubunSiteName  
  
 , ISNULL(SUM(order_mem_count),0) AS OrderMemberCnt  
 , ISNULL(SUM(show_count),0) AS ShowMarketingCnt  
 , ISNULL(SUM(s_count),0) AS SamsungMembershipCnt  
 , CASE WHEN SUM(s_count) > 0 THEN convert(numeric(10,1), ISNULL(SUM(convert(float, s_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) ELSE 0 END as SamsungMembershipRate  
 , ISNULL(SUM(i_count),0) AS IloomMembershipCnt  
 , CASE WHEN SUM(i_count) > 0 THEN convert(numeric(10,1), ISNULL(SUM(convert(float, i_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) ELSE 0 END as IloomMembershipRate  
 , ISNULL(SUM(third_party_comm_count),0) AS ThirdPartyCommunicationCnt  
 ,   CASE WHEN SUM(third_party_comm_count) > 0 THEN convert(numeric(10,1), ISNULL(SUM(convert(float, third_party_comm_count)),0)  * 100 / ISNULL(SUM(convert(float, show_count)),0)) ELSE 0 END as ThirdPartyCommunicationRate  
 , ISNULL(SUM(third_party_insure_count),0) AS ThirdPartyInsuranceCnt  
 , CASE WHEN SUM(third_party_insure_count) > 0 THEN convert(numeric(10,1), ISNULL(SUM(convert(float, third_party_insure_count)),0)  * 100 / ISNULL(SUM(convert(float, show_count)),0)) ELSE 0 END as ThirdPartyInsuranceRate  
 , ISNULL(SUM(third_party_shinhan_count),0) AS ThirdPartyShinhanCnt  
 , CASE WHEN SUM(third_party_shinhan_count) > 0 THEN convert(numeric(10,1), ISNULL(SUM(convert(float, third_party_shinhan_count)),0)  * 100 / ISNULL(SUM(convert(float, show_count)),0)) ELSE 0 END as ThirdPartyShinhanRate  
 , ISNULL(SUM(l_count),0) AS LgMembershipCnt
 , CASE WHEN SUM(l_count) > 0 THEN convert(numeric(10,1), ISNULL(SUM(convert(float, l_count)),0) * 100 / ISNULL(SUM(convert(float, show_count)),0)) ELSE 0 END as LgMembershipRate
FROM (  
  select   
   o.sales_Gubun,  
   o.order_mem_count,  
   a.show_count,  
   b.s_count,  
   c.i_count,  
   d.third_party_comm_count,  
   e.third_party_insure_count , 
   f.third_party_shinhan_count
   , g.l_count
  from (  
    select   
     sales_Gubun,  
     count(1) as order_mem_count  
    from #T as a  
    group by sales_Gubun  
   ) as o  
   left outer join (  
    select  
     sales_Gubun,  
     count(1) show_count  
    from #T AS a  
     inner join S2_UserInfo_TheCard as ui  
      on ui.uid = a.member_id  
    where  dbo.fn_datediff(smembership_reg_date, INTERGRATION_DATE) > 2  
     or (  
      smembership_reg_date is null  
     )  
    group by sales_Gubun  
   ) as a  
    on o.sales_Gubun = a.sales_Gubun  
   left outer join (  
    select   
     a.sales_Gubun,  
     count(1) as s_count  
    from #T as a  
     inner join S2_UserInfo_TheCard as ui  
      on a.member_id = ui.uid  
     inner join EVENT_MARKETING_AGREEMENT ema  
      on ui.uid = ema.uid AND ema.gubun ='S' and ema.created_tmstmp >= @p_start_date + ' 00:00:00' and ema.created_tmstmp <= @p_end_date + ' 23:59:59'  and
	ui.chk_smembership = 'Y'
    group by a.sales_Gubun  
   ) as b	
    on a.sales_Gubun = b.sales_Gubun  
   left outer join (  
    select   
     a.sales_Gubun,  
     count(1) as i_count  
    from #T as a  
     inner join S2_UserInfo_TheCard as ui  
      on a.member_id = ui.uid  
     inner join EVENT_MARKETING_AGREEMENT ema  
      on ui.uid = ema.uid AND ema.gubun ='S' and ema.created_tmstmp >= @p_start_date + ' 00:00:00' and ema.created_tmstmp <= @p_end_date + ' 23:59:59'  
    group by a.sales_Gubun  
   ) as c  
    on a.sales_Gubun = c.sales_Gubun  
   left outer join (  
    select   
     a.sales_Gubun,  
     count(1) as third_party_comm_count  
    from #T as a  
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
      on a.member_id= ema.uid AND ema.gubun ='S' and ema.created_tmstmp >= @p_start_date + ' 00:00:00' and ema.created_tmstmp <= @p_end_date + ' 23:59:59'  
    group by a.sales_Gubun  
   )  as d  
    on a.sales_Gubun = d.sales_Gubun  
   left outer join (  
    select   
     a.sales_Gubun,  
     count(1) as third_party_insure_count  
    from #T as a  
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
      on a.member_id= ema.uid AND ema.gubun ='S' and ema.created_tmstmp >= @p_start_date + ' 00:00:00' and ema.created_tmstmp <= @p_end_date + ' 23:59:59'  
    group by a.sales_Gubun  
   ) as e  
    on a.sales_Gubun = e.sales_Gubun  
   left outer join (  
    select   
     a.sales_Gubun,  
     count(1) as third_party_shinhan_count  
    from #T as a  
     inner join (  
      select   
       uid,  
       isnull(max(case when marketing_type_code = '119006' then 1 else 0 end), 0) as third_party_shinhan,  
       max(case when marketing_type_code = '119006' then REG_DATE else null end) as third_party_shinhan_reg_date  
      from S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT  
      group by uid  
     ) as b  
      on a.member_id = b.UID  
     inner join EVENT_MARKETING_AGREEMENT ema  
      on a.member_id= ema.uid AND ema.gubun ='S' and ema.created_tmstmp >= @p_start_date + ' 00:00:00' and ema.created_tmstmp <= @p_end_date + ' 23:59:59'  
    group by a.sales_Gubun  
   ) as f  
    on a.sales_Gubun = f.sales_Gubun  
   left outer join (  
    select   
     a.sales_Gubun,  
     count(1) as l_count  
    from #T as a  
     inner join S2_UserInfo_TheCard as ui  
      on a.member_id = ui.uid  
     inner join EVENT_MARKETING_AGREEMENT ema  
      on ui.uid = ema.uid AND ema.gubun ='S' and ema.created_tmstmp >= @p_start_date + ' 00:00:00' and ema.created_tmstmp <= @p_end_date + ' 23:59:59'  
    group by a.sales_Gubun  
   ) as g	
    on a.sales_Gubun = g.sales_Gubun  
    
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
