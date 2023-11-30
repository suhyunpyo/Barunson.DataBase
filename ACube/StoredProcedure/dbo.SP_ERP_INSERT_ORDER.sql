IF OBJECT_ID (N'dbo.SP_ERP_INSERT_ORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ERP_INSERT_ORDER
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
CREATE PROCEDURE [dbo].[SP_ERP_INSERT_ORDER]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	INSERT INTO [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_exOrderHeaderTemp](PO_No, OrderNo, ItemCode, ItemPrice, TotalQty, TotalAmount, ShipDate, OrderDate) 
	SELECT 
	VOM.ORDER_CODE,
	VCM.CART_CODE,
	REPLACE(LTRIM(RTRIM(ISNULL(PM.PROD_CODE, PSGM.PROD_SET_GROUP_CODE))), 'printing cost (Digital)', 'D-printing cost'),	--ERP는 품목코드 20자리 이하로만 넘길것. 20160609 이상민
	VCM.PRICE_UNIT,
	VCM.QUANTITY,
	VCM.PRICE,
	replace(convert(varchar, VCM.REQUEST_SHIPPING_DATE, 111), '/', ''),
	replace(convert(varchar, VOM.REG_DATE, 111), '/', '')
	FROM VW_CART_MST VCM 
	LEFT JOIN VW_ORDER_MST VOM ON VCM.ORDER_SEQ = VOM.ORDER_SEQ
	LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = VCM.PROD_SEQ AND VCM.CART_TYPE_CODE = '201003'
	LEFT JOIN PROD_SET_GROUP_MST PSGM ON PSGM.PROD_SET_GROUP_SEQ = VCM.PROD_SEQ AND VCM.CART_TYPE_CODE != '201003'
	WHERE VCM.ORDER_SEQ = @p_order_seq
	
	INSERT INTO [ERPDB.BHANDSCARD.COM].[XERP].[dbo].[C_exOrderItemTemp](PO_No, OrderNo, OrderSerNo, ItemCode, ItemQty, ItemAmnt)
	SELECT
	--VCM.CART_SEQ,
	VOM.ORDER_CODE,
	VCM.CART_CODE,
	row_number() over (PARTITION BY VCM.CART_SEQ ORDER BY CIM_PM.PROD_TYPE_CODE ASC) - 1,
	REPLACE(LTRIM(RTRIM(CIM_PM.PROD_CODE)), 'printing cost (Digital)', 'D-printing cost'),	--ERP는 품목코드 20자리 이하로만 넘길것. 20160609 이상민
	CIM.EXPORT_QUANTITY,
	(
		(CIM_PM.PRICE_UNIT  * CIM.QUANTITY)
		+
		(
			CASE CIM_PM.PROD_TYPE_CODE 
			WHEN '101001' 
			THEN VCM.ADDITION_PROCESSING_PRICE 
			ELSE 0 
			END 
		)
	)
	FROM VW_CART_MST VCM
	LEFT JOIN VW_ORDER_MST VOM ON VCM.ORDER_SEQ = VOM.ORDER_SEQ
	LEFT JOIN CART_ITEM_MST CIM ON VCM.CART_SEQ = CIM.CART_SEQ
	LEFT JOIN PROD_MST CIM_PM ON CIM.PROD_SEQ = CIM_PM.PROD_SEQ
	WHERE VCM.ORDER_SEQ = @p_order_seq AND VCM.CART_TYPE_CODE != '201003'
	ORDER BY VCM.CART_SEQ ASC,CIM_PM.PROD_TYPE_CODE ASC
	
	
	UPDATE ORDER_MST
	SET ERP_INSERT_YORN = 'Y',
	ERP_INSERT_DATE = GETDATE()
	WHERE ORDER_SEQ = @p_order_seq;
	
	
	
END

GO
