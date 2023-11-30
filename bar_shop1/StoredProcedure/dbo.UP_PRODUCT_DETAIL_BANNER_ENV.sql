IF OBJECT_ID (N'dbo.UP_PRODUCT_DETAIL_BANNER_ENV', N'P') IS NOT NULL DROP PROCEDURE dbo.UP_PRODUCT_DETAIL_BANNER_ENV
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
-- =============================================        
-- Author:  nsm        
-- Create date: 2019-06-11    
-- Description: 바/비/더/프 상세페이지 배너 연동    
-- UP_PRODUCT_DETAIL_BANNER 5001, 727 , 'Y', 'N' , null , 'P'     
-- 추가구성품에 배너 들어감, 카드코드와 연관이 없기 때문에 새로 생성     
    
-- EXEC UP_PRODUCT_DETAIL_BANNER_ENV 5001,789 , 'Y', 'Y', '1813CR', 'P'          
    
-- =============================================        
    
CREATE PROCEDURE [dbo].[UP_PRODUCT_DETAIL_BANNER_ENV]    
 @CCOM_SEQ INT    --// 바 5001 / 비 5006 / 더 45007 / 프 5003    
, @MD_SEQ  INT    --// 상세배너 / 중간배너    
, @ITEM_TYPE1_YORN char(1) --// 청첩장, 초대장 Y/N    
, @ITEM_TYPE2_YORN char(1) --// 감사장 Y/N    
, @CARD_CODE varchar(6)  --// 상품코드    
, @PC_GB  char(1)   --// P/M    
    
AS    
BEGIN    
    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
SET NOCOUNT ON;      
    
--// PC 노출    
IF @PC_GB = 'P'     
 BEGIN    
  SELECT SEQ    
   , BANNER_TITLE    
   , PC_BANNER_IMAGE AS BANNER_IMAGE    
   , PC_MOVE_URL  AS MOVE_URL    
   , CASE WHEN ISNULL(PC_NEW_WIN_YORN ,'N') = 'Y' THEN '_BLANK' ELSE '_SELF' END AS TARGET_STR    
   , PC_TITLE AS MD_TITLE  
   , PC_CONTENT AS MD_CONTENT  
    FROM S4_MD_CHOICE_PRODBANNER WITH(NOLOCK)    
   WHERE USE_YORN  = 'Y'    
     AND ISNULL(PC_SHOW_YORN , 'N')= 'Y'    
     AND COMPANY_SEQ = @CCOM_SEQ    
     AND MD_SEQ  = @MD_SEQ    
     AND CONVERT(CHAR(10), GETDATE(), 120) BETWEEN START_DATE AND END_DATE    
     AND (ITEM_TYPE1_YORN = @ITEM_TYPE1_YORN OR ITEM_TYPE2_YORN = @ITEM_TYPE2_YORN)
  
    
   ORDER BY SORT ASC     
 END    
ELSE    
    
--// 모바일 노출    
 BEGIN    
  SELECT SEQ    
   , BANNER_TITLE    
   , MO_BANNER_IMAGE AS BANNER_IMAGE    
   , MO_MOVE_URL  AS MOVE_URL    
   , CASE WHEN ISNULL(PC_NEW_WIN_YORN ,'N') = 'Y' THEN '_BLANK' ELSE '_SELF' END AS TARGET_STR    
   , MO_TITLE AS MD_TITLE  
   , MO_CONTENT AS MD_CONTENT  
    FROM S4_MD_CHOICE_PRODBANNER WITH(NOLOCK)    
   WHERE USE_YORN  = 'Y'    
     AND ISNULL(MO_SHOW_YORN , 'N')= 'Y'    
     AND COMPANY_SEQ = @CCOM_SEQ    
     AND MD_SEQ  = @MD_SEQ    
     AND CONVERT(CHAR(10), GETDATE(), 120) BETWEEN START_DATE AND END_DATE 
	 AND ( ITEM_TYPE1_YORN = @ITEM_TYPE1_YORN OR ITEM_TYPE2_YORN = @ITEM_TYPE2_YORN)  
  
   ORDER BY SORT ASC     
 END    
END 
GO
