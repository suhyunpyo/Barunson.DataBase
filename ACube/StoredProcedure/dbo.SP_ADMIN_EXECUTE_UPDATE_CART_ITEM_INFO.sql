IF OBJECT_ID (N'dbo.SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Cart Item의 종류 및 수량을 기준으로, 실제 산출 수량과 가격요소를 업데이트 한다.
-- =============================================
CREATE PROCEDURE [dbo].[SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO]
	@p_cart_item_seq int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @t_cart_item_quantity int,
	@t_cart_type_code nchar(6),
	@t_cart_item_export_quantity int,
	@t_cart_item_type_code nchar(6);
	
	SET @t_cart_item_quantity = (SELECT QUANTITY FROM CART_ITEM_MST WHERE CART_ITEM_SEQ = @p_cart_item_seq);
	
	SET @t_cart_type_code = (
		SELECT
		CM.CART_TYPE_CODE
		FROM CART_ITEM_MST CIM
		LEFT JOIN CART_MST CM ON CIM.CART_SEQ = CM.CART_SEQ
		WHERE CIM.CART_ITEM_SEQ = @p_cart_item_seq
	);
	
	SET @t_cart_item_type_code = (
			SELECT 
			PM.PROD_TYPE_CODE
			FROM CART_ITEM_MST CIM
			LEFT JOIN PROD_MST PM ON CIM.PROD_SEQ = PM.PROD_SEQ
			WHERE CIM.CART_ITEM_SEQ = @p_cart_item_seq
		);
	
	SET @t_cart_item_export_quantity = 
	(
		CASE @t_cart_type_code
		WHEN '201002' THEN 
			CASE @t_cart_item_type_code 
			-- Invite
			WHEN '101002' THEN (@t_cart_item_quantity +  ROUND(@t_cart_item_quantity * 0.1,0))
			-- Envelopes
			WHEN '101003' THEN (@t_cart_item_quantity +  ROUND(@t_cart_item_quantity * 0.1,0))
			-- Password 
			WHEN '101006' THEN CEILING((@t_cart_item_quantity * 1.0)/10)
			-- Labour
			WHEN '101007' THEN 1
			--Band
			WHEN '101008' THEN @t_cart_item_quantity + (2 * CEILING((@t_cart_item_quantity * 1.0)/10))
			-- Fee
			WHEN '101009' THEN 1
			ELSE @t_cart_item_quantity END
		ELSE 
			CASE @t_cart_item_type_code 
			-- Invite
			WHEN '101002' THEN (@t_cart_item_quantity +  ROUND(@t_cart_item_quantity * 0.1,0))
			-- Envelopes
			WHEN '101003' THEN (@t_cart_item_quantity +  ROUND(@t_cart_item_quantity * 0.1,0))
			-- Password 
			WHEN '101006' THEN 1
			-- Labour
			WHEN '101007' THEN 1
			--Band
			WHEN '101008' THEN @t_cart_item_quantity + 2
			-- Fee
			WHEN '101009' THEN 1
			ELSE @t_cart_item_quantity END
		END
	);
	
	
	UPDATE CART_ITEM_MST 
	SET EXPORT_QUANTITY = @t_cart_item_export_quantity
	WHERE CART_ITEM_SEQ= @p_cart_item_seq;
	

	DECLARE @t_item_print_seq int,
	@t_item_quantity int,
	@t_item_export_quantity int;
	
	DECLARE ITEM_PRINT_CURSOR CURSOR FOR
		SELECT CART_ITEM_PRINT_SEQ, QUANTITY, EXPORT_QUANTITY FROM CART_ITEM_PRINT_MST WHERE CART_ITEM_SEQ = @p_cart_item_seq;
		
	OPEN ITEM_PRINT_CURSOR;
	
	FETCH NEXT FROM ITEM_PRINT_CURSOR INTO @t_item_print_seq, @t_item_quantity, @t_item_export_quantity;
	
	WHILE(@@FETCH_STATUS=0)
	BEGIN
		SET @t_item_export_quantity = 
		(
			CASE @t_cart_type_code
			WHEN '201002' THEN 
				CASE @t_cart_item_type_code 
				-- Invite
				WHEN '101002' THEN (@t_cart_item_quantity +  ROUND(@t_cart_item_quantity * 0.1,0))
				-- Envelopes
				WHEN '101003' THEN (@t_cart_item_quantity +  ROUND(@t_cart_item_quantity * 0.1,0))
				-- Password 
				WHEN '101006' THEN CEILING((@t_cart_item_quantity * 1.0)/10)
				-- Labour
				WHEN '101007' THEN 1
				--Band
				WHEN '101008' THEN @t_cart_item_quantity + (2 * CEILING((@t_cart_item_quantity * 1.0)/10))
				-- Fee
				WHEN '101009' THEN 1
				ELSE @t_cart_item_quantity END
			ELSE 
				CASE @t_cart_item_type_code 
				-- Invite
				WHEN '101002' THEN (@t_item_quantity +  ROUND(@t_item_quantity * 0.1,0))
				-- Envelopes
				WHEN '101003' THEN (@t_item_quantity +  ROUND(@t_item_quantity * 0.1,0))
				-- Password 
				WHEN '101006' THEN 1
				-- Labour
				WHEN '101007' THEN 1
				--Band
				WHEN '101008' THEN @t_item_quantity + 2
				-- Fee
				WHEN '101009' THEN 1
				ELSE @t_item_quantity END
			END
		);
		
		UPDATE CART_ITEM_PRINT_MST 
		SET EXPORT_QUANTITY = @t_item_export_quantity
		WHERE CART_ITEM_PRINT_SEQ = @t_item_print_seq;
		
		FETCH NEXT FROM ITEM_PRINT_CURSOR INTO @t_item_print_seq, @t_item_quantity, @t_item_export_quantity;	
	END
	
	
	CLOSE ITEM_PRINT_CURSOR;
	DEALLOCATE ITEM_PRINT_CURSOR;
	

	
	
	
	
	

    -- Insert statements for procedure here
	
	
	
END

GO
