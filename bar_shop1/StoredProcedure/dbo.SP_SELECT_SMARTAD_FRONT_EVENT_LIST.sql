IF OBJECT_ID (N'dbo.SP_SELECT_SMARTAD_FRONT_EVENT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_SMARTAD_FRONT_EVENT_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
/*    
    
EXEC SP_SELECT_SMARTAD_EVENT_LIST NULL, 9999, 1, 'REG_DATE', 'DESC', ''    
    
*/    
    
CREATE PROCEDURE [dbo].[SP_SELECT_SMARTAD_FRONT_EVENT_LIST]    
  @P_SEARCH_VALUE AS VARCHAR(100) = ''    
 , @P_PAGE_SIZE AS INT    
 , @P_PAGE_NUMBER AS INT    
 , @P_ORDER_BY_NAME AS VARCHAR(50)    
 , @P_ORDER_BY_TYPE AS VARCHAR(10)    
 , @P_EVENT_SEQ AS VARCHAR(2000)    
AS    
BEGIN    
    
 SET NOCOUNT ON    
    
    
 SELECT *    
 FROM (    
    SELECT ROW_NUMBER() OVER (    
            ORDER BY     
             CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'     THEN C.REG_DATE      ELSE 0 END ASC    
            , C.EVENT_SEQ ASC    
                 
           ) AS ROW_NUM    
     , ROW_NUMBER() OVER (    
            ORDER BY     
             CASE WHEN @P_ORDER_BY_NAME = 'REG_DATE'     THEN C.REG_DATE      ELSE 0 END DESC    
            , C.EVENT_SEQ DESC    
                 
           ) AS ROW_NUM_DESC    
     , *    
    FROM (    
       SELECT      
         SE.EVENT_SEQ    
        ,SE.AD_SEQ    
        ,SE.EVENT_TYPE    
        ,SUBSTRING(SE.USER_NAME,1, LEN(SE.USER_NAME) -1) + '*' AS USER_NAME    
        ,SE.USER_PHONE    
        , SUBSTRING(SE.USER_HPHONE,1, LEN(SE.USER_HPHONE) -4) + '****' AS USER_HPHONE    
        ,SE.USER_EMAIL    
        ,SE.PARAM1    
        ,SE.PARAM2    
        ,SE.PARAM3    
        ,SE.PARAM4    
        ,SE.PARAM5    
        ,SE.PARAM6    
        ,SE.PARAM7    
        ,SE.MEMO    
        ,SE.STATUS_CODE    
        ,CC.DTL_NAME AS STATUS_NAME    
        ,SE.REG_DATE    
        ,SE.UPD_DATE    
        ,SE.UPD_ID    
        ,SE.IMG_URL    
        ,SE.IMG_URL2    
        ,SE.IMG_URL3    
        ,SE.COUPON_CODE    
        ,SE.USER_PWD    
       FROM SMARTAD_EVENT_INFO SE    
        LEFT OUTER JOIN  COMMON_CODE CC ON SE.STATUS_CODE = CC.CMMN_CODE    
       WHERE 1 = 1    
    AND SE.AD_SEQ IN ( 124 )  
       --AND    (ISNULL(@P_SEARCH_VALUE,'') = '' OR SE.USER_NAME = @P_SEARCH_VALUE OR SE.USER_HPHONE = @P_SEARCH_VALUE )    
           
       AND   (    
         ISNULL(@P_SEARCH_VALUE,'') = '' OR     
         SE.USER_NAME = @P_SEARCH_VALUE OR     
         REPLACE(SE.USER_HPHONE,'-','') = @P_SEARCH_VALUE     
          )    
       --AND    (ISNULL(@P_EVENT_SEQ,'') = '' OR SE.STATUS_CODE = @P_EVENT_SEQ )    
      ) C    
    
   ) A    
    
 WHERE 1 = 1    
 AND  CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END > (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE    
 AND  CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END <= @P_PAGE_NUMBER * @P_PAGE_SIZE    
      
 ORDER BY     
  CASE WHEN @P_ORDER_BY_TYPE = 'ASC' THEN A.ROW_NUM ELSE A.ROW_NUM_DESC END ASC    
     
END    
    
    
GO
