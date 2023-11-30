IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_FAQ_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_FAQ_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_FAQ_MST]
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

    -- Insert statements for procedure here
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
							SELECT COUNT(*) FROM FAQ_MST FM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'title' THEN FM.FAQ_TITLE
								WHEN 'contents' THEN FM.FAQ_CONTENTS
								ELSE FM.FAQ_TITLE END
							) LIKE @p_search_value
						);
    
    SELECT TOP(@p_page_row_size)
    FM.*
    FROM FAQ_MST FM
    WHERE FM.FAQ_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		FM.FAQ_SEQ
		FROM FAQ_MST FM
		WHERE 
			(
				CASE @p_search_type
				WHEN 'title' THEN FM.FAQ_TITLE
				WHEN 'contents' THEN FM.FAQ_CONTENTS
				ELSE FM.FAQ_TITLE END
			) LIKE @p_search_value
		ORDER BY FM.REG_DATE DESC
    )
    AND
		(
			CASE @p_search_type
			WHEN 'title' THEN FM.FAQ_TITLE
			WHEN 'contents' THEN FM.FAQ_CONTENTS
			ELSE FM.FAQ_TITLE END
		) LIKE @p_search_value
	ORDER BY FM.SORT_RATE ASC;
END
GO
