IF OBJECT_ID (N'dbo.up_insert_sample_vore', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_sample_vore
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김현기
-- Create date: 2016-07-04
-- Description:	샘플추천 로직
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_sample_vore]
		
	@uid			NVARCHAR(20),
	@card_seq		INT,
	@sales_gubun	VARCHAR(10),
	@ip_addr		VARCHAR(16),
	@order_seq		INT,
	@result_code	INT = 0 OUTPUT

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	DECLARE @ResultCount INT
	DECLARE @CouponCnt INT
	DECLARE @existCnt INT


	SELECT @ResultCount = COUNT(LIKE_SEQ)
	FROM SAMPLE_LIKE_CHECK
	WHERE LIKE_UID = @uid
	  --AND LIKE_CARD_sEQ = @card_seq
	  AND LIKE_SAMPLE_ORDER_SEQ = @order_seq
	  AND SALES_GUBUN = @sales_gubun
	  AND LIKE_IP = @ip_addr
	
	IF @ResultCount > 0		--이미 장바구니에 상품이 존재하는 경우
		
		BEGIN
			SET @result_code = 0	
			--GOTO PROBLEM
		END
	
	ELSE
		
		BEGIN
			--좋아요 추가
			INSERT INTO SAMPLE_LIKE_CHECK 
			( LIKE_SAMPLE_ORDER_SEQ, LIKE_CARD_sEQ, LIKE_UID, LIKE_IP, SALES_GUBUN, REG_DATE ) 
			VALUES 
			( @order_seq, @card_seq, @uid, @ip_addr, @sales_gubun, GETDATE() )	


			--쿠폰발급로직
			SELECT	@existCnt = COUNT(LIKE_SEQ)
			FROM	SAMPLE_LIKE_CHECK
			WHERE	1 = 1
			  AND	LIKE_SAMPLE_ORDER_SEQ = @order_seq
			  AND   LIKE_UID = @uid
			
			--좋아요 3회이상 받았을경우
			IF @existCnt > 2
				BEGIN 
					--발급된 쿠폰존재여부 체크
					SELECT	@CouponCnt = COUNT(CouponCD)
					FROM	tCouponSub
					WHERE	1 = 1
					  AND	CouponCD = 'C0000148'
					  AND   UserID = @uid
					
					--쿠폰이 존재할경우
					IF @CouponCnt > 0  
						SET @result_code = 1

					ELSE --쿠폰이 존재하지 않을 경우
						BEGIN
							EXEC up_insert_coupon '5007', @uid, 'C0000148'
						END

				END
			SET @result_code = 1
		END

	RETURN @result_code
	
END
GO
