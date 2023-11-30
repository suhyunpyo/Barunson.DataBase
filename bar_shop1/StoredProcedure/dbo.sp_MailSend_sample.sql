IF OBJECT_ID (N'dbo.sp_MailSend_sample', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_sample
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   procedure [dbo].[sp_MailSend_sample]
	@order_seq integer,
	@order_name varchar(50),
	@order_hphone varchar(50),
	@order_email varchar(100),
	@card_img varchar(1000),
	@order_info varchar(1000),
	@delivery_info varchar(1000),
	@sales_gubun varchar(1),
	@div varchar(20)
as
	Declare @sms_phone [varchar](20)
	Declare @sms_msg [varchar](200)
	DECLARE @email [varchar](100)
	Declare @email_sender [varchar](50)
	Declare @email_title [varchar](50)
	Declare @email_msg [varchar](8000)

	select @sms_phone = sms_phone,@sms_msg = sms_msg,@email_sender = email_sender,@email = email,@email_title = email_title,@email_msg = email_msg from wedd_mail 
	where sales_gubun=@sales_gubun and div=@div

--	set @sms_msg = Replace(@sms_msg, ':::etc:::', @etc)

	set @email_msg = Replace(@email_msg, ':::order_seq:::', @order_seq)
	set @email_msg = Replace(@email_msg, ':::order_name:::', @order_name)
	set @email_msg = Replace(@email_msg, ':::card_img:::', @card_img)
	set @email_msg = Replace(@email_msg, ':::order_info:::', @order_info)
	set @email_msg = Replace(@email_msg, ':::delivery_info:::', @delivery_info)
	
--	if @mypage_url <> ''
--		set @email_msg = Replace(@email_msg, ':::mypage_url:::', @mypage_url)

	if @sms_msg <> ''
	BEGIN
		
		DECLARE @P_REMARKS AS VARCHAR(64)
		SET @P_REMARKS = CONCAT(@div, ' - SP_MAILSEND_SAMPLE')
		EXEC SP_EXEC_SMS_OR_MMS_SEND @SMS_PHONE, @ORDER_HPHONE, '', @SMS_MSG, @SALES_GUBUN, '단계별 DM', @P_REMARKS, '', 0, ''

		--exec invtmng.sp_DacomSMS @order_hphone,@sms_phone,@sms_msg

	END
	
	if @email_msg <> ''
		exec sp_sendtNeoMail_wedd @email_sender,@email,@order_name,@order_email,@email_title,@email_msg




GO
