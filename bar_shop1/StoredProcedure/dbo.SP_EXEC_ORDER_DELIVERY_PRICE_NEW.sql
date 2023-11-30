IF OBJECT_ID (N'dbo.SP_EXEC_ORDER_DELIVERY_PRICE_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_ORDER_DELIVERY_PRICE_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/********************************************************************************************************************
작성자		: 표수현
작성일		: 2020-11-20
DESCRIPTION	: 
SPECIAL LOGIC	: 
URL			: 
EXEC		: 
*********************************************************************************************************************
MODIFICATION
*********************************************************************************************************************
수정일		작업자		요청자				DESCRIPTION
=====================================================================================================================
*********************************************************************************************************************/ 
CREATE PROCEDURE [dbo].[SP_EXEC_ORDER_DELIVERY_PRICE_NEW] 
	@ORDER_SEQ INT = 0
AS
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @배송지등록건수 INT
	DECLARE @ORDER_TOTAL_PRICE INT
	DECLARE @DELIVERY_PRICE INT

	-- 현재 등록된 배송지 개수 체크 
	SELECT @배송지등록건수 = COUNT(*) 
	FROM DELIVERY_INFO WHERE ORDER_SEQ = @ORDER_SEQ

	IF @배송지등록건수 = 0 BEGIN
		SET @배송지등록건수 = 1
	END

	-- LAST_TOTAL_PRICE값을  ORDER_TOTAL_PRICE값으로 우선 업데이트하고 DELIVERY_PRICE값을 0으로 초기화(LAST_TOTAL_PRICE에 배송비까지 합산되어지는 이유..
	--UPDATE CUSTOM_ORDER 
	--SET LAST_TOTAL_PRICE = ORDER_TOTAL_PRICE, 
	--	DELIVERY_PRICE = 0 
	--WHERE ORDER_SEQ = @ORDER_SEQ

	--SELECT @ORDER_TOTAL_PRICE = ORDER_TOTAL_PRICE
	--FROM CUSTOM_ORDER 
	--WHERE ORDER_SEQ = @ORDER_SEQ

	SELECT @ORDER_TOTAL_PRICE = LAST_TOTAL_PRICE - UNICEF_PRICE - DELIVERY_PRICE - REDUCE_PRICE 
	FROM CUSTOM_ORDER
	WHERE ORDER_SEQ = @ORDER_SEQ

	-- 총금액이 5만원 미만이면 배송지등록건수에 따라 배송비 부과 
	IF @ORDER_TOTAL_PRICE < 50000 BEGIN  
		IF @배송지등록건수 = 1 BEGIN
			SET @DELIVERY_PRICE = 3000
		END ELSE BEGIN 
			SET @DELIVERY_PRICE = (@배송지등록건수-1) * 3000
		END 
	END ELSE BEGIN
			IF @배송지등록건수 = 1 BEGIN  
				SET @DELIVERY_PRICE = 0
			END ELSE BEGIN 
				SET @DELIVERY_PRICE = (@배송지등록건수-1) * 3000
			END 

		--SET @DELIVERY_PRICE = 0
	END 

	-- LAST_TOTAL_PRICE와 DELIVERY_PRICE 최종 수정 
	UPDATE CUSTOM_ORDER 
	SET DELIVERY_PRICE = @DELIVERY_PRICE,  
		LAST_TOTAL_PRICE = @ORDER_TOTAL_PRICE + @DELIVERY_PRICE
	WHERE ORDER_SEQ = @ORDER_SEQ
GO
