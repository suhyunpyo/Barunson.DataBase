IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ORDER_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ORDER_DETAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ORDER_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_order_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
    OM.*,
    REQUEST_TYPE_CC.DTL_NAME AS REQUEST_STATUS_TYPE_NAME,
    REQUEST_TYPE_CC.DTL_DESC AS REQUEST_STATUS_TYPE_DESC,
    ORDER_TYPE_CC.DTL_NAME AS ORDER_STATUS_TYPE_NAME,
    ORDER_TYPE_CC.DTL_DESC AS ORDER_STATUS_TYPE_DESC,
    STUFF(
		(
			SELECT 
			'|,|' + '{' 
			+ '"CART_SEQ"' + ':"' + CONVERT(nvarchar, CM.CART_SEQ) + '",' 
			+ '"CART_CODE"' + ':"' + CM.CART_CODE + '",' 
			+ '"CART_TYPE_CODE"' + ':"' + CM.CART_TYPE_CODE + '",' 
			+ '"CART_TYPE_NAME"' + ':"' + TYPE_CC.DTL_NAME + '",'
			+ '"CART_TYPE_DESC"' + ':"' + TYPE_CC.DTL_DESC + '",'
			+ '"PROD_SEQ"' + ':"' + CONVERT(nvarchar, CM.PROD_SEQ) + '",' 
			+ '"PROD_CODE"' + ':"' + ISNULL(PM.PROD_CODE, PSGM.PROD_SET_GROUP_CODE) + '",' 
			+ '"QUANTITY"' + ':"' + CONVERT(nvarchar, CM.QUANTITY) + '",'
			+ '"REG_DATE"' + ':"' + CONVERT(nvarchar, CM.REG_DATE, 20) + '",'
			+ '"REQUEST_SHIPPING_DATE"' + ':"' + CONVERT(nvarchar, CM.REQUEST_SHIPPING_DATE, 20) + '",'
			+ '"TYPE_DTL_NAME"' + ':"' + ISNULL(PM_TYPE_CC.DTL_NAME,'') + '",'
			+ '"TYPE_DTL_DESC"' + ':"' + ISNULL(PM_TYPE_CC.DTL_DESC,'') + '",'
			+ '"PRICE"' + ':"' + CONVERT(nvarchar, CM.PRICE) + '",' 
			+ '"PRICE_UNIT"' + ':"' + CONVERT(nvarchar, CM.PRICE_UNIT) + '",' 
			+ '"CART_ITEM_LIST" : ['
			+ISNULL(
				(
					STUFF((	
						SELECT 
						',{'
						+'	"CART_ITEM_SEQ" : "' + CONVERT(nvarchar,CIM.CART_ITEM_SEQ)+'"' 
						+'	,"PROD_SEQ" : "' + CONVERT(nvarchar,CIM.PROD_SEQ)+'"'
						+'	,"PROD_CODE" : "' + CIM_PM.PROD_CODE+'"'
						+'	,"PROD_TYPE_CODE" : "' + CIM_PM.PROD_TYPE_CODE+'"'
						+'	,"PROD_TYPE_NAME" : "' + CIM_PM_TYPE_CC.DTL_NAME+'"'
						+'	,"PROD_TYPE_DESC" : "' + CIM_PM_TYPE_CC.DTL_DESC+'"'
						+'	,"QUANTITY" : "' + CONVERT(nvarchar,CIM.QUANTITY)+'"'
						+'	,"EXPORT_QUANTITY" : "' + CONVERT(nvarchar,CIM.EXPORT_QUANTITY)+'"'
						+'	,"REG_DATE"' + ':"' + CONVERT(nvarchar, CIM.REG_DATE, 20) + '"'
						+'  ,"CART_ITEM_PRINT_LIST" : [' + 
								ISNULL(
									STUFF((
										SELECT 
										',{'
										+'	"CART_ITEM_PRINT_SEQ" : "' + CONVERT(nvarchar, CIPM.CART_ITEM_PRINT_SEQ) + '"'
										+'	,"PDF_PATH" : "' + CIPM.PDF_PATH + '"'
										+'	,"JPG_PATH" : "' + CIPM.JPG_PATH + '"'
										+'	,"QUANTITY" : "' + CONVERT(nvarchar, CIPM.QUANTITY) + '"'
										+'	,"EXPORT_QUANTITY" : "' + CONVERT(nvarchar, CIPM.EXPORT_QUANTITY) + '"'
										+'	,"REG_DATE" : "' + CONVERT(nvarchar, CIM.REG_DATE, 20) + '"'
										+'}'
										FROM CART_ITEM_PRINT_MST CIPM
										WHERE CIPM.CART_ITEM_SEQ = CIM.CART_ITEM_SEQ
										FOR XML PATH('')
									),1, 1, '')
								,'') 
							+ ']'
						+'}'
						FROM CART_ITEM_MST CIM 
						LEFT JOIN PROD_MST CIM_PM ON CIM.PROD_SEQ = CIM_PM.PROD_SEQ
						LEFT JOIN COMMON_CODE CIM_PM_TYPE_CC ON CIM_PM_TYPE_CC.CMMN_CODE = CIM_PM.PROD_TYPE_CODE
						WHERE CIM.CART_SEQ = CM.CART_SEQ
						FOR XML PATH('')
					), 1, 1, '')
				)
			,'')
			+ ']'
			
			+ '}'
			FROM VW_CART_MST CM
			LEFT JOIN COMMON_CODE TYPE_CC ON CM.CART_TYPE_CODE = TYPE_CC.CMMN_CODE
			LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = CM.PROD_SEQ
			LEFT JOIN PROD_SET_GROUP_MST PSGM ON PSGM.PROD_SET_GROUP_SEQ = CM.PROD_SEQ
			LEFT JOIN COMMON_CODE PM_TYPE_CC ON PM.PROD_TYPE_CODE = PM_TYPE_CC.CMMN_CODE
			WHERE CM.ORDER_SEQ = OM.ORDER_SEQ
			ORDER BY CM.CART_TYPE_CODE ASC
			FOR XML PATH('')
		), 1, 3, ''
    ) AS CART_INFO_LIST
    FROM VW_ORDER_MST OM
    LEFT JOIN COMMON_CODE REQUEST_TYPE_CC ON OM.REQUEST_STATUS_TYPE_CODE = REQUEST_TYPE_CC.CMMN_CODE
    LEFT JOIN COMMON_CODE ORDER_TYPE_CC ON OM.ORDER_STATUS_TYPE_CODE = ORDER_TYPE_CC.CMMN_CODE
    WHERE ORDER_SEQ = @p_order_seq;
END

GO
