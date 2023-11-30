IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  황새롬  
-- Create date: 2016-06-10  
-- Description: 프리미어페이퍼 관리자 전용 식전영상쿠폰발급  
  
-- EXEC 쿠폰타입, 회원아이디, 사이트코드  
-- EXEC dbo.SP_INSERT_MOVIE_EVENT '114009', 's5guest', 5001  
-- =============================================  
  
CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT]  
 @COUPON_TYPE_CODE      AS VARCHAR(6),  
 @UID        AS VARCHAR(50),  
 @COMPANY_SEQ      AS INT  
AS  
BEGIN  
   
 DECLARE  @COUPON_CODE     AS VARCHAR(50) = ''  
 DECLARE  @END_DATE      AS VARCHAR(50) = ''  
 DECLARE  @MSG       AS VARCHAR(150) = ''  
 DECLARE  @SUBJECT      AS VARCHAR(50) = ''  
 DECLARE  @USERPHONE      AS VARCHAR(50) = ''  
 DECLARE  @COMPANY_NM      AS VARCHAR(50) = ''  
 DECLARE  @SEND_PHONE      AS VARCHAR(15) = ''  
 DECLARE  @SALES_GUBUN     AS VARCHAR(2) = ''  
    DECLARE  @COUPON_MST_SEQ     AS VARCHAR(50) = 131  
  
 -- 이미 발급된 쿠폰이 있는 지 확인  
 IF NOT EXISTS(  
  SELECT  *  
  FROM  COUPON_DETAIL   CD  
  INNER JOIN COUPON_ISSUE   CI ON CD.COUPON_DETAIL_SEQ= CI.COUPON_DETAIL_SEQ  
  WHERE  1 = 1  
  AND   CI.UID = @UID  
  AND   CI.COMPANY_SEQ = @COMPANY_SEQ  
  AND   CD.COUPON_MST_SEQ = @COUPON_MST_SEQ  
 )  
  
 -- 발급이력이 없다면 영상쿠폰 발급  
 BEGIN  
     
  -- 발급안된 쿠폰번호 검색 후, 쿠폰발급  
  SELECT TOP(1) @COUPON_CODE =  COUPON_CODE  
  FROM COUPON_DETAIL  
  WHERE 1 = 1  
  AND  COUPON_MST_SEQ = @COUPON_MST_SEQ  
  AND  DOWNLOAD_ACTIVE_YN = 'Y'  
  
  -- 쿠폰발급 후, 문자메세지 전송  
  --IF @COMPANY_SEQ = 5001     
  -- BEGIN  
  --  SET  @COMPANY_NM = '바른손카드';  
  --  SET  @MSG  = '웨딩초대영상이 발급되었습니다.' + CHAR(10)  
  --       + '▷ 쿠폰번호' + CHAR(10)+ '▷ ' + @COUPON_CODE + CHAR(10) + ' 마이페이지 > 쿠폰보관함에서' + CHAR(10)+ ' 확인가능';  
  --  SET  @SUBJECT = '[' + @COMPANY_NM + '] 쿠폰이 발급되었습니다.'  
  --  SET  @SEND_PHONE = '1644-0708';   
  --  SET  @SALES_GUBUN = 'SB';  
  -- END  
    
 -- IF @COUPON_CODE <> ''  
   --BEGIN  
    --EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE  
  
    --SELECT @USERPHONE = HPHONE  
    --FROM VW_USER_INFO  
    --WHERE UID = @UID AND SITE_DIV = @SALES_GUBUN  
  
    --INSERT INTO invtmng.MMS_MSG(SUBJECT, PHONE, CALLBACK, STATUS, REQDATE, MSG, TYPE) VALUES  
    --(@SUBJECT, @USERPHONE, @SEND_PHONE, '0', GETDATE(), @MSG, '0')  
  
    --UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE   
   --END   
    END  
END  
GO
