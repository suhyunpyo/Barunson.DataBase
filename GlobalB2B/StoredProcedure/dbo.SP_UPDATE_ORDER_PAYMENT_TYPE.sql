IF OBJECT_ID (N'dbo.SP_UPDATE_ORDER_PAYMENT_TYPE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_ORDER_PAYMENT_TYPE
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
CREATE PROCEDURE [dbo].[SP_UPDATE_ORDER_PAYMENT_TYPE]
	@p_order_seq int,
	@p_payment_type char(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ORDER_MST
	SET PAYMENT_TYPE_CODE = @p_payment_type
	WHERE ORDER_SEQ = @p_order_seq;
	
	DECLARE @t_payment_status_code char(6);
	
	SET @t_payment_status_code = (SELECT PAYMENT_STATUS_CODE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq);
	
	IF(@t_payment_status_code IS NULL)
	BEGIN
		UPDATE ORDER_MST
		SET PAYMENT_STATUS_CODE = '145001'
		WHERE ORDER_SEQ = @p_order_seq;
	END
	
	
END

GO
