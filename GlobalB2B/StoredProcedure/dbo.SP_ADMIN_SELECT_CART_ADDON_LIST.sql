IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_CART_ADDON_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_CART_ADDON_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_CART_ADDON_LIST]
	@p_cart_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	CAM.*,
	PM.PROD_CODE,
	PM.TYPE_CODE AS PROD_TYPE_CODE,
	TYPE_CC.DTL_NAME AS PROD_TYPE_NAME
	FROM CART_ADDON_MST CAM
	LEFT JOIN PROD_MST PM ON CAM.PROD_SEQ = PM.PROD_SEQ
	LEFT JOIN COMMON_CODE TYPE_CC ON PM.TYPE_CODE = TYPE_CC.CMMN_CODE
	WHERE CAM.CART_SEQ = @p_cart_seq;
END

GO
