IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_SAMPLE_ORDER_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_SAMPLE_ORDER_MST
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
-- TODO : SP_AMDIN_SELECT_ORDER_MST 와의 통합 처리에 대한 검토 필요

CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_SAMPLE_ORDER_MST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
	@p_order_status nvarchar(255),
	@r_total_count int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @t_page_num int;

    IF(@p_search_type IS NULL)
		SET @p_search_type = 'code';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	IF(@p_date_kind_type IS NULL)
		SET @p_date_kind_type = 'orderDate';
		
	IF(@p_order_status IS NULL)
		SET @p_order_status = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
		SELECT COUNT(*) FROM VW_ORDER_MST VOM
		WHERE
		VOM.ORDER_TYPE_CODE = '110002'
		AND
		(
			CASE @p_search_type
			WHEN 'code' THEN VOM.ORDER_CODE
			ELSE VOM.ORDER_CODE END
		) LIKE @p_search_value
		AND
		(
			CASE @p_date_kind_type
			WHEN 'orderDate' THEN VOM.ORDER_DATE
			WHEN 'updateDate' THEN VOM.UPDATE_DATE
			ELSE VOM.ORDER_DATE END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'orderDate' THEN VOM.ORDER_DATE
			WHEN 'updateDate' THEN VOM.UPDATE_DATE
			ELSE VOM.ORDER_DATE END
		) <= @p_end_date
		AND
		(
			CASE @p_order_status
			WHEN '' THEN ''
			ELSE VOM.ORDER_STATUS_TYPE_CODE END
		) = @p_order_status
    )
    
    SELECT TOP(@p_page_row_size)
    VOM.*
    FROM VW_ORDER_MST VOM
    WHERE VOM.ORDER_SEQ NOT IN
    (
		SELECT TOP(@t_page_num)
		IVOM.ORDER_SEQ
		FROM VW_ORDER_MST IVOM
		WHERE
		IVOM.ORDER_TYPE_CODE = '110002'
		AND
		(
			CASE @p_search_type
			WHEN 'code' THEN IVOM.ORDER_CODE
			ELSE IVOM.ORDER_CODE END
		) LIKE @p_search_value
		AND
		(
			CASE @p_date_kind_type
			WHEN 'orderDate' THEN IVOM.ORDER_DATE
			WHEN 'updateDate' THEN IVOM.UPDATE_DATE
			ELSE IVOM.ORDER_DATE END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'orderDate' THEN IVOM.ORDER_DATE
			WHEN 'updateDate' THEN IVOM.UPDATE_DATE
			ELSE IVOM.ORDER_DATE END
		) <= @p_end_date
		AND
		(
			CASE @p_order_status
			WHEN '' THEN ''
			ELSE IVOM.ORDER_STATUS_TYPE_CODE END
		) = @p_order_status
		ORDER BY IVOM.ORDER_DATE DESC, IVOM.ORDER_SEQ DESC
    ) 
    AND
    VOM.ORDER_TYPE_CODE = '110002'
	AND
	(
		CASE @p_search_type
		WHEN 'code' THEN VOM.ORDER_CODE
		ELSE VOM.ORDER_CODE END
	) LIKE @p_search_value
	AND
	(
		CASE @p_date_kind_type
		WHEN 'orderDate' THEN VOM.ORDER_DATE
		WHEN 'updateDate' THEN VOM.UPDATE_DATE
		ELSE VOM.ORDER_DATE END
	) >= @p_start_date
	AND
	(
		CASE @p_date_kind_type
		WHEN 'orderDate' THEN VOM.ORDER_DATE
		WHEN 'updateDate' THEN VOM.UPDATE_DATE
		ELSE VOM.ORDER_DATE END
	) <= @p_end_date
	AND
	(
		CASE @p_order_status
		WHEN '' THEN ''
		ELSE VOM.ORDER_STATUS_TYPE_CODE END
	) = @p_order_status
    ORDER BY VOM.ORDER_DATE DESC, VOM.ORDER_SEQ DESC
END

GO
