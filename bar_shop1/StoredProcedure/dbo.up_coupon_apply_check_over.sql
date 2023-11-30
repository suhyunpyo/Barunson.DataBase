IF OBJECT_ID (N'dbo.up_coupon_apply_check_over', N'P') IS NOT NULL DROP PROCEDURE dbo.up_coupon_apply_check_over
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김현기
-- Create date: 2016-07-18
-- Description:	주문단에서 쿠폰적용하기
-- exec up_coupon_apply_check_over 's4guest', 'C0000112', 'C0000183', 'C000011216090250070005229', 'C000018316111550070000001', 2413373, 35798, 0, 0
-- exec up_coupon_apply_check_over 's4guest', '', 'C0000170', '', 'C000017016093050070000001 ', 2393069, 35544, 0, 0
-- =============================================
CREATE PROCEDURE [dbo].[up_coupon_apply_check_over]
		
	@uid			NVARCHAR(16),
	@CouponCD		VARCHAR(20),
	@CouponCD_over	VARCHAR(20),
	@CouponNum		VARCHAR(50),
	@CouponNum_over	VARCHAR(50),
	@order_seq		INT,
	@card_seq		INT,
	@result_code	INT = 0 OUTPUT,
	@reduce		    INT = 0 OUTPUT,
	@reduce_over	INT = 0 OUTPUT
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

	DECLARE @useTarget_over	CHAR(1)
	DECLARE @amt_over	INT
	DECLARE @amtgb_over	VARCHAR(5)
	DECLARE @order_total_price_over INT
	DECLARE @resultcount_over INT = 0
	DECLARE @cint_over	INT
	DECLARE @ValidAMT_over	INT

	SET @CouponCD_over = ltrim(rtrim(@CouponCD_over))


	--추가주문에는 쿠폰적용 불가
	--IF @uid <> 'angela0206' 
	--BEGIN

	--	IF EXISTS(SELECT * FROM custom_order WHERE order_seq = @order_seq AND member_id=@uid AND ISNULL(up_order_seq, '') <> '')
	--	BEGIN
	--		SET @CouponNum = ''
	--		SET @CouponNum_over = ''
	--	END
	--END

	--얼리버드 쿠폰 By,2017
	IF @CouponCD_over = 'C0000170'
	BEGIN
		IF EXISTS(SELECT * FROM custom_order_WeddInfo WHERE order_seq = @order_seq AND event_year <> '2017')
		BEGIN
			SET @CouponNum = ''
			SET @CouponNum_over = ''
		END
	END
	-- 11월얼리버드쿠폰
	IF @CouponCD_over = 'C0000175'
	BEGIN
		IF NOT EXISTS(SELECT * FROM custom_order_WeddInfo WHERE order_seq = @order_seq AND event_year = '2017' AND CONVERT(int,event_month) >= '02')
		BEGIN
			SET @CouponNum = ''
			SET @CouponNum_over = ''
		END
	END

	--할로윈 쿠폰
	IF @CouponCD_over = 'C0000169'
	BEGIN
		IF NOT EXISTS(SELECT * FROM custom_order WHERE order_seq = @order_seq AND member_id=@uid AND order_date >= '2016-10-21' AND order_date < '2016-11-01')
		BEGIN
			SET @CouponNum = ''
			SET @CouponNum_over = ''
		END
	END

	--블랙프라이데이 쿠폰
	IF @CouponCD_over = 'C0000174'
	BEGIN
		IF NOT EXISTS(SELECT * FROM custom_order WHERE order_seq = @order_seq AND member_id=@uid AND order_date >= '2016-11-25' AND order_date < '2016-12-01')
		BEGIN
			SET @CouponNum = ''
			SET @CouponNum_over = ''
		END
	END


	-- YOLO쿠폰_얼리버드할인
	IF @CouponCD_over = 'C0000230'
	BEGIN
		IF NOT EXISTS(SELECT * FROM custom_order_WeddInfo WHERE order_seq = @order_seq AND event_year = '2017' AND CONVERT(int,event_month) >= '10' AND CONVERT(int,event_day) >= '18')
		BEGIN
			SET @CouponNum = ''
			SET @CouponNum_over = ''
		END
	END


	--기본쿠폰 정보
	IF ISNULL(@CouponNum,'') <> ''
		BEGIN
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
		END
	
	--중복쿠폰 정보
	IF ISNULL(@CouponNum_over,'') <> ''
		BEGIN
			SELECT 
				  @useTarget_over = B.UseTarget
				, @amt_over = B.Amt
				, @amtgb_over = B.amtgb 
				, @ValidAMT_over = B.ValidAMT
			FROM tCouponSub AS A 
				INNER JOIN tCouponMst AS B 
					ON A.CouponCD = B.CouponCD
			WHERE A.CouponCD = @couponCD_over 
				AND A.CouponNum = @CouponNum_over
				AND A.TakeYN = 'Y' 
				AND A.UseYN = 'N'
				
		END

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

	IF 	ISNULL(@useTarget,'') <> ''  --기본쿠폰이 존재할경우
		BEGIN
			IF @useTarget = 'A'	--전품목 적용
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

			ELSE IF @useTarget = 'L'	--한정품목 적용
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
			ELSE IF @useTarget = 'E'	--제외품목 적용
				BEGIN
					SELECT @resultcount = COUNT(itemCd) FROM tCouponUseItem WHERE CouponCD = @couponCD AND itemCD = @card_seq
			
					IF @resultcount > 0
						BEGIN
							SET @result_code = 0
						END
					ELSE						
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
				END
		END  --	ISNULL(@useTarget,'')
		

	IF 	ISNULL(@useTarget_over,'') <> ''  --중복쿠폰이 존재할경우
		BEGIN
			IF @useTarget_over = 'A'	--전품목 적용
				BEGIN 
					IF ISNULL(@useTarget_over,'') <> ''
						BEGIN 
							IF @amtgb_over = 'per'
								BEGIN
									SET @reduce_over = (@order_total_price - @reduce ) * @amt_over / 100
								END
							ELSE
								BEGIN
									SET @reduce_over = @amt_over
								END
						END
					ELSE 
						BEGIN 
							IF @amtgb_over = 'per'
								BEGIN
									SET @reduce_over = @order_total_price * @amt_over / 100
								END
							ELSE
								BEGIN
									SET @reduce_over = @amt_over
								END
						End					

					IF @order_total_price >= @ValidAMT_over
						BEGIN 
							SET @result_code = 1
						END
					ELSE
						BEGIN 
							SET @result_code = 2
						END
				END

			ELSE IF @useTarget_over = 'L'	--한정품목 적용
				BEGIN
					SELECT @resultcount_over = COUNT(itemCd) FROM tCouponUseItem WHERE CouponCD = @couponCD_over AND itemCD = @card_seq
			
					IF @resultcount_over > 0
						BEGIN
							IF @amtgb_over = 'per'
								BEGIN
									SET @reduce_over = @order_total_price * @amt_over / 100
								END
							ELSE
								BEGIN
									SET @reduce_over = @amt_over
								END

							IF @order_total_price >= @ValidAMT_over
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

			ELSE IF @useTarget_over = 'E'	--제외품목 적용
				BEGIN
					SELECT @resultcount_over = COUNT(itemCd) FROM tCouponUseItem WHERE CouponCD = @couponCD_over AND itemCD = @card_seq
			
					IF @resultcount_over > 0
						BEGIN
							SET @result_code = 0
						END						
					ELSE
						BEGIN
							IF @amtgb_over = 'per'
								BEGIN
									SET @reduce_over = @order_total_price * @amt_over / 100
								END
							ELSE
								BEGIN
									SET @reduce_over = @amt_over
								END

							IF @order_total_price >= @ValidAMT_over
								BEGIN 
									SET @result_code = 1
								END
							ELSE
								BEGIN 
									SET @result_code = 2
								END
						END
				END
		END  --	ISNULL(@useTarget,'')

	--set @reduce = @reduce
	--exec up_coupon_apply_check_over 's5guest', '', 'C0000149', 'C000014816070450070000001', 'C000014916071850070000001', 2351424, 35542, 0, 0, 0

	--SELECT ISNULL(@reduce,0) , ISNULL(@reduce_over,0)
	--print @reduce



	--SET @reduce = ISNULL(@reduce,0) + ISNULL(@reduce_over,0)

	PRINT @result_code
	PRINT @reduce
	PRINT @reduce_over
	

END
GO
