IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ADMIN_PERMISSION_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ADMIN_PERMISSION_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ADMIN_PERMISSION_INFO]
	-- Add the parameters for the stored procedure here
	@p_admin_user_seq int,
	@p_type_code nchar(6),
	@p_ref_key int,
	@p_is_allow nchar(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE
	FROM ADMIN_USER_PERMISSION_MST
	WHERE
	USER_SEQ = @p_admin_user_seq
	AND REF_KEY = @p_ref_key
	AND PERMISSION_TYPE_CODE = @p_type_code
	
	
	IF(@p_is_allow = 'Y')
	BEGIN
		INSERT INTO [ACube].[dbo].[ADMIN_USER_PERMISSION_MST]
           ([USER_SEQ]
           ,[PERMISSION_TYPE_CODE]
           ,[REF_KEY]
           ,[REG_DATE])
		 VALUES
			   (@p_admin_user_seq
			   ,@p_type_code
			   ,@p_ref_key
			   ,GETDATE());
	END
	
END
GO
