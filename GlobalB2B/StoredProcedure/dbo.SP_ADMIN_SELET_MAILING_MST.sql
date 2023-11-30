IF OBJECT_ID (N'dbo.SP_ADMIN_SELET_MAILING_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELET_MAILING_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELET_MAILING_MST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(20),
	@p_search_value nvarchar(100),
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @t_page_num int;
	
	IF(@p_search_type IS NULL)
		SET @p_search_type = 'email';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
		
	SET @t_page_num = (@p_current_page - 1 ) * @p_page_row_size;
    SET @r_total_count = (
							SELECT COUNT(*) FROM MAILING_MST MM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'email' THEN MM.EMAIL
								WHEN 'name' THEN MM.FIRST_NAME + MM.LAST_NAME
								ELSE MM.EMAIL END
							) LIKE @p_search_value
						);
    
    SELECT TOP(@p_page_row_size)
    MM.*
    FROM MAILING_MST MM
    WHERE MM.MAILING_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		MM.MAILING_SEQ
		FROM MAILING_MST MM
		WHERE 
			(
				CASE @p_search_type
				WHEN 'email' THEN MM.EMAIL
				WHEN 'name' THEN MM.FIRST_NAME + MM.LAST_NAME
				ELSE MM.EMAIL END
			) LIKE @p_search_value
		ORDER BY MM.MAILING_SEQ DESC
    )
    AND
		(
			CASE @p_search_type
			WHEN 'email' THEN MM.EMAIL
			WHEN 'name' THEN MM.FIRST_NAME + MM.LAST_NAME
			ELSE MM.EMAIL END
		) LIKE @p_search_value
    ORDER BY MM.MAILING_SEQ DESC
	
END
GO
