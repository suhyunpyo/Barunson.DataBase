IF OBJECT_ID (N'dbo.sp_MailSend_memberReg', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_memberReg
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   procedure [dbo].[sp_MailSend_memberReg]
	@member_id varchar(20),
	@member_name varchar(50),
	@member_email varchar(100),
	@sales_gubun varchar(1)
as
	DECLARE @email [varchar](100)
	Declare @email_sender [varchar](50)
	Declare @email_title [varchar](50)
	Declare @email_msg [varchar](8000)

	select @email_sender = email_sender,@email = email,@email_title = email_title,@email_msg = email_msg from wedd_mail 
	where sales_gubun=@sales_gubun and div='회원가입'

	set @email_msg = Replace(@email_msg, ':::member_id:::', @member_id)
	set @email_msg = Replace(@email_msg, ':::member_name:::', @member_name)
	set @email_msg = Replace(@email_msg,':::reg_date:::',convert(varchar(10),getdate(),21))
	

	if @email_msg <> ''
		exec sp_sendtNeoMail_wedd @email_sender,@email,@member_name,@member_email,@email_title,@email_msg



GO
