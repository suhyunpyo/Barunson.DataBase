IF OBJECT_ID (N'dbo.up_select_login_DupInfo_boton', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_login_DupInfo_boton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================크
-- Author:		김덕중
-- Create date: 2014-08-20
-- Description:	회원가입 실명체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_login_DupInfo_boton]
	-- Add the parameters for the stored procedure here
	@DupInfo	AS nvarchar(600)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		SELECT DupInfo, uid, pwd, reg_date FROM S2_UserInfo_Botondays with(nolock) WHERE DupInfo=@DupInfo
	
END
GO
