IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_ADDON_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_ADDON_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_ADDON_LIST]
	-- Add the parameters for the stored procedure here
	@p_prod_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	*,
	PM.PROD_CODE AS PROD_CODE,
	ADDON_PM.PROD_CODE AS ADD_PROD_CODE,
	PM_TYPE_CC.DTL_NAME AS PROD_TYPE_NAME,
	ADDON_PM_TYPE_CC.DTL_NAME AS ADD_PROD_TYPE_NAME
	FROM 
	PROD_ADDON_MST PAM
	LEFT JOIN PROD_MST PM ON PAM.PROD_SEQ = PM.PROD_SEQ
	LEFT JOIN PROD_MST ADDON_PM ON PAM.ADD_PROD_SEQ = ADDON_PM.PROD_SEQ
	LEFT JOIN COMMON_CODE PM_TYPE_CC ON PM.TYPE_CODE = PM_TYPE_CC.CMMN_CODE
	LEFT JOIN COMMON_CODE ADDON_PM_TYPE_CC ON ADDON_PM.TYPE_CODE = ADDON_PM_TYPE_CC.CMMN_CODE
	WHERE PAM.PROD_SEQ = @p_prod_seq;
END

GO
