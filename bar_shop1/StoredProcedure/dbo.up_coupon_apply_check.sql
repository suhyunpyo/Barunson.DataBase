IF OBJECT_ID (N'dbo.up_coupon_apply_check', N'P') IS NOT NULL DROP PROCEDURE dbo.up_coupon_apply_check
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-12-30
-- Description:	주문단에서 쿠폰적용하기
-- exec up_coupon_apply_check 'hanws531', 'C0000024', 'C000002415092050070013047', 2214617, 35363, 0, 0
-- =============================================
CREATE PROCEDURE [dbo].[up_coupon_apply_check]
		
	@uid			NVARCHAR(16),
	@CouponCD		VARCHAR(20),
	@CouponNum		VARCHAR(50),
	@order_seq		INT,
	@card_seq		INT,
	@result_code	INT = 0 OUTPUT,
	@reduce		INT = 0 OUTPUT
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @useTarget	CHAR(1)
	DECLARE @amt	INT
	DECLARE @amtgb	VARCHAR(5)
	DECLARE @order_total_price INT
	DECLARE @resultcount INT = 0
	DECLARE @cint	INT
	DECLARE @ValidAMT	INT

	SELECT 
		  @useTarget = B.UseTarget
		, @amt = B.Amt
		, @amtgb = B.amtgb 
		, @ValidAMT = B.ValidAMT
	FROM tCouponSub AS A 
		INNER JOIN tCouponMst AS B 
			ON A.CouponCD = B.CouponCD
	WHERE A.CouponCD = @couponCD 
		AND A.CouponNum = @CouponNum
		AND A.TakeYN = 'Y' 
		AND A.UseYN = 'N'
	
	-- 해당 주문이 부가상품인지 청첩장 주문인지 구분
	SELECT @cint = COUNT(order_seq) FROM custom_order WHERE order_seq = @order_seq AND member_id=@uid

	IF @cint > 0	--청첩장주문일 경우
		BEGIN
			SELECT @order_total_price = order_total_price FROM custom_order WHERE order_seq = @order_seq AND member_id = @uid
		END
	ELSE
		BEGIN
			SELECT @order_total_price = settle_price FROM custom_etc_order WHERE order_seq = @order_seq AND member_id = @uid
		END
	
	IF @useTarget = 'A'	--전상품적용
		BEGIN 
			IF @amtgb = 'per'
				BEGIN
					SET @reduce = @order_total_price * @amt / 100
				END
			ELSE
				BEGIN
					SET @reduce = @amt
				END

			IF @order_total_price >= @ValidAMT
				BEGIN 
					SET @result_code = 1
				END
			ELSE
				BEGIN 
					SET @result_code = 2
				END
		END

	ELSE	--특정항목 적용
		BEGIN
			SELECT @resultcount = COUNT(itemCd) FROM tCouponUseItem WHERE CouponCD = @couponCD AND itemCD = @card_seq
			
			IF @resultcount > 0
				BEGIN
					IF @amtgb = 'per'
						BEGIN
							SET @reduce = @order_total_price * @amt / 100
						END
					ELSE
						BEGIN
							SET @reduce = @amt
						END

					IF @order_total_price >= @ValidAMT
						BEGIN 
							SET @result_code = 1
						END
					ELSE
						BEGIN 
							SET @result_code = 2
						END
				END
			ELSE
				BEGIN
					SET @result_code = 0
				END
		END

	PRINT @result_code
	PRINT @reduce
	

END


--  SELECT * FROM S4_Cart
--  delete FROM S4_Cart

GO
