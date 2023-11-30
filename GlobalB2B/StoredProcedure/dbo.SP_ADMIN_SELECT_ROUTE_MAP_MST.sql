IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ROUTE_MAP_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ROUTE_MAP_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ROUTE_MAP_MST]
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
		SET @p_search_type = 'url';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM ROUTE_MAP_MST RM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'url' THEN RM.PHYSICAL_URL + RM.ROUTE_URL
								ELSE RM.PHYSICAL_URL + RM.ROUTE_URL END
							) LIKE @p_search_value
						);
	
    
    SELECT TOP(@p_page_row_size)
    RM.*
    FROM ROUTE_MAP_MST RM
    WHERE RM.ROUTE_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		IRM.ROUTE_SEQ
		FROM ROUTE_MAP_MST IRM
		WHERE 
		(
			CASE @p_search_type
			WHEN 'url' THEN RM.PHYSICAL_URL + RM.ROUTE_URL
			ELSE RM.PHYSICAL_URL + RM.ROUTE_URL END
		) LIKE @p_search_value
		ORDER BY IRM.REG_DATE DESC
    )
    AND
    (
		CASE @p_search_type
		WHEN 'url' THEN RM.PHYSICAL_URL + RM.ROUTE_URL
		ELSE RM.PHYSICAL_URL + RM.ROUTE_URL END
	) LIKE @p_search_value
	
	ORDER BY RM.REG_DATE DESC
END
GO
