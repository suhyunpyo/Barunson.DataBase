IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_PROD_CODE_ERP_EXIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_PROD_CODE_ERP_EXIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_PROD_CODE_ERP_EXIST]
	@p_prod_seq int,
	@p_exist_yorn char(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PROD_MST
	SET 
		ERP_EXIST_YORN = @p_exist_yorn,
		ERP_EXIST_CHECK_YORN = 'Y'
	WHERE PROD_SEQ = @p_prod_seq;
	
END

GO
