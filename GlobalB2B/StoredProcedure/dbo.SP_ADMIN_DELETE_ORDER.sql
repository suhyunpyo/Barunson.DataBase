IF OBJECT_ID (N'dbo.SP_ADMIN_DELETE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_DELETE_ORDER
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
CREATE PROCEDURE [dbo].[SP_ADMIN_DELETE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DELETE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq;
	DELETE FROM CART_MST WHERE ORDER_SEQ = @p_order_seq;
	-- CART_ADDON_MST 도 삭제 필요.
END

GO
