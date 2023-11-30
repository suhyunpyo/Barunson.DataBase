IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_SAMPLE_GROUP_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_SAMPLE_GROUP_LIST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_SAMPLE_GROUP_LIST]
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

    -- Insert statements for procedure here
	DECLARE @t_page_num int;

    IF(@p_search_type IS NULL)
		SET @p_search_type = 'title';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count =	(
								SELECT COUNT(*) FROM SAMPLE_GROUP_MST SGM
								WHERE 
								(
									CASE @p_search_type
									WHEN 'title' THEN SGM.TITLE
									ELSE SGM.TITLE END
								) LIKE @p_search_value
							);
						
	SELECT TOP(@p_page_row_size)
	SGM.*,
	STUFF(
			(
				SELECT ',' + CAST(ISGIM.PROD_SEQ AS NVARCHAR)
				FROM SAMPLE_GROUP_ITEM_MST ISGIM
				WHERE ISGIM.SAMPLE_GROUP_SEQ = SGM.SAMPLE_GROUP_SEQ 
				ORDER BY ISGIM.PROD_SEQ ASC
				FOR XML PATH('')
			)
		, 1, 1, '') AS PROD_SEQ_LIST,
	STUFF(
			(
				SELECT ',' + IPM.PROD_CODE
				FROM SAMPLE_GROUP_ITEM_MST ISGIM
				LEFT JOIN PROD_MST IPM ON ISGIM.PROD_SEQ = IPM.PROD_SEQ
				WHERE ISGIM.SAMPLE_GROUP_SEQ = SGM.SAMPLE_GROUP_SEQ 
				ORDER BY ISGIM.PROD_SEQ ASC
				FOR XML PATH('')
			)
		, 1, 1, '') AS PROD_CODE_LIST,
	STUFF(
			(
				SELECT ',' + IPM.PROD_TITLE
				FROM SAMPLE_GROUP_ITEM_MST ISGIM
				LEFT JOIN PROD_MST IPM ON ISGIM.PROD_SEQ = IPM.PROD_SEQ
				WHERE ISGIM.SAMPLE_GROUP_SEQ = SGM.SAMPLE_GROUP_SEQ 
				ORDER BY ISGIM.PROD_SEQ ASC
				FOR XML PATH('')
			)
		, 1, 1, '') AS PROD_TITLE_LIST
	FROM SAMPLE_GROUP_MST SGM
	WHERE
	SGM.SAMPLE_GROUP_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		ISGM.SAMPLE_GROUP_SEQ
		FROM SAMPLE_GROUP_MST ISGM
		WHERE
		(
			CASE @p_search_type
			WHEN 'title' THEN ISGM.TITLE
			ELSE ISGM.TITLE END
		) LIKE @p_search_value
		ORDER BY ISGM.SORT_RATE ASC,ISGM.SAMPLE_GROUP_SEQ ASC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'title' THEN SGM.TITLE
		ELSE SGM.TITLE END
	) LIKE @p_search_value
	ORDER BY SGM.SORT_RATE ASC,SGM.SAMPLE_GROUP_SEQ ASC
END

GO
