IF OBJECT_ID (N'dbo.sp_MailSend_qna', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_qna
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE       procedure [dbo].[sp_MailSend_qna]
	@qa_id integer
as
	Declare @member_name [varchar](50)
	Declare @member_email [varchar](100)
	Declare @member_hphone [varchar](100)
	Declare @sales_gubun [varchar](1)
	Declare @q_title [varchar](100)
	Declare @q_content [varchar](2000)
	Declare @a_content [varchar](2000)
	
	Declare @sms_phone [varchar](20)
	Declare @sms_msg [varchar](200)
	Declare @email [varchar](100)
	Declare @email_sender [varchar](50)
	Declare @email_title [varchar](50)
	Declare @email_msg [varchar](8000)

	DECLARE @P_REMARKS AS VARCHAR(64)
	SET @P_REMARKS = CONCAT('질문답변', ' - SP_MAILSEND_QNA')

	DECLARE item_cursor CURSOR

	FOR 		
		Select 	sales_gubun = case sales_gubun
			when 'Q' then 'D'
			when 'O' then 'D'
			when 'P' then 'D'
			when 'X' then 'W'
			else sales_gubun
			end
			,member_name,e_mail,tel_no,q_title,q_content,a_content
			from sqm_qa_tbl where qa_iid = @qa_id

	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @sales_gubun,@member_name,@member_email,@member_hphone,@q_title,@q_content,@a_content
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
			select @sms_phone = sms_phone,@sms_msg = sms_msg,@email_sender = email_sender,@email = email,@email_title = email_title,@email_msg = email_msg from wedd_mail 
			where sales_gubun=@sales_gubun and div='질문답변'


			set @email_msg = Replace(@email_msg, ':::name:::', @member_name)
			set @email_msg = Replace(@email_msg, ':::title:::', @q_title)
			set @email_msg = Replace(@email_msg, ':::question:::', @q_content)
			set @email_msg = Replace(@email_msg, ':::answer:::', @a_content)
			set @email_msg = Replace(@email_msg, ':::regdate:::', getdate())


			
			EXEC SP_EXEC_SMS_OR_MMS_SEND @SMS_PHONE, @MEMBER_HPHONE, '', @SMS_MSG, @SALES_GUBUN, '단계별 DM', @P_REMARKS, '', 0, ''
			--exec invtmng.sp_DacomSMS @member_hphone,@sms_phone,@sms_msg

			if @email_msg <> ''
			exec sp_sendtNeoMail_wedd @email_sender,@email,@member_name,@member_email,@email_title,@email_msg
			

			FETCH NEXT FROM item_cursor  INTO @sales_gubun,@member_name,@member_email,@member_hphone,@q_title,@q_content,@a_content

	END			-- end of while
	CLOSE item_cursor
	DEALLOCATE item_cursor



GO
