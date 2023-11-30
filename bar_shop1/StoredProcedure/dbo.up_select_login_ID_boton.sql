IF OBJECT_ID (N'dbo.up_select_login_ID_boton', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_login_ID_boton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-08-20
-- Description:	회원로그인 체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_login_ID_boton]
	-- Add the parameters for the stored procedure here
	@uid	AS nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
					Select pwd,uname,umail,site_div,isnull(company_seq,0) as company_seq,isJehu, ISNULL(DupInfo, '') AS DupInfo,left(birth,4) as birth_year,gender From 
					S2_UserInfo_Botondays with(nolock)  Where  company_seq is null  and uid=@uid
		
END
GO
