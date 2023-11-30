IF OBJECT_ID (N'dbo.sp_MailSend_order_new', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_order_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_MailSend_order_new]
	@order_seq integer,
	@order_name varchar(50),
	@order_hphone varchar(50),
	@order_email varchar(100),
	@card_img varchar(1000),
	@etc varchar(100),
	@sales_gubun varchar(2),
	@div varchar(20),
	@mypage_url varchar(200)
as

	/* 20201123 추가 START */
	DECLARE	@ERRNUM INT,
			@ERRSEV INT, 
			@ERRSTATE INT, 
			@ERRPROC VARCHAR(50), 
			@ERRLINE INT, 
			@ERRMSG VARCHAR(2000)
	/* 20201123 추가 END */

	Declare @sms_phone [varchar](20)
	Declare @sms_msg [varchar](200)
	DECLARE @email [varchar](100)
	Declare @email_sender [varchar](50)
	Declare @email_title [varchar](50)
	Declare @email_msg [varchar](8000)

	Declare @sms_new_msg [varchar](200)

	select  @sms_phone = sms_phone
        ,   @sms_msg = sms_msg
        ,   @email_sender = email_sender
        ,   @email = email
        ,   @email_title = email_title
        ,   @email_msg = email_msg 
    from    wedd_mail 
	where   sales_gubun = @sales_gubun 
    and     div_s2 = @div
    AND     USE_YORN = 'Y'

	set @sms_msg = Replace(@sms_msg, ':::etc:::', @etc)
		
	set @email_msg = Replace(@email_msg, ':::order_seq:::', @order_seq)
	set @email_msg = Replace(@email_msg, ':::order_name:::', @order_name)
	set @email_msg = Replace(@email_msg, ':::card_img:::', @card_img)
	set @email_msg = Replace(@email_msg, ':::etc:::', @etc)
	
	if @mypage_url <> ''
		set @email_msg = Replace(@email_msg, ':::mypage_url:::', @mypage_url)

	SELECT @sms_new_msg = '[' + @email_sender + ']' + ' 초안신청이완료되었습니다. 초안은 ' + a.TARGET_DATE + ' 등록될 예정입니다' 
	FROM
	(
		SELECT
			REPLACE(RIGHT(dbo.fn_IsWorkDay(CONVERT(varchar(10), a.new_order_date, 120), dbo.FN_GET_BAESONG_CHOAN(a.card_seq, a.new_order_date) + 1), 5), '-', '월 ') + '일 까지' AS TARGET_DATE
		FROM
		(
			SELECT 			
				a.card_seq,
				-- 주문일이 휴일이라면 가장 가까운 평일 오전 9시로 주문일을 변경합니다.
				(SELECT TOP 1 confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(a.order_date)) AS new_order_date
			FROM 
				custom_order a
			WHERE 
				order_seq = @order_seq
		) a
	) a

	DECLARE @P_REMARKS AS VARCHAR(64)
	SET @P_REMARKS = CONCAT(@div, ' - SP_MAILSEND_ORDER_NEW')

	if @div = '초대장주문' or @div = 'IC01'
	begin
		if @sms_new_msg <> ''
		BEGIN				
				SET @ORDER_HPHONE = '^' + @ORDER_HPHONE
				--20201123 표수현 KT 발송 --
				EXEC BAR_SHOP1.DBO.PROC_SMS_MMS_SEND '', 0, '', @sms_msg, '', @sms_phone, 1, @ORDER_HPHONE, 0, '', 0, @SALES_GUBUN, '', '', '', '', @ERRNUM OUTPUT, @ERRSEV OUTPUT, @ERRSTATE OUTPUT, @ERRPROC OUTPUT, @ERRLINE OUTPUT, @ERRMSG OUTPUT
		END

        IF @div = '초대장주문' AND @sales_gubun IN ( 'SB' , 'SA' ,'SS','ST','B')
        BEGIN
            EXEC sp_MailSend_order_new 	@order_seq, @order_name, @order_hphone, @order_email, @card_img, @etc, @sales_gubun, '초대장주문 - 추가발송', @mypage_url
        END

	end
	else
	begin
		if @sms_msg <> ''
		BEGIN
			SET @ORDER_HPHONE = '^' + @ORDER_HPHONE
			--20201123 표수현 KT 발송 --
			EXEC BAR_SHOP1.DBO.PROC_SMS_MMS_SEND '', 0, '', @sms_msg, '', @sms_phone, 1, @ORDER_HPHONE, 0, '', 0, @SALES_GUBUN, '', '', '', '', @ERRNUM OUTPUT, @ERRSEV OUTPUT, @ERRSTATE OUTPUT, @ERRPROC OUTPUT, @ERRLINE OUTPUT, @ERRMSG OUTPUT
		END
	end


	if @email_msg <> ''
		exec sp_sendtNeoMail_wedd @email_sender,@email,@order_name,@order_email,@email_title,@email_msg
GO
