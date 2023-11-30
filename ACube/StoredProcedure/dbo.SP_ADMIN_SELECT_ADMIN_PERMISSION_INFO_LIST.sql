IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ADMIN_PERMISSION_INFO_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ADMIN_PERMISSION_INFO_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ADMIN_PERMISSION_INFO_LIST]
	-- Add the parameters for the stored procedure here
	@p_admin_user_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT *
	FROM [ADMIN_USER_PERMISSION_MST]
	WHERE USER_SEQ = @p_admin_user_seq;
	
END
GO
