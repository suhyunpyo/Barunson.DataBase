IF OBJECT_ID (N'dbo.SP_ERP_DELETE_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ERP_DELETE_ORDER
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
CREATE PROCEDURE [dbo].[SP_ERP_DELETE_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @t_order_code nvarchar(255);
	
	SET @t_order_code = (SELECT ORDER_CODE FROM ORDER_MST WHERE ORDER_SEQ = @p_order_seq);
	
	DELETE FROM [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_exOrderHeaderTemp] WHERE PO_NO = @t_order_code;
	DELETE FROM [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_exOrderItemTemp] WHERE PO_NO = @t_order_code;
	
	UPDATE ORDER_MST
	SET ERP_INSERT_YORN = 'N',
	ERP_INSERT_DATE = GETDATE()
	WHERE ORDER_SEQ = @p_order_seq;
	
END

GO
