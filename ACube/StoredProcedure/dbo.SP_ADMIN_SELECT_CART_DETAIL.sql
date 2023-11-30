IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_CART_DETAIL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_CART_DETAIL
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_CART_DETAIL]
	-- Add the parameters for the stored procedure here
	@p_cart_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	CM.*,
	TYPE_CC.DTL_NAME AS CART_TYPE_NAME,
	TYPE_CC.DTL_DESC AS CART_TYPE_DESC,
	ISNULL(PM.PROD_CODE, PSGM.PROD_SET_GROUP_CODE) AS PROD_CODE,
	'{'
	+'"CART_ITEM_LIST" : ['
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
	+ ']'-- CART_ITEM_LIST
	+ '}' AS CART_ITEM_LIST
	FROM CART_MST CM
	LEFT JOIN COMMON_CODE TYPE_CC ON CM.CART_TYPE_CODE = TYPE_CC.CMMN_CODE
	LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = CM.PROD_SEQ AND CM.CART_TYPE_CODE = '201003'
	LEFT JOIN PROD_SET_GROUP_MST PSGM ON PSGM.PROD_SET_GROUP_SEQ = CM.PROD_SEQ AND (CM.CART_TYPE_CODE = '201002' OR CM.CART_TYPE_CODE = '201001')
	WHERE CM.CART_SEQ = @p_cart_seq;
END

GO
