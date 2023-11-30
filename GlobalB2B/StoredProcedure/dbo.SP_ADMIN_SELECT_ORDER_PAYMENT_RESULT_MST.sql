IF OBJECT_ID (N'dbo.SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_MST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_MST
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
CREATE PROCEDURE [dbo].[SP_ADMIN_SELECT_ORDER_PAYMENT_RESULT_MST]
	-- Add the parameters for the stored procedure here
	@p_current_page int,
	@p_page_row_size int,
	@p_search_type nvarchar(255),
	@p_search_value nvarchar(255),
	@p_date_kind_type nvarchar(255),
	@p_start_date datetime,
	@p_end_date datetime,
	@p_success nchar(1),
	@r_total_count int output	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @t_page_num int;

    IF(@p_search_type IS NULL)
		SET @p_search_type = 'code';
	
	IF(@p_search_value IS NULL)
		SET @p_search_value = '';
		
	IF(@p_date_kind_type IS NULL)
		SET @p_date_kind_type = 'orderDate';
		
	IF(@p_success IS NULL)
		SET @p_success = '';
		
	SET @p_search_type = LOWER(@p_search_type);	
	SET @p_search_value = '%' + @p_search_value + '%';
    
    SET @t_page_num = (@p_current_page - 1) *  @p_page_row_size;
    
    set @r_total_count = (
							SELECT COUNT(*) FROM ORDER_PAYMENT_RESULT_MST PRM
							WHERE
							(
								CASE @p_success
								WHEN '' THEN ''
								ELSE PRM.PAYMENT_RESULT_SUCCESS_YORN END
							) = @p_success
							AND
							(
								CASE @p_search_type
								WHEN 'orderSeq' THEN CONVERT(nvarchar, PRM.ORDER_SEQ)
								WHEN 'orderCode' THEN PRM.WEB_ORDER_NUMBER
								ELSE CONVERT(nvarchar, PRM.ORDER_SEQ) END
							) LIKE @p_search_value
							AND
							(
								CASE @p_date_kind_type
								WHEN 'regDate' THEN PRM.REG_DATE
								ELSE PRM.REG_DATE END
							) >= @p_start_date
							AND
							(
								CASE @p_date_kind_type
								WHEN 'regDate' THEN PRM.REG_DATE
								ELSE PRM.REG_DATE END
							) <= @p_end_date
						);
								
	SELECT TOP(@p_page_row_size)
	PRM.*
	FROM ORDER_PAYMENT_RESULT_MST PRM
	WHERE PRM.PAYMENT_RESULT_SEQ NOT IN
	(
		SELECT TOP(@t_page_num)
		IPRM.PAYMENT_RESULT_SEQ
		FROM ORDER_PAYMENT_RESULT_MST IPRM
		WHERE
		(
			CASE @p_success
			WHEN '' THEN ''
			ELSE IPRM.PAYMENT_RESULT_SUCCESS_YORN END
		) = @p_success
		AND
		(
			CASE @p_search_type
			WHEN 'orderSeq' THEN CONVERT(nvarchar, IPRM.ORDER_SEQ)
			WHEN 'orderCode' THEN IPRM.WEB_ORDER_NUMBER
			ELSE CONVERT(nvarchar, IPRM.ORDER_SEQ) END
		) LIKE @p_search_value
		AND
		(
			CASE @p_date_kind_type
			WHEN 'regDate' THEN IPRM.REG_DATE
			ELSE IPRM.REG_DATE END
		) >= @p_start_date
		AND
		(
			CASE @p_date_kind_type
			WHEN 'regDate' THEN IPRM.REG_DATE
			ELSE IPRM.REG_DATE END
		) <= @p_end_date
		ORDER BY IPRM.PAYMENT_RESULT_SEQ DESC
	)
	AND
	(
		CASE @p_success
		WHEN '' THEN ''
		ELSE PRM.PAYMENT_RESULT_SUCCESS_YORN END
	) = @p_success
	AND
	(
		CASE @p_search_type
		WHEN 'orderSeq' THEN CONVERT(nvarchar, PRM.ORDER_SEQ)
		WHEN 'orderCode' THEN PRM.WEB_ORDER_NUMBER
		ELSE CONVERT(nvarchar, PRM.ORDER_SEQ) END
	) LIKE @p_search_value
	AND
	(
		CASE @p_date_kind_type
		WHEN 'regDate' THEN PRM.REG_DATE
		ELSE PRM.REG_DATE END
	) >= @p_start_date
	AND
	(
		CASE @p_date_kind_type
		WHEN 'regDate' THEN PRM.REG_DATE
		ELSE PRM.REG_DATE END
	) <= @p_end_date
    ORDER BY PRM.PAYMENT_RESULT_SEQ DESC
END

GO
