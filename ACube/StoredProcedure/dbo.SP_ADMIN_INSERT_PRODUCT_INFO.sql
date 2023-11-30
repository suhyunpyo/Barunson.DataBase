IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_PRODUCT_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_PRODUCT_INFO
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_PRODUCT_INFO]
	-- Add the parameters for the stored procedure here
	@p_prod_code nvarchar(255),
    @p_prod_title nvarchar(255),
    @p_price_unit float,
    @p_part_price_unit float,
    @p_add_process_price_unit float,
    @p_prod_type_code nvarchar(255),
    @r_prod_seq int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SET @p_prod_code = LTRIM(RTRIM(@p_prod_code));
	
	DECLARE @t_overlap_count int;
	
	SET @t_overlap_count = (SELECT COUNT(*) FROM PROD_MST WHERE PROD_CODE = @p_prod_code);
	
	IF(@t_overlap_count < 1)
		BEGIN
			-- Insert statements for procedure here
			INSERT INTO [ACube].[dbo].[PROD_MST]
				   ([PROD_CODE]
				   ,[PROD_TITLE]
				   ,[PROD_DESCRIPTION]
				   ,[PROD_TYPE_CODE]
				   ,[PRICE_UNIT]
				   ,[PART_CASE_PRICE_UNIT]
				   ,[ADDITIONAL_PROCESSING_PRICE]
				   ,[REG_DATE])
			 VALUES
				   (@p_prod_code
				   ,@p_prod_title
				   ,''
				   ,@p_prod_type_code
				   ,@p_price_unit
				   ,@p_part_price_unit
				   ,@p_add_process_price_unit
				   ,GETDATE());
		           
			SET @r_prod_seq = SCOPE_IDENTITY();
		END
END

GO
