IF OBJECT_ID (N'dbo.SP_UPDATE_USER_PWD_BY_TOKKEN', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_USER_PWD_BY_TOKKEN
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
CREATE PROCEDURE [dbo].[SP_UPDATE_USER_PWD_BY_TOKKEN]
	-- Add the parameters for the stored procedure here
	@p_pwd nvarchar(100),
	@p_tokken nvarchar(40)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_user_seq int;
	
	SET @t_user_seq = (SELECT USER_SEQ FROM USER_TOKKEN_MST WHERE TOKKEN_CODE = @p_tokken AND TOKKEN_TYPE = '602002');
	
	IF(@t_user_seq > 0 AND @t_user_seq IS NOT NULL)
		BEGIN
			UPDATE USER_MST
			SET USER_PWD = @p_pwd
			WHERE USER_SEQ = @t_user_seq;		
			
			UPDATE USER_TOKKEN_MST
			SET EXPIRE_YORN = 'Y'
			WHERE TOKKEN_CODE = @p_tokken;
		END
	
	
END
GO
