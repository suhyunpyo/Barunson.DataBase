IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ADMIN_NOTIFY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ADMIN_NOTIFY
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ADMIN_NOTIFY]
	-- Add the parameters for the stored procedure here
	@p_seq int,
	@p_title nvarchar(255),
	@p_content ntext
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ADMIN_NOTIFY_MST 
	SET NOTIFY_TITLE = @p_title,
	NOTIFY_CONTENTS = @p_content
	WHERE NOTIFY_SEQ = @p_seq
END
GO
