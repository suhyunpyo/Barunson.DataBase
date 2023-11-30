IF OBJECT_ID (N'dbo.SP_ADMIN_INSERT_CART_ADDON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_INSERT_CART_ADDON
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
CREATE PROCEDURE [dbo].[SP_ADMIN_INSERT_CART_ADDON]
	-- Add the parameters for the stored procedure here
	@p_cart_seq int,
	@p_prod_seq int,
	@p_quantity int,
	@p_price_unit float,
	@r_result int OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @t_exist_count int;
	
	SET @t_exist_count = (SELECT COUNT(*) FROM CART_ADDON_MST WHERE CART_SEQ = @p_cart_seq AND PROD_SEQ = @p_prod_seq);

	IF(@t_exist_count < 1)
		BEGIN
		INSERT INTO [GlobalB2B].[dbo].[CART_ADDON_MST]
			   ([CART_SEQ]
			   ,[PROD_SEQ]
			   ,[QUANTITY]
			   ,[PRICE_UNIT]
			   ,[REG_DATE])
		 VALUES
			   (@p_cart_seq
			   ,@p_prod_seq
			   ,@p_quantity
			   ,@p_price_unit
			   ,GETDATE())	
			   
		SET @r_result = SCOPE_IDENTITY();
		END
END

GO
