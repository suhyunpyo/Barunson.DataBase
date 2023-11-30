IF OBJECT_ID (N'dbo.SP_REPORT_SIGN_UP_AND_USER_INFORMATION', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_SIGN_UP_AND_USER_INFORMATION
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
  
EXEC SP_REPORT_SIGN_UP_AND_USER_INFORMATION '2017-05-01', '2017-05-21'  
  
  
SP_REPORT_SIGN_UP_AND_USER_INFORMATION_VER2  @P_START_DATE  = '2023-02-06' ,  @P_END_DATE = '2023-02-13'  
  
SP_REPORT_SIGN_UP_AND_USER_INFORMATION_VER2_TEST  @P_START_DATE  = '2023-02-06' ,  @P_END_DATE = '2023-02-13'  

원본 -> SP_REPORT_SIGN_UP_AND_USER_INFORMATION_BACKUP

EXEC SP_REPORT_SIGN_UP_AND_USER_INFORMATION @P_START_DATE  = '2023-02-16' ,  @P_END_DATE = '2023-02-23'  


EXEC SP_REPORT_SIGN_UP_AND_USER_INFORMATION_TEST @P_START_DATE  = '2023-02-16' ,  @P_END_DATE = '2023-02-23'  
*/  
  
CREATE PROCEDURE [dbo].[SP_REPORT_SIGN_UP_AND_USER_INFORMATION]  
  @P_START_DATE  AS VARCHAR(10)  
 , @P_END_DATE   AS VARCHAR(10)  
AS  
BEGIN  
  
 SET NOCOUNT ON  
  
  
 SELECT A.SITE_DIV AS RegisterSalesGubun  
  , CASE   
    WHEN A.SITE_DIV = 'SB' THEN '바른손카드'  
    WHEN A.SITE_DIV = 'SA' THEN '비핸즈카드(운영중단)'  
    WHEN A.SITE_DIV = 'ST' THEN '더카드'  
    WHEN A.SITE_DIV = 'SS' THEN '프리미어페이퍼'  
    WHEN A.SITE_DIV = 'B' THEN '바른손몰'  
    WHEN A.SITE_DIV = 'CE' THEN '셀레모(운영중단)'  
    WHEN A.SITE_DIV = 'BE' THEN '비웨딩(운영중단)'  
    WHEN A.SITE_DIV = 'GS' THEN '바른손G샵'  
    WHEN A.SITE_DIV = 'BM' THEN '바른손M카드'  
    WHEN A.SITE_DIV IS NULL THEN '합계'  
    ELSE ''  
   END AS RegisterSalesGubunSiteName  
  , SUM(A.ALL_SIGN_UP_COUNT) AS AllSignUpCnt  
  , SUM(A.SIGN_UP_COUNT) AS SignUpCnt  
  , SUM(A.MALE_COUNT) AS MaleCnt  
  , SUM(A.FEMALE_COUNT) AS FemaleCnt  
  , SUM(A.METROPOLITAN_COUNT) AS MetropolitanCnt  
  , SUM(A.COUNTRY_COUNT) AS CountryCnt  
  , SUM(ISNULL(WITHDRAWAL.WITHDRAWAL_COUNT, 0)) AS WithdrawalCount  
  
  , SUM(AGE_20) AS Age20  
  , SUM(AGE_30) AS Age30  
  , SUM(AGE_OTHER) AS AgeOther  
  
  , SUM(THIRD_PARTY_COMMUNICATION_COUNT) AS ThirdPartyCommunicationCnt  
  , SUM(THIRD_PARTY_INSURANCE_COUNT) AS ThirdPartyInsuranceCnt    
  , ISNULL(SUM(SMEMBERSHIP_COUNT),0) AS SamsungMembershipCnt  
  , ISNULL(SUM(IMEMBERSHIP_COUNT),0) AS IloomMembershipCnt  
  , SUM(THIRD_PARTY_SHINHAN_COUNT) AS ThirdPartyShinhanCnt   
  , ISNULL(SUM(LGMEMBERSHIP_COUNT),0) AS LgMembershipCnt  
  
  , CASE   
     WHEN SUM(A.SIGN_UP_COUNT) > 0 THEN CAST(ROUND(100.0 * SUM(THIRD_PARTY_COMMUNICATION_COUNT) / SUM(A.SIGN_UP_COUNT), 1) AS NUMERIC(12, 1))  
     ELSE 0   
   END AS ThirdPartyCommunicationAgreementRate  
  
  , CASE   
     WHEN SUM(A.SIGN_UP_COUNT) > 0 THEN CAST(ROUND(100.0 * SUM(THIRD_PARTY_INSURANCE_COUNT) / SUM(A.SIGN_UP_COUNT), 1) AS NUMERIC(12, 1))   
     ELSE 0  
   END AS ThirdPartyInsuranceAgreementRate  
  
  , CASE   
     WHEN SUM(A.SIGN_UP_COUNT) > 0 THEN CAST(ROUND(100.0 * ISNULL(SUM(SMEMBERSHIP_COUNT),0) / SUM(A.SIGN_UP_COUNT), 1) AS NUMERIC(12, 1))   
     ELSE 0  
   END AS SamsungMembershipAgreementRate  
  , CASE   
     WHEN SUM(A.SIGN_UP_COUNT) > 0 THEN CAST(ROUND(100.0 * ISNULL(SUM(IMEMBERSHIP_COUNT),0) / SUM(A.SIGN_UP_COUNT), 1) AS NUMERIC(12, 1))   
     ELSE 0  
   END AS IloomMembershipAgreementRate  
  , CASE   
     WHEN SUM(A.SIGN_UP_COUNT) > 0 THEN CAST(ROUND(100.0 * SUM(THIRD_PARTY_SHINHAN_COUNT) / SUM(A.SIGN_UP_COUNT), 1) AS NUMERIC(12, 1))   
     ELSE 0  
   END AS ThirdPartyShinhanAgreementRate  
  , CASE   
     WHEN SUM(A.SIGN_UP_COUNT) > 0 THEN CAST(ROUND(100.0 * ISNULL(SUM(LGMEMBERSHIP_COUNT),0) / SUM(A.SIGN_UP_COUNT), 1) AS NUMERIC(12, 1))   
     ELSE 0  
   END AS LgMembershipAgreementRate  
  
 FROM (  
  
    SELECT   
     -- CASE   
     --  WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
     --   CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END  
     --  ELSE   
     --   CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END  
     -- END  
  
      CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
       ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END AS SITE_DIV  
     , COUNT(*) AS ALL_SIGN_UP_COUNT  
     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' THEN 1 ELSE 0 END) AS SIGN_UP_COUNT  
     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND ISNULL(SUT.GENDER, 0) = 1 THEN 1 ELSE 0 END) MALE_COUNT  
     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND ISNULL(SUT.GENDER, 0) <> 1 THEN 1 ELSE 0 END) FEMALE_COUNT  
     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND SUBSTRING(ADDRESS, 1, 2) IN ('서울', '경기', '인천') THEN 1 ELSE 0 END) METROPOLITAN_COUNT  







     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND SUBSTRING(ADDRESS, 1, 2) NOT IN ('서울', '경기', '인천') THEN 1 ELSE 0 END) COUNTRY_COUNT  
       
     , SUM(  
        CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND   
        INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND   
        DATEDIFF(YEAR, substring(SUT.BIRTH,0,9)+'01', GETDATE()) >= 20 AND   
        DATEDIFF(YEAR, substring(SUT.BIRTH,0,9)+'01', GETDATE()) < 30 THEN 1 ELSE 0 END  
       ) AGE_20  
     , SUM(  
        CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND   
           INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND   
           DATEDIFF(YEAR, substring(SUT.BIRTH,0,9)+'01', GETDATE()) >= 30 AND   
           DATEDIFF(YEAR, substring(SUT.BIRTH,0,9)+'01', GETDATE()) < 40 THEN 1 ELSE 0 END  
       ) AGE_30,   
     SUM(  
       CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND   
       INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND   
       (DATEDIFF(YEAR, substring(SUT.BIRTH,0,9)+'01', GETDATE()) < 20 OR   
       DATEDIFF(YEAR, substring(SUT.BIRTH,0,9)+'01', GETDATE()) >= 40) THEN 1 ELSE 0 END  
      ) AGE_OTHER  
     /*  
     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND ISNULL(SUT.MKT_CHK_FLAG, 'N') = 'Y' AND TP.THIRD_PARTY_COMMUNICATION = 1 THEN 1 ELSE 0 






  
  
  
END) THIRD_PARTY_COMMUNICATION_COUNT  
     , SUM(CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND ISNULL(SUT.MKT_CHK_FLAG, 'N') = 'Y' AND TP.THIRD_PARTY_INSURANCE = 1 THEN 1 ELSE 0 END)






  
  
  
 THIRD_PARTY_INSURANCE_COUNT  
     */  
     , SUM(  
       CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND   
          INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND   
          ISNULL(SUT.MKT_CHK_FLAG, 'N') = 'Y' AND   
          TP.THIRD_PARTY_COMMUNICATION = 1 AND   
          dbo.fn_datediff(TP.THIRD_PARTY_COMMUNICATION_DT, SUT.INTERGRATION_DATE) < 5  THEN 1 ELSE 0 END  
       ) THIRD_PARTY_COMMUNICATION_COUNT  
   , SUM(  
       CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND   
          INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND   
          ISNULL(SUT.MKT_CHK_FLAG, 'N') = 'Y' AND TP.THIRD_PARTY_INSURANCE = 1 AND   
          dbo.fn_datediff( TP.THIRD_PARTY_INSURANCE_DT, SUT.INTERGRATION_DATE) < 5 THEN 1 ELSE 0 END  
       ) THIRD_PARTY_INSURANCE_COUNT  
     , SUM(  
       CASE WHEN INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND   
          INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00' AND   
          ISNULL(SUT.MKT_CHK_FLAG, 'N') = 'Y' AND TP.THIRD_PARTY_SHINHAN = 1 AND   
          dbo.fn_datediff(TP.THIRD_PARTY_SHINHAN_DT, SUT.INTERGRATION_DATE) < 5 THEN 1 ELSE 0 END) THIRD_PARTY_SHINHAN_COUNT  
     
    FROM S2_USERINFO_THECARD SUT  
    LEFT   
    JOIN (  
       SELECT UID  
        , ISNULL(MAX(CASE WHEN MARKETING_TYPE_CODE = '119001' THEN 1 ELSE 0 END), 0) AS THIRD_PARTY_COMMUNICATION  
        ,   MAX(CASE WHEN MARKETING_TYPE_CODE = '119001' THEN REG_DATE ELSE 0 END) AS THIRD_PARTY_COMMUNICATION_DT  
        , ISNULL(MAX(CASE WHEN MARKETING_TYPE_CODE = '119005' THEN 1 ELSE 0 END), 0) AS THIRD_PARTY_INSURANCE   
        , MAX(CASE WHEN MARKETING_TYPE_CODE = '119005' THEN REG_DATE ELSE 0 END) AS THIRD_PARTY_INSURANCE_DT  
        , ISNULL(MAX(CASE WHEN MARKETING_TYPE_CODE = '119006' THEN 1 ELSE 0 END), 0) AS THIRD_PARTY_SHINHAN  
        ,  MAX(CASE WHEN MARKETING_TYPE_CODE = '119006' THEN REG_DATE ELSE 0 END) AS THIRD_PARTY_SHINHAN_DT  
       FROM S2_USERINFO_THIRD_PARTY_MARKETING_AGREEMENT  
       GROUP BY UID  
      ) TP ON SUT.UID = TP.UID  
  
    WHERE 1 = 1  
    AND  INTEGRATION_MEMBER_YORN = 'Y'  
  
    and sut.birth <> '' and sut.birth is not null and  sut.birth <> '' and len(sut.birth) = 10  
