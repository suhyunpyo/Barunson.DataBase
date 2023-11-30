IF OBJECT_ID (N'dbo.SP_INSERT_COUPON_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_COUPON_EVENT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

BRSTYP16012530000
BRSP16012530000


SELECT * FROM S4_MYCOUPON WHERE UID = 's4guest' ORDER BY REG_DATE DESC

SELECT * FROM S4_MD_CHOICE WHERE MD_SEQ = 393

EXEC SP_INSERT_COUPON_EVENT 2285633

SELECT * FROM S4_MD_CHOICE WHERE MD_SEQ = 393 AND VIEW_DIV = 'Y' AND CARD_SEQ = 35460

*/

CREATE PROCEDURE [dbo].[SP_INSERT_COUPON_EVENT]
    @P_ORDER_SEQ					AS INT

AS
BEGIN



	DECLARE		@COMPANY_SEQ					AS INT			= 0
	DECLARE		@CARD_SEQ						AS INT			= 0
	DECLARE		@ORDER_COUNT					AS INT			= 0
	DECLARE		@CARD_CODE						AS VARCHAR(20)	= ''
	DECLARE		@UID							AS VARCHAR(50)	= ''
	DECLARE		@COUPON_CODE					AS VARCHAR(50)	= ''
	DECLARE		@END_DATE						AS VARCHAR(50)	= ''
	DECLARE		@STATUS_SEQ						AS INT			= 0

	SELECT	@COMPANY_SEQ	= CO.COMPANY_SEQ
		,	@CARD_SEQ		= CO.CARD_SEQ
		,	@CARD_CODE		= SC.CARD_CODE
		,	@ORDER_COUNT	= ISNULL(CO.ORDER_COUNT, 0)
		,	@UID			= ISNULL(CO.MEMBER_ID, '')
		,	@STATUS_SEQ		= isnull(STATUS_SEQ, 0)
	FROM	CUSTOM_ORDER	CO
	JOIN	S2_CARD	SC ON CO.CARD_SEQ = SC.CARD_SEQ
	WHERE	1 = 1
	AND		CO.ORDER_SEQ = @P_ORDER_SEQ



	/* 바른손카드 신상품 출시 이벤트  - 160125 */
	/* 비핸즈카드 신상품 출시 이벤트  - 170105 */
	IF @COMPANY_SEQ = 5006 AND @ORDER_COUNT >= 400 AND @UID <> '' AND GETDATE() >= '2017-01-09 00:00:00' AND GETDATE() <= '2017-02-23 23:59:59' AND @STATUS_SEQ = 1
	
	
	BEGIN
		
		/* 각 카드당 10번째 구매자 까지만 지급 */
		/* 원차장님 추가 요청 - 최초 10건 구매시에 대한 조건 제외 */
		--IF (SELECT COUNT(*) FROM CUSTOM_ORDER WHERE CARD_SEQ = @CARD_SEQ AND UP_ORDER_SEQ IS NULL AND COMPANY_SEQ = 5001 AND SETTLE_STATUS = 2) < 11
		--BEGIN

			/* 해당 카드가 종료 되었는지 확인 */
			IF EXISTS(SELECT * FROM S4_MD_CHOICE WHERE MD_SEQ = 472 AND VIEW_DIV = 'Y' AND CARD_SEQ = @CARD_SEQ)
			BEGIN

				SET @COUPON_CODE	= 'BHRTP1EVT30000'
				SET @END_DATE		= '2017-02-28'
				IF NOT EXISTS(SELECT * FROM S4_MYCOUPON WHERE UID = @UID AND COUPON_CODE = @COUPON_CODE)
				BEGIN
		
					INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, @COMPANY_SEQ, 'Y', @END_DATE)

				END

				SET @COUPON_CODE	= 'BHRTP6EVT30000'
				SET @END_DATE		= '2017-02-28'
				IF NOT EXISTS(SELECT * FROM S4_MYCOUPON WHERE UID = @UID AND COUPON_CODE = @COUPON_CODE)
				BEGIN
		
					INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, @COMPANY_SEQ, 'Y', @END_DATE)

				END

			END

		--END

	END



END

GO
