IF OBJECT_ID (N'dbo.sp_MailSend_SampleOrder', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_SampleOrder
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   procedure [dbo].[sp_MailSend_SampleOrder]
	@from_name varchar(100),
	@from_mail varchar(100),
	@to_name varchar(100),
	@to_mail varchar(100),
	@title varchar(1000),
	@body text
as
	exec sp_sendtNeoMail_wedd @from_name,@from_mail,@to_name,@to_mail,@title,@body




GO
