IF OBJECT_ID (N'dbo.SP_INSERT_CONCIERGE_SERVICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_CONCIERGE_SERVICE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================    
-- Create date: 2020-11-10  
-- Description: 컨시어지 25매 추가 서비스
  
-- EXEC dbo.SP_INSERT_CONCIERGE_SERVICE 3073086

--컨시어지 프로시저

-->> 컨시어지관련 테이블
--CUSTOM_ORDER
--CUSTOM_ORDER_ITEM
--CUSTOM_ORDER_PLIST

-- =============================================  
  
CREATE PROCEDURE [dbo].[SP_INSERT_CONCIERGE_SERVICE]  
 @ORDER_SEQ      AS INT
AS  
BEGIN  
   
  
 DECLARE  @CHK_SERVICE     AS INT 
 DECLARE @SERVICE_COUNT     AS INT = 25 
 DECLARE @ENV_CARD_SEQ		AS INT
 DECLARE @ENV_CARD_CODE	AS VARCHAR(15) = '' 
 DECLARE @C_MEMO AS VARCHAR(50) = ''
 DECLARE @ENV_CNT     AS INT 
 DECLARE @ENV_PLIST_CNT  AS INT
 
	 -- 컨시어지 서비스 수량을 받은 주문인가 확인
	 SELECT @CHK_SERVICE = COUNT(*) 
	 FROM CUSTOM_ORDER WHERE ISVAR <> 'C' AND ORDER_SEQ = @ORDER_SEQ 

		-- 컨시어지 서비스 받을 주문이 맞다면!
		IF @CHK_SERVICE = 1
		BEGIN
		-- 1 ) CUSTOM_ORDER 업데이트
		UPDATE CUSTOM_ORDER SET order_count = ORDER_COUNT + @SERVICE_COUNT , ISVAR = 'C' , ISCCG = 'Y' WHERE ORDER_SEQ = @ORDER_SEQ
	
		-- 2) CUSTOM_ORDER_ITEM ------------------------------------------------------------------------------------------------------------------------------------
		-- 2-1) ITEM_TYPE ='C' ,'I'
		UPDATE CUSTOM_ORDER_ITEM SET ITEM_COUNT = ITEM_COUNT + @SERVICE_COUNT WHERE ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE IN ('C','I','P','A')

		-- 2-2) ITEM_TYPE ='E' 디자인 봉투로 봉투정보 다시 구하기
		SELECT @ENV_CARD_SEQ = S.CARD_SEQ 
			, @ENV_CARD_CODE = S.CARD_CODE
		FROM (
			SELECT TOP 1 ( CASE WHEN MEMO1 ='디자인봉투' THEN left(CARD_CODE,LEN(CARD_CODE)-4)   ELSE CARD_CODE END) CARD_CODE
			FROM S2_CARD S, CUSTOM_ORDER_ITEM C
			WHERE C.ITEM_TYPE ='E'
			AND C.CARD_SEQ = S.CARD_SEQ 
			AND C.ORDER_sEQ = @ORDER_SEQ
			) A , S2_CARD S
		WHERE A.CARD_CODE = S.CARD_CODE


		SELECT @ENV_CNT = COUNT(ID) FROM CUSTOM_ORDER_ITEM WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @ENV_CARD_SEQ AND ITEM_TYPE ='E'

		IF @ENV_CNT = 0 
			BEGIN
				insert into CUSTOM_ORDER_ITEM (  order_seq, card_seq, item_type, item_count, item_price, item_sale_price, discount_rate, memo1, addnum_price, REG_DATE ) 				values ( @ORDER_SEQ, @ENV_CARD_SEQ, 'E', @SERVICE_COUNT, 0, 0, NULL, NULL, 0, GETDATE() )			
			END 
		ELSE
			BEGIN
				UPDATE CUSTOM_ORDER_ITEM SET item_count = item_count + @SERVICE_COUNT WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @ENV_CARD_SEQ AND ITEM_TYPE ='E'
			END 
	
		-- 2-3) ITEM_TYPE ='S'
			UPDATE CUSTOM_ORDER_ITEM 
				SET ITEM_COUNT = (SELECT SUM(ITEM_COUNT) FROM CUSTOM_ORDER_ITEM WHERE ITEM_TYPE ='E' AND ORDER_SEQ = @ORDER_SEQ) 
			WHERE ORDER_SEQ = @ORDER_SEQ AND ITEM_TYPE ='S'

		-- 3) CUSTOM_ORDER_PLIST (백봉투여야함) --------------------------------------------
			UPDATE CUSTOM_ORDER_PLIST SET print_count = print_count + @SERVICE_COUNT WHERE ORDER_SEQ = @ORDER_SEQ AND PRINT_TYPE IN ('C','I','P') 

		IF EXISTS(SELECT * FROM CUSTOM_ORDER_PLIST WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @ENV_CARD_SEQ and title ='백봉투')    
			BEGIN  	
				UPDATE CUSTOM_ORDER_PLIST SET print_count = print_count + @SERVICE_COUNT WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @ENV_CARD_SEQ and title ='백봉투'
			END
		------------------------------------------------------------------------------------
		END

END  
GO
