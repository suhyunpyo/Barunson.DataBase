IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_ORDER_REQUEST_STATUS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_ORDER_REQUEST_STATUS
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_ORDER_REQUEST_STATUS]
	-- Add the parameters for the stored procedure here
	@p_order_seq int,
	@p_requeset_status_type_code nchar(6)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE ORDER_MST
	SET REQUEST_STATUS_TYPE_CODE = @p_requeset_status_type_code
	WHERE ORDER_SEQ = @p_order_seq;
END
GO
