IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_USER_CONN_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_USER_CONN_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_USER_CONN_MST]
	@p_user_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	*
	FROM
	USER_CONN_MST WHERE USER_SEQ = @p_user_seq;
END
GO
