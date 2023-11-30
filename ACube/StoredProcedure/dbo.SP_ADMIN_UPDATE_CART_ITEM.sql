IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_CART_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_CART_ITEM
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_CART_ITEM]
	-- Add the parameters for the stored procedure here
	@p_cart_item_seq int,
	@p_quantity int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE CART_ITEM_MST
	SET QUANTITY = @p_quantity,
	EXPORT_QUANTITY = @p_quantity
	WHERE CART_ITEM_SEQ = @p_cart_item_seq;
	
	EXECUTE [ACube].[dbo].[SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO] 
		@p_cart_item_seq;    
	
END

GO
