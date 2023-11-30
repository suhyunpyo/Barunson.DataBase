IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_MST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_whole_sale_value nvarchar(255),
	@p_sample_use_yorn_value nvarchar(255),
	@p_order_column nvarchar(255) = NULL,
	@p_order_type nvarchar(255) = NULL,
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_page_num int;

    IF(@p_search_type IS NULL)
		SET @p_search_type = 'title';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	IF(@p_order_column IS NULL)
		SET @p_order_column = 'prod_seq';
	
	IF(@p_order_type IS NULL)
		SET @p_order_type = 'desc';
		

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM PROD_MST PM
							WHERE 
							PM.WHOLE_SALE_YORN =
							(
								CASE @p_whole_sale_value
								WHEN 'Y' THEN 'Y'
								WHEN 'N' THEN 'N'
								ELSE PM.WHOLE_SALE_YORN END
							)
							AND
							(
								CASE @p_search_type
								WHEN 'title' THEN PM.PROD_TITLE
								WHEN 'contents' THEN PM.PROD_CONTENT
								WHEN 'code' THEN PM.PROD_CODE
								ELSE PM.PROD_TITLE END
							) LIKE @p_search_value
							
						);
    
    SELECT TOP(@p_page_row_size)
    PM.*
    ,PG.GROUP_CODE
    ,CATEGORY_CC.DTL_NAME as CATEGORY_NAME
    ,TYPE_CC.DTL_NAME as TYPE_NAME
    ,COLOR_CC.DTL_NAME as COLOR_NAME
    ,COLOR_CC.DTL_DESC as COLOR_RGB
    ,KIND_CC.DTL_NAME as KIND_NAME
    ,PRICE_TERM_CC.DTL_NAME as PRICE_TERM_NAME
    ,PRINT_CC.DTL_NAME as PRINT_NAME
    ,SIZE_CC.DTL_NAME as SIZE_NAME
    ,FORMAT_CC.DTL_NAME as FORMAT_NAME
    ,STUFF
	(
		(
			SELECT 
			',' + CAST(PAM.ADD_PROD_SEQ AS NVARCHAR)
			FROM PROD_ADDON_MST PAM 
			WHERE PAM.PROD_SEQ = PM.PROD_SEQ
			ORDER BY PAM.ADD_PROD_SEQ ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS ADD_PROD_SEQ_LIST
    ,STUFF
	(
		(
			SELECT 
			',' + ADD_PM.PROD_CODE
			FROM PROD_ADDON_MST PAM 
			LEFT JOIN PROD_MST ADD_PM ON PAM.ADD_PROD_SEQ = ADD_PM.PROD_SEQ
			WHERE PAM.PROD_SEQ = PM.PROD_SEQ
			ORDER BY PAM.ADD_PROD_SEQ ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS ADD_PROD_CODE_LIST,
	STUFF
	(
		(
			SELECT 
			',' + ADD_PM.TYPE_CODE
			FROM PROD_ADDON_MST PAM 
			LEFT JOIN PROD_MST ADD_PM ON PAM.ADD_PROD_SEQ = ADD_PM.PROD_SEQ
			WHERE PM.PROD_SEQ = PM.PROD_SEQ
			ORDER BY PAM.ADD_PROD_SEQ ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS ADD_PROD_TYPE_CODE_LIST,
	STUFF
	(
		(
			SELECT 
			',' + TYPE_CC.DTL_NAME
			FROM PROD_ADDON_MST PAM
			LEFT JOIN PROD_MST ADD_PM ON PAM.ADD_PROD_SEQ = ADD_PM.PROD_SEQ
			LEFT JOIN COMMON_CODE TYPE_CC ON TYPE_CC.CMMN_CODE = ADD_PM.TYPE_CODE
			WHERE PM.PROD_SEQ = PM.PROD_SEQ
			ORDER BY PAM.ADD_PROD_SEQ ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS ADD_PROD_TYPE_NAME_LIST
    FROM PROD_MST PM
    LEFT JOIN PROD_GROUP PG ON PM.PROD_SEQ = PG.PROD_SEQ AND PG.TYPE_CODE = '117002'
    LEFT JOIN COMMON_CODE CATEGORY_CC ON CATEGORY_CC.CMMN_CODE = PM.CATEGORY_TYPE_CODE
    LEFT JOIN COMMON_CODE TYPE_CC ON TYPE_CC.CMMN_CODE = PM.TYPE_CODE
    LEFT JOIN COMMON_CODE COLOR_CC ON COLOR_CC.CMMN_CODE = PM.COLOR_TYPE_CODE
    LEFT JOIN COMMON_CODE KIND_CC ON KIND_CC.CMMN_CODE = PM.KIND_CODE
    LEFT JOIN COMMON_CODE PRICE_TERM_CC ON PRICE_TERM_CC.CMMN_CODE = PM.PRICE_TERM_TYPE_CODE
    LEFT JOIN COMMON_CODE PRINT_CC ON PRINT_CC.CMMN_CODE = PM.PRINT_TYPE_CODE
    LEFT JOIN COMMON_CODE SIZE_CC ON SIZE_CC.CMMN_CODE = PM.PROD_SIZE_TYPE_CODE
    LEFT JOIN COMMON_CODE FORMAT_CC ON FORMAT_CC.CMMN_CODE = PM.FORMAT_TYPE_CODE
    WHERE PM.PROD_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		PM.PROD_SEQ
		FROM PROD_MST PM
		WHERE
			PM.SAMPLE_USE_YORN = 
			(
				CASE @p_sample_use_yorn_value
				WHEN 'Y' THEN 'Y'
				WHEN 'N' THEN 'N'
				ELSE PM.SAMPLE_USE_YORN END
			)
			AND
			PM.WHOLE_SALE_YORN =
			(
				CASE @p_whole_sale_value
				WHEN 'Y' THEN 'Y'
				WHEN 'N' THEN 'N'
				ELSE PM.WHOLE_SALE_YORN END
			) 
			AND
			(
				CASE @p_search_type
				WHEN 'title' THEN PM.PROD_TITLE
				WHEN 'contents' THEN PM.PROD_CONTENT
				WHEN 'code' THEN PM.PROD_CODE
				ELSE PM.PROD_TITLE END
			) LIKE @p_search_value
		ORDER BY 
			CASE @p_order_type 
			WHEN 'asc' THEN 
				CASE @p_order_column WHEN 'prod_seq' THEN PM.PROD_SEQ ELSE 0 END
			ELSE 0 END 
			ASC,
			CASE @p_order_type 
			WHEN 'asc' THEN 
				CASE @p_order_column WHEN 'prod_code' THEN PM.PROD_CODE ELSE '' END
			ELSE '' END 
			ASC
			,
			CASE @p_order_type 
			WHEN 'desc' THEN 
				CASE @p_order_column WHEN 'prod_seq' THEN PM.PROD_SEQ ELSE 0 END
			ELSE 0 END 
			DESC,
			CASE @p_order_type
			WHEN 'desc' THEN
				CASE @p_order_column WHEN 'prod_code' THEN PM.PROD_CODE ELSE '' END
			ELSE '' END
			DESC		
			, PM.REG_DATE DESC
    )
    AND
		PM.SAMPLE_USE_YORN = 
		(
			CASE @p_sample_use_yorn_value
			WHEN 'Y' THEN 'Y'
			WHEN 'N' THEN 'N'
			ELSE PM.SAMPLE_USE_YORN END
		)
		AND
		PM.WHOLE_SALE_YORN =
		(
			CASE @p_whole_sale_value
			WHEN 'Y' THEN 'Y'
			WHEN 'N' THEN 'N'
			ELSE PM.WHOLE_SALE_YORN END
		) 
		AND
		(
			CASE @p_search_type
			WHEN 'title' THEN PM.PROD_TITLE
			WHEN 'contents' THEN PM.PROD_CONTENT
			WHEN 'code' THEN PM.PROD_CODE
			ELSE PM.PROD_TITLE END
		) LIKE @p_search_value
	ORDER BY 
			CASE @p_order_type 
			WHEN 'asc' THEN 
				CASE @p_order_column WHEN 'prod_seq' THEN PM.PROD_SEQ ELSE 0 END
			ELSE 0 END 
			ASC,
			CASE @p_order_type 
			WHEN 'asc' THEN 
				CASE @p_order_column WHEN 'prod_code' THEN PM.PROD_CODE ELSE '' END
			ELSE '' END 
			ASC
			,
			CASE @p_order_type 
			WHEN 'desc' THEN 
				CASE @p_order_column WHEN 'prod_seq' THEN PM.PROD_SEQ ELSE 0 END
			ELSE 0 END 
			DESC,
			CASE @p_order_type
			WHEN 'desc' THEN
				CASE @p_order_column WHEN 'prod_code' THEN PM.PROD_CODE ELSE '' END
			ELSE '' END
			DESC		
			, PM.REG_DATE DESC
END

GO
