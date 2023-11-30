IF OBJECT_ID (N'dbo.up_select_login_DupInfo', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_login_DupInfo
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================크
-- Author:		김덕중
-- Create date: 2014-04-04
-- Description:	회원가입 실명체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_login_DupInfo]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@DupInfo	AS nvarchar(600)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if @company_seq = '5001' or @company_seq='5003'
		SELECT DupInfo, uid, pwd, reg_date FROM S2_UserInfo with(nolock) WHERE DupInfo=@DupInfo
	else if @company_seq = '5006'
		SELECT DupInfo, uid, pwd, reg_date FROM S2_UserInfo_BHands with(nolock) WHERE DupInfo=@DupInfo
	else if @company_seq = '5007' or @company_seq = '5000'
		SELECT DupInfo, uid, pwd, reg_date FROM S2_UserInfo_TheCard with(nolock) WHERE DupInfo=@DupInfo

END
GO
