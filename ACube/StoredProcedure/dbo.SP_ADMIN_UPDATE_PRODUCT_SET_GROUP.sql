IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_PRODUCT_SET_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_PRODUCT_SET_GROUP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_PRODUCT_SET_GROUP]
	-- Add the parameters for the stored procedure here
	@p_prod_set_group_seq int,
    @p_set_group_type_code nchar(6),
    @p_normal_price_unit numeric(18, 3),
    @p_retail_price_unit numeric(18, 3),
    @p_add_print_price numeric(18, 3),
    @p_add_process_price numeric(18, 3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
    UPDATE [ACube].[dbo].[PROD_SET_GROUP_MST]
	SET [NORMAL_PRICE_UNIT] = @p_normal_price_unit
      ,[RETAIL_PRICE_UNIT] = @p_retail_price_unit
      ,[ADDITIONAL_PRINT_PRICE] = @p_add_print_price
      ,[ADDITIONAL_PROCESSING_PRICE] = @p_add_process_price
      ,[SET_GROUP_TYPE_CODE] = @p_set_group_type_code
	WHERE PROD_SET_GROUP_SEQ = @p_prod_set_group_seq
	
END

GO
