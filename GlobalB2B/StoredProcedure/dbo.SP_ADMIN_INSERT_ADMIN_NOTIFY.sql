IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_ADMIN_NOTIFY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_ADMIN_NOTIFY
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_ADMIN_NOTIFY]
	-- Add the parameters for the stored procedure here
	@p_admin_user_id nvarchar(255),
	@p_title nvarchar(255),
	@p_content ntext
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_admin_user_seq int;
	
	SET @t_admin_user_seq = (SELECT ADMIN_USER_SEQ FROM ADMIN_USER_MST WHERE ADMIN_USER_ID = @p_admin_user_id);
	
	IF(@t_admin_user_seq IS NOT NULL)
	BEGIN
		INSERT INTO [GlobalB2B].[dbo].[ADMIN_NOTIFY_MST]
           ([ADMIN_USER_SEQ]
           ,[NOTIFY_TITLE]
           ,[NOTIFY_CONTENTS]
           ,[REG_DATE])
     VALUES
           (@t_admin_user_seq
           ,@p_title
           ,@p_content
           ,GETDATE());
	END
END
GO
