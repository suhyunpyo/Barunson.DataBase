IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_COUNT_PRODUCT_GROUP_SET_IN_PRODUCT_CODE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_COUNT_PRODUCT_GROUP_SET_IN_PRODUCT_CODE
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_COUNT_PRODUCT_GROUP_SET_IN_PRODUCT_CODE]
	@p_type_code char(6),
	@p_prod_code nvarchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT COUNT(*)
	FROM PROD_GROUP PG
	LEFT JOIN PROD_MST PM ON PG.PROD_SEQ = PM.PROD_SEQ
	WHERE PM.PROD_CODE = @p_prod_code
	AND PG.TYPE_CODE = @p_type_code;
END
GO
