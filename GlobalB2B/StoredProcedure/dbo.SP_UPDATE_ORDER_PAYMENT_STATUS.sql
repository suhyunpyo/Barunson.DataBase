IF OBJECT_ID (N'dbo.SP_UPDATE_ORDER_PAYMENT_STATUS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_UPDATE_ORDER_PAYMENT_STATUS
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
CREATE PROCEDURE [dbo].[SP_UPDATE_ORDER_PAYMENT_STATUS]
	-- Add the parameters for the stored procedure here
	@p_order_seq int,
	@p_code nvarchar(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Insert statements for procedure here
	UPDATE ORDER_MST
	SET PAYMENT_STATUS_CODE = @p_code
	WHERE ORDER_SEQ = @p_order_seq;
END

GO
