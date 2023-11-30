IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_ADMIN_USER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_ADMIN_USER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_ADMIN_USER]
	-- Add the parameters for the stored procedure here
	@p_user_id nvarchar(255),
	@p_user_pwd nvarchar(255),
	@p_user_name nvarchar(255)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [ACube].[dbo].[ADMIN_USER_MST]
           ([ADMIN_USER_ID]
           ,[ADMIN_USER_PWD]
           ,[ADMIN_USER_NAME]
           ,[REG_DATE])
     VALUES
           (@p_user_id
           ,@p_user_pwd
           ,@p_user_name
           ,GETDATE())
END


GO
