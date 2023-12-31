IF OBJECT_ID (N'dbo.SP_CHG_ORDER_SEALING', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CHG_ORDER_SEALING
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- EXEC SP_CHG_ORDER_SEALING
-- 실링스티커 변경 
-- =============================================

CREATE PROCEDURE [dbo].[SP_CHG_ORDER_SEALING]
AS
BEGIN
	
	DECLARE		@CARD_SEQ		AS	INT		
		,		@CHG_CARD_SEQ	AS INT
		,		@ORDER_SEQ		AS INT
		,		@ITEM_COUNT		AS INT

 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR 
 

--37444	SW_G01 -> 38678 sealing_dear_G_C1
--37622	SW_W01 -> 38679 seal_leaf_w_C1
--38126	SW_P01 -> 38677 seal_flower_p_C1 


	SELECT C.ORDER_SEQ, CI.CARD_SEQ, CI.ITEM_COUNT
	FROM CUSTOM_ORDER C, CUSTOM_ORDER_ITEM CI
	WHERE C.ORDER_SEQ = CI.ORDER_SEQ
	AND CI.ITEM_TYPE ='A'
	AND CI.CARD_SEQ IN (37444, 37622, 38126)
	AND C.ORDER_DATE >= CONVERT(CHAR(10), GETDATE() -1 , 23) 
	AND C.ORDER_DATE < GETDATE()

 OPEN cur_AutoInsert_For_Order  

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @ORDER_SEQ,  @CARD_SEQ, @ITEM_COUNT
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN

   IF @CARD_SEQ = 37444 
	BEGIN
		SET @CHG_CARD_SEQ = 38678 
	END 
   ELSE IF @CARD_SEQ = 37622
	BEGIN
		SET @CHG_CARD_SEQ = 38679 
	END 
   ELSE IF @CARD_SEQ = 38126
	BEGIN
		SET @CHG_CARD_SEQ = 38677 
	END

	-- 부속품코드 변경
	UPDATE CUSTOM_ORDER_ITEM SET CARD_SEQ = @CHG_CARD_SEQ , ITEM_COUNT = (@ITEM_COUNT/25) WHERE ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE ='A'
	
	-- 혹시 모를 로그를 남겨두자
	insert into chg_env_log (order_seq, card_code, chg_date, gubun) values (@ORDER_SEQ, @CARD_SEQ, getdate(), 'SEAL') 


  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @ORDER_SEQ,  @CARD_SEQ, @ITEM_COUNT
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order

END
GO
