IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_LAST_ORDER_PAYMENT_RESULT_DETAIL_BY_ORDER_SEQ', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_LAST_ORDER_PAYMENT_RESULT_DETAIL_BY_ORDER_SEQ
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_LAST_ORDER_PAYMENT_RESULT_DETAIL_BY_ORDER_SEQ]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @p_seq int

	SET @p_seq = (SELECT TOP 1 PAYMENT_RESULT_SEQ FROM ORDER_PAYMENT_RESULT_MST WHERE ORDER_SEQ = @p_order_seq ORDER BY PAYMENT_RESULT_SEQ DESC);

	IF(@p_seq > 0 )
	BEGIN 
		EXECUTE [GlobalB2B].[dbo].[SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_DETAIL] 
			@p_seq;	
	END

END

GO
