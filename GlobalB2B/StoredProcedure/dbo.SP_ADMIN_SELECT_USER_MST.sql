IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_USER_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_USER_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_USER_MST]
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(20),
	@p_search_value nvarchar(100),
	@r_total_count int output
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @t_page_num int;
	
	IF(@p_search_type IS NULL)
		SET @p_search_type = 'id';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
	
	SET @t_page_num = (@p_current_page - 1 ) * @p_page_row_size;
    SET @r_total_count = (
							SELECT COUNT(*) FROM USER_MST UM
							WHERE (
								CASE @p_search_type 
								WHEN 'id' THEN UM.USER_ID
								WHEN 'name' THEN UM.FIRST_NAME+UM.LAST_NAME
								WHEN 'company_name' THEN UM.COMPANY_NAME
								ELSE UM.USER_ID END
							) LIKE @p_search_value
						);
    
    SELECT TOP(@p_page_row_size)
    UM.*
    /*
    퍼포먼스 저하 발생
    ,(SELECT MAX(UCM.REG_DATE) FROM USER_CONN_MST UCM WHERE UCM.USER_SEQ = UM.USER_SEQ) AS LAST_CONN_DATE
    ,(SELECT COUNT(*) FROM USER_CONN_MST UCM WHERE UCM.USER_SEQ = UM.USER_SEQ) AS CONN_COUNT
    */
    FROM USER_MST UM
    WHERE UM.USER_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		UM.USER_SEQ
		FROM USER_MST UM
		WHERE 
			(
				CASE @p_search_type 
				WHEN 'id' THEN UM.USER_ID
				WHEN 'name' THEN UM.FIRST_NAME+UM.LAST_NAME
				WHEN 'company_name' THEN UM.COMPANY_NAME
				ELSE UM.USER_ID END
			) LIKE @p_search_value
		ORDER BY UM.USER_SEQ DESC
    )
    AND (
				CASE @p_search_type 
				WHEN 'id' THEN UM.USER_ID
				WHEN 'name' THEN UM.FIRST_NAME+UM.LAST_NAME
				WHEN 'company_name' THEN UM.COMPANY_NAME
				ELSE UM.USER_ID END
			) LIKE @p_search_value
	ORDER BY UM.USER_SEQ DESC
END

GO
