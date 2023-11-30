IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_MAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_MAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_MAIL]
	@p_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM MAIL_MST WHERE MAIL_SEQ = @p_seq;
END
GO
