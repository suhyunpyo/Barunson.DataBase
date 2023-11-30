IF OBJECT_ID (N'dbo.SP_SELECT_S4_MD_CHOICE_LIST_INCLUDE_DATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S4_MD_CHOICE_LIST_INCLUDE_DATE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*      
      
EXEC SP_SELECT_S4_MD_CHOICE_LIST_INCLUDE_DATE 380, 'Y'      
      
*/      
  
CREATE PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_LIST_INCLUDE_DATE]      
    @MD_SEQ AS INT      
,   @VIEW_DIV AS VARCHAR(1) = ''      
 AS      
BEGIN      
      
    SELECT  ROW_NUMBER() OVER(ORDER BY SORTING_NUM ASC) AS ROW_NUM      
        ,   SEQ      
        ,   MD_SEQ      
        ,   SORTING_NUM      
        ,   CARD_SEQ      
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
        ,   ADMIN_ID      
        ,   REG_DATE      
        ,   RECOM_NUM      
        ,   ISNULL(CONVERT(VARCHAR(10), START_DATE, 120), '') AS START_DATE      
        ,   ISNULL(CONVERT(VARCHAR(10), END_DATE, 120), '') AS END_DATE      
  , ISNULL(SNS_SHARE_YORN, 'N') AS SNS_SHARE_YORN      
  , ISNULL(SNS_SHARE_IMAGE_URL, '') AS SNS_SHARE_IMAGE_URL      
  , ISNULL(SNS_TYPE, '') AS SNS_TYPE      
    FROM    S4_MD_CHOICE      
    WHERE   1 = 1      
    AND     MD_SEQ = @MD_SEQ    
    AND 	CONVERT(CHAR(10), GETDATE(), 120) BETWEEN START_DATE AND END_DATE 
    AND     (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN VIEW_DIV ELSE '' END)      
            =      
            (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN @VIEW_DIV ELSE '' END)      

    ORDER BY SORTING_NUM ASC      
      
END 
GO
