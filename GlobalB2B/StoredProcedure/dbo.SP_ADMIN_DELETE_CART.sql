IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_CART', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_CART
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_CART]
	@p_cart_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE 
	FROM
	ADDITIONAL_PRICE_MST
	WHERE FOREIGN_SEQ = @p_cart_seq
	AND (
		ADD_PRICE_TYPE_CODE = '120001'
		OR 
		ADD_PRICE_TYPE_CODE = '120002'
	)
	
	DELETE
	FROM 
	CART_MST 
	WHERE CART_SEQ = @p_cart_seq
END
GO
