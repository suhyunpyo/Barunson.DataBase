IF OBJECT_ID (N'dbo.SP_CHG_ETC_CODE_PRIC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CHG_ETC_CODE_PRIC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CHG_ETC_CODE_PRIC]
	@GUBUN		AS CHAR(10)
	,@ORDER_SEQ		AS INT
AS
BEGIN
	
	DECLARE		@ORDER_COUNT		AS	INT = 0
	DECLARE		@FLOW			AS	INT = 0 

	IF @GUBUN = 'A_SEAL' 
	
	BEGIN
		-- 실링스티커 부속품
		IF EXISTS ( 
			select top 1 order_Seq 
			from custom_order_item ci, s2_Card s
			where ci.card_Seq = s.card_seq 
			and ci.order_Seq =  @ORDER_SEQ 
			AND ci.card_seq = 37622
			)  
			
			BEGIN                     
				SET @FLOW = 1  
			END  
		ELSE  
			BEGIN                     
				SET @FLOW = 0
			END 

		IF @FLOW = 1 
		BEGIN
	
			SELECT @ORDER_COUNT = ORDER_COUNT FROM CUSTOM_ORDER C WHERE ORDER_SEQ = @ORDER_SEQ 
		
			IF @ORDER_COUNT > 0 
		
			BEGIN			
				UPDATE custom_order_item SET item_count =  ( @ORDER_COUNT / 25 ) , card_Seq = 38621 WHERE order_Seq = @ORDER_SEQ and card_seq = 37622
				
				insert into err_chk_log (order_seq, err_gubun) values (@ORDER_SEQ, @GUBUN) 
			END
		END
	END

END
GO
