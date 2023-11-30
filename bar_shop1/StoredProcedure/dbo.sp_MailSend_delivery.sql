IF OBJECT_ID (N'dbo.sp_MailSend_delivery', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_delivery
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
exec [sp_MailSend_delivery] 2926050
*/

CREATE PROCEDURE [dbo].[sp_MailSend_delivery]    
    @ORDER_SEQ INTEGER    
AS    

        DECLARE     @ORDER_NAME     [VARCHAR](50)    
        DECLARE     @ORDER_EMAIL    [VARCHAR](100)    
        DECLARE     @SALES_GUBUN    [VARCHAR](2)    
        DECLARE     @ORDER_HPHONE   [VARCHAR](100)    
        DECLARE     @CARD_IMG       [VARCHAR](100)    
        DECLARE     @MYPAGE_URL     [VARCHAR](200)    
        DECLARE     @DIV            [VARCHAR](20)    
        DECLARE     @ETC_INFO       [VARCHAR](50)    
        DECLARE     @SMS_PHONE      [VARCHAR](20)    
        DECLARE     @SMS_MSG        [VARCHAR](200)    
        DECLARE     @EMAIL          [VARCHAR](100)    
        DECLARE     @EMAIL_SENDER   [VARCHAR](50)    
        DECLARE     @EMAIL_TITLE    [VARCHAR](50)    
        DECLARE     @EMAIL_MSG      [VARCHAR](8000)    
        DECLARE     @CNT            INT    = 0

        SELECT  @SALES_GUBUN = CASE A.SALES_GUBUN    
                                    WHEN 'Q' THEN 'D'    
                                    WHEN 'P' THEN 'D'    
                                    WHEN 'O' THEN 'D'    
                                    WHEN 'H' THEN 'B'
									WHEN 'C' THEN 'B'    
                                    ELSE A.SALES_GUBUN    
                               END    
            ,   @DIV    =   CASE A.ISSPECIAL    WHEN '1' THEN '초특급배송'    ELSE '초대장배송'    END    
            ,   @ORDER_NAME = ORDER_NAME
            ,   @ORDER_HPHONE = ORDER_HPHONE
            ,   @ORDER_EMAIL = ORDER_EMAIL    
            ,   @CARD_IMG = 'HTTP://FILE.BARUNSONCARD.COM/COMMON_IMG/' + B.CARD_IMAGE,@MYPAGE_URL =  ISNULL(C.MYPAGE_URL,''),@ETC_INFO=CONVERT(VARCHAR(16),SRC_SEND_DATE,21)    
        FROM    CUSTOM_ORDER A INNER JOIN S2_CARDVIEW B ON A.CARD_SEQ = B.CARD_SEQ,COMPANY C     
        WHERE   A.COMPANY_SEQ = C.COMPANY_SEQ AND A.ORDER_SEQ =@ORDER_SEQ    
        
		-- 2021.02.18 초특급배송 템플릿 등록
        --IF @SALES_GUBUN = 'ST' 
        --BEGIN
        --    SET @DIV = '초대장배송'
        --END
    
        SELECT  @SMS_PHONE = SMS_PHONE
            ,   @SMS_MSG = SMS_MSG
            ,   @EMAIL_SENDER = EMAIL_SENDER
            ,   @EMAIL = EMAIL
            ,   @EMAIL_TITLE = EMAIL_TITLE
            ,   @EMAIL_MSG = EMAIL_MSG 
        FROM    WEDD_MAIL     
        WHERE   SALES_GUBUN=@SALES_GUBUN 
        AND     DIV=@DIV    
        
        DECLARE     @P_REMARKS  AS VARCHAR(64)    
        SET @P_REMARKS = CONCAT(@DIV, ' - SP_MAILSEND_DELIVERY')    
 
    /* 발송처리가 완료되었습니다 내용의 문자 발송 예약 시각 계산 */
	/*
	로직
	1. 18시 05분 이후 라면 다음날 9시로 변경
	2. 0시 ~ 9시까지는 당일 9시로 변경
	3. 1, 2번 적용 후 휴일이라면(주말 포함) 가장 가까운 평일 9시로 변경
	*/    
    DECLARE @RESERVE_DATE   DATETIME
    DECLARE @date datetime
    SET @date = GETDATE();

	SELECT
		-- 3. 1, 2번 적용 후 휴일이라면(주말 포함) 가장 가까운 평일 9시로 변경
		@RESERVE_DATE = (SELECT TOP 1 confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(A.TARGET_DATE))
	FROM
	(
		-- 1. 18시 05분 이후 라면 다음날 9시로 변경
		-- 2. 0시 ~ 9시까지는 당일 9시로 변경
		SELECT
			CASE 
				WHEN CONVERT(VARCHAR(20), @date, 108) >= '18:05:00' THEN 
					CONVERT(VARCHAR(10), DATEADD(DD, 1, @date), 120) + ' 09:00:00'
				WHEN RIGHT(CONVERT(VARCHAR(13), @date, 120), 2) <= '08' THEN 
					CONVERT(VARCHAR(10), @date, 120) + ' 09:00:00'
				ELSE @date 
			END AS TARGET_DATE
	) A

	/* 문자 발송 날짜 제어 */
	DECLARE @START_DATE DATETIME
	DECLARE @END_DATE DATETIME
	DECLARE @USE_YN CHAR(1)

	SELECT @START_DATE = START_DATE,
			@END_DATE = END_DATE,
			@USE_YN = USE_YN 
	FROM ADMIN_LIMIT_SETTING
	WHERE TYPE = 'D' 

	--2022.10.25 관리자 연동으로 수정 임승인
	IF @USE_YN = 'N' OR (@USE_YN = 'Y' AND (@date <= @START_DATE OR @date >= @END_DATE))
	--IF @date <= '2022-09-05 18:00:00' OR @date >= '2022-09-08 23:59:59'
	--IF @date >= '2021-02-15 08:00:00'
	BEGIN
        IF ISNULL(@SMS_PHONE, '') != ''    
        BEGIN    
            IF ( @SALES_GUBUN = 'SA' OR @SALES_GUBUN = 'SB' OR @SALES_GUBUN = 'ST' OR @SALES_GUBUN = 'SS' OR @SALES_GUBUN = 'B')     
            BEGIN    
                EXEC SP_MAILSEND_DELIVERY_BIZTALK @ORDER_SEQ, @ORDER_HPHONE, @SALES_GUBUN, @DIV , @RESERVE_DATE --// 2019-06-14 nsm  : 공휴일 주말 체크해서 예약발송일 넘기기  
            END    
            ELSE    
            BEGIN
				DECLARE @P_RESERVE_DATE VARCHAR(19)
				SET @P_RESERVE_DATE = FORMAT(CONVERT(DATETIME,@RESERVE_DATE),'yyyyMMddHHmmss')
                EXEC SP_EXEC_SMS_OR_MMS_SEND @SMS_PHONE, @ORDER_HPHONE, '', @SMS_MSG, @SALES_GUBUN, '단계별 DM', @P_REMARKS, @P_RESERVE_DATE, 0, ''    --// 2019-06-14 nsm  : 공휴일 주말 체크해서 예약발송일 넘기기
            END    
        END   
      
        SET     @EMAIL_MSG = REPLACE(@EMAIL_MSG, ':::ORDER_NAME:::', @ORDER_NAME)    
        SET     @EMAIL_MSG = REPLACE(@EMAIL_MSG, ':::CARD_IMG:::', @CARD_IMG)    
        SET     @EMAIL_MSG = REPLACE(@EMAIL_MSG, ':::ORDER_SEQ:::', @ORDER_SEQ)    
        SET     @EMAIL_MSG = REPLACE(@EMAIL_MSG, ':::MYPAGE_URL:::', @MYPAGE_URL)    
        SET     @EMAIL_MSG = REPLACE(@EMAIL_MSG, ':::ETC:::', @ETC_INFO)    
    
        IF @EMAIL_MSG <> ''    
        BEGIN    
            EXEC SP_SENDTNEOMAIL_WEDD @EMAIL_SENDER,@EMAIL,@ORDER_NAME,@ORDER_EMAIL,@EMAIL_TITLE,@EMAIL_MSG    
        END
	END
GO
