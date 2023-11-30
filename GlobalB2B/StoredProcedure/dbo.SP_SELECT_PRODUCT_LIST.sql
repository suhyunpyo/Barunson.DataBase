IF OBJECT_ID (N'dbo.SP_SELECT_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_PRODUCT_LIST
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
CREATE PROCEDURE [dbo].[SP_SELECT_PRODUCT_LIST]
	@p_current_page int,
	@p_page_row_size int,
	@p_category_code nvarchar(6),
	@p_search_value nvarchar(255),
	@p_option_code_list nvarchar(255),
	@p_sort_by nvarchar(255),
	@p_whole_sale_list_yorn char(1),
	@p_user_id nvarchar(255) = NULL,
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @t_page_num int,
	@t_user_seq int = -1;
	
	if(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	if(@p_sort_by IS NULL OR @p_sort_by = '')
		SET @p_sort_by = 'newproduct';
		
	IF(@p_user_id IS NOT NULL)
		SET @t_user_seq = (SELECT TOP 1 USER_SEQ FROM USER_MST WHERE USER_ID = @p_user_id);
		
	SET @p_search_value = '%' + @p_search_value + '%';
	
	SET @t_page_num = (@p_current_page - 1) * @p_page_row_size;	
	
	DECLARE @t_option_table table
    (
		OPTION_CODE nvarchar(100)
    )
    
    
    
    -- OPTION CODE 분리
    BEGIN
    
		DECLARE @paramlist varchar(500),
				@delim char,
				@currentStrIndex int,
				@findStr varchar(100)
				
		--SET @paramlist = 'AB,BB,CB,DB,EB';
		SET @paramlist = @p_option_code_list;
		SET @delim = ',';
		SET @currentStrIndex = 0;
		SET @findStr = '';

		IF(CHARINDEX(@delim,@paramList) > 0)
			BEGIN
				WHILE CHARINDEX(@delim,@paramlist,@currentStrIndex) > 0
				BEGIN
					DECLARE @findIndex int = CHARINDEX(@delim,@paramlist,@currentStrIndex);	
					SET @findIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex);
					-- 찾은 문자열 저장
					SET @findStr = SUBSTRING(@paramlist,@currentStrIndex,@findIndex-@currentStrIndex);
					INSERT INTO @t_option_table VALUES (@findStr);
					SET @currentStrIndex = CHARINDEX(@delim,@paramlist,@currentStrIndex)+1;
				END--END WHILE
				
				IF((SELECT COUNT(*) FROM @t_option_table)>0)
				BEGIN
					INSERT INTO @t_option_table VALUES (SUBSTRING(@paramList,@findIndex+1,LEN(@paramList)-@findIndex));
				END 
			END
		ELSE
			BEGIN
				INSERT INTO @t_option_table VALUES (@paramList);
			END	
    
    END   
    DELETE FROM @t_option_table WHERE OPTION_CODE IS NULL;
    -- OPTION CODE 분리
    
    DECLARE @t_color_option_code_count int,
    @t_theme_option_code_count int;
    
    SET @t_color_option_code_count = (SELECT COUNT(*) FROM @t_option_table WHERE OPTION_CODE LIKE '104%');
    SET @t_theme_option_code_count = (SELECT COUNT(*) FROM @t_option_table WHERE OPTION_CODE LIKE '102%');
    
    SET @r_total_count = (
		SELECT 
		COUNT(*) 
		FROM 
		PROD_MST PM
		WHERE 
		PM.USE_YORN != 'N'
		AND
		PM.WHOLE_SALE_YORN = 
		(
			CASE @p_whole_sale_list_yorn 
			WHEN 'Y' THEN 'Y'
			ELSE PM.WHOLE_SALE_YORN END
		)
		AND
		PM.CATEGORY_TYPE_CODE = (
			CASE @p_category_code
			WHEN '' THEN PM.CATEGORY_TYPE_CODE
			ELSE @p_category_code END
		)
		AND
		PM.COLOR_TYPE_CODE IN 
		(
			CASE @t_color_option_code_count
			WHEN 0 THEN (SELECT PM.COLOR_TYPE_CODE)
			ELSE (SELECT OPTION_CODE FROM @t_option_table WHERE OPTION_CODE LIKE '104%' AND OPTION_CODE = PM.COLOR_TYPE_CODE) END
		)
		AND
		PM.THEME_TYPE_CODE IN 
		(
			CASE @t_theme_option_code_count
			WHEN 0 THEN (SELECT PM.THEME_TYPE_CODE)
			ELSE (SELECT OPTION_CODE FROM @t_option_table WHERE OPTION_CODE LIKE '102%' AND OPTION_CODE = PM.THEME_TYPE_CODE) END
		)
	)	
		
    SELECT TOP
    (@p_page_row_size)
    *
    ,CATEGORY_CC.DTL_NAME as CATEGORY_NAME
    ,COLOR_CC.DTL_DESC AS RGB_VALUE
    ,CM.CART_SEQ AS CART_SEQ
    ,CM.QUANTITY AS CART_QUANTITY
    FROM
    PROD_MST PM
    LEFT JOIN COMMON_CODE CATEGORY_CC ON CATEGORY_CC.CMMN_CODE = PM.CATEGORY_TYPE_CODE
    LEFT JOIN COMMON_CODE COLOR_CC ON PM.COLOR_TYPE_CODE = COLOR_CC.CMMN_CODE 
    LEFT JOIN CART_MST CM ON CM.PROD_SEQ = PM.PROD_SEQ AND CM.USER_SEQ = @t_user_seq AND CM.CART_STATE_CODE = '118001'
    WHERE PM.PROD_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		IPM.PROD_SEQ
		FROM PROD_MST IPM
		WHERE
		IPM.USE_YORN != 'N'
		AND
		IPM.WHOLE_SALE_YORN = 
		(
			CASE @p_whole_sale_list_yorn 
			WHEN 'Y' THEN 'Y'
			ELSE IPM.WHOLE_SALE_YORN END
		)
		AND
		IPM.CATEGORY_TYPE_CODE = (
			CASE @p_category_code
			WHEN '' THEN IPM.CATEGORY_TYPE_CODE
			ELSE @p_category_code END
		)
		AND
		IPM.COLOR_TYPE_CODE IN 
		(
			CASE @t_color_option_code_count
			WHEN 0 THEN (SELECT IPM.COLOR_TYPE_CODE)
			ELSE (SELECT OPTION_CODE FROM @t_option_table WHERE OPTION_CODE LIKE '104%' AND OPTION_CODE = IPM.COLOR_TYPE_CODE) END
		)
		AND
		IPM.THEME_TYPE_CODE IN 
		(
			CASE @t_theme_option_code_count
			WHEN 0 THEN (SELECT IPM.THEME_TYPE_CODE)
			ELSE (SELECT OPTION_CODE FROM @t_option_table WHERE OPTION_CODE LIKE '102%' AND OPTION_CODE = IPM.THEME_TYPE_CODE) END
		)
		AND
		(
			IPM.PROD_CODE LIKE
			(
				CASE @p_search_value
				WHEN '' THEN IPM.PROD_CODE
				ELSE @p_search_value END	
			)
			OR
			IPM.PROD_TITLE LIKE
			(
				CASE @p_search_value
				WHEN '' THEN IPM.PROD_TITLE
				ELSE @p_search_value END	
			)
		)
		ORDER BY 
		CASE @p_sort_by WHEN 'recommend' THEN IPM.RECOMMEND_SORT_RATE END ASC,
		CASE @p_sort_by WHEN 'bestsaller' THEN IPM.BEST_SALLER_SORT_RATE END ASC,
		CASE @p_sort_by WHEN 'newproduct' THEN IPM.PROD_SEQ END DESC
		, IPM.PROD_SEQ DESC
    )
    AND
    PM.USE_YORN != 'N'
    AND
	PM.WHOLE_SALE_YORN = 
	(
		CASE @p_whole_sale_list_yorn 
		WHEN 'Y' THEN 'Y'
		ELSE PM.WHOLE_SALE_YORN END
	)
	AND
	PM.CATEGORY_TYPE_CODE = (
		CASE @p_category_code
		WHEN '' THEN PM.CATEGORY_TYPE_CODE
		ELSE @p_category_code END
	)
	AND
	PM.COLOR_TYPE_CODE IN 
	(
		CASE @t_color_option_code_count
		WHEN 0 THEN (SELECT PM.COLOR_TYPE_CODE)
		ELSE (SELECT OPTION_CODE FROM @t_option_table WHERE OPTION_CODE LIKE '104%' AND OPTION_CODE = PM.COLOR_TYPE_CODE) END
	)
	AND
	PM.THEME_TYPE_CODE IN 
	(
		CASE @t_theme_option_code_count
		WHEN 0 THEN (SELECT PM.THEME_TYPE_CODE)
		ELSE (SELECT OPTION_CODE FROM @t_option_table WHERE OPTION_CODE LIKE '102%' AND OPTION_CODE = PM.THEME_TYPE_CODE) END
	)
	AND
	(
		PM.PROD_CODE LIKE
		(
			CASE @p_search_value
			WHEN '' THEN PM.PROD_CODE
			ELSE @p_search_value END	
		)
		OR
		PM.PROD_TITLE LIKE
		(
			CASE @p_search_value
			WHEN '' THEN PM.PROD_TITLE
			ELSE @p_search_value END	
		)
	)
	ORDER BY  
	CASE @p_sort_by WHEN 'recommend' THEN PM.RECOMMEND_SORT_RATE END ASC,
	CASE @p_sort_by WHEN 'bestsaller' THEN PM.BEST_SALLER_SORT_RATE END ASC,
	CASE @p_sort_by WHEN 'newproduct' THEN PM.PROD_SEQ END DESC
	, PM.PROD_SEQ DESC
    -- Insert statements for procedure here
	
		
END

GO
