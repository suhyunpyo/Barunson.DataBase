IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_SAMPLE_ITEM_LIST_BY_SAMPLE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_SAMPLE_ITEM_LIST_BY_SAMPLE_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_SAMPLE_ITEM_LIST_BY_SAMPLE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	CM.*,
	PM.PROD_SEQ,
	PM.PROD_CODE,
	PM.PROD_TITLE
	FROM CART_MST CM
	LEFT JOIN PROD_MST PM ON CM.PROD_SEQ = PM.PROD_SEQ
	WHERE CM.ORDER_SEQ = @p_order_seq
	AND CM.CART_TYPE_CODE = '111003'
	ORDER BY CM.CART_SEQ ASC;
	
END

GO
