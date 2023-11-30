IF OBJECT_ID (N'dbo.SP_MD_GIFT_EVENT_CHANEL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MD_GIFT_EVENT_CHANEL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2017-09-29
-- Description:	바/비/더 사은품 or 쿠폰 이벤트 (옥승D)

-- EXEC 회원아이디, 주문번호, 사은품
-- EXEC dbo.[SP_MD_GIFT_EVENT_CHANEL] 's4guest', 2542396, 'CECE16004'
-- EXEC dbo.[SP_MD_GIFT_EVENT_CHANEL] 's4guest', 2542396, 'CEJA16002'
-- EXEC dbo.[SP_MD_GIFT_EVENT_CHANEL] 's4guest', 2542396, 'CEKI16001'
-- EXEC dbo.[SP_MD_GIFT_EVENT_CHANEL] 's4guest', 2542396, 'CEWA15006'
-- EXEC dbo.[SP_MD_GIFT_EVENT_CHANEL] 's4guest', 2542396, 'COUPON'

-- =============================================

CREATE PROCEDURE [dbo].[SP_MD_GIFT_EVENT_CHANEL]
	@UID								AS VARCHAR(50),        
	@ORDER_SEQ							AS INT,
	@CARD_CODE							AS VARCHAR(50)
AS
BEGIN
	
    SET NOCOUNT ON;

    DECLARE		@RESULT_CODE		AS	VARCHAR(4)	= '0000'
		,		@RESULT_MESSAGE		AS	VARCHAR(500)	= ''

	DECLARE		@GIFT_CNT			AS	INT
	
	-- 회원아이디로 나간 사은품 or 쿠폰이 있는 지 확인
	SELECT	@GIFT_CNT = SUM(A.CNT)
	FROM	(
				SELECT	COUNT(*) AS CNT
				FROM	CUSTOM_ORDER_ITEM COI
						LEFT JOIN CUSTOM_ORDER CO ON CO.ORDER_SEQ = COI.ORDER_SEQ
				WHERE	COI.CARD_SEQ IN (36432,36433,36434,36435,36440,36441)
				AND		CO.SETTLE_STATUS = 2
				AND		CO.MEMBER_ID = @UID
				  
				UNION ALL

				SELECT	COUNT(*) AS CNT
				FROM	COUPON_ISSUE
				WHERE	UID = @UID
				AND		COUPON_DETAIL_SEQ = 40857
			) 
			AS A

	
	IF	@GIFT_CNT > 0 

	BEGIN
		SET @RESULT_CODE	= '9999'
		SET @RESULT_MESSAGE = '이미 발급받았습니다.'		
	END

	ELSE -- 없다면 쿠폰 or 사은품으로 발급해서 custom_order_item / coupon_issue 에 넣어주고
	
	BEGIN

		IF @CARD_CODE = 'COUPON'	-- 쿠폰일경우
		BEGIN

			DECLARE		@COUPON_CODE	AS	VARCHAR(100) = '28F8-90D3-4144-9298'
				,		@COMPANY_SEQ	AS	INT
				,		@SALES_GUBUN	AS	VARCHAR(2)

			SELECT		@SALES_GUBUN = SALES_GUBUN
				,		@COMPANY_SEQ = COMPANY_SEQ
			FROM		CUSTOM_ORDER
			WHERE		ORDER_SEQ = @ORDER_SEQ
			AND			MEMBER_ID = @UID

			EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ,	@SALES_GUBUN, @UID, @COUPON_CODE
		END

		ELSE			-- 사은품일경우

		BEGIN
			
			DECLARE		@CARD_SEQ	AS	INT
				,		@CARD_NAME	AS	VARCHAR(50)
				,		@ITEM_CNT	AS	iNT

			SELECT		@CARD_SEQ = CARD_SEQ
				,		@CARD_NAME = CARD_NAME		
			FROM		MD_GIFT_EVENT_CHANEL
			WHERE		CARD_CODE = @CARD_CODE

			IF @CARD_SEQ = 36440
				BEGIN
					SET @ITEM_CNT = 2
				END
			ELSE
				BEGIN
					SET @ITEM_CNT = 1
				END 

			INSERT INTO CUSTOM_ORDER_ITEM (ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE, ITEM_SALE_PRICE, DISCOUNT_RATE, MEMO1, ADDNUM_PRICE)
			VALUES (@ORDER_SEQ, @CARD_SEQ, 'Z', @ITEM_CNT, 0, 0, 0, '', 0)

			UPDATE  MD_GIFT_EVENT_CHANEL
			SET     REMAIN_CNT = REMAIN_CNT - 1
			WHERE   CARD_CODE = @CARD_CODE

		END

		SET @RESULT_CODE	= '0000'
		SET @RESULT_MESSAGE = '발급되었습니다.'	

	END

    SELECT  @RESULT_CODE	AS RESULT_CODE
		,	@RESULT_MESSAGE AS RESULT_MESSAGE

END

GO
