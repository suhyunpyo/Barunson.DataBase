IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_CART_ITEM', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_CART_ITEM
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_CART_ITEM]
	-- Add the parameters for the stored procedure here
	@p_cart_item_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM CART_ITEM_PRINT_MST WHERE CART_ITEM_SEQ = @p_cart_item_seq;
	DELETE FROM CART_ITEM_MST WHERE CART_ITEM_SEQ = @p_cart_item_seq;
END

GO
