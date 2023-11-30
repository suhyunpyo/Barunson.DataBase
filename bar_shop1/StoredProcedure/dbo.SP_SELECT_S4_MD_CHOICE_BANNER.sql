IF OBJECT_ID (N'dbo.SP_SELECT_S4_MD_CHOICE_BANNER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S4_MD_CHOICE_BANNER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    
    
EXEC SP_SELECT_S4_MD_CHOICE_BANNER 759, 'Y'  
  
배너 기간에 맞게 노출하기   
    
*/    
  
  
  
CREATE PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_BANNER]    
    @MD_SEQ AS INT    
, @VIEW_DIV as char(1)  
  
  
 AS    
BEGIN    
    
    SELECT  ROW_NUMBER() OVER(partition BY A.md_seq ORDER BY A.SORTING_NUM ASC) AS ROW_NUM    
  , *    
  FROM   (SELECT DISTINCT     
   SEQ    
       ,   MD_SEQ    
       ,   SORTING_NUM    
       ,   Z.CARD_SEQ    
       ,   CARD_TEXT    
       ,   ISNULL(MD_TITLE, '') AS MD_TITLE    
       ,   ISNULL(MD_CONTENT, '') AS MD_CONTENT    
       ,   ISNULL(MD_DESC, '') AS MD_DESC    
       ,   replace(ISNULL(IMGFILE_PATH, ''), 'http://', 'https://') AS IMGFILE_PATH    
       ,   CUSTOM_IMG    
       ,   ISNULL(LINK_URL, '') AS LINK_URL    
       ,   LOWER(CASE WHEN UPPER(LINK_TARGET) = '_SELF' THEN '_SELF' ELSE '_BLANK' END) AS LINK_TARGET    
       ,   CLICK_COUNT    
       ,   VIEW_DIV    
       ,   JEHU_VIEW_DIV    
       ,   EVENT_OPEN_YORN    
       ,   Z.ADMIN_ID    
       ,   REG_DATE    
       ,   RECOM_NUM    
       ,   ISNULL(CONVERT(VARCHAR(10), START_DATE, 120), '') AS START_DATE    
       ,   ISNULL(CONVERT(VARCHAR(10), END_DATE, 120), '') AS END_DATE    
       , ISNULL(SNS_SHARE_YORN, 'N') AS SNS_SHARE_YORN    
       , ISNULL(SNS_SHARE_IMAGE_URL, '') AS SNS_SHARE_IMAGE_URL    
  
      FROM    S4_MD_CHOICE Z   
  
      WHERE   1 = 1    
      AND     MD_SEQ = @MD_SEQ     
      AND    (CONVERT(CHAR(10), GETDATE(), 120) BETWEEN START_DATE AND END_DATE      
   or (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN VIEW_DIV ELSE '' END)    
   =    
   (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN @VIEW_DIV ELSE '' END)    
   )  
      ) A    
      ORDER BY SORTING_NUM ASC    
    
END 
GO
