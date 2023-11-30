IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ORDER_CART_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ORDER_CART_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ORDER_CART_LIST]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	VCM.*,
	UM.USER_ID,
	UM.FIRST_NAME,
	UM.LAST_NAME,
	PM.PROD_CODE,
	PM.PROD_TITLE,
	PM.MIN_ORDER
	FROM VW_CART_MST VCM
	LEFT JOIN USER_MST UM ON VCM.USER_SEQ = UM.USER_SEQ
	LEFT JOIN PROD_MST PM ON VCM.PROD_SEQ = PM.PROD_SEQ
	WHERE ORDER_SEQ = @p_order_seq
END


GO
