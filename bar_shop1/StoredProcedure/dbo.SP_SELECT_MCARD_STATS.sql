IF OBJECT_ID (N'dbo.SP_SELECT_MCARD_STATS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_MCARD_STATS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC SP_SELECT_MCARD_STATS
*/
CREATE PROCEDURE [dbo].[SP_SELECT_MCARD_STATS]  
AS  
BEGIN  
    --등록일 ==> RegisterTime    SELECT /*모바일초대장 완료월 기준 브랜드별 만료건수*/
            CASE WHEN GROUP_A = 0 THEN 
            CASE WHEN GROUP_B = 1 THEN YearMonth + '_Total'
            ELSE YearMonth 
            END
            WHEN GROUP_A = 1 THEN 'TOTAL' 
            END YearMonth 
            ,ISNULL(SITECODE , '') SITECODE
            ,CNT
    FROM (
               SELECT 
                  C.CompletedTime AS YearMonth
                , C.SITECODE
                , COUNT(C.CompletedTime) AS CNT
                , GROUPING(C.CompletedTime) GROUP_A
                , GROUPING_ID(C.CompletedTime , SITECODE) GROUP_B 

               FROM 
               (
                    SELECT /**/ CONVERT(VARCHAR(7), CompletedTime, 120) AS YearMonth 
                    , CASE WHEN SITECODE IN ('B','H','C') THEN '바른손몰'
                           WHEN SITECODE = 'SB' THEN '바른손'
                           WHEN SiteCode = 'SA' THEN '비핸즈'
                           WHEN SITECODE = 'ST' THEN '더카드'
                           WHEN SITECODE = 'SS' THEN '프리미어'
                           ELSE '셀레모' END AS SITECODE
                    , CONVERT(VARCHAR(7), CompletedTime, 120) AS CompletedTime
                    FROM mcard_Invitation
                    WHERE CompletedTime IS NOT NULL 
                    AND ExpireYN = 'Y'
                    AND DeleteYN = 'Y'
                ) C 
                GROUP BY CompletedTime , SITECODE WITH ROLLUP 
        ) A
END
GO
