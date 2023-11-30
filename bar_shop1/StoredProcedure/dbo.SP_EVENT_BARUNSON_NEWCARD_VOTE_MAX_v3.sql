IF OBJECT_ID (N'dbo.SP_EVENT_BARUNSON_NEWCARD_VOTE_MAX_v3', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EVENT_BARUNSON_NEWCARD_VOTE_MAX_v3
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  곽태원
-- Create date: 2018-07-17  
-- Description: 바른손카드 좋아요이벤트 인데 5번 클릭하고싶데...
  
-- EXEC dbo.[SP_EVENT_BARUNSON_NEWCARD_VOTE_MAX_v3] '아이디', '상품코드', '투표코드'  , '최대클릭수'  , '쿠폰코드'  

-- 20년도에 이벤트 살짝 변경됨
-- =============================================  
  
CREATE PROCEDURE [dbo].[SP_EVENT_BARUNSON_NEWCARD_VOTE_MAX_v3]  
 @UID        AS VARCHAR(50),  
 @POLL_ITEM_SEQ       AS INT,  
 @POLL_SEQ            AS INT,  
 @DAY_MAX             AS INT = 1,
 @COUPON_CODE         AS VARCHAR(100) = '955E-CDBE-4F07-8178'
AS  
BEGIN  
  
    SET NOCOUNT ON  
  
    DECLARE		@UNAME				AS VARCHAR(50) = ''  
    DECLARE     @RESULT_CODE        AS  VARCHAR(4) = '0000'  
    DECLARE     @RESULT_MESSAGE     AS  VARCHAR(500) = ''    
    DECLARE     @COMPANY_SEQ        AS  INT = 5001  
    DECLARE     @SALES_GUBUN        AS  VARCHAR(2) = 'SB'  
    DECLARE     @DAY_COUNT          AS  INT = (SELECT  count(1)     
        FROM    S4_Poll_itemComment  
        WHERE   CONVERT(VARCHAR(10), REG_DATE, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)  
        AND     POLL_SEQ = @POLL_SEQ     
        AND     UID = @UID  )  
  
 -- 이미 투표를 했는 지 확인  


 IF EXISTS (
   SELECT  * 
        FROM    S4_Poll_itemComment  
        WHERE   CONVERT(VARCHAR(10), REG_DATE, 120) = CONVERT(VARCHAR(10), GETDATE(), 120)  
        AND     POLL_ITEM_SEQ = @POLL_ITEM_SEQ     
        AND     UID = @UID   
  )
 
    BEGIN  
        SET @RESULT_CODE = '8888'  
        SET @RESULT_MESSAGE = '이미 선택한 제품입니다.'  
    END  

 ELSE IF @DAY_MAX > @DAY_COUNT
  
 -- 투표안했으면 투표  
 BEGIN  
          
  UPDATE  S4_Poll_item SET item_count = item_count + 1 WHERE SEQ = @POLL_ITEM_SEQ     
            
  SELECT @UNAME = uname  
  FROM VW_USER_INFO  
  WHERE UID = @UID AND SITE_DIV = 'SB'  

  INSERT INTO [dbo].[S4_Poll_itemComment]([uid],[UNAME],[comment],[poll_item_seq],[reg_date],[poll_seq]) VALUES  
            (@UID , @UNAME, '2020년_신상품투표' , @POLL_ITEM_SEQ, GETDATE(), @POLL_SEQ)  
  
  IF @DAY_COUNT = (@DAY_MAX-1) AND NOT EXISTS(  
      SELECT  *  
      FROM  COUPON_DETAIL   CD  
      INNER JOIN COUPON_ISSUE   CI ON CD.COUPON_DETAIL_SEQ= CI.COUPON_DETAIL_SEQ  
      WHERE  1 = 1  
      AND   CI.UID = @UID  
      AND   CI.COMPANY_SEQ = @COMPANY_SEQ  
      AND   CD.COUPON_CODE = @COUPON_CODE  
   )  

	   BEGIN  
		  DECLARE @TABLE_TEMP TABLE (
						RESULT_CODE VARCHAR(4)  
					,   RESULT_MESSAGE VARCHAR(100))  
  
		  INSERT @TABLE_TEMP EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE  
			   SET @RESULT_CODE = (SELECT RESULT_CODE FROM @TABLE_TEMP)  
			   SET @RESULT_MESSAGE = (SELECT RESULT_MESSAGE FROM @TABLE_TEMP)  

        SET @RESULT_CODE = '0000'  
        SET @RESULT_MESSAGE = '신상 한정 5천원 할인 쿠폰이 발급되었습니다. 마이페이지를 확인하세요! :)'  
          
	   END  
    ELSE  
        BEGIN  
        SET @RESULT_CODE = '0000'  
        SET @RESULT_MESSAGE = '3종 이상 선택 시 할인 쿠폰이 발급됩니다.'  
        END  
    END  
ELSE  
    BEGIN  
        SET @RESULT_CODE = '8888'  
        SET @RESULT_MESSAGE = '1일 1회('+ CAST(@DAY_MAX AS varchar(10)) +'종 선택)만 참여 가능합니다'  
    END  
  
    SELECT @RESULT_CODE AS RESULT_CODE  
    ,   @RESULT_MESSAGE AS RESULT_MESSAGE  
END  
GO
