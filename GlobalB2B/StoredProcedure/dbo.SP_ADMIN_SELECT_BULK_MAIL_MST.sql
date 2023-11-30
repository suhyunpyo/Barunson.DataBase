IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_BULK_MAIL_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_BULK_MAIL_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_BULK_MAIL_MST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
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
		SET @p_date_kind_type = 'regDate';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM BULK_MAIL_MST BM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'title' THEN BM.BULK_MAIL_TITLE
								ELSE BM.BULK_MAIL_TITLE END
							) LIKE @p_search_value
							AND
							(
								CASE @p_date_kind_type
								WHEN 'regDate' THEN BM.REG_DATE
								WHEN 'scheduleDate' THEN BM.SCHEDULE_DATE
								ELSE BM.REG_DATE END
							) >= @p_start_date
							AND
							(
								CASE @p_date_kind_type
								WHEN 'regDate' THEN BM.REG_DATE
								WHEN 'scheduleDate' THEN BM.SCHEDULE_DATE
								ELSE BM.REG_DATE END
							) <= @p_end_date
						);
						

	SELECT TOP(@p_page_row_size)
	BM.*
	FROM BULK_MAIL_MST BM
	WHERE BM.BULK_MAIL_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IBM.BULK_MAIL_SEQ
		FROM BULK_MAIL_MST IBM
		WHERE
		(
			CASE @p_search_type
			WHEN 'title' THEN IBM.BULK_MAIL_TITLE
			ELSE IBM.BULK_MAIL_TITLE END
		) LIKE @p_search_value
		AND
		(
			CASE @p_date_kind_type
			WHEN 'regDate' THEN IBM.REG_DATE
			WHEN 'scheduleDate' THEN IBM.SCHEDULE_DATE
			ELSE IBM.REG_DATE END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'regDate' THEN IBM.REG_DATE
			WHEN 'scheduleDate' THEN IBM.SCHEDULE_DATE
			ELSE IBM.REG_DATE END
		) <= @p_end_date
		ORDER BY REG_DATE DESC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'title' THEN BM.BULK_MAIL_TITLE
		ELSE BM.BULK_MAIL_TITLE END
	) LIKE @p_search_value
	AND
	(
		CASE @p_date_kind_type
		WHEN 'regDate' THEN BM.REG_DATE
		WHEN 'scheduleDate' THEN BM.SCHEDULE_DATE
		ELSE BM.REG_DATE END
	) >= @p_start_date
	AND
	(
		CASE @p_date_kind_type
		WHEN 'regDate' THEN BM.REG_DATE
		WHEN 'scheduleDate' THEN BM.SCHEDULE_DATE
		ELSE BM.REG_DATE END
	) <= @p_end_date
	ORDER BY REG_DATE DESC
						
END

GO
