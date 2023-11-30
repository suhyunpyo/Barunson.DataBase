IF OBJECT_ID (N'dbo.SP_INSERT_FREE_GIFT_DEARDEER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_FREE_GIFT_DEARDEER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/******************************************************* 
-- BATCH - 전일 결제완료한 주문번호 구매이벤트 호출 SP_INSERT_FREE_GIFT
-- EX) 2022.04.06 티아시아 커리2종 증정 

exec SP_INSERT_FREE_GIFT_DEARDEER
*********************************************************/ 
 
CREATE PROCEDURE [dbo].[SP_INSERT_FREE_GIFT_DEARDEER] 
AS 
BEGIN 
 
DECLARE @ORDER_SEQ AS INT = 0  
 
 --커서를 이용하여 해당되는 주문번호를 얻는다. 
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD 
 FOR 
  select ORDER_SEQ
  from custom_order
  where sales_gubun = 'SD'
  and settle_Date >= Convert(char(10), getdate()-1, 23)
  AND settle_Date <  Convert(char(10), getdate(), 23)
  and settle_status = '2'
  and up_order_Seq is null
  and order_type in ('1','6','7')
  and status_seq < 10 -- 지시서 발급전까지만.
  and pay_type <> '4'
 
 OPEN cur_AutoInsert_For_Order 
 
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @ORDER_SEQ
  WHILE @@FETCH_STATUS = 0 
	
	BEGIN 	
		-- 전일 결제완료한 주문건 구매이벤트 호출 
		EXEC SP_INSERT_FREE_GIFT @ORDER_SEQ
   
		FETCH NEXT FROM cur_AutoInsert_For_Order INTO @ORDER_SEQ
	END 
 
 CLOSE cur_AutoInsert_For_Order 
 DEALLOCATE cur_AutoInsert_For_Order 
END
GO
