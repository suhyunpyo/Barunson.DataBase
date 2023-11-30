IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_PRODUCT_SET_GROUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_PRODUCT_SET_GROUP
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_PRODUCT_SET_GROUP]
	-- Add the parameters for the stored procedure here
	@p_prod_set_group_code nvarchar(255),
    @p_set_group_type_code nchar(6),
    @p_normal_price_unit numeric(18,3),
    @p_retail_price_unit numeric(18,3),
    @p_add_print_price numeric(18,3),
    @p_add_process_price numeric(18,3),
	@r_prod_set_group_seq int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_exist_count int;
	
	SET @p_prod_set_group_code = LTRIM(RTRIM(@p_prod_set_group_code));
	
	SET @t_exist_count = (SELECT COUNT(*) FROM PROD_SET_GROUP_MST WHERE PROD_SET_GROUP_CODE = @p_prod_set_group_code);
	
	IF(@t_exist_count < 1)
	BEGIN
		INSERT INTO [ACube].[dbo].[PROD_SET_GROUP_MST]
			   ([PROD_SET_GROUP_CODE]
			   ,[NORMAL_PRICE_UNIT]
			   ,[RETAIL_PRICE_UNIT]
			   ,[ADDITIONAL_PRINT_PRICE]
			   ,[ADDITIONAL_PROCESSING_PRICE]
			   ,[SET_GROUP_TYPE_CODE]
			   ,[REG_DATE])
		 VALUES
			   (@p_prod_set_group_code
			   ,@p_normal_price_unit
			   ,@p_retail_price_unit
			   ,@p_add_print_price
			   ,@p_add_process_price
			   ,@p_set_group_type_code
			   ,GETDATE());
			   
		SET @r_prod_set_group_seq  = SCOPE_IDENTITY();
	END
	
	
           
     
    
END

GO
