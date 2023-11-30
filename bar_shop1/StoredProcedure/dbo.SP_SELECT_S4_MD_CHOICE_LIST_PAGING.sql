IF OBJECT_ID (N'dbo.SP_SELECT_S4_MD_CHOICE_LIST_PAGING', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_S4_MD_CHOICE_LIST_PAGING
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*    
    
EXEC SP_SELECT_S4_MD_CHOICE_LIST_PAGING 614, 'Y', 6, 1  
    
20180426 페이지가능한 MD_LIST - 바른손에서 사용함(기획전)  
  
*/    
CREATE PROCEDURE [dbo].[SP_SELECT_S4_MD_CHOICE_LIST_PAGING]    
        @MD_SEQ             AS  INT    
    ,   @VIEW_DIV           AS  VARCHAR(1)  =   ''    
    ,   @PAGE_SIZE          AS  INT = 10  
    ,   @PAGE_NUMBER        AS  INT = 1   
 AS    
BEGIN    
  
    /* 전체 카운터 */  
    SELECT  COUNT(*) TOTAL_COUNT  
    FROM    S4_MD_CHOICE    
    WHERE   1 = 1    
    AND     MD_SEQ = @MD_SEQ    
    --AND     CAST(CONVERT(VARCHAR(8), START_DATE, 112) AS NUMERIC) <=  CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC)  
    --AND     CAST(CONVERT(VARCHAR(8), END_DATE, 112) AS NUMERIC)   >=  CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC)   
    AND     (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN VIEW_DIV ELSE '' END)  
            =  
            (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN @VIEW_DIV ELSE '' END)  
    
      
    /* 해당 페이지 출력 리스트 */  
    SELECT  ROW_NUMBER() OVER(ORDER BY SORTING_NUM ASC) AS ROW_NUM    
        ,   SEQ    
        ,   MD_SEQ    
        ,   SORTING_NUM    
        ,   CARD_SEQ    
        ,   CARD_TEXT    
        ,   ISNULL(MD_TITLE, '') AS MD_TITLE    
        ,   ISNULL(MD_CONTENT, '') AS MD_CONTENT    
        ,   ISNULL(MD_DESC, '') AS MD_DESC    
        ,   replace(ISNULL(IMGFILE_PATH, '') , 'http://admin.barunsoncard.com' , 'https://admin.barunsoncard.com') AS IMGFILE_PATH    
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
        ,   ISNULL(SNS_SHARE_YORN, 'N') AS SNS_SHARE_YORN    
        ,   ISNULL(SNS_SHARE_IMAGE_URL, '') AS SNS_SHARE_IMAGE_URL    
        ,   ISNULL(SNS_TYPE, '') AS SNS_TYPE    
        ,   CASE   
                WHEN   
                    CAST(CONVERT(VARCHAR(8), START_DATE, 112) AS NUMERIC) >  CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC) OR   
                    CAST(CONVERT(VARCHAR(8), END_DATE, 112) AS NUMERIC)   <  CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC)   
                THEN 'N'   
                ELSE 'Y'   
            END  
            AS MD_ING  
    FROM    S4_MD_CHOICE    
    WHERE   1 = 1    
    AND     MD_SEQ = @MD_SEQ    
    --AND     CAST(CONVERT(VARCHAR(8), START_DATE, 112) AS NUMERIC) <=  CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC)  
    --AND     CAST(CONVERT(VARCHAR(8), END_DATE, 112) AS NUMERIC)   >=  CAST(CONVERT(VARCHAR(8), GETDATE(), 112) AS NUMERIC)   
    AND     (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN VIEW_DIV ELSE '' END)  
            =  
            (CASE WHEN @VIEW_DIV IN ( 'Y' , 'N' ) THEN @VIEW_DIV ELSE '' END)  
      
    ORDER BY SORTING_NUM ASC    
      
    OFFSET @PAGE_SIZE * (@PAGE_NUMBER - 1) ROWS FETCH NEXT @PAGE_SIZE ROWS ONLY    
  
END 
GO
