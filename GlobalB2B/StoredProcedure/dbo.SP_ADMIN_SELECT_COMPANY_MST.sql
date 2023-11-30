IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_COMPANY_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_COMPANY_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_COMPANY_MST]
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
		SET @p_search_type = 'name';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
	
	SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
	
	SET @r_total_count = (
		SELECT COUNT(*) FROM COMPANY_MST CM
		WHERE
		(
			(
				CASE @p_search_type
				WHEN 'name' THEN CM.COMPANY_NAME
				ELSE CM.COMPANY_NAME END
			) LIKE @p_search_value
		)
	);
	
	SELECT TOP(@p_page_row_size)
	*
	FROM COMPANY_MST CM
	WHERE CM.COMPANY_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		COMPANY_SEQ
		FROM COMPANY_MST ICM
		WHERE
		(
			(
				CASE @p_search_type
				WHEN 'name' THEN ICM.COMPANY_NAME
				ELSE ICM.COMPANY_NAME END
			) LIKE @p_search_value
		)
		ORDER BY ICM.REG_DATE DESC
	)
	AND
	(
		(
			CASE @p_search_type
			WHEN 'name' THEN CM.COMPANY_NAME
			ELSE CM.COMPANY_NAME END
		) LIKE @p_search_value
	)
	ORDER BY CM.REG_DATE DESC
	
END
GO