--    and SUT.reg_date >= @P_START_DATE  
--    AND SUT.reg_date <= @P_END_DATE+' 23:59:59'  
  
    GROUP BY   
      CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END  
  
   ) A  
 LEFT   
 JOIN (  
    SELECT CASE WHEN SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE SITE_DIV END AS SITE_DIV  
     , COUNT(*) AS WITHDRAWAL_COUNT   
    FROM S2_USERBYE_SECESSION_CAUSE  USC   
    WHERE 1 = 1  
    AND  REG_DATE >= @P_START_DATE + ' 00:00:00'  
    AND  REG_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00'  
  
    GROUP BY CASE WHEN SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE SITE_DIV END  
   ) AS WITHDRAWAL ON CASE WHEN A.SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE A.SITE_DIV END = WITHDRAWAL.SITE_DIV  
 LEFT   
 JOIN (   
  SELECT  
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  

           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END AS SITE_DIV,  
  count(1) SMEMBERSHIP_COUNT  
  from S2_UserInfo_TheCard as uit  
   left outer join EVENT_MARKETING_AGREEMENT as ema  
    on uit.uid = ema.uid  
  where chk_smembership = 'Y'  
   and uit.smembership_reg_date is not null  
   and ema.uid is null  
   and convert(varchar(10), uit.smembership_reg_date, 120) = convert(varchar(10), uit.reg_date, 120)  
   and uit.reg_date >= @P_START_DATE + ' 00:00:00' and uit.reg_date <= @P_END_DATE + ' 23:59:59'  
   and uit.smembership_leave_date is null  
  
   --and dbo.fn_datediff(smembership_reg_date, INTERGRATION_DATE) < 5  
   --and INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00'  
  GROUP BY   
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END  
/*   
 SELECT SITE_DIV  
     , COUNT(*) AS SMEMBERSHIP_COUNT   
    FROM (  
      select ISNULL(BB.SELECT_SALES_GUBUN , BYE.SELECT_SALES_GUBUN) SITE_DIV  
      from SAMSUNG_DAILY_INFO A  left JOIN (select uid   
                 , CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END SELECT_SALES_GUBUN   
                from S2_UserInfo_TheCard bb   
                --where convert(varchar(10),bb.smembership_reg_date,120) >= @P_START_DATE  
                --and convert(varchar(10),bb.smembership_reg_date,120) < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120)  
                --and bb.chk_smembership = 'Y'  
                ) bb ON A.UID= bb.UID    
  
             left JOIN (SELECT distinct UID , CASE WHEN ISNULL(SITE_DIV, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SITE_DIV, 'SB') END SELECT_SALES_GUBUN    
                FROM S2_USERBYE_SECESSION_CAUSE) BYE ON A.UID= BYE.UID    
      WHERE A.REG_DATE_S >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)  
      AND  A.REG_DATE_S < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )  
     ) SMEMBERSHIP  
    GROUP BY SMEMBERSHIP.SITE_DIV  
*/  
   ) AS SM_CNT ON CASE WHEN A.SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE A.SITE_DIV END = SM_CNT.SITE_DIV  
 LEFT   
 JOIN (   
  SELECT  
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END AS SITE_DIV,  
  count(1) IMEMBERSHIP_COUNT  
  from S2_UserInfo_TheCard  
  where smembership_reg_date is not null  
   and dbo.fn_datediff(iloommembership_reg_date, INTERGRATION_DATE) < 5  
   and INTERGRATION_DATE >= @P_START_DATE + ' 00:00:00' AND INTERGRATION_DATE < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00'  
  GROUP BY   
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END  
/*   
 SELECT SITE_DIV  
     , COUNT(*) AS SMEMBERSHIP_COUNT   
    FROM (  
      select ISNULL(BB.SELECT_SALES_GUBUN , BYE.SELECT_SALES_GUBUN) SITE_DIV  
      from SAMSUNG_DAILY_INFO A  left JOIN (select uid   
                 , CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END SELECT_SALES_GUBUN   
                from S2_UserInfo_TheCard bb   
                --where convert(varchar(10),bb.smembership_reg_date,120) >= @P_START_DATE  
                --and convert(varchar(10),bb.smembership_reg_date,120) < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120)  
                --and bb.chk_smembership = 'Y'  
                ) bb ON A.UID= bb.UID    
  
             left JOIN (SELECT distinct UID , CASE WHEN ISNULL(SITE_DIV, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SITE_DIV, 'SB') END SELECT_SALES_GUBUN    
                FROM S2_USERBYE_SECESSION_CAUSE) BYE ON A.UID= BYE.UID    
      WHERE A.REG_DATE_S >= CONVERT(VARCHAR(10),DATEADD(DAY,1,@P_START_DATE),120)  
      AND  A.REG_DATE_S < DATEADD(DAY ,  2 , CAST(CONVERT(VARCHAR, @P_END_DATE  ,  23) AS DATETIME)  )  
     ) SMEMBERSHIP  
    GROUP BY SMEMBERSHIP.SITE_DIV  
*/  
   ) AS IM_CNT ON CASE WHEN A.SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE A.SITE_DIV END = IM_CNT.SITE_DIV  
 LEFT   
 JOIN (   
  SELECT  
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END AS SITE_DIV,  
  count(1) LGMEMBERSHIP_COUNT  
  from S2_UserInfo_TheCard a  
   left outer join EVENT_MARKETING_AGREEMENT ema  
    on a.uid = ema.uid  
  where a.chk_lgmembership = 'Y'  
   and a.lgmembership_reg_date is not null  
   and ema.uid is null  
   and convert(varchar(10), a.reg_date, 120) = convert(varchar(10), a.lgmembership_reg_date, 120)  
   and a.reg_date >= @P_START_DATE + ' 00:00:00' AND a.reg_date < CONVERT(VARCHAR(10), DATEADD(DAY, 1, @P_END_DATE), 120) + ' 00:00:00'  
   and a.lgmembership_leave_date is null  
  GROUP BY   
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
        CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'   
          ELSE ISNULL(REFERER_SALES_GUBUN, 'SB')   
        END  
      ELSE    
        CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B'  -- SELECT_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
        ELSE   
           CASE WHEN SELECT_SALES_GUBUN = 'SA'  THEN  -- SELECT_SALES_GUBUN값이 'SA'고   
              CASE WHEN REFERER_SALES_GUBUN IN ('B', 'H', 'C')  THEN 'B'  -- REFERER_SALES_GUBUN값이 'B', 'H', 'C'면 B로 하고   
              else REFERER_SALES_GUBUN  -- 아니면 REFERER_SALES_GUBUN로 대체  
              end  
           else ISNULL(SELECT_SALES_GUBUN, 'SB')   
           end  
  
  
           -- ISNULL(SELECT_SALES_GUBUN, 'SB')   
        END  
      END  
   ) AS LG_CNT ON CASE WHEN A.SITE_DIV IN ('B', 'H', 'C') THEN 'B' ELSE A.SITE_DIV END = LG_CNT.SITE_DIV  
--where A.SITE_DIV <> 'GS'
 GROUP BY A.SITE_DIV WITH ROLLUP   
 ORDER BY   
   CASE   
	WHEN A.SITE_DIV = 'BM' THEN 1  --  '바른손M카드' 
    WHEN A.SITE_DIV = 'SB' THEN 2    --'바른손카드'  
    WHEN A.SITE_DIV = 'ST' THEN 3   --  '더카드'  
    WHEN A.SITE_DIV = 'SS' THEN 4   -- '프리미어페이퍼'  
    WHEN A.SITE_DIV = 'B' THEN 5    --  '바른손몰'
	WHEN A.SITE_DIV = 'GS' THEN 6 --  '바른손G샵'  
	WHEN A.SITE_DIV = 'SA' THEN 7	-- '비핸즈카드'  
    WHEN A.SITE_DIV = 'CE' THEN 8   --  '셀레모'  
    WHEN A.SITE_DIV = 'BE' THEN 9   -- '비웨딩'  

    WHEN A.SITE_DIV IS NULL THEN 10  
    ELSE 1   
   END ASC  
  
END  



GO
