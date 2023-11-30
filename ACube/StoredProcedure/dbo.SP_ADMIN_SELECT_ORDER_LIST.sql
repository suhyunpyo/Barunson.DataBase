IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ORDER_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ORDER_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ORDER_LIST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
	@p_request_status_type nchar(6),
	@p_order_status_type nchar(6),
	@p_exist_print_yorn nchar(1) = null,
	@p_erp_insert_yorn nchar(1) = null,
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_page_num int;
	
    IF(@p_search_type IS NULL)
		SET @p_search_type = 'code';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	IF(@p_date_kind_type IS NULL)
		SET @p_date_kind_type = 'orderDate';
		
	IF(@p_request_status_type IS NULL)
		SET @p_request_status_type = '';
		
	IF(@p_order_status_type IS NULL)
		SET @p_order_status_type = '';	
		
	IF(@p_exist_print_yorn IS NULL)
		SET @p_exist_print_yorn = '';
	
	IF(@p_erp_insert_yorn IS NULL)
		SET @p_erp_insert_yorn = '';
		
	--검색어가 존재할경우, 모든 검색요건을 삭제한다.
	--2015.08.03. 박은현 대리 요청사항
	IF(@p_search_value != '')
	BEGIN
		SET @p_date_kind_type = '';
		SET @p_request_status_type = '';
		SET @p_order_status_type = '';
		SET @p_exist_print_yorn = '';
		SET @p_erp_insert_yorn = '';
	END

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
					SELECT COUNT(*) FROM VW_ORDER_MST OM
					LEFT JOIN 
					(
						SELECT 
							DISTINCT ORDER_SEQ 
						FROM CART_MST CM
						WHERE
						(
							CASE @p_date_kind_type
							WHEN 'shippingDate' THEN CM.REQUEST_SHIPPING_DATE
							ELSE @p_start_date END
						) >= @p_start_date
						AND
						(
							CASE @p_date_kind_type
							WHEN 'shippingDate' THEN CM.REQUEST_SHIPPING_DATE
							ELSE @p_end_date END
						) <= @p_end_date
					) CART_OM ON OM.ORDER_SEQ = CART_OM.ORDER_SEQ
					WHERE CART_OM.ORDER_SEQ IS NOT NULL
					AND
					(
						CASE @p_date_kind_type
						WHEN 'orderDate' THEN OM.REG_DATE
						ELSE @p_start_date END
					) >= @p_start_date
					AND
					(
						CASE @p_date_kind_type
						WHEN 'orderDate' THEN OM.REG_DATE
						ELSE @p_end_date  END
					) <= @p_end_date
					AND
					(
						CASE @p_request_status_type
						WHEN '' THEN ''
						ELSE OM.REQUEST_STATUS_TYPE_CODE END
					) = @p_request_status_type
					AND
					(
						CASE @p_order_status_type
						WHEN '' THEN ''
						ELSE OM.ORDER_STATUS_TYPE_CODE END
					) = @p_order_status_type
					AND
					(
						CASE @p_search_type
						WHEN 'code' THEN OM.ORDER_CODE
						ELSE OM.ORDER_CODE END
					) LIKE @p_search_value
					AND
					(
						CASE @p_exist_print_yorn 
						WHEN '' THEN @p_exist_print_yorn
						ELSE 
							(CASE WHEN OM.CART_ITEM_PRINT_COUNT > 0 THEN 'Y' ELSE 'N' END)
						END
					) = @p_exist_print_yorn
					AND
					(
						CASE @p_erp_insert_yorn 
						WHEN '' THEN @p_erp_insert_yorn
						ELSE ISNULL(OM.ERP_INSERT_YORN,'N') END
					) = @p_erp_insert_yorn
				)

				
	SELECT TOP(@p_page_row_size)
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
						ORDER BY CIM_PM.PROD_TYPE_CODE ASC
						FOR XML PATH('')
					), 1, 1, '')
				)
			,'')
			+ ']'
			+ '}'
			FROM VW_CART_MST CM
			LEFT JOIN COMMON_CODE TYPE_CC ON CM.CART_TYPE_CODE = TYPE_CC.CMMN_CODE
			LEFT JOIN PROD_MST PM ON PM.PROD_SEQ = CM.PROD_SEQ AND CM.CART_TYPE_CODE = '201003'
			LEFT JOIN PROD_SET_GROUP_MST PSGM ON PSGM.PROD_SET_GROUP_SEQ = CM.PROD_SEQ AND CM.CART_TYPE_CODE != '201003'
			LEFT JOIN COMMON_CODE PM_TYPE_CC ON PM.PROD_TYPE_CODE = PM_TYPE_CC.CMMN_CODE
			WHERE CM.ORDER_SEQ = OM.ORDER_SEQ
			ORDER BY CM.CART_TYPE_CODE ASC
			FOR XML PATH('')
		), 1, 3, ''
    ) AS CART_INFO_LIST
	
	FROM VW_ORDER_MST OM
	LEFT JOIN 
	(
		SELECT 
			DISTINCT ORDER_SEQ 
		FROM CART_MST CM
		WHERE
		(
			CASE @p_date_kind_type
			WHEN 'shippingDate' THEN CM.REQUEST_SHIPPING_DATE
			ELSE @p_start_date END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'shippingDate' THEN CM.REQUEST_SHIPPING_DATE
			ELSE @p_end_date END
		) <= @p_end_date
	) CART_OM ON OM.ORDER_SEQ = CART_OM.ORDER_SEQ
	
	LEFT JOIN COMMON_CODE REQUEST_TYPE_CC ON REQUEST_TYPE_CC.CMMN_CODE = OM.REQUEST_STATUS_TYPE_CODE
	LEFT JOIN COMMON_CODE ORDER_TYPE_CC ON ORDER_TYPE_CC.CMMN_CODE = OM.ORDER_STATUS_TYPE_CODE
	WHERE OM.ORDER_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IOM.ORDER_SEQ
		FROM VW_ORDER_MST IOM
		LEFT JOIN 
		(
			SELECT 
				DISTINCT ORDER_SEQ 
			FROM CART_MST ICM
			WHERE
			(
				CASE @p_date_kind_type
				WHEN 'shippingDate' THEN ICM.REQUEST_SHIPPING_DATE
				ELSE @p_start_date END
			) >= @p_start_date
			AND
			(
				CASE @p_date_kind_type
				WHEN 'shippingDate' THEN ICM.REQUEST_SHIPPING_DATE
				ELSE @p_end_date END
			) <= @p_end_date
		) ICART_OM ON IOM.ORDER_SEQ = ICART_OM.ORDER_SEQ
		WHERE ICART_OM.ORDER_SEQ IS NOT NULL
		AND
		(
			CASE @p_date_kind_type
			WHEN 'orderDate' THEN IOM.REG_DATE
			ELSE @p_start_date END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'orderDate' THEN IOM.REG_DATE
			ELSE @p_end_date  END
		) <= @p_end_date
		AND
		(
			CASE @p_request_status_type
			WHEN '' THEN ''
			ELSE IOM.REQUEST_STATUS_TYPE_CODE END
		) = @p_request_status_type
		AND
		(
			CASE @p_order_status_type
			WHEN '' THEN ''
			ELSE IOM.ORDER_STATUS_TYPE_CODE END
		) = @p_order_status_type
		AND
		(
			CASE @p_search_type
			WHEN 'code' THEN IOM.ORDER_CODE
			ELSE IOM.ORDER_CODE END
		) LIKE @p_search_value
		AND
		(
			CASE @p_exist_print_yorn 
			WHEN '' THEN @p_exist_print_yorn
			ELSE 
				(CASE WHEN IOM.CART_ITEM_PRINT_COUNT > 0 THEN 'Y' ELSE 'N' END)
			END
		) = @p_exist_print_yorn
		AND
		(
			CASE @p_erp_insert_yorn 
			WHEN '' THEN @p_erp_insert_yorn
			ELSE ISNULL(IOM.ERP_INSERT_YORN,'N') END
		) = @p_erp_insert_yorn
		ORDER BY IOM.ORDER_SEQ ASC
	)
	AND
	CART_OM.ORDER_SEQ IS NOT NULL
	AND
	(
		CASE @p_date_kind_type
		WHEN 'orderDate' THEN OM.REG_DATE
		ELSE @p_start_date END
	) >= @p_start_date
	AND
	(
		CASE @p_date_kind_type
		WHEN 'orderDate' THEN OM.REG_DATE
		ELSE @p_end_date  END
	) <= @p_end_date
	AND
	(
		CASE @p_request_status_type
		WHEN '' THEN ''
		ELSE OM.REQUEST_STATUS_TYPE_CODE END
	) = @p_request_status_type
	AND
	(
		CASE @p_order_status_type
		WHEN '' THEN ''
		ELSE OM.ORDER_STATUS_TYPE_CODE END
	) = @p_order_status_type
	AND
	(
		CASE @p_search_type
		WHEN 'code' THEN OM.ORDER_CODE
		ELSE OM.ORDER_CODE END
	) LIKE @p_search_value
	AND
	(
		CASE @p_exist_print_yorn 
		WHEN '' THEN @p_exist_print_yorn
		ELSE 
			(CASE WHEN OM.CART_ITEM_PRINT_COUNT > 0 THEN 'Y' ELSE 'N' END)
		END
	) = @p_exist_print_yorn
	AND
	(
		CASE @p_erp_insert_yorn 
		WHEN '' THEN @p_erp_insert_yorn
		ELSE 
			ISNULL(OM.ERP_INSERT_YORN,'N')
		END
	) = @p_erp_insert_yorn
	ORDER BY OM.ORDER_SEQ ASC;	
END
GO
