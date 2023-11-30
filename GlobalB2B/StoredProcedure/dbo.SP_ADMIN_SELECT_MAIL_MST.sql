IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_MAIL_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_MAIL_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_MAIL_MST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(20),
	@p_search_value nvarchar(100),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
	@p_mail_type_code nvarchar(255),
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
		
	IF(@p_date_kind_type IS NULL)
		SET @p_date_kind_type = 'requestDate';
		
	IF(@p_mail_type_code IS NULL)
		SET @p_mail_type_code = '';

	SET @p_search_type = LOWER(@p_search_type);	
	
	IF(@p_search_type != 'bulkseq')
		SET @p_search_value = '%' + @p_search_value + '%';
		
	
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM MAIL_MST MM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'title' THEN MM.MAIL_TITLE
								WHEN 'contents' THEN MM.MAIL_CONTENT
								WHEN 'to' THEN MM.TO_MAIL_ADDR+MM.TO_MAIL_NAME
								WHEN 'bulkseq' THEN CAST(MM.BULK_MAIL_SEQ as nvarchar)
								ELSE MM.MAIL_TITLE END
							) LIKE @p_search_value
							AND
							(
								CASE @p_date_kind_type
								WHEN 'requestDate' THEN MM.REG_DATE
								WHEN 'scheduleDate' THEN MM.SCHEDULE_DATE
								ELSE MM.REG_DATE END
							) >= @p_start_date
							AND
							(
								CASE @p_date_kind_type
								WHEN 'requestDate' THEN MM.REG_DATE
								WHEN 'scheduleDate' THEN MM.SCHEDULE_DATE
								ELSE MM.REG_DATE END
							) <= @p_end_date
							AND
							(
								CASE @p_mail_type_code
								WHEN '' THEN ''
								ELSE MM.MAIL_TYPE_CODE END
							) = @p_mail_type_code
						);
    
    SELECT TOP(@p_page_row_size)
    MM.*,
    MAIL_CC.DTL_NAME AS MAIL_TYPE_NAME,
    MAIL_CC.DTL_DESC AS MAIL_TYPE_DESC
    FROM MAIL_MST MM
    LEFT JOIN COMMON_CODE MAIL_CC ON MM.MAIL_TYPE_CODE = MAIL_CC.CMMN_CODE
    WHERE MM.MAIL_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		MM.MAIL_SEQ
		FROM MAIL_MST MM
		WHERE 
			(
				CASE @p_search_type
				WHEN 'title' THEN MM.MAIL_TITLE
				WHEN 'contents' THEN MM.MAIL_CONTENT
				WHEN 'to' THEN MM.TO_MAIL_ADDR+MM.TO_MAIL_NAME
				WHEN 'bulkseq' THEN CAST(MM.BULK_MAIL_SEQ as nvarchar)
				ELSE MM.MAIL_TITLE END
			) LIKE @p_search_value
			AND
			(
				CASE @p_date_kind_type
				WHEN 'requestDate' THEN MM.REG_DATE
				WHEN 'scheduleDate' THEN MM.SCHEDULE_DATE
				ELSE MM.REG_DATE END
			) >= @p_start_date
			AND
			(
				CASE @p_date_kind_type
				WHEN 'requestDate' THEN MM.REG_DATE
				WHEN 'scheduleDate' THEN MM.SCHEDULE_DATE
				ELSE MM.REG_DATE END
			) <= @p_end_date
			AND
			(
				CASE @p_mail_type_code
				WHEN '' THEN ''
				ELSE MM.MAIL_TYPE_CODE END
			) = @p_mail_type_code
		ORDER BY MM.REG_DATE DESC, MM.MAIL_SEQ DESC
    )
    AND
		(
			CASE @p_search_type
			WHEN 'title' THEN MM.MAIL_TITLE
			WHEN 'contents' THEN MM.MAIL_CONTENT
			WHEN 'to' THEN MM.TO_MAIL_ADDR+MM.TO_MAIL_NAME
			WHEN 'bulkseq' THEN CAST(MM.BULK_MAIL_SEQ as nvarchar)
			ELSE MM.MAIL_TITLE END
		) LIKE @p_search_value
		AND
		(
			CASE @p_date_kind_type
			WHEN 'requestDate' THEN MM.REG_DATE
			WHEN 'scheduleDate' THEN MM.SCHEDULE_DATE
			ELSE MM.REG_DATE END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'requestDate' THEN MM.REG_DATE
			WHEN 'scheduleDate' THEN MM.SCHEDULE_DATE
			ELSE MM.REG_DATE END
		) <= @p_end_date
		AND
		(
			CASE @p_mail_type_code
			WHEN '' THEN ''
			ELSE MM.MAIL_TYPE_CODE END
		) = @p_mail_type_code
	ORDER BY MM.REG_DATE DESC, MM.MAIL_SEQ DESC
END

GO
