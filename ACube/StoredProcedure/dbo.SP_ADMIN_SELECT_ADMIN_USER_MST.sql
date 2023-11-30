IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ADMIN_USER_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ADMIN_USER_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ADMIN_USER_MST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(20),
	@p_search_value nvarchar(20),
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_page_num int;
    
    IF(@p_search_type IS NULL)
		SET @p_search_type = 'id';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM ADMIN_USER_MST AUM
							WHERE 
							(
								CASE @p_search_type
								WHEN 'id' THEN AUM.ADMIN_USER_ID
								WHEN 'name' THEN AUM.ADMIN_USER_NAME
								ELSE AUM.ADMIN_USER_ID END
							) LIKE @p_search_value
						);
						
	
	SELECT TOP(@p_page_row_size)
	AUM.*,
	(SELECT MAX(REG_DATE) FROM ADMIN_USER_CONN_MST AUCM WHERE AUCM.ADMIN_USER_SEQ = AUM.ADMIN_USER_SEQ) AS LAST_CONN_DATE,
	(SELECT COUNT(*) FROM ADMIN_USER_CONN_MST AUCM WHERE AUCM.ADMIN_USER_SEQ = AUM.ADMIN_USER_SEQ) AS CONN_COUNT
	FROM
	ADMIN_USER_MST AUM
	WHERE AUM.ADMIN_USER_SEQ NOT IN	
	(
		SELECT TOP(@t_page_num)
		AUM.ADMIN_USER_SEQ
		FROM ADMIN_USER_MST AUM
		WHERE
		(
			CASE @p_search_type
			WHEN 'id' THEN AUM.ADMIN_USER_ID
			WHEN 'name' THEN AUM.ADMIN_USER_NAME
			ELSE AUM.ADMIN_USER_ID END
		) LIKE @p_search_value
		ORDER BY AUM.REG_DATE DESC
	)
	AND
	(
		CASE @p_search_type
		WHEN 'id' THEN AUM.ADMIN_USER_ID
		WHEN 'name' THEN AUM.ADMIN_USER_NAME
		ELSE AUM.ADMIN_USER_ID END
	) LIKE @p_search_value
	ORDER BY AUM.REG_DATE DESC
	
END


GO
