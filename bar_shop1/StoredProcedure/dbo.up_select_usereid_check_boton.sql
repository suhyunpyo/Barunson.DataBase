IF OBJECT_ID (N'dbo.up_select_usereid_check_boton', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_usereid_check_boton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-08-20
-- Description:	회원가입시  ID체크
-- =============================================
CREATE PROCEDURE [dbo].[up_select_usereid_check_boton]
	-- Add the parameters for the stored procedure here
	@DupInfo	AS nvarchar(200)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select DupInfo from S2_UserInfo_Botondays with(nolock) where DupInfo=@DupInfo 
	
END
GO
