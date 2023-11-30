IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PRODUCT_SET_GROUP_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PRODUCT_SET_GROUP_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PRODUCT_SET_GROUP_LIST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
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

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM PROD_SET_GROUP_MST PSGM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'code' THEN PSGM.PROD_SET_GROUP_CODE
								ELSE PSGM.PROD_SET_GROUP_CODE END
							) LIKE @p_search_value
						);
						
						
	SELECT TOP(@p_page_row_size)
	PSGM.*,
	TYPE_CC.DTL_NAME AS SET_GROUP_TYPE_DTL_NAME,
	TYPE_CC.DTL_DESC AS SET_GROUP_TYPE_DTL_DESC,
	STUFF
	(
		(
			SELECT 
				',' + '{' 
				+ 'REF_SEQ' + '|:|' + CONVERT(nvarchar,PSGRM.REF_SEQ) + '|+|' 
				+ 'PROD_SEQ' + '|:|' + CONVERT(nvarchar,PM.PROD_SEQ) + '|+|' 
				+ 'PROD_CODE' + '|:|' + PM.PROD_CODE + '|+|' 
				+ 'PROD_TYPE_CODE' + '|:|' + PM.PROD_TYPE_CODE + '|+|' 
				+ 'PROD_TYPE_NAME' + '|:|' + TYPE_CC.DTL_NAME + '|+|' 
				+ 'PROD_TYPE_DESC' + '|:|' + TYPE_CC.DTL_DESC + '|+|' 
				+ 'REF_TYPE_CODE' + '|:|' + PSGRM.REF_TYPE_CODE + '|+|' 
				+ 'REF_TYPE_NAME' + '|:|' + REF_TYPE_CC.DTL_NAME + '|+|' 
				+ 'REF_TYPE_DESC' + '|:|' + REF_TYPE_CC.DTL_DESC + '|+|' 
				+ 'PROD_PRICE_UNIT' + '|:|' +  CONVERT(nvarchar,PM.PRICE_UNIT) + '|+|' 
				+ 'PROD_PART_PRICE_UNIT' + '|:|' +  CONVERT(nvarchar,PM.PART_CASE_PRICE_UNIT) + '|+|' 
				+ '}'
			FROM PROD_SET_GROUP_REF_MST  PSGRM
			LEFT JOIN PROD_MST PM ON PSGRM.PROD_SEQ = PM.PROD_SEQ
			LEFT JOIN COMMON_CODE TYPE_CC ON PM.PROD_TYPE_CODE = TYPE_CC.CMMN_CODE
			LEFT JOIN COMMON_CODE REF_TYPE_CC ON REF_TYPE_CC.CMMN_CODE = PSGRM.REF_TYPE_CODE
			WHERE PSGRM.PROD_SET_GROUP_SEQ = PSGM.PROD_SET_GROUP_SEQ
			ORDER BY PSGRM.REF_TYPE_CODE ASC,PSGRM.REF_SEQ ASC
			FOR XML PATH('')
		), 1, 1, ''
	) AS PROD_INFO_LIST
	FROM PROD_SET_GROUP_MST PSGM
	LEFT JOIN COMMON_CODE TYPE_CC ON PSGM.SET_GROUP_TYPE_CODE = TYPE_CC.CMMN_CODE 
	WHERE PSGM.PROD_SET_GROUP_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IPSGM.PROD_SET_GROUP_SEQ
		FROM PROD_SET_GROUP_MST IPSGM
		WHERE
			(
				CASE @p_search_type
				WHEN 'code' THEN IPSGM.PROD_SET_GROUP_CODE
				ELSE IPSGM.PROD_SET_GROUP_CODE END
			) LIKE @p_search_value
		ORDER BY IPSGM.REG_DATE DESC, IPSGM.PROD_SET_GROUP_SEQ DESC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'code' THEN PSGM.PROD_SET_GROUP_CODE
		ELSE PSGM.PROD_SET_GROUP_CODE END
	) LIKE @p_search_value
	ORDER BY PSGM.REG_DATE DESC, PSGM.PROD_SET_GROUP_SEQ DESC
END

GO
