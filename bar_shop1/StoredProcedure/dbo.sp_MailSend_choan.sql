IF OBJECT_ID (N'dbo.sp_MailSend_choan', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_choan
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
EXEC sp_MailSend_choan 2856319 
*/

--[sp_MailSend_choan] 4242960

CREATE PROCEDURE [dbo].[sp_MailSend_choan]
    @ostr   VARCHAR(50)
AS
	DECLARE     @order_seq      INTEGER;
	DECLARE     @order_name     VARCHAR(50);
	DECLARE     @order_email    VARCHAR(100);
	DECLARE     @sales_gubun    VARCHAR(2);
	DECLARE     @order_hphone   VARCHAR(100);
	DECLARE     @card_img       VARCHAR(100);
	DECLARE     @choan_date     VARCHAR(10);
	DECLARE     @mypage_url     VARCHAR(200);
	DECLARE     @div            VARCHAR(20);
	DECLARE     @sms_phone      VARCHAR(20);
	DECLARE     @sms_msg        VARCHAR(200);
	DECLARE     @email          VARCHAR(100);
	DECLARE     @email_sender   VARCHAR(50);
	DECLARE     @email_title    VARCHAR(50);
	DECLARE     @email_msg      VARCHAR(8000);
	DECLARE     @hour_minute    INTEGER;
	DECLARE     @reserve_date   VARCHAR(19);
	DECLARE     @isReserve      CHAR(1);


	SELECT  @sales_gubun  =   CASE A.sales_gubun
						             WHEN 'Q' THEN 'D'
						             WHEN 'P' THEN 'D'
						             WHEN 'O' THEN 'D'
						             WHEN 'H' THEN 'B'
									 WHEN 'C' THEN 'B'
					                 ELSE A.sales_gubun
                                END
        ,   @order_seq    =   A.order_seq
        ,   @div          =   CASE A.isSpecial WHEN '1' THEN '초특급초안'
			                    ELSE 
                                        CASE WHEN DATEDIFF(second , a.src_compose_date , isnull(a.settle_date , GETDATE() + 1)) < 0 THEN '선결제초안'
                                        ELSE '초대장초안'END
			                    END
        ,   @order_name   =   order_name
        ,   @order_hphone =   order_hphone
        ,   @choan_date   =   CONVERT(VARCHAR(10) , src_compose_mod_date , 21)
        ,   @order_email  =   order_email
        ,   @card_img     =   'http://file.barunsoncard.com/common_img/'+B.card_image
        ,   @mypage_url   =   ISNULL(C.mypage_url , '')
	FROM    custom_order AS A
            INNER JOIN S2_CardView AS B ON A.card_seq = B.card_seq
    ,       Company AS C
	WHERE   A.company_seq = C.company_seq
            AND A.order_seq = @ostr;

    IF @sales_gubun = 'ST'     -- 더카드일 경우엔 선결제초안으로만 전송(선결제이므로)            
    BEGIN
        SET @div = '선결제초안'
    END

	SELECT  @sms_phone      =   sms_phone
        ,   @sms_msg        =   sms_msg
		,   @email_sender   =   email_sender
		,   @email          =   email
		,   @email_title    =   email_title
		,   @email_msg      =   email_msg
	FROM    wedd_mail
	WHERE   sales_gubun     =   @sales_gubun
    AND     div = @div;

	SET     @email_msg = Replace(@email_msg , ':::order_name:::' , @order_name);
	SET     @email_msg = Replace(@email_msg , ':::card_img:::' , @card_img);
	SET     @email_msg = Replace(@email_msg , ':::choan_date:::' , @choan_date);
	SET     @email_msg = Replace(@email_msg , ':::order_seq:::' , @order_seq);
	SET     @email_msg = Replace(@email_msg , ':::mypage_url:::' , @mypage_url);

	SET @isReserve = '1';

	/* 초안등록 했으니 확인하라는 내용의 문자 발송 예약 시각 계산 */
	/*
	로직
	1. 22시 이후 라면 다음날 9시로 변경
	2. 0시 ~ 9시까지는 당일 9시로 변경
	3. 1, 2번 적용 후 휴일이라면(주말 포함) 가장 가까운 평일 9시로 변경
	*/
	DECLARE @CHOAN_UP_DATE DATETIME

	SET @CHOAN_UP_DATE = GETDATE();

	SELECT
		-- 3. 1, 2번 적용 후 휴일이라면(주말 포함) 가장 가까운 평일 9시로 변경
		@reserve_date = CONVERT(VARCHAR(19), (SELECT TOP 1 confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(A.TARGET_DATE)), 120)
	FROM
	(
		-- 1. 22시 이후 라면 다음날 9시로 변경
		-- 2. 0시 ~ 9시까지는 당일 9시로 변경
		SELECT
			CASE 
				WHEN RIGHT(CONVERT(VARCHAR(13), @CHOAN_UP_DATE, 120), 2) >= '22' THEN 
					CONVERT(VARCHAR(10), DATEADD(DD, 1, @CHOAN_UP_DATE), 120) + ' 09:00:00'
				WHEN RIGHT(CONVERT(VARCHAR(13), @CHOAN_UP_DATE, 120), 2) <= '08' THEN 
					CONVERT(VARCHAR(10), @CHOAN_UP_DATE, 120) + ' 09:00:00'
				ELSE @CHOAN_UP_DATE 
			END AS TARGET_DATE
	) A

    DECLARE     @P_REMARKS      AS VARCHAR(64);
	SET         @P_REMARKS  =   CONCAT(@div , ' - SP_MAILSEND_CHOAN');
	
    /* 문자 발송 날짜 제어 */

	DECLARE @START_DATE DATETIME
	DECLARE @END_DATE DATETIME
	DECLARE @USE_YN CHAR(1)

	SELECT TOP 1 @START_DATE = START_DATE,
			@END_DATE = END_DATE,
			@USE_YN = USE_YN
	FROM ADMIN_LIMIT_SETTING
	WHERE TYPE = 'C' 

	--2022.10.25 관리자 연동으로 수정 임승인
	--IF @CHOAN_UP_DATE <= '2022-09-05 18:00:00' OR @CHOAN_UP_DATE >= '2022-09-08 23:59:59'
	IF @USE_YN = 'N' OR (@USE_YN = 'Y' AND (@CHOAN_UP_DATE <= @START_DATE OR @CHOAN_UP_DATE >= @END_DATE))	
	BEGIN
		IF @SMS_PHONE <> ''
		BEGIN
			IF ( @SALES_GUBUN = 'SA' or @SALES_GUBUN = 'SB' or @SALES_GUBUN = 'ST' or @SALES_GUBUN = 'SS' or @SALES_GUBUN = 'B' ) 
			BEGIN
				EXEC SP_EXEC_BIZTALK_SEND  @ORDER_HPHONE, 'sp_MailSend_choan', @SALES_GUBUN, @ostr, @div, @reserve_date , ''	
			END
			ELSE
			BEGIN
				SET @RESERVE_DATE = FORMAT(CONVERT(DATETIME,@reserve_date),'yyyyMMddHHmmss')
				EXEC SP_EXEC_SMS_OR_MMS_SEND  @SMS_PHONE, @ORDER_HPHONE, '', @SMS_MSG, @SALES_GUBUN, '단계별 DM', @P_REMARKS, @RESERVE_DATE, 0, ''
			END
		END

		IF @email_msg <> ''
		BEGIN
			EXEC sp_sendtNeoMail_wedd @email_sender, @email, @order_name, @order_email, @email_title, @email_msg
		END
	END
GO
