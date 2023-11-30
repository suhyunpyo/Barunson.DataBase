IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_MAIL_TO_FAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_MAIL_TO_FAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_MAIL_TO_FAIL]
	@p_mail_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE MAIL_MST 
	SET 
	FAIL_YORN = 'Y'
	WHERE MAIL_SEQ = @p_mail_seq;
END
GO
