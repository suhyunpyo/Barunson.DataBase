IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PAGE_SEO_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PAGE_SEO_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PAGE_SEO_MST]
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
		SET @p_search_type = 'url';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
	
	SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
	
    SET @r_total_count = (
		SELECT COUNT(*) FROM PAGE_SEO_INFO_MST PSIM
		WHERE
		(
			(
				CASE @p_search_type
				WHEN 'url' THEN PSIM.PAGE_URL
				WHEN 'value' THEN PSIM.TITLE + PSIM.DESCRIPTION + PSIM.KEYWORD
				ELSE PSIM.PAGE_URL END
			) LIKE @p_search_value
		)
	);
	
	SELECT TOP(@p_page_row_size)
	*
	FROM PAGE_SEO_INFO_MST PSIM
	WHERE PSIM.SEO_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		SEO_SEQ
		FROM PAGE_SEO_INFO_MST IPSIM
		WHERE
		(
			CASE @p_search_type
			WHEN 'url' THEN IPSIM.PAGE_URL
			WHEN 'value' THEN IPSIM.TITLE + IPSIM.DESCRIPTION + IPSIM.KEYWORD
			ELSE IPSIM.PAGE_URL END
		) LIKE @p_search_value
		ORDER BY IPSIM.REG_DATE DESC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'url' THEN PSIM.PAGE_URL
		WHEN 'value' THEN PSIM.TITLE + PSIM.DESCRIPTION + PSIM.KEYWORD
		ELSE PSIM.PAGE_URL END
	) LIKE @p_search_value
	ORDER BY PSIM.REG_DATE DESC
	
END
GO
