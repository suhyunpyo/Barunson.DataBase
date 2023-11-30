IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_PERSONAL_PAYMENT_ORDER_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_PERSONAL_PAYMENT_ORDER_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_PERSONAL_PAYMENT_ORDER_MST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
	@p_order_status nvarchar(255),
	@p_claim_exist char(1),
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
		
	IF(@p_claim_exist IS NULL)
		SET @p_claim_exist = '';

	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    SET @r_total_count = (
							SELECT COUNT(*) FROM VW_ORDER_MST VOM
							WHERE 
							VOM.ORDER_TYPE_CODE = '110003'
							AND
							(
								CASE @p_search_type
								WHEN 'code' THEN VOM.ORDER_CODE
								WHEN 'id' THEN VOM.USER_ID + ISNULL(VOM.FIRST_NAME,'') +  ISNULL(VOM.LAST_NAME,'')
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
								ELSE VOM.ORDER_DATE  END
							) <= @p_end_date
							AND
							(
								CASE @p_order_status 
								WHEN '' THEN ''
								ELSE ORDER_STATUS_TYPE_CODE END
							) = @p_order_status
							AND
							(
								CASE @p_claim_exist
								WHEN '' THEN ''
								ELSE CLAIM_EXIST_YORN END
							)= @p_claim_exist
						);
						
						
	SELECT TOP(@p_page_row_size)
	VOM.*
	FROM VW_ORDER_MST VOM
	WHERE VOM.ORDER_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IVOM.ORDER_SEQ
		FROM VW_ORDER_MST IVOM
		WHERE 
		IVOM.ORDER_TYPE_CODE = '110003'
		AND
		(
			CASE @p_search_type
			WHEN 'code' THEN IVOM.ORDER_CODE
			WHEN 'id' THEN IVOM.USER_ID + ISNULL(IVOM.FIRST_NAME,'') +  ISNULL(IVOM.LAST_NAME,'')
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
			ELSE IVOM.ORDER_DATE  END
		) <= @p_end_date
		AND
		(
			CASE @p_order_status 
			WHEN '' THEN ''
			ELSE ORDER_STATUS_TYPE_CODE END
		) = @p_order_status
		AND
		(
			CASE @p_claim_exist
			WHEN '' THEN ''
			ELSE CLAIM_EXIST_YORN END
		)= @p_claim_exist
		ORDER BY ORDER_DATE DESC
	)
	AND
	VOM.ORDER_TYPE_CODE = '110003'	
	AND
	(
		CASE @p_search_type
		WHEN 'code' THEN VOM.ORDER_CODE
		WHEN 'id' THEN VOM.USER_ID + ISNULL(VOM.FIRST_NAME,'') +  ISNULL(VOM.LAST_NAME,'')
		ELSE VOM.ORDER_CODE END
	)LIKE @p_search_value
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
		ELSE VOM.ORDER_DATE  END
	) <= @p_end_date
	AND
	(
		CASE @p_order_status 
		WHEN '' THEN ''
		ELSE ORDER_STATUS_TYPE_CODE END
	) = @p_order_status
	AND
	(
		CASE @p_claim_exist
		WHEN '' THEN ''
		ELSE CLAIM_EXIST_YORN END
	)= @p_claim_exist
	ORDER BY ORDER_DATE DESC
END

GO
