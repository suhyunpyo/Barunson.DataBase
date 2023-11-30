IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_FOR_SAMPLE_BARUNSONCARD_SAMPLE_DM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_FOR_SAMPLE_BARUNSONCARD_SAMPLE_DM
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
  
EXEC SP_EXEC_SMS_SEND_FOR_SAMPLE_BARUNSONCARD_SAMPLE_DM '1401465,1396827,1396341,1394839,1394186'  
  
*/  
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_FOR_SAMPLE_BARUNSONCARD_SAMPLE_DM]  
      
AS      
BEGIN   
  
    /*  
        하루에 두번 LMS를 발송한다.  
        1. 전일 18:00 이후부터 오늘 12:00 이전까지의 샘플 발송 완료건  
        2. 오늘 12:00 이후부터 오늘 18:00 이전까지의 샘플 발송 완료건  
    */  
  
    DECLARE @START_DATE     AS DATETIME  
    DECLARE @END_DATE       AS DATETIME  
  
    SET @START_DATE = CASE   
                            /* 프로시저가 실행된 시간이 12시 30분 이후라면(프로시저는 12시에 한번, 18시에 한번 실행됨. 12시 이후의 대략적인 시간) */  
                            WHEN REPLACE(CONVERT(VARCHAR(5), GETDATE(), 108), ':', '') > 1230   
  
                            /* 시작 날짜를 오늘 12:00 로 셋팅 */  
                            THEN CONVERT(VARCHAR(10), GETDATE(), 120) + ' 12:00:00'  
  
                            /* 시작 날짜를 어제 18:00 이후로 셋팅 */  
                            ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, GETDATE()), 120) + ' 18:00:00'  
                      END  
  
    SET @END_DATE   = CASE   
                            /* 프로시저가 실행된 시간이 12시 30분 이후라면(프로시저는 12시에 한번, 18시에 한번 실행됨. 12시 이후의 대략적인 시간) */  
                            WHEN REPLACE(CONVERT(VARCHAR(5), GETDATE(), 108), ':', '') > 1230   
  
                            /* 종료일을 오늘 18:00 로 셋팅 */  
                            THEN CONVERT(VARCHAR(10), GETDATE(), 120) + ' 18:00:00'  
  
                            /* 종료일을 오늘 12:00 로 셋팅 */  
                            ELSE CONVERT(VARCHAR(10), GETDATE(), 120) + ' 12:00:00'  
                      END  
    
    DECLARE cur_AutoInsert_For_Barunsoncard_Sample_DM CURSOR FAST_FORWARD      
    FOR    
  
        SELECT    
                GETDATE() AS SEND_DATE    
            ,   CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN CSO.MEMBER_HPHONE ELSE VUI.HPHONE END HPHONE  
            ,   CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN CSO.MEMBER_EMAIL ELSE VUI.UID END UID  
            ,   CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN CSO.MEMBER_NAME ELSE VUI.UNAME END UNAME  
            ,   CSO.SALES_GUBUN      
            ,   CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN 'Y' ELSE ISNULL(VUI.CHK_SMS, 'N') END CHK_SMS  
            ,   CASE WHEN ISNULL(CSO.MEMBER_ID, '') = '' THEN 'N' ELSE 'Y' END MEMBER_YN    -- 회원/비회원 구분변수
        FROM    CUSTOM_SAMPLE_ORDER CSO     
        LEFT  
        JOIN    VW_USER_INFO VUI  
            ON      CSO.MEMBER_ID = VUI.UID  
            AND     ISNULL(CSO.MEMBER_ID, '') <> ''  
            AND     CSO.SALES_GUBUN = VUI.SITE_DIV  
  
        WHERE   1 = 1  
        AND     CSO.SALES_GUBUN IN ('SB')   
        AND     CSO.STATUS_SEQ = 12  
        AND     CSO.DELIVERY_DATE >= @START_DATE
        AND     CSO.DELIVERY_DATE < @END_DATE
        AND     CSO.MEMBER_ID <> 'thesnssample'  
        --AND     CSO.MEMBER_ID != '' -- 20180416 비회원은 발송안되게 추가 / 20180425 비회원 다른문구로 발송되게 변경 
        /* 한번 발송된 고객 제외(회원, 비회원) */  
        AND     CSO.MEMBER_ID       NOT IN ( SELECT UID FROM COUPON_ISSUE WHERE COMPANY_SEQ = 5001 AND COUPON_DETAIL_SEQ in ( 47182, 456360) )  
   
        OPEN cur_AutoInsert_For_Barunsoncard_Sample_DM  
           
            DECLARE @MMS_DATE                   AS VARCHAR(100)      
            DECLARE @HAND_PHONE                 AS VARCHAR(100)      
            DECLARE @USER_ID                    AS VARCHAR(100)      
            DECLARE @USER_NAME                  AS VARCHAR(100)      
            DECLARE @SALES_GUBUN                AS VARCHAR(100)      
            DECLARE @COMPANY_SEQ                AS INT      
            DECLARE @CALL_NUMBER                AS VARCHAR(50)  
            DECLARE @MSG                        AS VARCHAR(MAX)      
            DECLARE @TITLE                      AS VARCHAR(200)   
     DECLARE @COUPON_CODE                AS VARCHAR(40)      
            DECLARE @CHK_SMS                    AS VARCHAR(1)  
            DECLARE @MEMBER_YN                    AS VARCHAR(1)  
      
            FETCH NEXT FROM cur_AutoInsert_For_Barunsoncard_Sample_DM INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @USER_NAME, @SALES_GUBUN, @CHK_SMS, @MEMBER_YN 
  
            WHILE @@FETCH_STATUS = 0   
            BEGIN  

                SET @COMPANY_SEQ = 5001       
                SET @CALL_NUMBER = '1644-0708';   
                
                IF  @MEMBER_YN = 'Y'    -- 회원일경우 
                BEGIN
                    SET @TITLE = '[바른손카드] 쿠폰이 발송되었습니다.';      
                    SET @MSG = @USER_NAME + '님, 신청하신 청첩장 샘플이 발송되었습니다.'     
                            + CHAR(10) + CHAR(10) + '소중한 날을 위해 설렘을 담아 보내드린 청첩장, 마음에 드시기를 바랍니다. :)'     
                            + CHAR(10) + CHAR(10) + '샘플 주문 고객님에게만 드리는 시크릿쿠폰(중복10%할인)을 발급해 드렸어요.'    
                            + CHAR(10) + CHAR(10) + '바른손카드 고객님만의 혜택, 시크릿쿠폰으로 마음에드는 청첩장을 구매하세요!'     
                            + CHAR(10) + CHAR(10) + '※ 내 쿠폰 확인하기 ▶ http://m.barunsoncard.com/mypage/coupon/coupon_list.asp'     
  
                    --쿠폰 발송    
                    SET @COUPON_CODE = '7288-61CE-4931-B592'      
                    EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE_NOWHERE @COMPANY_SEQ, @SALES_GUBUN, @USER_ID, @COUPON_CODE  
                END
                ELSE    -- 비회원일 경우
                BEGIN
                    SET @TITLE = '[바른손카드] 샘플이 발송되었습니다.';      
                    SET @MSG = @USER_NAME + '님, 신청하신 청첩장 샘플이 발송되었습니다.'     
                            + CHAR(10) + CHAR(10) + '소중한 날을 위해 설렘을 담아 보내드린 청첩장, 마음에 드시기를 바랍니다.'     
                            + CHAR(10) + CHAR(10) + '바른손카드 청첩장 구매 고객에게 드리는 다양한 혜택을 확인해 보세요!'    
                            + CHAR(10) + CHAR(10) + '회원가입 시 더 많은 혜택을 만날 수 있습니다. :)'     
                            + CHAR(10) + CHAR(10) + '※ 구매혜택 확인하기 ▶ http://m.barunsoncard.com/event/event_benefit.asp'     
                END
  
                IF @CHK_SMS = 'Y'  
                BEGIN  
                    --MMS 발송      
                    EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @HAND_PHONE, @TITLE, @MSG, @SALES_GUBUN, '샘플후기SMS', '', @MMS_DATE, 0, ''      
                END  
  
                FETCH NEXT FROM cur_AutoInsert_For_Barunsoncard_Sample_DM INTO @MMS_DATE, @HAND_PHONE, @USER_ID, @USER_NAME, @SALES_GUBUN, @CHK_SMS, @MEMBER_YN  
            END  
  
        CLOSE cur_AutoInsert_For_Barunsoncard_Sample_DM  
              
    DEALLOCATE cur_AutoInsert_For_Barunsoncard_Sample_DM    
  
END
GO
