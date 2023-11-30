IF OBJECT_ID (N'dbo.up_select_login_ID', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_login_ID
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-04
-- Description:	회원로그인 체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_login_ID]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(16)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (@company_seq = '5001' or @company_seq='5003')
		begin
			Select pwd,uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
			S2_UserInfo with(nolock)  Where uid=@uid
		end
	if (@company_seq = '5006' )
		begin
			Select pwd,uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
			S2_UserInfo_BHands with(nolock)  Where uid=@uid
		end
	if (@company_seq = '5007')
		begin
			Select pwd,uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
			S2_UserInfo_TheCard with(nolock)  Where uid=@uid
		end
END
GO
