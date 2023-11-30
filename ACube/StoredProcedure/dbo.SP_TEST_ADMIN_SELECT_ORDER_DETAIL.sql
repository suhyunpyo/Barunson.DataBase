IF OBJECT_ID (N'dbo.SP_TEST_ADMIN_SELECT_ORDER_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_TEST_ADMIN_SELECT_ORDER_DETAIL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Multiple Result Type 
-- =============================================
CREATE PROCEDURE [dbo].[SP_TEST_ADMIN_SELECT_ORDER_DETAIL]
	@p_order_seq int
AS
BEGIN
	SET NOCOUNT ON;

    -- Result Order MST 
	SELECT 
    OM.*,
    REQUEST_TYPE_CC.DTL_NAME AS REQUEST_STATUS_TYPE_NAME,
    REQUEST_TYPE_CC.DTL_DESC AS REQUEST_STATUS_TYPE_DESC,
    ORDER_TYPE_CC.DTL_NAME AS ORDER_STATUS_TYPE_NAME,
    ORDER_TYPE_CC.DTL_DESC AS ORDER_STATUS_TYPE_DESC
    FROM ORDER_MST OM
    LEFT JOIN COMMON_CODE REQUEST_TYPE_CC ON OM.REQUEST_STATUS_TYPE_CODE = REQUEST_TYPE_CC.CMMN_CODE
    LEFT JOIN COMMON_CODE ORDER_TYPE_CC ON OM.ORDER_STATUS_TYPE_CODE = ORDER_TYPE_CC.CMMN_CODE
    WHERE ORDER_SEQ = @p_order_seq;
    
    
    -- Result Cart Mst
    SELECT 
    CM.CART_SEQ
    ,CM.CART_CODE
    ,CM.CART_TYPE_CODE
    ,CM.ORDER_SEQ
    ,CM.QUANTITY
    ,CM.REQUEST_SHIPPING_DATE
    ,CM.UPDATE_DATE
    ,CM.REG_DATE
    ,TYPE_CC.DTL_NAME AS CART_TYPE_NAME
    ,TYPE_CC.DTL_DESC AS CART_TYPE_DESC
    ,PM.PROD_SEQ AS PROD_SEQ
    ,ISNULL(PM.PROD_CODE, PSGM.PROD_SET_GROUP_CODE) AS PROD_CODE
    FROM CART_MST CM
    LEFT JOIN COMMON_CODE TYPE_CC ON CM.CART_TYPE_CODE = TYPE_CC.CMMN_CODE
	LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = CM.PROD_SEQ
	LEFT JOIN PROD_SET_GROUP_MST PSGM ON PSGM.PROD_SET_GROUP_SEQ = CM.PROD_SEQ
	WHERE CM.ORDER_SEQ = @p_order_seq
	
	
	-- Result Cart Item
	
	SELECT
	CIM.CART_SEQ,
	CIM.CART_ITEM_SEQ,
	CIM.PROD_SEQ,
	CIM.QUANTITY,
	CIM.EXPORT_QUANTITY,
	CIM.REG_DATE,
	CIM_PM.PROD_CODE,
	CIM_PM_TYPE_CC.DTL_NAME AS PROD_TYPE_CODE,
	CIM_PM_TYPE_CC.DTL_DESC AS PROD_TYPE_DESC
	FROM CART_ITEM_MST CIM 
	LEFT JOIN CART_MST CM ON CIM.CART_SEQ = CM.CART_SEQ
	LEFT JOIN PROD_MST CIM_PM ON CIM.PROD_SEQ = CIM_PM.PROD_SEQ
	LEFT JOIN COMMON_CODE CIM_PM_TYPE_CC ON CIM_PM_TYPE_CC.CMMN_CODE = CIM_PM.PROD_TYPE_CODE
	WHERE CM.ORDER_SEQ = @p_order_seq 
	
	
	-- Result Cart Print Item
	SELECT
	CIPM.CART_ITEM_SEQ
	,CIPM.CART_ITEM_PRINT_SEQ
	,CIPM.PDF_PATH
	,CIPM.JPG_PATH
	,CIPM.QUANTITY
	,CIPM.EXPORT_QUANTITY
	,CIPM.REG_DATE
	FROM CART_ITEM_PRINT_MST CIPM
	LEFT JOIN CART_ITEM_MST CIM ON CIPM.CART_ITEM_SEQ = CIPM.CART_ITEM_SEQ
	LEFT JOIN CART_MST CM ON CIM.CART_SEQ = CM.CART_SEQ
	WHERE CM.ORDER_SEQ = @p_order_seq;
	
END

GO
