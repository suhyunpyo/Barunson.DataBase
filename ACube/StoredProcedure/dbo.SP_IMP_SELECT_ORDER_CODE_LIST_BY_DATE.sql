IF OBJECT_ID (N'dbo.SP_IMP_SELECT_ORDER_CODE_LIST_BY_DATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_IMP_SELECT_ORDER_CODE_LIST_BY_DATE
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
CREATE PROCEDURE [dbo].[SP_IMP_SELECT_ORDER_CODE_LIST_BY_DATE]
	@p_start_date Datetime,
	@p_end_date Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT 
	VM.ORDER_CODE,
	COUNT(*) as PRINT_COUNT,
	MIN(VM.REQUEST_SHIPPING_DATE) AS REQUEST_SHIPPING_DATE
	FROM VW_IMP_CART_PRINT_ITEM_MST VM
	WHERE 
	VM.REQUEST_SHIPPING_DATE >= @p_start_date AND VM.REQUEST_SHIPPING_DATE <= @p_end_date
	GROUP BY VM.ORDER_CODE
	ORDER BY VM.ORDER_CODE DESC;
END
GO
