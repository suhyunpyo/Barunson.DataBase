IF OBJECT_ID (N'dbo.SP_SELECT_PRODUCT_GROUP_SET_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_PRODUCT_GROUP_SET_MST
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
CREATE PROCEDURE [dbo].[SP_SELECT_PRODUCT_GROUP_SET_MST]
	@p_current_page int,
	@p_page_row_size int,
	@p_category_code nvarchar(6),
	@p_search_value nvarchar(255),
	@p_option_code_list nvarchar(255),
	@p_whole_sale_list_yorn char(1),
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_page_num int;
    
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
    
    
    -- 데이터를 가공하여 임시 테이블에 할당
    DECLARE @t_data_table table
    (
		GROUP_CODE nvarchar(255),
		SORT_NUM int,
		PROD_CODE_LIST nvarchar(255),
		PROD_TITLE_LIST nvarchar(500),
		PROD_SEQ_LIST nvarchar(255),
		COLOR_CODE_LIST nvarchar(255),
		RGB_VALUE_LIST nvarchar(255),
		CATEGORY_CODE_LIST nvarchar(255),
		CATEGORY_NAME_LIST nvarchar(255),
		KIND_CODE_LIST nvarchar(255),
		KIND_NAME_LIST nvarchar(255),
		PRICE_TERM_CODE_LIST nvarchar(255),
		PRICE_TERM_NAME_LIST nvarchar(255),
		PRINT_CODE_LIST nvarchar(255),
		PRINT_NAME_LIST nvarchar(255),
		SIZE_CODE_LIST nvarchar(255),
		SIZE_NAME_LIST nvarchar(255),
		SEARCH_TARGET nvarchar(500),
		CODE_MERGE nvarchar(255)
	)
	
	-- 데이터 임시 테이블 할당
	BEGIN
	
		INSERT INTO @t_data_table(
			GROUP_CODE,
			SORT_NUM,
			PROD_CODE_LIST,
			PROD_TITLE_LIST,
			PROD_SEQ_LIST,
			COLOR_CODE_LIST,
			RGB_VALUE_LIST,
			CATEGORY_CODE_LIST,
			CATEGORY_NAME_LIST,
			KIND_CODE_LIST,
			KIND_NAME_LIST,
			PRICE_TERM_CODE_LIST,
			PRICE_TERM_NAME_LIST,
			PRINT_CODE_LIST,
			PRINT_NAME_LIST,
			SIZE_CODE_LIST,
			SIZE_NAME_LIST
		)
		SELECT 
			MST.GROUP_CODE,
			MST.SORT_NUM,
			MST.PROD_CODE_LIST,
			MST.PROD_TITLE_LIST,
			MST.PROD_SEQ_LIST,
			MST.COLOR_CODE_LIST,
			MST.RGB_VALUE_LIST,
			MST.CATEGORY_CODE_LIST,
			MST.CATEGORY_NAME_LIST,
			MST.KIND_CODE_LIST,
			MST.KIND_NAME_LIST,
			MST.PRICE_TERM_CODE_LIST,
			MST.PRICE_TERM_NAME_LIST,
			MST.PRINT_CODE_LIST,
			MST.PRINT_NAME_LIST,
			MST.SIZE_CODE_LIST,
			MST.SIZE_NAME_LIST
		FROM
		(
			SELECT 
				PG.GROUP_CODE
				,(SELECT MIN(SORT_NUM) FROM PROD_GROUP WHERE GROUP_CODE  = PG.GROUP_CODE) AS SORT_NUM
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + IPM.PROD_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PROD_TITLE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + IPM.PROD_TITLE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PROD_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + convert(varchar,IPM.PROD_SEQ))
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PROD_SEQ_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + IPM.COLOR_TYPE_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS COLOR_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + COLOR_CC.DTL_DESC)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE COLOR_CC ON COLOR_CC.CMMN_CODE = IPM.COLOR_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS RGB_VALUE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + CATEGORY_CC.CMMN_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE CATEGORY_CC ON CATEGORY_CC.CMMN_CODE = IPM.CATEGORY_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS CATEGORY_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + CATEGORY_CC.DTL_NAME)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE CATEGORY_CC ON CATEGORY_CC.CMMN_CODE = IPM.CATEGORY_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS CATEGORY_NAME_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + KIND_CC.CMMN_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE KIND_CC ON KIND_CC.CMMN_CODE = IPM.KIND_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS KIND_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + KIND_CC.DTL_NAME)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE KIND_CC ON KIND_CC.CMMN_CODE = IPM.KIND_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS KIND_NAME_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + PRICETERM_CC.CMMN_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE PRICETERM_CC ON PRICETERM_CC.CMMN_CODE = IPM.PRICE_TERM_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PRICE_TERM_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + PRICETERM_CC.DTL_NAME)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE PRICETERM_CC ON PRICETERM_CC.CMMN_CODE = IPM.PRICE_TERM_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PRICE_TERM_NAME_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + PRINT_CC.CMMN_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE PRINT_CC ON PRINT_CC.CMMN_CODE = IPM.PRINT_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PRINT_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + PRINT_CC.DTL_NAME)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE PRINT_CC ON PRINT_CC.CMMN_CODE = IPM.PRINT_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS PRINT_NAME_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + SIZE_CC.CMMN_CODE)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE SIZE_CC ON SIZE_CC.CMMN_CODE = IPM.PROD_SIZE_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS SIZE_CODE_LIST
				,
				(
					SUBSTRING( 
					 (
					  SELECT ( ', ' + SIZE_CC.DTL_NAME)
					  FROM PROD_GROUP IPG
					  LEFT JOIN PROD_MST IPM ON IPG.PROD_SEQ = IPM.PROD_SEQ
					  LEFT JOIN COMMON_CODE SIZE_CC ON SIZE_CC.CMMN_CODE = IPM.PROD_SIZE_TYPE_CODE
					  WHERE GROUP_CODE = PG.GROUP_CODE
					  AND IPM.USE_YORN != 'N'
					  AND WHOLE_SALE_YORN = (
						CASE @p_whole_sale_list_yorn
						WHEN 'Y' THEN 'Y'
						ELSE WHOLE_SALE_YORN END
					  )
					  FOR XML PATH('')
					 ), 3, 1000) 
				) AS SIZE_NAME_LIST
				FROM
				PROD_GROUP PG
				LEFT JOIN PROD_MST PM ON PG.PROD_SEQ = PM.PROD_SEQ
				WHERE 
				PM.USE_YORN != 'N' 
				AND PG.TYPE_CODE = '117002'
				AND PM.CATEGORY_TYPE_CODE LIKE '%' + @p_category_code + '%'
				GROUP BY PG.GROUP_CODE
		)MST
		
		UPDATE @t_data_table
		SET COLOR_CODE_LIST = CASE WHEN COLOR_CODE_LIST IS NULL THEN '' ELSE COLOR_CODE_LIST END
		,CATEGORY_CODE_LIST = CASE WHEN CATEGORY_CODE_LIST IS NULL THEN '' ELSE CATEGORY_CODE_LIST END
		,KIND_CODE_LIST = CASE WHEN KIND_CODE_LIST IS NULL THEN '' ELSE KIND_CODE_LIST END
		,PRICE_TERM_CODE_LIST = CASE WHEN PRICE_TERM_CODE_LIST IS NULL THEN '' ELSE PRICE_TERM_CODE_LIST END
		,PRINT_CODE_LIST = CASE WHEN PRINT_CODE_LIST IS NULL THEN '' ELSE PRINT_CODE_LIST END
		,SIZE_CODE_LIST = CASE WHEN SIZE_CODE_LIST IS NULL THEN '' ELSE SIZE_CODE_LIST END
		
		UPDATE @t_data_table
		SET CODE_MERGE = COLOR_CODE_LIST + ',' + CATEGORY_CODE_LIST + ',' + KIND_CODE_LIST + ',' + PRICE_TERM_CODE_LIST + ',' + PRINT_CODE_LIST + ',' + SIZE_CODE_LIST
		,SEARCH_TARGET = PROD_CODE_LIST + ',' + PROD_TITLE_LIST + ',' + PROD_SEQ_LIST;
		
	END
	
	if(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	SET @p_search_value = '%' + @p_search_value + '%';
	
	SET @t_page_num = (@p_current_page - 1) * @p_page_row_size;
	
	SET @r_total_count = (SELECT COUNT(*) FROM @t_data_table TMST WHERE TMST.SEARCH_TARGET LIKE @p_search_value);
	
	SELECT TOP(@p_page_row_size)
	*
	FROM
	@t_data_table TMST
	WHERE TMST.GROUP_CODE NOT IN
	(
		SELECT TOP(@t_page_num)
		ITMST.GROUP_CODE
		FROM @t_data_table ITMST
		WHERE ITMST.SEARCH_TARGET LIKE @p_search_value
		ORDER BY ITMST.SORT_NUM
	)
	AND 
	TMST.SEARCH_TARGET LIKE @p_search_value
	AND
	(
		(SELECT COUNT(*) FROM @t_option_table TOT WHERE TMST.CODE_MERGE like '%'+TOT.OPTION_CODE+'%')>= (CASE (SELECT COUNT(*) FROM @t_option_table) WHEN 0 THEN 0 ELSE 1 END)
	)
	ORDER BY SORT_NUM;
	
END

GO
