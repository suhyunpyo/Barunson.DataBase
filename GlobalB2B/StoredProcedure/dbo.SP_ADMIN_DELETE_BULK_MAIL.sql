IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_BULK_MAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_BULK_MAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_BULK_MAIL]
	-- Add the parameters for the stored procedure here
	@p_bulk_mail_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM MAIL_MST WHERE BULK_MAIL_SEQ = @p_bulk_mail_seq;
	DELETE FROM BULK_MAIL_MST WHERE BULK_MAIL_SEQ = @p_bulk_mail_seq;
END

GO
