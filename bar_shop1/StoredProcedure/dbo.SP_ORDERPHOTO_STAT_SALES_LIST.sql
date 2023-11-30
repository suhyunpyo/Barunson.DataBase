IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_STAT_SALES_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_STAT_SALES_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************
-- SP Name       : SP_ORDERPHOTO_STAT_SALES_LIST
-- Author        : 변미정
-- Create date   : 2023-03-02
-- Description   : 이미지보정 매출통계
-- Update History:
-- Comment       : 
*******************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_STAT_SALES_LIST]
      @SearchType          TINYINT             --검색구분 (1:일별, 2:월별)     
     ,@SearchYear          CHAR(4)                          
     ,@SearchMonth         CHAR(2)     = NULL    

     ,@ErrNum              INT             OUTPUT
     ,@ErrSev              INT             OUTPUT
     ,@ErrState            INT             OUTPUT
     ,@ErrProc             VARCHAR(50)     OUTPUT
     ,@ErrLine             INT             OUTPUT
     ,@ErrMsg              VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON

BEGIN 
    BEGIN TRY

        DECLARE @StartDate  DATETIME
        DECLARE @EndDate    DATETIME
        DECLARE @ToDay      DATETIME

        SET @ToDay = CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),121))
        SET @SearchMonth = RIGHT('00'+@SearchMonth,2)

         IF ISNULL(@SearchType,1) = 1 BEGIN
             SET @StartDate = CONVERT (DATETIME, @SearchYear +'-'+@SearchMonth+'-01 00:00:00')
             SET @EndDate   = DATEADD(MONTH,1,@StartDate)

             IF DATEDIFF(SECOND,@ToDay,@StartDate) >= 0 BEGIN
                SET @StartDate = @ToDay       
                SET @EndDate = DATEADD(DAY,-1,@ToDay)
             END 
     
             IF DATEDIFF(SECOND,@ToDay,@EndDate) >= 0 BEGIN
                SET @EndDate = @ToDay
             END 
     
             SELECT B.[VALUE] AS YMD
                   ,SUM(ISNULL(TOTAL_PRICE,0)) AS TOTALPRICE
                   ,SUM(ISNULL(TOTAL_CNT,0)) AS TOTALCNT
                   ,SUM(ISNULL(TOTAL_CANCEL_PRICE,0)) AS TOTALCANCELPRICE
                   ,SUM(ISNULL(TOTAL_CANCEL_CNT,0)) AS TOTALCANCELCNT
             FROM (
                 SELECT CONVERT(VARCHAR(10),REG_DATE,121) AS YMD 
                       ,SUM(SETTLE_PRICE)  AS TOTAL_PRICE
                       ,SUM(1) AS TOTAL_CNT
                       ,0 AS TOTAL_CANCEL_PRICE
                       ,0 AS TOTAL_CANCEL_CNT
                 FROM IMAGE_ORDER_PG
                 WHERE REG_DATE >=@StartDate AND REG_DATE<@EndDate
                 AND   PAY_STATUS IN (1,2)
                 GROUP BY CONVERT(VARCHAR(10),REG_DATE,121)

                 UNION ALL
                 SELECT CONVERT(VARCHAR(10),CANCEL_DATE,121) AS YMD
                       ,0 AS TOTAL_PRICE
                       ,0 AS TOTAL_CNT
                       ,SUM(SETTLE_PRICE)  AS TOTAL_CANCEL_PRICE
                       ,SUM(1) AS TOTAL_CANCEL_CNT
                 FROM IMAGE_ORDER_PG
                 WHERE CANCEL_DATE >=@StartDate AND CANCEL_DATE<@EndDate
                 AND   PAY_STATUS = 2
                 GROUP BY CONVERT(VARCHAR(10),CANCEL_DATE,121)
            ) A
            RIGHT OUTER JOIN DBO.FN_YYYYMMDD(@StartDate,DATEADD(DAY,-1,@EndDate)) B ON A.YMD=B.[VALUE]
            GROUP BY B.[VALUE]
            ORDER BY B.[VALUE] DESC
        END
        ELSE BEGIN    

             SET @StartDate = CONVERT (DATETIME, @SearchYear +'-01-01 00:00:00')
             SET @EndDate   = DATEADD(YEAR,1,@StartDate)

              IF DATEDIFF(SECOND,@ToDay,@StartDate) >= 0 BEGIN
                SET @StartDate = @ToDay       
                SET @EndDate = DATEADD(DAY,-1,@ToDay)
             END 
     
             IF DATEDIFF(SECOND,@ToDay,@EndDate) >= 0 BEGIN
                SET @EndDate = @ToDay
             END 
     
             SELECT A.YMD AS YMD
                   ,SUM(ISNULL(TOTAL_PRICE,0)) AS TOTALPRICE
                   ,SUM(ISNULL(TOTAL_CNT,0)) AS TOTALCNT
                   ,SUM(ISNULL(TOTAL_CANCEL_PRICE,0)) AS TOTALCANCELPRICE
                   ,SUM(ISNULL(TOTAL_CANCEL_CNT,0)) AS TOTALCANCELCNT   
             FROM (
                 SELECT CONVERT(VARCHAR(7),REG_DATE,121) AS YMD 
                       ,SUM(SETTLE_PRICE)  AS TOTAL_PRICE
                       ,SUM(1) AS TOTAL_CNT
                       ,0 AS TOTAL_CANCEL_PRICE
                       ,0 AS TOTAL_CANCEL_CNT
                 FROM IMAGE_ORDER_PG
                 WHERE REG_DATE >=@StartDate AND REG_DATE<@EndDate
                 AND   PAY_STATUS IN (1,2)
                 GROUP BY CONVERT(VARCHAR(7),REG_DATE,121)

                 UNION ALL
                 SELECT CONVERT(VARCHAR(7),CANCEL_DATE,121) AS YMD
                       ,0 AS TOTAL_PRICE
                       ,0 AS TOTAL_CNT
                       ,SUM(SETTLE_PRICE)  AS TOTAL_CANCEL_PRICE
                       ,SUM(1) AS TOTAL_CANCEL_CNT
                 FROM IMAGE_ORDER_PG
                 WHERE CANCEL_DATE >=@StartDate AND CANCEL_DATE<@EndDate
                 AND   PAY_STATUS = 2
                 GROUP BY CONVERT(VARCHAR(7),CANCEL_DATE,121)
            ) A
            GROUP BY YMD
            ORDER BY YMD DESC
        END
    END TRY
    BEGIN CATCH
    
        SET @ErrNum   = ERROR_NUMBER()
        SET @ErrSev   = ERROR_SEVERITY()
        SET @ErrState = ERROR_STATE()
        SET @ErrProc  = ERROR_PROCEDURE()
        SET @ErrLine  = ERROR_LINE()
        SET @ErrMsg   = ERROR_MESSAGE();
        RETURN  
        
    END CATCH
END
 

GO
