IF OBJECT_ID (N'dbo.PROC_ORDER_DELETE', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_ORDER_DELETE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_ORDER_DELETE
-- Author        : 박혜림
-- Create date   : 2022-05-03
-- Description   : 주문데이터 삭제
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_ORDER_DELETE]
      @Type      VARCHAR(10)		-- 구분(CARD: 청첩장/감사장, ETC: 부가상품, GIFT: 답례품, SAMPLE: 샘플)
	, @ORDER_SEQ INT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @pid	BIGINT

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			IF @Type = 'CARD'
			BEGIN

			    DELETE custom_order_WeddInfo
				 WHERE order_seq = @ORDER_SEQ

				DELETE custom_order_plist
				 WHERE order_seq = @ORDER_SEQ
				
				DELETE custom_order_item
				 WHERE order_seq = @ORDER_SEQ

				DELETE custom_order
				 WHERE order_seq = @ORDER_SEQ


			END
			ELSE IF @Type = 'ETC'
			BEGIN

				DELETE CUSTOM_ETC_ORDER_WeddInfo
				 WHERE order_seq = @ORDER_SEQ

				DELETE CUSTOM_ETC_ORDER_ITEM
				 WHERE order_seq = @ORDER_SEQ

				DELETE CUSTOM_ETC_ORDER
				 WHERE order_seq = @ORDER_SEQ
				
			END
			ELSE IF @Type = 'GIFT'
			BEGIN

				DELETE CUSTOM_ETC_ORDER_GIFT_ITEM
				 WHERE order_seq = @ORDER_SEQ

				DELETE CUSTOM_ETC_ORDER_ITEM
				 WHERE order_seq = @ORDER_SEQ

				DELETE CUSTOM_ETC_ORDER
				 WHERE order_seq = @ORDER_SEQ
				
			END
			ELSE IF @Type = 'SAMPLE'
			BEGIN

				DELETE CUSTOM_SAMPLE_ORDER_ITEM
				 WHERE sample_order_seq = @ORDER_SEQ

				DELETE CUSTOM_SAMPLE_ORDER
				 WHERE sample_order_seq = @ORDER_SEQ
			END
			
			
		COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		BEGIN
		     ROLLBACK TRAN
        END
	END CATCH

END

-- EXEC bar_shop1.dbo.PROC_ORDER_DELETE 'CARD', 4161173
GO
