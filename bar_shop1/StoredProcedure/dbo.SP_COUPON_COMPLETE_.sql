SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Author		:	황새롬
	Create date	:	2017-07-20
	Description	:	쿠폰사용완료

	EXEC SP_COUPON_COMPLETE_ 'kywa16', 4135055, '1730420', '',''
*/

ALTER PROCEDURE [dbo].[SP_COUPON_COMPLETE_]
		@P_UID									AS VARCHAR(50)
	,	@P_ORDER_SEQ							AS INT
	,	@P_VERIFICATION_COUPON_DETAIL_SEQ_LIST	AS VARCHAR(100) = ''
	,	@P_SETTLE_PRICE							AS INT
	,	@P_DEVICE_TYPE							AS VARCHAR(100) = 'P'
AS
BEGIN
	
    SET NOCOUNT ON;

    DECLARE @RESULT_CODE	AS VARCHAR(4)	= '0000'
		,	@RESULT_MESSAGE AS VARCHAR(500)	= ''

	DECLARE	@MEMBER_ID							AS VARCHAR(100)
	DECLARE	@COMPANY_SEQ							AS INT

	SELECT	@MEMBER_ID							= MEMBER_ID
	,		@COMPANY_SEQ						= COMPANY_SEQ
	FROM	CUSTOM_ORDER
	WHERE	1 = 1
	AND		ORDER_SEQ							= @P_ORDER_SEQ

	/* 주문자 확인 */
	IF @MEMBER_ID <> @P_UID
	BEGIN
		SET @RESULT_CODE	= '9999'
		SET @RESULT_MESSAGE = '주문정보가 일치하지 않습니다.'
	END
	ELSE
	BEGIN
		/*사용된 쿠폰과 결제금액이 일치하는 지 확인한다*/
		-- 임시테이블 생성
		CREATE TABLE #TempTable (ORDER_SEQ							INT
						,	UP_ORDER_SEQ							INT
						,	UID										VARCHAR(100)
						,	COMPANY_SEQ								INT
						,	SALES_GUBUN								VARCHAR(2)
						,	ORDER_TYPE								INT
						,	COUPON_ISSUE_SEQ						INT
						,	COUPON_DETAIL_SEQ						INT
						,	COUPON_NAME								VARCHAR(100)
						,	COUPON_TYPE_CODE						INT
						,	COUPON_SERVICE_TYPE_CODE				INT
						,	COUPON_SERVICE_TYPE_NAME				VARCHAR(50)
						,	DUP_COUPON_ALLOW_YN						VARCHAR(1)
						,	AD_COUPON_ALLOW_YN						VARCHAR(1)
						,	ADD_COUPON_ALLOW_YN						VARCHAR(1)
						,	CARD_SEQ								INT
						,	ORDER_COUNT								INT
						,	LAST_TOTAL_PRICE						INT
						,	USE_DEVICE								VARCHAR(1)
						,	DISCOUNT_FIXED_RATE_TYPE				VARCHAR(1)
						,	DISCOUNT_VALUE							INT
						,	DISCOUNT_MAX_AMT						INT
						,	ORDER_PRICE								INT
						,	FTICKET_PRICE							INT
						,	GUESTBOOK_PRICE							INT
						,	LINING_ENV_PRICE						INT
						,	PRINT_PRICE								INT
						,	EMBO_PRICE								INT
						,	JEBON_PRICE								INT
						,	ENVINSERT_PRICE							INT
						,	EXPRESS_SHIPPING_PRICE					INT
						, 	LININGJAEBON_PRICE						INT
						,	DELIVERY_PRICE							INT
						,	DISCOUNT_TARGET_ORDER_PRICE_ORG			INT
						,	DISCOUNT_TARGET_ORDER_PRICE				INT
						,	DISCOUNT_TARGET_FTICKET_PRICE			INT
						,	DISCOUNT_TARGET_GUESTBOOK_PRICE			INT
						,	DISCOUNT_TARGET_LINING_ENV_PRICE		INT
						,	DISCOUNT_TARGET_FLOWER_PRICE			INT
						,	DISCOUNT_TARGET_SEALING_PRICE			INT
						, 	DISCOUNT_TARGET_ENVSPECIAL_PRICE		INT
						,	DISCOUNT_TARGET_RIBBON_PRICE			INT
						,	DISCOUNT_TARGET_PAPERCOVER_PRICE		INT
						,	DISCOUNT_TARGET_PRINT_PRICE				INT
						,	DISCOUNT_TARGET_EMBO_PRICE				INT	
						,	DISCOUNT_TARGET_JEBON_PRICE				INT
						,	DISCOUNT_TARGET_ENVINSERT_PRICE			INT
						,	DISCOUNT_TARGET_DELIVERY_PRICE			INT
						,	DISCOUNT_TARGET_EXPRESS_SHIPPING_PRICE	INT
						, 	DISCOUNT_TARGET_LININGJAEBON_PRICE		INT
						,	DISCOUNT_ORDER_PRICE					FLOAT
						,	DISCOUNT_FTICKET_PRICE					FLOAT
						,	DISCOUNT_GUESTBOOK_PRICE				FLOAT
						,	DISCOUNT_LINING_ENV_PRICE				FLOAT
						, 	DISCOUNT_FLOWER_PRICE					FLOAT
						,	DISCOUNT_SEALING_STICKER_PRICE			FLOAT
						,	DISCOUNT_ENVSPECIAL_PRICE				FLOAT
						,	DISCOUNT_RIBBON_PRICE					FLOAT
						,	DISCOUNT_PAPERCOVER_PRICE				FLOAT
						,	DISCOUNT_PRINT_PRICE					FLOAT
						,	DISCOUNT_EMBO_PRICE						FLOAT
						,	DISCOUNT_JEBON_PRICE					FLOAT
						,	DISCOUNT_ENVINSERT_PRICE				FLOAT
						,	DISCOUNT_DELIVERY_PRICE					FLOAT
						,	DISCOUNT_EXPRESS_SHIPPING_PRICE			FLOAT
						,	DISCOUNT_LININGJAEBON_PRICE				FLOAT
						,	DISCOUNT_TOTAL_PRICE					INT
						)


		-- 테이블에 INSERT
		INSERT #TempTable EXEC SP_EXEC_COUPON_CALC_FOR_CO @P_UID, @P_ORDER_SEQ, '', @P_VERIFICATION_COUPON_DETAIL_SEQ_LIST, @P_DEVICE_TYPE
			
		-- 선택한 쿠폰의 합계금액 추출
		DECLARE	@P_TOTAL_PRICE	INT
		SET @P_TOTAL_PRICE = (
								SELECT	LAST_TOTAL_PRICE - DISCOUNT_TOTAL_PRICE AS P_TOTAL_PRICE
								FROM	(
											SELECT	SUM(DISCOUNT_TOTAL_PRICE) DISCOUNT_TOTAL_PRICE
												,	MIN(LAST_TOTAL_PRICE) LAST_TOTAL_PRICE
												,	GROUPING(DISCOUNT_TOTAL_PRICE) DTP
											FROM	#TempTable
											GROUP BY 
													DISCOUNT_TOTAL_PRICE WITH ROLLUP
										)	A
								WHERE	DTP = 1
		)

		-- 실제 결제된 SETTLE_PRICE 비교
		SELECT @P_TOTAL_PRICE P_TOTAL_PRICE

		SELECT @P_SETTLE_PRICE P_SETTLE_PRICE
			
		DECLARE @P_REDUCE_PRICE	INT
		SET @P_REDUCE_PRICE = (SELECT SUM(DISCOUNT_TOTAL_PRICE) DISCOUNT_TOTAL_PRICE FROM #TempTable)

		SELECT @P_REDUCE_PRICE P_REDUCE_PRICE

		DROP TABLE #TempTable

		END
END
GO
