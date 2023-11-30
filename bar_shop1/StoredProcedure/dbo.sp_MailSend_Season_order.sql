IF OBJECT_ID (N'dbo.sp_MailSend_Season_order', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_Season_order
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_MailSend_Season_order]
	@order_name varchar(50),
	@order_email varchar(100),
	@email varchar(100),
	@email_sender varchar(50),
	@email_title varchar(100),
	@email_msg varchar(8000)
as
	exec sp_sendtNeoMail_wedd @email_sender,@email,@order_name,@order_email,@email_title,@email_msg

GO
