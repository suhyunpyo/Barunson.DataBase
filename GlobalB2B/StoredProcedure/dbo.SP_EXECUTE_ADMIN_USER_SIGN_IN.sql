IF OBJECT_ID (N'dbo.SP_EXECUTE_ADMIN_USER_SIGN_IN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXECUTE_ADMIN_USER_SIGN_IN
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
CREATE PROCEDURE [dbo].[SP_EXECUTE_ADMIN_USER_SIGN_IN]
	@p_user_id nvarchar(100),
	@p_user_pwd nvarchar(100),
	@r_result char(1) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_user_seq int;
	SET @r_result = 'N';
	SET @t_user_seq = (SELECT  ADMIN_USER_SEQ FROM ADMIN_USER_MST WHERE ADMIN_USER_ID = @p_user_id AND ADMIN_USER_PWD = @p_user_pwd);
	
	IF(@t_user_seq IS NOT NULL AND @t_user_seq > 0)
	BEGIN
		INSERT INTO [GlobalB2B].[dbo].[ADMIN_USER_CONN_MST]
			   ([ADMIN_USER_SEQ]
			   ,[REG_DATE])
		 VALUES
			   (@t_user_seq
			   ,GETDATE());
		SET @r_result = 'Y';
	END
END

GO
