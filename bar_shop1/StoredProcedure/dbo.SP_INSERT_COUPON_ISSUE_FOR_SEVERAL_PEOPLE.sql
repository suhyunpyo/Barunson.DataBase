IF OBJECT_ID (N'dbo.SP_INSERT_COUPON_ISSUE_FOR_SEVERAL_PEOPLE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_COUPON_ISSUE_FOR_SEVERAL_PEOPLE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*  
  
EXEC SP_INSERT_COUPON_ISSUE_FOR_SEVERAL_PEOPLE 12, '', '', '', '', '', '', '', '', '', '', 'N', 0, 's4guest'  


EXEC SP_INSERT_COUPON_ISSUE_FOR_SEVERAL_PEOPLE 6, '', '', '', '', '', '', '', '', '', '', 'Y', 0, 'gpdbs713'  
  
*/  
  
CREATE PROCEDURE [dbo].[SP_INSERT_COUPON_ISSUE_FOR_SEVERAL_PEOPLE]  
  @P_COUPON_MST_SEQ       AS INT  
 , @P_SEARCH_VALUE        AS VARCHAR(100)  
 , @P_SIGN_UP_SITE        AS VARCHAR(50)  
 , @P_SIGN_UP_START_DATE      AS VARCHAR(10)  
 , @P_SIGN_UP_END_DATE       AS VARCHAR(10)  
 , @P_WEDDING_START_DATE      AS VARCHAR(10)  
 , @P_WEDDING_END_DATE       AS VARCHAR(10)  
 , @P_SAMPLE_ORDER_YORN      AS VARCHAR(10)  
 , @P_SAMPLE_ORDER_START_DATE     AS VARCHAR(10)  
 , @P_SAMPLE_ORDER_END_DATE     AS VARCHAR(10)  
 , @P_WEDDING_PLACE       AS VARCHAR(200)  
 , @P_WEDDINGINVITATION_ORDER_YORN    AS VARCHAR(10)  
 , @P_WEDDINGINVITATION_ORDER_QNT    AS INT  
 , @P_SELECT_USER_LIST       AS VARCHAR(8000)  
  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 DECLARE @RETURN_CODE  AS VARCHAR(10)  
 DECLARE @RETURN_MESSAGE  AS VARCHAR(4000)  
  
 /* 쿼리 속도 향상을 위한 기준 날짜 (통합회원 이후 건만 조회) */  
 DECLARE @BASE_DATE AS DATETIME = '2016-07-01 00:00:00';  
  
 DECLARE @T_USERS TABLE  
    (  
   ROW_NUM  INT  
  , UID   VARCHAR(50)  
 )  
  
 DECLARE @T_COUPON TABLE  
    (  
   ROW_NUM    INT  
  , COUPON_DETAIL_SEQ INT  
  , COUPON_MST_SEQ  INT  
  , COUPON_CODE   VARCHAR(50)  
  , DOWNLOAD_ACTIVE_YN VARCHAR(1)  
 )  
   
 IF @P_SELECT_USER_LIST = ''  
 BEGIN  
    
  INSERT INTO @T_USERS (ROW_NUM, UID)  
  
  SELECT ROW_NUMBER() OVER(ORDER BY UId ASC) AS ROW_NUM  
   , UId  
  
  FROM (  
  
     SELECT DISTINCT  
       SUI.UID                AS UId  
  
     FROM S2_USERINFO_THECARD SUI  
  
     WHERE 1 = 1  
  
     AND  SUI.INTERGRATION_DATE >= @BASE_DATE  
  
     /* 샘플 주문 여부 */  
     AND  (  
         (@P_SAMPLE_ORDER_YORN = '')  
        OR (   
           @P_SAMPLE_ORDER_YORN = 'Y'  
          AND  EXISTS  (  
               SELECT MEMBER_ID  
               FROM CUSTOM_SAMPLE_ORDER   
               WHERE MEMBER_ID = SUI.UID  
               AND  REQUEST_DATE >= @BASE_DATE  
               AND  CASE WHEN @P_SAMPLE_ORDER_START_DATE = '' THEN '' ELSE REQUEST_DATE END   
                 >=   
                 @P_SAMPLE_ORDER_START_DATE  
               AND  CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 0 ELSE REQUEST_DATE END   
                 <  
                 CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SAMPLE_ORDER_END_DATE) END   
              )  
         )  
        OR (    
           @P_SAMPLE_ORDER_YORN = 'N'  
          AND NOT EXISTS (  
               SELECT MEMBER_ID   
               FROM CUSTOM_SAMPLE_ORDER   
               WHERE MEMBER_ID = SUI.UID  
               AND  REQUEST_DATE >= @BASE_DATE  
               AND  CASE WHEN @P_SAMPLE_ORDER_START_DATE = '' THEN '' ELSE REQUEST_DATE END   
                 >=   
                 @P_SAMPLE_ORDER_START_DATE  
               AND  CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 0 ELSE REQUEST_DATE END   
                 <  
                 CASE WHEN @P_SAMPLE_ORDER_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SAMPLE_ORDER_END_DATE) END   
              )  
         )  
  
       )  
  
     AND  (  
         (@P_WEDDINGINVITATION_ORDER_YORN = '')  
        OR (  
           @P_WEDDINGINVITATION_ORDER_YORN = 'Y'   
          AND EXISTS (  
            SELECT DISTINCT MEMBER_ID  
            FROM CUSTOM_ORDER CO  
            JOIN CUSTOM_ORDER_WEDDINFO COW ON CO.ORDER_SEQ = COW.ORDER_SEQ  
            WHERE 1 = 1  
            AND  CO.MEMBER_ID = SUI.UID  
            AND  CO.ORDER_DATE >= @BASE_DATE  
            AND  CO.SETTLE_STATUS = 2   
            AND  CO.ORDER_COUNT >= @P_WEDDINGINVITATION_ORDER_QNT  
            AND  CO.UP_ORDER_SEQ IS NULL  
            AND  CO.ORDER_TYPE IN (1,6,7)              
            AND  (@P_WEDDING_PLACE = '' OR @P_WEDDING_PLACE LIKE '%' + LEFT(ISNULL(COW.WEDD_ADDR, ''), 2) + '%')  
           )  
         )  
  
        OR (  
           @P_WEDDINGINVITATION_ORDER_YORN = 'N'   
          AND NOT EXISTS(  
            SELECT DISTINCT MEMBER_ID  
            FROM CUSTOM_ORDER CO  
            JOIN CUSTOM_ORDER_WEDDINFO COW ON CO.ORDER_SEQ = COW.ORDER_SEQ  
            WHERE 1 = 1  
            AND  CO.MEMBER_ID = SUI.UID  
            AND  CO.ORDER_DATE >= @BASE_DATE  
            AND  CO.SETTLE_STATUS = 2   
            AND  CO.ORDER_COUNT >= @P_WEDDINGINVITATION_ORDER_QNT  
            AND  CO.UP_ORDER_SEQ IS NULL  
            AND  CO.ORDER_TYPE IN (1,6,7)  
            AND  (@P_WEDDING_PLACE = '' OR @P_WEDDING_PLACE LIKE '%' + LEFT(ISNULL(COW.WEDD_ADDR, ''), 2) + '%')  
           )  
         )  
       )  
  
     /* 가입 사이트 */  
     AND  (  
         ISNULL(SUI.REFERER_SALES_GUBUN, ISNULL(SELECT_SALES_GUBUN, 'SB')) IN ( SELECT VALUE FROM dbo.[ufn_SplitTable](@P_SIGN_UP_SITE, '|') )  
        OR @P_SIGN_UP_SITE = ''  
       )  
  
     /* 통합회원 가입일 */  
     AND  CASE WHEN @P_SIGN_UP_START_DATE = '' THEN '' ELSE SUI.INTERGRATION_DATE END   
       >=   
       @P_SIGN_UP_START_DATE  
     AND  CASE WHEN @P_SIGN_UP_END_DATE = '' THEN 0 ELSE SUI.INTERGRATION_DATE END   
       <  
       CASE WHEN @P_SIGN_UP_END_DATE = '' THEN 1 ELSE DATEADD(DAY, 1, @P_SIGN_UP_END_DATE) END   
  
     /* 검색어 */  
     AND  (   
         SUI.UID LIKE '%' + @P_SEARCH_VALUE + '%'  
        OR SUI.UNAME LIKE '%' + @P_SEARCH_VALUE + '%'  
       )  
  
     /* 결혼예정일 */  
     AND  CASE WHEN @P_WEDDING_START_DATE = '' THEN '' ELSE SUI.WEDD_YEAR + '-' + SUI.WEDD_MONTH + '-' + SUI.WEDD_DAY END  
       >=  
       @P_WEDDING_START_DATE  
     AND  CASE WHEN @P_WEDDING_END_DATE = '' THEN '' ELSE SUI.WEDD_YEAR + '-' + SUI.WEDD_MONTH + '-' + SUI.WEDD_DAY END  
       <=  
       @P_WEDDING_END_DATE  
    ) A  
 END  
  
 ELSE  
 BEGIN  
  
  INSERT INTO @T_USERS (ROW_NUM, UID)  
  SELECT ROW_NUMBER() OVER(ORDER BY value ASC) AS ROW_NUM  
   , value   
  FROM dbo.[ufn_SplitTable] (@P_SELECT_USER_LIST, '|')  
    
 END  
  
   
 /* 반복 사용 가능한 쿠폰인지 */  
 DECLARE @IS_USE_REPEAT_COUPON AS VARCHAR(1)  
 DECLARE @COUPON_CODE_COUNT AS INT  
 SET @COUPON_CODE_COUNT = ISNULL((SELECT COUNT(*) FROM COUPON_DETAIL WHERE COUPON_MST_SEQ = @P_COUPON_MST_SEQ), 0)  
 SET @IS_USE_REPEAT_COUPON = CASE WHEN @COUPON_CODE_COUNT = 1 THEN 'Y' WHEN @COUPON_CODE_COUNT > 1 THEN 'N' ELSE '' END  
  
 IF @IS_USE_REPEAT_COUPON = 'Y'  
  BEGIN  
  
   INSERT INTO COUPON_ISSUE (COUPON_DETAIL_SEQ, UID, ACTIVE_YN, COMPANY_SEQ, SALES_GUBUN, END_DATE, REG_DATE)  
  
   SELECT CD.COUPON_DETAIL_SEQ  
    , TU.UID  
    , 'Y'  
    , CAS.COMPANY_SEQ  
    , CASE   
       WHEN CAS.COMPANY_SEQ = 5001 THEN 'SB'  
       WHEN CAS.COMPANY_SEQ = 5003 THEN 'SS'  
       WHEN CAS.COMPANY_SEQ = 5006 THEN 'SA'  
       WHEN CAS.COMPANY_SEQ = 5007 THEN 'ST'  
       WHEN CAS.COMPANY_SEQ = 5000 THEN 'B'  
       ELSE 'SB'  
     END  
    , CASE WHEN CM.EXPIRY_CUSTOM_VALUE IS NULL OR CM.EXPIRY_CUSTOM_VALUE = 0 THEN NULL ELSE (CONVERT(VARCHAR(10), DATEADD(DAY, CM.EXPIRY_CUSTOM_VALUE, GETDATE()), 120) + ' 23:59:59.997') END  
    , GETDATE()  
   FROM @T_USERS TU  
  
   JOIN COUPON_DETAIL CD ON 1 = 1  
   JOIN COUPON_MST CM ON CM.COUPON_MST_SEQ = CD.COUPON_MST_SEQ  
   JOIN COUPON_APPLY_SITE CAS ON CAS.COUPON_MST_SEQ = CD.COUPON_MST_SEQ  
   
   WHERE 1 = 1  
   AND  CD.COUPON_MST_SEQ = @P_COUPON_MST_SEQ  
   AND  CD.DOWNLOAD_ACTIVE_YN = 'Y'  
  
   -- AND  TU.UID NOT IN ( SELECT UID FROM COUPON_ISSUE WHERE COUPON_DETAIL_SEQ = CD.COUPON_DETAIL_SEQ )  
  
   AND  (   
      CASE   
       WHEN CAS.COMPANY_SEQ = 5001 THEN 'SB'  
       WHEN CAS.COMPANY_SEQ = 5003 THEN 'SS'  
       WHEN CAS.COMPANY_SEQ = 5006 THEN 'SA'  
       WHEN CAS.COMPANY_SEQ = 5007 THEN 'ST'  
       WHEN CAS.COMPANY_SEQ = 5000 THEN 'B'  
       ELSE 'SB'  
      END  
     ) NOT IN ( SELECT SALES_GUBUN FROM COUPON_ISSUE WHERE COUPON_DETAIL_SEQ = CD.COUPON_DETAIL_SEQ AND UID = TU.UID )  
  
   SET @RETURN_CODE = '0000'  
   SET @RETURN_MESSAGE = '완료'  
  
  END  
  
 ELSE IF @IS_USE_REPEAT_COUPON = 'N'  
  BEGIN  
     
   INSERT INTO @T_COUPON (ROW_NUM, COUPON_DETAIL_SEQ, COUPON_MST_SEQ, COUPON_CODE, DOWNLOAD_ACTIVE_YN)  
  
   SELECT ROW_NUMBER() OVER(ORDER BY COUPON_CODE ASC)  
    , CD.COUPON_DETAIL_SEQ  
    , CD.COUPON_MST_SEQ  
    , CD.COUPON_CODE  
    , CD.DOWNLOAD_ACTIVE_YN  
   FROM COUPON_DETAIL CD  
   JOIN COUPON_MST CM ON CM.COUPON_MST_SEQ = CD.COUPON_MST_SEQ  
   JOIN COUPON_APPLY_SITE CAS ON CAS.COUPON_MST_SEQ = CD.COUPON_MST_SEQ  
   
   WHERE 1 = 1  
   AND  CD.COUPON_MST_SEQ = @P_COUPON_MST_SEQ  
   AND  CD.DOWNLOAD_ACTIVE_YN = 'Y'  
  
  
  
   DECLARE @T_USERS_COUNT AS INT  
   DECLARE @T_COUPON_COUNT AS INT  
   SET @T_USERS_COUNT = ISNULL((SELECT COUNT(*) FROM @T_USERS), 0)  
   SET @T_COUPON_COUNT = ISNULL((SELECT COUNT(*) FROM @T_COUPON), 0)  
  
  
  
   IF @T_USERS_COUNT <= @T_COUPON_COUNT  
    BEGIN  
       
     INSERT INTO COUPON_ISSUE (COUPON_DETAIL_SEQ, UID, ACTIVE_YN, COMPANY_SEQ, SALES_GUBUN, END_DATE, REG_DATE)  
  
     SELECT TC.COUPON_DETAIL_SEQ  
      , TU.UID  
      , 'Y'  
      , CAS.COMPANY_SEQ  
      , CASE   
         WHEN CAS.COMPANY_SEQ = 5001 THEN 'SB'  
         WHEN CAS.COMPANY_SEQ = 5003 THEN 'SS'  
         WHEN CAS.COMPANY_SEQ = 5006 THEN 'SA'  
         WHEN CAS.COMPANY_SEQ = 5007 THEN 'ST'  
         WHEN CAS.COMPANY_SEQ = 5000 THEN 'B'  
         ELSE 'SB'  
       END  
      , CASE WHEN CM.EXPIRY_CUSTOM_VALUE IS NULL OR CM.EXPIRY_CUSTOM_VALUE = 0 THEN NULL ELSE (CONVERT(VARCHAR(10), DATEADD(DAY, CM.EXPIRY_CUSTOM_VALUE, GETDATE()), 120) + ' 23:59:59.997') END  
      , GETDATE()  
     FROM @T_USERS TU  
     JOIN @T_COUPON TC ON TU.ROW_NUM = TC.ROW_NUM  
     JOIN COUPON_MST CM ON CM.COUPON_MST_SEQ = TC.COUPON_MST_SEQ  
     JOIN COUPON_APPLY_SITE CAS ON CAS.COUPON_MST_SEQ = TC.COUPON_MST_SEQ  
   
     WHERE 1 = 1  
  
     --AND  TU.UID NOT IN ( SELECT UID FROM COUPON_ISSUE WHERE COUPON_DETAIL_SEQ = TC.COUPON_DETAIL_SEQ )  
  
     AND  (  
        CASE   
         WHEN CAS.COMPANY_SEQ = 5001 THEN 'SB'  
         WHEN CAS.COMPANY_SEQ = 5003 THEN 'SS'  
         WHEN CAS.COMPANY_SEQ = 5006 THEN 'SA'  
         WHEN CAS.COMPANY_SEQ = 5007 THEN 'ST'  
         WHEN CAS.COMPANY_SEQ = 5000 THEN 'B'  
         ELSE 'SB'  
        END  
       ) NOT IN ( SELECT SALES_GUBUN FROM COUPON_ISSUE WHERE COUPON_DETAIL_SEQ = TC.COUPON_DETAIL_SEQ AND UID = TU.UID  )  
  
     UPDATE COUPON_DETAIL  
     SET  DOWNLOAD_ACTIVE_YN = 'N'  
     WHERE COUPON_DETAIL_SEQ IN ( SELECT COUPON_DETAIL_SEQ FROM @T_COUPON WHERE ROW_NUM <= @T_USERS_COUNT)  
  
  
     SET @RETURN_CODE = '0000'  
     SET @RETURN_MESSAGE = '완료'  
  
    END  
   ELSE  
    BEGIN  
       
     SET @RETURN_CODE = '9999'  
     SET @RETURN_MESSAGE = '사용 가능한 쿠폰 코드가 없습니다.'  
  
    END  
  
  
  END  
 ELSE  
  BEGIN  
     
   SET @RETURN_CODE = '9999'  
   SET @RETURN_MESSAGE = '사용 가능한 쿠폰 코드가 없습니다.'  
  
  END  
  
  
  
 SELECT @RETURN_CODE AS RETURN_CODE  
  , @RETURN_MESSAGE AS RETURN_MESSAGE  
  
  
  
END
GO