IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_USER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_USER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_USER]
	@p_user_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	UM.*
	,(SELECT TOP 1 UCM.REG_DATE FROM USER_CONN_MST UCM WHERE UCM.USER_SEQ = UM.USER_SEQ ORDER BY UCM.REG_DATE DESC) AS LAST_CONN_DATE
	FROM USER_MST UM
	WHERE UM.USER_SEQ = @p_user_seq;
END
GO
