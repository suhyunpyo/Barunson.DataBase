IF OBJECT_ID (N'dbo.sp_sendtNeoMail_SMTP', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_sendtNeoMail_SMTP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_sendtNeoMail_SMTP]

as
DECLARE @url [varchar](100)

BEGIN
	SET @url = 'http://api.bhandscard.com/MailSend.asmx/StepMailSend'
	exec http_get  @url
END
GO
