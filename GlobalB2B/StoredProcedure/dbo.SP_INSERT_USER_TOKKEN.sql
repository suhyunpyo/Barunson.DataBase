IF OBJECT_ID (N'dbo.SP_INSERT_USER_TOKKEN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_USER_TOKKEN
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
CREATE PROCEDURE [dbo].[SP_INSERT_USER_TOKKEN]
	@p_user_id nvarchar(100),
	@p_tokken_type_code char(6),
	@p_tokken_code nvarchar(40),
	@r_result_code char(3) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @t_user_seq int;
    SET @t_user_seq = (SELECT UM.USER_SEQ FROM USER_MST UM WHERE UM.USER_ID = @p_user_id);
	
	IF(@t_user_seq > 0 and @t_user_seq IS NOT NULL)
		BEGIN
			UPDATE USER_TOKKEN_MST
			SET EXPIRE_YORN = 'Y'
			WHERE USER_SEQ = @t_user_seq
			AND TOKKEN_TYPE = @p_tokken_type_code;
			
			INSERT INTO [GlobalB2B].[dbo].[USER_TOKKEN_MST]
				([TOKKEN_CODE]
				,[TOKKEN_TYPE] 
				,[USER_SEQ]
				,[REG_DATE]
				,[EXPIRE_YORN])
			VALUES
				(@p_tokken_code
				,@p_tokken_type_code
				,@t_user_seq
				,GETDATE()
				,'N');
				   
			SET @r_result_code = '200';
		END
	ELSE
		BEGIN
			SET @r_result_code = '401';
		END
END
GO
