IF OBJECT_ID (N'dbo.SP_SELECT_S4_MD_CHOICE_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S4_MD_CHOICE_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
/*    
     
    SELECT *    
    FROM S4_MD_CHOICE_STR    
    WHERE COMPANY_SEQ = 5001    
    
    SELECT *    
    FROM S4_MD_CHOICE    
    WHERE MD_SEQ = 380    
    AND  SEQ = 7676    
     
    EXEC SP_SELECT_S4_MD_CHOICE_INFO 388, 8783    
  
*/    
    
CREATE PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_INFO]    
    @MD_SEQ AS INT    
,   @SEQ AS INT    
 AS    
BEGIN    
  
    SELECT  SEQ    
        ,   MD_SEQ    
        ,   SORTING_NUM    
        ,   ISNULL(CAST(CARD_SEQ AS VARCHAR(10)), '') AS CARD_SEQ    
        ,   CARD_TEXT    
        ,   MD_TITLE    
        ,   MD_CONTENT    
        ,   MD_DESC    
        ,   replace(IMGFILE_PATH, 'http://admin.barunsoncard.com', 'https://admin.barunsoncard.com') as IMGFILE_PATH    
        ,   CUSTOM_IMG    
        ,   LINK_URL    
        ,   CASE WHEN UPPER(LINK_TARGET) = '_SELF' THEN '_SELF' ELSE '_BLANK' END AS LINK_TARGET    
        ,   CLICK_COUNT    
        ,   VIEW_DIV    
        ,   JEHU_VIEW_DIV    
        ,   EVENT_OPEN_YORN    
        ,   ADMIN_ID    
        ,   REG_DATE    
        ,   RECOM_NUM    
        ,   CONVERT(VARCHAR(10), START_DATE, 120) AS START_DATE    
        ,   CONVERT(VARCHAR(10), END_DATE, 120) AS END_DATE    
        ,   ISNULL(SNS_SHARE_YORN, 'N') AS SNS_SHARE_YORN    
        ,   replace(ISNULL(SNS_SHARE_IMAGE_URL, '') , 'http://admin.barunsoncard.com' , 'https://admin.barunsoncard.com') AS SNS_SHARE_IMAGE_URL    
    FROM    S4_MD_CHOICE    
    WHERE   1 = 1    
    AND     MD_SEQ = @MD_SEQ    
    AND     SEQ = @SEQ    
  
END  
GO
