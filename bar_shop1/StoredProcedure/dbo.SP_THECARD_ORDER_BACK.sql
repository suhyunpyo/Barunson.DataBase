IF OBJECT_ID (N'dbo.SP_THECARD_ORDER_BACK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_THECARD_ORDER_BACK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_THECARD_ORDER_BACK]
	@P_ORDER_SEQ		AS INT
AS

BEGIN

	DECLARE @CARD_SEQ AS INT
	DECLARE @CARD_NUM AS INT
	DECLARE @UNIT_PRICE AS INT
	DECLARE @DISCOUNT_RATE AS INT
	DECLARE @CART_SEQ AS INT = 0
	DECLARE @ORDER_G_SEQ AS INT

	DECLARE @EXIST_COUPON_SEQ VARCHAR(50)
	DECLARE @EXIST_OVER_COUPON_SEQ VARCHAR(50) 


	DECLARE @UID AS VARCHAR(20)


	--장바구니에 담겨있는 정보를 얻어온다.
	SELECT		@CARD_NUM = ORDER_COUNT
			,	@CARD_SEQ = CARD_SEQ
			,	@DISCOUNT_RATE = DISCOUNT_RATE
			,	@UID = MEMBER_ID
			,	@ORDER_G_SEQ = ORDER_G_SEQ
			,	@EXIST_COUPON_SEQ = ISNULL(COUPONSEQ, '')
			,	@EXIST_OVER_COUPON_SEQ = ISNULL(ADDITION_COUPONSEQ,'')
	FROM	CUSTOM_ORDER
	WHERE	ORDER_SEQ = @P_ORDER_SEQ

	
	--단가를 얻어온다
	SELECT	@UNIT_PRICE = ITEM_SALE_PRICE
	FROM	CUSTOM_ORDER_ITEM
	WHERE	ORDER_SEQ = @P_ORDER_SEQ
	AND		CARD_SEQ = @CARD_SEQ


	--장바구니에 담겨있는 정보를 얻어온다.
	SELECT	@CART_SEQ = CART_SEQ
	FROM	S4_CART
	WHERE	CART_OWNER_ID = @UID
	AND		CARD_SEQ = @CARD_SEQ	
	

	--존재할경우 UPDATE
	IF @CART_SEQ > 0
		BEGIN
			UPDATE	S4_CART
			SET		CARD_NUM = @CARD_NUM
				,	UNIT_PRICE = @UNIT_PRICE
				,	DISCOUNT_RATE = @DISCOUNT_RATE
				,	REG_DATE = GETDATE()
				,	ORDER_sEQ = @P_ORDER_SEQ
			WHERE	CART_SEQ = @CART_SEQ
			
		END 

	--존재하지 않을경우 INSERT
	ELSE
		BEGIN
			INSERT INTO S4_CART(		CART_OWNER_ID
									,	CARD_SEQ
									,	COMPANY_SEQ
									,	SALES_GUBUN
									,	ORDER_TYPE
									,	OWNER_SESSION_ID
									,	CARD_NUM
									,	UNIT_PRICE
									,	DISCOUNT_RATE
									,	REG_DATE
									,	CARD_OPTION
									,	Order_Seq
									,	Cart_Status)
			VALUES(
					@UID
					,@CARD_SEQ
					,5007
					,'W'
					,'O'
					,''  --SESSION_ID
					,@CARD_NUM
					,@UNIT_PRICE
					,@DISCOUNT_RATE
					,GETDATE()
					,NULL
					,@P_ORDER_SEQ
					,1
			)
		END 


		
	--주문정보 갱신(CUSTOM_ORDER)
	BEGIN

		----기본쿠폰 및 주문정보 복원
		--IF @EXIST_COUPON_SEQ <> ''
		--	BEGIN
		--		--쿠폰복원
		--		UPDATE TCOUPONSUB
		--			SET UseDT = NULL, UseYN = 'N'
		--		WHERE CouponNum = @EXIST_COUPON_SEQ
		--		AND	UserID = @UID

		--		--주문정보
		--		UPDATE CUSTOM_ORDER
		--			SET COUPONSEQ = NULL, reduce_price = 0, last_total_price = last_total_price +(reduce_price * -1)
		--		WHERE ORDER_SEQ = @P_ORDER_SEQ
		--		AND MEMBER_ID = @UID
		--	END 

		----중복쿠폰 및 주문정보 복원
		--IF @EXIST_OVER_COUPON_SEQ <> ''
		--	BEGIN
		--		--쿠폰복원
		--		UPDATE TCOUPONSUB
		--			SET UseDT = NULL, UseYN = 'N'
		--		WHERE CouponNum = @EXIST_OVER_COUPON_SEQ
		--		AND	UserID = @UID

		--		--주문정보
		--		UPDATE CUSTOM_ORDER
		--			SET addition_couponseq = NULL, addition_reduce_price = 0, last_total_price = last_total_price +(addition_reduce_price * -1)
		--		WHERE ORDER_SEQ = @P_ORDER_SEQ
		--		AND MEMBER_ID = @UID
		--	END 


		UPDATE	CUSTOM_ORDER
		SET		SETTLE_STATUS = 0 
			,	STATUS_SEQ = 0
			,	SETTLE_PRICE = 0
			,	SETTLE_DATE = NULL
			,   ORDER_G_SEQ = NULL	
		WHERE	ORDER_SEQ = @P_ORDER_SEQ
		AND		MEMBER_ID = @UID
	END

	--통합주문정보 갱신 (CUSTOM_ORDER_GROUP)
	IF 	@ORDER_G_SEQ > 0
	BEGIN
		UPDATE	CUSTOM_ORDER_GROUP
		SET		SETTLE_STATUS = 0 
			,	STATUS_SEQ = 0
			,	SETTLE_PRICE = 0
			,	SETTLE_DATE = NULL
			,	SETTLE_METHOD = NULL
			,	PG_SHOPID = NULL
			,	PG_TID = NULL
			,	PG_RESULTINFO = NULL
			,	PG_RESULTINFO2 = NULL
			,	PG_STATUS = NULL
			,	PG_RECEIPT_TID = NULL
		WHERE	ORDER_G_SEQ = @ORDER_G_SEQ
		AND		MEMBER_ID = @UID
	END 
	
	--배송정보 삭제
	DELETE DELIVERY_INFO WHERE ORDER_SEQ = @P_ORDER_SEQ

	
	--SELECT * FROM S4_CART
	--where cart_seq = 41942

	--SELECT * FROM CUSTOM_ORDER_GROUP
	--WHERE ORDER_G_SEQ = 1136305
	
	--SELECT * FROM CUSTOM_ORDER
	--WHERE ORDER_SEQ = 2472414

	--SELECT * FROM CUSTOM_ORDER_ITEM
	--WHERE ORDER_SEQ = 2472414

	--41942	aji4012	35836	5007	W	O	1012324247	500	480	52	2017-04-14 00:51:23.780	NULL	2472414	1

END
GO
