IF OBJECT_ID (N'dbo.SP_REPORT_SIGN_UP_AND_SIGN_IN_BACKUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_REPORT_SIGN_UP_AND_SIGN_IN_BACKUP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
/*  
  
EXEC SP_REPORT_SIGN_UP_AND_SIGN_IN '2017-01-02', '2017-01-02'  
  
*/  
  
CREATE PROCEDURE [dbo].[SP_REPORT_SIGN_UP_AND_SIGN_IN_BACKUP]  
  @P_START_DATE  AS VARCHAR(10)  
 , @P_END_DATE   AS VARCHAR(10)  
AS  
BEGIN  
  
 SET NOCOUNT ON  
  
 SELECT   
   ISNULL(A.REGISTER_SALES_GUBUN, '') AS RegisterSalesGubun  
  , CASE                                     
     WHEN A.REGISTER_SALES_GUBUN = 'SB'   THEN '바른손카드'                     
     WHEN A.REGISTER_SALES_GUBUN = 'SA'   THEN '비핸즈카드'                     
     WHEN A.REGISTER_SALES_GUBUN = 'ST'   THEN '더카드'                      
     WHEN A.REGISTER_SALES_GUBUN = 'SS'   THEN '프리미어페이퍼'                    
     WHEN A.REGISTER_SALES_GUBUN IN ('B', 'C') THEN '비핸즈카드 제휴'                    
     WHEN A.REGISTER_SALES_GUBUN = 'H'   THEN '프리미어페이퍼 제휴'                   
     WHEN A.REGISTER_SALES_GUBUN = 'CE'   THEN '셀레모'                      
     WHEN A.REGISTER_SALES_GUBUN = 'BE'   THEN '비웨딩'                      
     WHEN A.REGISTER_SALES_GUBUN = 'N/A'   THEN '기타'                          
     WHEN A.REGISTER_SALES_GUBUN IS NULL   THEN '합계'                       
     ELSE '바른손카드'                               
   END AS RegisterSalesGubunSiteName   
                               
  , SUM(CASE WHEN A.BARUNSONCARD_LOGIN_CNT   > 0  THEN 1 ELSE 0 END) AS BarunsoncardLoginCnt            
  , SUM(CASE WHEN A.BHANDSCARD_LOGIN_CNT   > 0  THEN 1 ELSE 0 END) AS BhandscardLoginCnt             
  , SUM(CASE WHEN A.THECARD_LOGIN_CNT    > 0  THEN 1 ELSE 0 END) AS ThecardLoginCnt              
  , SUM(CASE WHEN A.PREMIERPAPER_LOGIN_CNT   > 0  THEN 1 ELSE 0 END) AS PremierpaperLoginCnt            
  , SUM(CASE WHEN A.BHANDSCARD_JEHU_LOGIN_CNT  > 0  THEN 1 ELSE 0 END) AS BhandscardJehuLoginCnt            
  , SUM(CASE WHEN A.PREMIERPAPER_JEHU_LOGIN_CNT     > 0  THEN 1 ELSE 0 END) AS PremierpaperJehuLoginCnt           
  , SUM(CASE WHEN A.BEWEDDING_LOGIN_CNT    > 0  THEN 1 ELSE 0 END) AS BeweddingLoginCnt            
  , SUM(CASE WHEN A.NOT_LOGIN_CNT     > 0  THEN 1 ELSE 0 END) AS NotLoginCnt               
                                        
  , SUM(CASE WHEN A.BARUNSONCARD_LOGIN_CNT   > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.BHANDSCARD_LOGIN_CNT   > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.THECARD_LOGIN_CNT    > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.PREMIERPAPER_LOGIN_CNT   > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.BHANDSCARD_JEHU_LOGIN_CNT  > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.PREMIERPAPER_JEHU_LOGIN_CNT     > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.BEWEDDING_LOGIN_CNT    > 0  THEN 1 ELSE 0 END) +                  
   SUM(CASE WHEN A.NOT_LOGIN_CNT     > 0  THEN 1 ELSE 0 END) AS TotalLoginCnt              
                                        
  , COUNT(*) AS TotalRegisterCnt                              
                                        
 FROM (                                     
                                        
    SELECT ISNULL(CONVERT(VARCHAR(10), MAX(VUI.REFERER_SALES_GUBUN)), 'N/A') AS REGISTER_SALES_GUBUN             
     , VUI.UID                                 
     , SUM(CASE WHEN SLI.SALES_GUBUN = 'SB' AND SELECT_SALES_GUBUN <> 'BE'   THEN 1 ELSE 0 END)   AS BARUNSONCARD_LOGIN_CNT    
     , SUM(CASE WHEN SLI.SALES_GUBUN = 'SA' AND SELECT_SALES_GUBUN <> 'BE'   THEN 1 ELSE 0 END)   AS BHANDSCARD_LOGIN_CNT     
     , SUM(CASE WHEN SLI.SALES_GUBUN = 'ST' AND SELECT_SALES_GUBUN <> 'BE'   THEN 1 ELSE 0 END)   AS THECARD_LOGIN_CNT     
     , SUM(CASE WHEN SLI.SALES_GUBUN = 'SS' AND SELECT_SALES_GUBUN <> 'BE'   THEN 1 ELSE 0 END)   AS PREMIERPAPER_LOGIN_CNT    
     , SUM(CASE WHEN SLI.SALES_GUBUN IN ('B', 'C') AND SELECT_SALES_GUBUN <> 'BE' THEN 1 ELSE 0 END)   AS BHANDSCARD_JEHU_LOGIN_CNT   
     , SUM(CASE WHEN SLI.SALES_GUBUN = 'H' AND SELECT_SALES_GUBUN <> 'BE'   THEN 1 ELSE 0 END)   AS PREMIERPAPER_JEHU_LOGIN_CNT   
     , SUM(CASE WHEN SLI.SALES_GUBUN = 'BE'          THEN 1 ELSE 0 END)   AS BEWEDDING_LOGIN_CNT   
     , SUM(CASE WHEN SLI.SALES_GUBUN IS NULL AND SELECT_SALES_GUBUN <> 'BE'  THEN 1 ELSE 0 END)   AS NOT_LOGIN_CNT      
                                        
    FROM (                                  
                                        
       SELECT MAX(UID) AS UID                            
        , MAX(CASE WHEN SELECT_SALES_GUBUN = 'BE' THEN SELECT_SALES_GUBUN ELSE REFERER_SALES_GUBUN END) AS REFERER_SALES_GUBUN  
        , MAX(SELECT_SALES_GUBUN) AS SELECT_SALES_GUBUN                    
        , MAX(INTERGRATION_DATE) AS INTERGRATION_DATE                     
                                        
       FROM VW_USER_INFO                            
       WHERE 1 = 1                              
                                        
       AND  REG_DATE >= @P_START_DATE + ' 00:00:00'                     
       AND  REG_DATE <= @P_END_DATE + ' 23:59:59'                     
       AND  (  
           SITE_DIV = REFERER_SALES_GUBUN   
          OR SITE_DIV = SELECT_SALES_GUBUN   
          OR (SELECT_SALES_GUBUN = 'BE' OR REFERER_SALES_GUBUN = 'BE')  
          OR (SELECT_SALES_GUBUN = 'CE' OR REFERER_SALES_GUBUN = 'CE')  
         )  
                                        
       GROUP BY DUPINFO                             
  
      ) VUI                                 
                                        
    LEFT JOIN S4_LOGINIPINFO SLI                              
     ON VUI.UID = SLI.UID AND SLI.REGDATE >= VUI.INTERGRATION_DATE                     
                                        
    WHERE 1 = 1                                 
                                        
    GROUP BY VUI.UID                                
                                        
   ) A                                     
                                        
 GROUP BY A.REGISTER_SALES_GUBUN                                
                                        
 WITH ROLLUP                                     
                                        
 ORDER BY   
   CASE                                     
     WHEN A.REGISTER_SALES_GUBUN = 'SB'   THEN 1                        
     WHEN A.REGISTER_SALES_GUBUN = 'SA'   THEN 2                        
     WHEN A.REGISTER_SALES_GUBUN = 'ST'   THEN 3                        
     WHEN A.REGISTER_SALES_GUBUN = 'SS'   THEN 4                        
     WHEN A.REGISTER_SALES_GUBUN IN ('B', 'C') THEN 5                        
     WHEN A.REGISTER_SALES_GUBUN = 'H'   THEN 6                        
     WHEN A.REGISTER_SALES_GUBUN = 'CE'   THEN 7                        
     WHEN A.REGISTER_SALES_GUBUN = 'BE'   THEN 8                        
     WHEN A.REGISTER_SALES_GUBUN = 'N/A'   THEN 9                        
     WHEN A.REGISTER_SALES_GUBUN IS NULL   THEN 10                        
     ELSE 1  
   END ASC  
END
GO
