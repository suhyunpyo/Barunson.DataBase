IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_COMMON_CODE_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_COMMON_CODE_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_COMMON_CODE_MST]
	-- Add the parameters for the stored procedure here
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
	DECLARE @t_page_num int;
    
    IF(@p_search_type IS NULL)
		SET @p_search_type = 'title';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM COMMON_CODE CC
							WHERE 
							(
								CASE @p_search_type
								WHEN 'name' THEN CC.DTL_NAME + CC.CLSS_NAME + CC.DTL_DESC
								WHEN 'code' THEN CC.CMMN_CODE
								ELSE CC.DTL_NAME + CC.CLSS_NAME + CC.DTL_DESC END
							) LIKE @p_search_value
						);
    
    SELECT TOP(@p_page_row_size)
    CC.*
    FROM COMMON_CODE CC
    WHERE CC.CMMN_CODE NOT IN
    (
		SELECT TOP(@t_page_num)
		CC.CMMN_CODE
		FROM COMMON_CODE CC
		WHERE 
			(
				CASE @p_search_type
				WHEN 'name' THEN CC.DTL_NAME + CC.CLSS_NAME + CC.DTL_DESC
				WHEN 'code' THEN CC.CMMN_CODE
				ELSE CC.DTL_NAME + CC.CLSS_NAME + CC.DTL_DESC END
			) LIKE @p_search_value
		ORDER BY CC.CLSS_CODE ASC,CC.CMMN_CODE ASC
    )
    AND
		(
			CASE @p_search_type
			WHEN 'name' THEN CC.DTL_NAME + CC.CLSS_NAME + CC.DTL_DESC
			WHEN 'code' THEN CC.CMMN_CODE
			ELSE CC.DTL_NAME + CC.CLSS_NAME + CC.DTL_DESC END
		) LIKE @p_search_value
	ORDER BY CC.CLSS_CODE ASC,CC.CMMN_CODE ASC
END
GO
