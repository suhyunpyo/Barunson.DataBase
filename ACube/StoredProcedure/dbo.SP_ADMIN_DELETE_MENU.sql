IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_MENU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_MENU
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_MENU]
	@p_menu_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DELETE FROM ADMIN_MENU_MST WHERE PARENT_MENU_SEQ = @p_menu_seq;
	
	DELETE FROM ADMIN_MENU_MST WHERE MENU_SEQ = @p_menu_seq;
END


GO
