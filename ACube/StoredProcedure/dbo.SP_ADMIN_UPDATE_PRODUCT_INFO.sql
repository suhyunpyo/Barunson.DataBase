IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_PRODUCT_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_PRODUCT_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_PRODUCT_INFO]
	@p_prod_seq int,
	@p_prod_title nvarchar(255),
	@p_prod_type_code nchar(6),
	@p_price_unit numeric(18,3),
	@p_part_price_unit numeric(18,3),
	@p_add_process_price_unit numeric(18,3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [ACube].[dbo].[PROD_MST]
	SET [PROD_TITLE] = @p_prod_title
	  ,[PROD_TYPE_CODE] = @p_prod_type_code
	  ,[PRICE_UNIT] = @p_price_unit
	  ,[PART_CASE_PRICE_UNIT] = @p_part_price_unit
	  ,[ADDITIONAL_PROCESSING_PRICE] = @p_add_process_price_unit
	WHERE PROD_SEQ = @p_prod_seq

END

GO
