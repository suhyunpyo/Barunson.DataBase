IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_PRODUCT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_PRODUCT
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_PRODUCT]
	-- Add the parameters for the stored procedure here
	@p_prod_seq int,
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
	@p_movie_url nvarchar(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [GlobalB2B].[dbo].[PROD_MST]
	SET [CATEGORY_TYPE_CODE] = @p_category_type_code
	  ,[KIND_CODE] = @p_kind_code
	  ,[TYPE_CODE] = @p_type_code
	  ,[PRINT_TYPE_CODE] = @p_print_type_code
	  ,[THEME_TYPE_CODE] = @p_theme_type_code
	  ,[PROD_TITLE] = @p_prod_title
	  ,[PROD_CONTENT] = @p_prod_content
	  ,[MIN_ORDER] = @p_min_order
	  ,[PRICE_TERM_TYPE_CODE] = @p_price_term_type_code
	  ,[PROD_SIZE_TYPE_CODE] = @p_prod_size_type_code
	  ,[PROD_WIDTH] = @p_prod_width
	  ,[PROD_HEIGHT] = @p_prod_height
	  ,[PROD_WEIGHT] = @p_prod_weight
	  ,[COLOR_TYPE_CODE] = @p_color_type_code
	  ,[USE_YORN] = @p_user_yorn
	  ,[WHOLE_SALE_YORN] = @p_whole_sale_yorn
	  ,[SAMPLE_USE_YORN] = @p_sample_use_yorn
	  ,[MOVIE_URL] = @p_movie_url
	WHERE PROD_SEQ = @p_prod_seq;
	
END

GO
