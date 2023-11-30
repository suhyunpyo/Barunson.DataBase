IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ADMIN_USER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ADMIN_USER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ADMIN_USER]
	@p_admin_user_seq int,
	@p_name nvarchar(255),
	@p_pwd nvarchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    UPDATE [GlobalB2B].[dbo].[ADMIN_USER_MST]
	SET 
      [ADMIN_USER_PWD] = @p_pwd
      ,[ADMIN_USER_NAME] = @p_name
	WHERE ADMIN_USER_SEQ = @p_admin_user_seq;

END


GO
