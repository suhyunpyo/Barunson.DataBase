IF OBJECT_ID (N'dbo.up_insert_to_cart_DET', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_to_cart_DET
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		By 유과장의 짝꿍
-- Create date: 2017-06-27
-- Description:	주문단에서 장바구니에 제품 꽂아넣기..
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_to_cart_DET]
		
	@uid			NVARCHAR(16),
	@card_seq		INT,
	@company_seq	INT,	
	@session_id		VARCHAR(10),
	@quantity		INT,
	@discRate		INT,
	@unitPrice		INT,
	@order_seq		INT,
	@cart_status		INT,
	@cart_seq		INT = 0,
	@order_type		CHAR(1) = 'O',
	@result_code	INT = 0 OUTPUT,
	@result_cnt		INT = 0 OUTPUT,
	@IDENTITY		INT = 0 OUTPUT
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @ResultCount INT
	DECLARE @OriginCartSeq INT
	DECLARE @OriginOrderSeq INT

	DECLARE @EXIST_COUPON_SEQ VARCHAR(50)
	DECLARE @EXIST_OVER_COUPON_SEQ VARCHAR(50)


	SELECT @ResultCount = COUNT(CART_SEQ)
	FROM S4_Cart
	WHERE CART_OWNER_ID = @uid
	  AND CARD_SEQ = @card_seq
	  --And CART_SEQ = @cart_seq
	
	
	IF @ResultCount > 0		--이미 장바구니에 상품이 존재하는 경우
		BEGIN

			SELECT @OriginCartSeq = CART_SEQ,
				   @OriginOrderSeq = Order_Seq
			FROM S4_Cart
			WHERE CART_OWNER_ID = @uid
			AND CARD_SEQ = @card_seq


			SET @result_cnt = 0
			SET @result_code = 0
			--GOTO PROBLEM

			--적용쿠폰 얻어오기
			SELECT @EXIST_COUPON_SEQ = ISNULL(COUPONSEQ, ''),
				   @EXIST_OVER_COUPON_SEQ = ISNULL(ADDITION_COUPONSEQ,'')
			FROM CUSTOM_ORDER
			WHERE MEMBER_ID = @uid
			AND ORDER_SEQ = @OriginOrderSeq

			--기본쿠폰 및 주문정보 복원
			IF @EXIST_COUPON_SEQ <> ''
				BEGIN
					--쿠폰복원
					UPDATE TCOUPONSUB
						SET UseDT = NULL, UseYN = 'N'
					WHERE CouponNum = @EXIST_COUPON_SEQ
					AND	UserID = @uid

					--주문정보
					UPDATE CUSTOM_ORDER
						SET COUPONSEQ = NULL, reduce_price = 0
					WHERE ORDER_SEQ = @OriginOrderSeq
					AND MEMBER_ID = @uid
				END 

			--중복쿠폰 및 주문정보 복원
			IF @EXIST_OVER_COUPON_SEQ <> ''
				BEGIN
					--쿠폰복원
					UPDATE TCOUPONSUB
						SET UseDT = NULL, UseYN = 'N'
					WHERE CouponNum = @EXIST_OVER_COUPON_SEQ
					AND	UserID = @uid

					--주문정보
					UPDATE CUSTOM_ORDER
						SET addition_couponseq = NULL, addition_reduce_price = 0
					WHERE ORDER_SEQ = @OriginOrderSeq
					AND MEMBER_ID = @uid
				END 

			--카트(장바구니) 정보 갱신
			update S4_Cart set card_num=@quantity, UNIT_PRICE=@unitPrice, DISCOUNT_RATE=@discRate, Order_Seq=@order_seq, Cart_Status=@cart_status
				where cart_seq=@OriginCartSeq

			--SET @IDENTITY = @OriginCartSeq
		END
	
	ELSE
		
		BEGIN
		
			INSERT INTO S4_Cart 
			( cart_owner_id, card_seq, company_seq, ORDER_TYPE, owner_session_id, card_num, unit_price, discount_rate, reg_date, order_seq, Cart_Status ) 
			VALUES 
			( @uid, @card_seq, @company_seq, @order_type, @session_id, @quantity, @unitPrice, @discRate, GETDATE(), @order_seq, @cart_status)	
			
			SET @result_cnt = @@ROWCOUNT	--변경된 rowcount
			SET @result_code = @@Error		--에러발생 cnt
			SET @IDENTITY = @@IDENTITY
			--IF (@result_code <> 0) GOTO PROBLEM
		
		END
		
	/*
	PROBLEM:
	IF (@result_code <> 0) BEGIN
		ROLLBACK TRAN
	END
	*/
	
	RETURN @result_code
	RETURN @result_cnt
	RETURN @IDENTITY 
	
END


--  select * from S4_Cart
--  delete from S4_Cart

GO
