IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_PRODUCT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_PRODUCT
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_PRODUCT]
	-- Add the parameters for the stored procedure here
	@p_prod_code nvarchar(15),	
	@p_category_type_code char(6),
	@p_kind_code char(6),
	@p_type_code char(6),
	@p_print_type_code char(6),
	@p_theme_type_code char(6),
	@p_color_type_code char(6),
	@p_prod_title nvarchar(200),
	@p_prod_content ntext,
	@p_min_order int,
	@p_price_term_type_code char(6),
	@p_prod_size_type_code char(6),
	@p_prod_width numeric(18,2),
	@p_prod_height numeric(18,2),
	@p_prod_weight numeric(18,2),
	@p_user_yorn char(1),
	@p_whole_sale_yorn char(1),
	@p_sample_use_yorn char(1),
	@p_movie_url nvarchar(500),
	@r_result int OUTPUT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	INSERT INTO [GlobalB2B].[dbo].[PROD_MST]
           ([PROD_CODE]
           ,[CATEGORY_TYPE_CODE]
           ,[KIND_CODE]
           ,[TYPE_CODE]
           ,[PRINT_TYPE_CODE]
           ,[THEME_TYPE_CODE]
           ,[PROD_TITLE]
           ,[PROD_CONTENT]
           ,[MIN_ORDER]
           ,[PRICE_TERM_TYPE_CODE]
           ,[PROD_SIZE_TYPE_CODE]
           ,[PROD_WIDTH]
           ,[PROD_HEIGHT]
           ,[PROD_WEIGHT]
           ,[FORMAT_TYPE_CODE]
           ,[COLOR_TYPE_CODE]
           ,[USE_YORN]
           ,[WHOLE_SALE_YORN]
           ,[SAMPLE_USE_YORN]
           ,[REG_DATE]
           ,[ERP_EXIST_CHECK_YORN]
           ,[ERP_EXIST_YORN]
		   ,[MOVIE_URL]
           )
     VALUES
           (@p_prod_code
           ,@p_category_type_code
           ,@p_kind_code
           ,@p_type_code
           ,@p_print_type_code
           ,@p_theme_type_code
           ,@p_prod_title
           ,@p_prod_content
           ,@p_min_order
           ,@p_price_term_type_code
           ,@p_prod_size_type_code
           ,@p_prod_width
           ,@p_prod_height
           ,@p_prod_weight
           ,NULL --FORMAT_TYPE_CODE
           ,@p_color_type_code
           ,@p_user_yorn
           ,@p_whole_sale_yorn
           ,@p_sample_use_yorn
           ,GETDATE()
           ,'Y'
           ,'Y'
		   ,@p_movie_url
           )
	
	SET @r_result = SCOPE_IDENTITY();
	
END

GO
