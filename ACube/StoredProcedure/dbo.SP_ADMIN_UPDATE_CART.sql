IF OBJECT_ID (N'dbo.SP_ADMIN_UPDATE_CART', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ADMIN_UPDATE_CART
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
CREATE PROCEDURE [dbo].[SP_ADMIN_UPDATE_CART]
	-- Add the parameters for the stored procedure here
	@p_cart_seq int,
	@p_quantity int,
	@p_request_shipping_date Datetime,
	@p_item_quantity_update CHAR(1)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE CART_MST
	SET 
	QUANTITY = @p_quantity,
	REQUEST_SHIPPING_DATE = @p_request_shipping_date
	WHERE
	CART_SEQ = @p_cart_seq;
	
	
	IF(@p_item_quantity_update = 'Y')
	BEGIN
		--하위 Item 요소의 수량도 모두 업데이트 한다.
		UPDATE CART_ITEM_MST 
		SET QUANTITY = @p_quantity
		WHERE CART_SEQ = @p_cart_seq
		

		DECLARE @t_cart_item_seq int;
		
		DECLARE ITEM_CURSOR CURSOR FOR
			SELECT CART_ITEM_SEQ FROM CART_ITEM_MST WHERE CART_SEQ = @p_cart_seq;
			
		OPEN ITEM_CURSOR;
		
		FETCH NEXT FROM ITEM_CURSOR INTO @t_cart_item_seq;	
		
		WHILE(@@FETCH_STATUS=0)
		BEGIN
			
			EXECUTE [ACube].[dbo].[SP_ADMIN_EXECUTE_UPDATE_CART_ITEM_INFO] 
				@t_cart_item_seq;    
			
			FETCH NEXT FROM ITEM_CURSOR INTO @t_cart_item_seq;		
		END
		
		CLOSE ITEM_CURSOR;
		DEALLOCATE ITEM_CURSOR;



		--W1101P 주문시 수량 강제 조정 (글로벌 박은현대리 요청-20170525(UPDATE로직 적용일자20170621))
		--Retail Product(201002)
		IF EXISTS (select * from CART_MST where CART_SEQ = @p_cart_seq AND CART_TYPE_CODE = 201002 AND PROD_SEQ = 485 )
		BEGIN 
		
		--2579	AID001
		--2581	AP002
		--2698	LABOUR
		--2762	W1101p

			UPDATE CART_ITEM_MST 
			SET QUANTITY = ROUND(QUANTITY / 6, 0)
				, EXPORT_QUANTITY = ROUND(EXPORT_QUANTITY / 6, 0)
			WHERE CART_SEQ = @p_cart_seq  AND  PROD_SEQ = 2581 

			UPDATE CART_ITEM_MST 
			SET EXPORT_QUANTITY = CASE WHEN QUANTITY < 12 THEN 1 ELSE ROUND(QUANTITY / 12, 0) END
			WHERE CART_SEQ = @p_cart_seq  AND  PROD_SEQ = 2579 
	 
		END

	END
	
END

GO
