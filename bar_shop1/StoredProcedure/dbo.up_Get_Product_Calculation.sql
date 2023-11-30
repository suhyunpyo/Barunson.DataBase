IF OBJECT_ID (N'dbo.up_Get_Product_Calculation', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Get_Product_Calculation
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  유우종  
-- Create date: 2016-08-11  
-- Description: 카드 제작일정 계산  
-- TEST: exec up_Get_Product_Calculation '2016-08-12', 10, 'C', 35700, 5007  
-- =============================================  
CREATE PROCEDURE [dbo].[up_Get_Product_Calculation]    
 @input_date VARCHAR(10), --입력일자  
 @input_time INT,   --입력시간  
 @input_gb CHAR(1),   --입력구분(C:초안, D:배송)  
 @card_seq INT = 0,  
 @company_seq INT  
AS  
BEGIN   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED   
SET NOCOUNT ON;  
   
 DECLARE @add_days INT = 0 --카드 조건에 따라  추가되는 일 수  
  
 DECLARE @CardKind_Seq INT, @isCustomDColor CHAR(1), @PrintMethod1 CHAR(1), @PrintMethod2 CHAR(1), @PrintMethod3 CHAR(1),   
   @Master_2Color CHAR(1), @isLaser CHAR(1), @isRepinart CHAR(1), @isJigunamu CHAR(1)          
  
 SELECT   
  @CardKind_Seq = MAX(F.CardKind_Seq),    --카드기본정보(1:청첩장, 14:커스텀디지털카드)  
  @isCustomDColor = ISNULL(D.isCustomDColor, '0'), --정책옵션(0:해당없음, 1:커스텀디지털인쇄)  
  @PrintMethod1 = LEFT(D.PrintMethod, 1),    --특수인쇄_박(0:해당없음, G:금박,)   
  @PrintMethod2 = SUBSTRING(D.PrintMethod, 2, 1),  --특수인쇄_광(0:해당없음, 유광:1)  
  @PrintMethod3 = RIGHT(D.PrintMethod, 1),   --특수인쇄_압(0:해당없음, 형압:1)  
  @Master_2Color = ISNULL(D.Master_2Color, '0'),  --정책옵션(0:해당없음, 1:마스터2도)  
  @isLaser = ISNULL(D.isLaser, '0'),     --레이저컷(0:해당없음, 1:외부, 2:내부)  
  @isRepinart = ISNULL(D.isRepinart, '0'),   --레핀아트(0:해당없음, 1:팝아트)  
  @isJigunamu = ISNULL(D.isJigunamu, '0')    --지구나무(0:해당없음, 1:손수건, 2:수첩, 3:풍선)  
 FROM S2_CardSalesSite A   
  INNER JOIN S2_Card B ON A.Card_Seq = B.Card_Seq   
  INNER JOIN S2_CardDetail C ON A.Card_Seq = C.Card_Seq   
  INNER JOIN S2_CardOption D ON A.Card_Seq = D.Card_Seq   
  INNER JOIN S2_CardKind F ON A.Card_Seq = F.Card_Seq   
 WHERE A.Card_Seq = @card_seq   
  AND A.Company_Seq = @company_seq  
 GROUP BY isCustomDColor, PrintMethod, master_2color, isLaser, isRepinart, isJigunamu  
  
 --SELECT @CardKind_Seq AS CardKind_Seq, @isCustomDColor AS isCustomDColor, @PrintMethod1 AS PrintMethod1, @PrintMethod2 AS PrintMethod2, @PrintMethod3 AS PrintMethod3,   
 --@Master_2Color AS Master_2Color, @isLaser AS isLaser, @isRepinart AS isRepinart, @isJigunamu AS isJigunamu  
   
 IF @card_seq > 0  
  BEGIN   
   IF @input_gb = 'C' --초안  
    BEGIN   
     IF @isJigunamu <> '0'   
      BEGIN  
       SET @add_days = 1  
      END  
     ELSE IF @isRepinart <> '0'  
      BEGIN  
       SET @add_days = 5  
      END  
     ELSE IF @CardKind_Seq = 14  
      BEGIN  
       SET @add_days = 1  
      END  
     ELSE IF @input_time >= 13  
      BEGIN  
       SET @add_days = 1  
      END  
     ELSE  
      BEGIN  
       SET @add_days = 0  
      END  
    END  
   ELSE --배송  
    BEGIN  
     IF @isJigunamu <> '0'   
      BEGIN    
       SET @add_days = 5  
      END  
     ELSE IF @isRepinart <> '0'  
      BEGIN  
       SET @add_days = 3  
      END  
     ELSE IF @CardKind_Seq = 14  
      BEGIN    
       SET @add_days = 3  
  
       IF @isLaser <> '0' OR @PrintMethod1 <> '0'  
        BEGIN  
         SET @add_days = @add_days + 1  
        END  
      END  
     ELSE IF @PrintMethod1 <> '0' --20180724 박일경우, 하루 추가  
      BEGIN  
       SET @add_days = 3  
      END  
     ELSE  
      BEGIN  
       SET @add_days = 1  
  
       IF @isLaser <> '0' OR @PrintMethod1 <> '0' OR @PrintMethod3 <> '0' OR @Master_2Color <> '0'  
        BEGIN  
         SET @add_days = @add_days + 1  
        END  
      END  
  
     IF @input_time >= 13 
      BEGIN  
       SET @add_days = @add_days + 1  
      END  
    END  
  END  
  
 --휴일, 주말 적용  
 SELECT [dbo].[fn_IsWorkDay](@input_date, @add_days + 1) AS OUTPUT_DATE  
  
END  
  
GO
