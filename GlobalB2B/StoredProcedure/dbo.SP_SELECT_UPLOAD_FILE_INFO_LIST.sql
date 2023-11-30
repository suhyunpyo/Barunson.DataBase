IF OBJECT_ID (N'dbo.SP_SELECT_UPLOAD_FILE_INFO_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_UPLOAD_FILE_INFO_LIST
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
CREATE PROCEDURE [dbo].[SP_SELECT_UPLOAD_FILE_INFO_LIST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
	@p_content_type nvarchar(255),
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_page_num int;

    IF(@p_search_type IS NULL)
		SET @p_search_type = 'code';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	IF(@p_date_kind_type IS NULL)
		SET @p_date_kind_type = 'orderDate';
		
	IF(@p_content_type IS NULL)
		SET @p_content_type = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM UPLOAD_FILE_MST UFM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'name' THEN UFM.ORG_FILE_NAME
								ELSE UFM.ORG_FILE_NAME END
							) LIKE @p_search_value
							AND
							(
								CASE @p_date_kind_type
								WHEN 'regDate' THEN UFM.REG_DATE
								ELSE UFM.REG_DATE END
							) >= @p_start_date
							AND
							(
								CASE @p_date_kind_type
								WHEN 'regDate' THEN UFM.REG_DATE
								ELSE UFM.REG_DATE END
							) <= @p_end_date
							AND 
							(
								CASE @p_content_type
								WHEN '' THEN ''
								ELSE UFM.CONTENT_TYPE END
							) = @p_content_type
						);
						
	SELECT TOP(@p_page_row_size)
	UFM.*
	FROM UPLOAD_FILE_MST UFM
	WHERE UFM.FILE_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IUFM.FILE_SEQ
		FROM UPLOAD_FILE_MST IUFM
		WHERE
		(
			CASE @p_search_type
			WHEN 'name' THEN IUFM.ORG_FILE_NAME
			ELSE IUFM.ORG_FILE_NAME END
		) LIKE @p_search_value
		AND
		(
			CASE @p_date_kind_type
			WHEN 'regDate' THEN IUFM.REG_DATE
			ELSE IUFM.REG_DATE END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'regDate' THEN IUFM.REG_DATE
			ELSE IUFM.REG_DATE END
		) <= @p_end_date
		AND 
		(
			CASE @p_content_type
			WHEN '' THEN ''
			ELSE IUFM.CONTENT_TYPE END
		) = @p_content_type
		ORDER BY IUFM.REG_DATE DESC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'name' THEN UFM.ORG_FILE_NAME
		ELSE UFM.ORG_FILE_NAME END
	) LIKE @p_search_value
	AND
	(
		CASE @p_date_kind_type
		WHEN 'regDate' THEN UFM.REG_DATE
		ELSE UFM.REG_DATE END
	) >= @p_start_date
	AND
	(
		CASE @p_date_kind_type
		WHEN 'regDate' THEN UFM.REG_DATE
		ELSE UFM.REG_DATE END
	) <= @p_end_date
	AND 
	(
		CASE @p_content_type
		WHEN '' THEN ''
		ELSE UFM.CONTENT_TYPE END
	) = @p_content_type
	ORDER BY UFM.REG_DATE DESC
	
	
	
END



GO
