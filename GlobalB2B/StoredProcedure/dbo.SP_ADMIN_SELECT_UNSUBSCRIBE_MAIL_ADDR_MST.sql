IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_UNSUBSCRIBE_MAIL_ADDR_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_UNSUBSCRIBE_MAIL_ADDR_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_UNSUBSCRIBE_MAIL_ADDR_MST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
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
		SET @p_search_type = 'email';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM UNSUBSCRIBE_MAIL_ADDR_MST UMAM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'email' THEN UMAM.MAIL_ADDR
								WHEN 'description' THEN UMAM.DESCRIPTION
								ELSE UMAM.MAIL_ADDR END
							) LIKE @p_search_value
							AND
							UMAM.REG_DATE >= @p_start_date
							AND
							UMAM.REG_DATE  <= @p_end_date
						);
						
	
	SELECT TOP(@p_page_row_size)
	UMAM.*
	FROM UNSUBSCRIBE_MAIL_ADDR_MST UMAM
	WHERE UMAM.SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IUMAM.SEQ
		FROM UNSUBSCRIBE_MAIL_ADDR_MST IUMAM
		WHERE
		(
			CASE @p_search_type
			WHEN 'email' THEN IUMAM.MAIL_ADDR
			WHEN 'description' THEN IUMAM.DESCRIPTION
			ELSE IUMAM.MAIL_ADDR END
		) LIKE @p_search_value
		AND
		IUMAM.REG_DATE >= @p_start_date
		AND
		IUMAM.REG_DATE  <= @p_end_date
		ORDER BY IUMAM.REG_DATE DESC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'email' THEN UMAM.MAIL_ADDR
		WHEN 'description' THEN UMAM.DESCRIPTION
		ELSE UMAM.MAIL_ADDR END
	) LIKE @p_search_value
	AND
	UMAM.REG_DATE >= @p_start_date
	AND
	UMAM.REG_DATE  <= @p_end_date
	ORDER BY UMAM.REG_DATE DESC
	
END

GO
