IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_LIST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_product_type_code nchar(6),
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
		
	IF(@p_product_type_code IS NULL)
		SET @p_product_type_code = '';		

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM PROD_MST PM
							WHERE 
							(
								CASE @p_product_type_code
								WHEN '' THEN ''
								ELSE PM.PROD_TYPE_CODE END
							) = @p_product_type_code
							AND
							(
								CASE @p_search_type
								WHEN 'code' THEN PM.PROD_CODE
								WHEN 'title' THEN PM.PROD_TITLE
								ELSE PM.PROD_CODE END
							) LIKE @p_search_value
						);
						
						
	SELECT TOP(@p_page_row_size)
	PM.*,
	TYPE_CC.DTL_NAME AS TYPE_DTL_NAME,
	TYPE_CC.DTL_DESC AS TYPE_DTL_DESC,
	STUFF(
		(
			SELECT  
			',' + '{' 
				+ 'ADDON_SEQ' + '|:|' + CONVERT(nvarchar, PAM.ADDON_SEQ) + '|+|'	
				+ 'PROD_SEQ' + '|:|' + CONVERT(nvarchar,PAM.ADDON_PROD_SEQ) + '|+|' 
				+ 'PROD_CODE' + '|:|' + PAM_PM.PROD_CODE + '|+|' 
				+ 'PROD_TYPE_CODE' + '|:|' + PAM_PM.PROD_TYPE_CODE + '|+|'
				+ 'PROD_TYPE_NAME' + '|:|' + PAM_TYPE_CC.DTL_NAME + '|+|'
				+ 'PROD_TYPE_DESC' + '|:|' + PAM_TYPE_CC.DTL_DESC 
				+ '}'
			FROM PROD_ADDON_MST PAM
			LEFT JOIN PROD_MST PAM_PM ON PAM.ADDON_PROD_SEQ = PAM_PM.PROD_SEQ
			LEFT JOIN COMMON_CODE PAM_TYPE_CC ON PAM_TYPE_CC.CMMN_CODE = PAM_PM.PROD_TYPE_CODE
			WHERE PAM.PROD_SEQ = PM.PROD_SEQ
			ORDER BY PAM_PM.PROD_TYPE_CODE ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS ADDON_PROD_INFO_LIST
	FROM PROD_MST PM
	LEFT JOIN COMMON_CODE TYPE_CC ON PM.PROD_TYPE_CODE = TYPE_CC.CMMN_CODE 
	WHERE PM.PROD_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IPM.PROD_SEQ
		FROM PROD_MST IPM
		WHERE(
				CASE @p_product_type_code
				WHEN '' THEN ''
				ELSE IPM.PROD_TYPE_CODE END
			) = @p_product_type_code
			AND
			(
				CASE @p_search_type
				WHEN 'code' THEN IPM.PROD_CODE
				WHEN 'title' THEN IPM.PROD_TITLE
				ELSE IPM.PROD_CODE END
			) LIKE @p_search_value
			ORDER BY IPM.REG_DATE DESC, IPM.PROD_SEQ DESC
	)
	AND
	(
		CASE @p_product_type_code
		WHEN '' THEN ''
		ELSE PM.PROD_TYPE_CODE END
	) = @p_product_type_code
	AND
	(
		CASE @p_search_type
		WHEN 'code' THEN PM.PROD_CODE
		WHEN 'title' THEN PM.PROD_TITLE
		ELSE PM.PROD_CODE END
	) LIKE @p_search_value
	
	ORDER BY PM.REG_DATE DESC, PM.PROD_SEQ DESC
END

GO
