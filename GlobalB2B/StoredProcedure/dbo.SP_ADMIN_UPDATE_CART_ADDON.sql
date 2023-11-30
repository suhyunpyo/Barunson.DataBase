IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_CART_ADDON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_CART_ADDON
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_CART_ADDON]
	-- Add the parameters for the stored procedure here
	@p_cart_addon_seq int,
	@p_quantity int,
	@p_price_unit float
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [GlobalB2B].[dbo].[CART_ADDON_MST]
	SET 
	  [QUANTITY] = @p_quantity
	  ,[PRICE_UNIT] = @p_price_unit
	WHERE CART_ADDON_SEQ = @p_cart_addon_seq;

	
END


GO
