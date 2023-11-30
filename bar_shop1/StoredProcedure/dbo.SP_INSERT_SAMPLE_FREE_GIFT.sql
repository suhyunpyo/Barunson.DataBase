IF OBJECT_ID (N'dbo.SP_INSERT_SAMPLE_FREE_GIFT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_SAMPLE_FREE_GIFT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC SP_INSERT_SAMPLE_FREE_GIFT 1068965, 5001

*/

/****************************************************************************************************************
-- SP Name       : SP_INSERT_SAMPLE_FREE_GIFT
-- Author        : 박혜림
-- Create date   : 2023-06-16
-- Description   : 샘플구매 무료 증정
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_INSERT_SAMPLE_FREE_GIFT]
    @ORDER_SEQ        AS INT,
    @COMPANY_G_SEQ    AS INT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000


----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @FREE_GIFT_SEQ INT
DECLARE @FREE_GIFT_CARD_SEQ INT
DECLARE @FREE_GIFT_ITEM_TYPE VARCHAR(2)
DECLARE @TOTAL_QTY INT
DECLARE @COMPANY_SEQ INT
DECLARE @UID VARCHAR(50)
DECLARE @WeddingHall CHAR(1)
DECLARE @site_div VARCHAR(2)
DECLARE @SALES_GUBUN VARCHAR(2)
DECLARE @ORDER_G_SEQ INT
DECLARE @CARD_CODE VARCHAR(20)
DECLARE @EcoCardYn BIT
DECLARE @LIMIT_ORDER_PRICE INT
DECLARE @LIMIT_ORDER_COUNT INT
DECLARE @LIMIT_DELIVERY_REGION_STR VARCHAR(500)

DECLARE @MAX_CNT INT
DECLARE @i INT

DECLARE @CARD_CNT_1 INT
DECLARE @CARD_CNT_3 INT
DECLARE @DELIVERY_REGION_MATCHING_CNT INT

DECLARE @FREE_GIFT_TARGET_CHK_1 CHAR(1)
      , @FREE_GIFT_TARGET_CHK_2 CHAR(1)
	  , @FREE_GIFT_TARGET_CHK_3 CHAR(1)
	  , @FREE_GIFT_TARGET_CHK_4 CHAR(1)

SET @FREE_GIFT_SEQ = 0
SET @FREE_GIFT_CARD_SEQ = 0
SET @FREE_GIFT_ITEM_TYPE = ''
SET @TOTAL_QTY = 0
SET @COMPANY_SEQ = 0
SET @UID = ''
SET @WeddingHall = ''
SET @site_div = ''
SET @SALES_GUBUN = ''
SET @ORDER_G_SEQ = 0
SET @CARD_CODE = ''
SET @EcoCardYn = 0
SET @LIMIT_ORDER_PRICE = 0
SET @LIMIT_ORDER_COUNT = 0
SET @LIMIT_DELIVERY_REGION_STR = ''

SET @MAX_CNT = 0
SET @i = 1

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	
	SELECT @SALES_GUBUN = SALES_GUBUN
	     , @UID = MEMBER_ID
	  FROM CUSTOM_SAMPLE_ORDER
	 WHERE SAMPLE_ORDER_SEQ = @ORDER_SEQ
		AND SampleFreeParentSeq IS NULL

	IF @SALES_GUBUN = 'C' OR @SALES_GUBUN = 'H' 
	BEGIN 
		SET @SALES_GUBUN = 'B'
	END

	SELECT @MAX_CNT = ISNULL(COUNT(*), 0)
	  FROM S2_CARD_SAMPLE_FREE_GIFT SCFG
	 WHERE SCFG.SALES_GUBUN = @SALES_GUBUN 
	   AND SCFG.START_DATE <= GETDATE()
	   AND SCFG.END_DATE >= GETDATE()
	   AND SCFG.USE_YORN = 'Y'
	   AND SCFG.QTY > 0  
	

	WHILE @i <= @MAX_CNT
	BEGIN
	
		-- 초기화
		SET @CARD_CNT_1 = 0
		SET @CARD_CNT_3 = 0
		SET @DELIVERY_REGION_MATCHING_CNT = 0
		SET @FREE_GIFT_TARGET_CHK_1 = 'Y'	-- 친환경 상품 주문여부 체크
		SET @FREE_GIFT_TARGET_CHK_2 = 'Y'	-- 예식장 구분 체크
		SET @FREE_GIFT_TARGET_CHK_3 = 'Y'	-- 단가&수량제한 체크
		SET @FREE_GIFT_TARGET_CHK_4 = 'Y'	-- 배송지역 제한


		SELECT @FREE_GIFT_SEQ             = A.FREE_GIFT_SEQ
			 , @FREE_GIFT_CARD_SEQ        = A.FREE_GIFT_CARD_SEQ
			 , @CARD_CODE                 = A.CARD_CODE
			 , @WeddingHall               = A.WeddingHall
			 , @site_div                  = A.site_div
			 , @FREE_GIFT_ITEM_TYPE       = A.FREE_GIFT_ITEM_TYPE
			 , @EcoCardYn                 = A.EcoCardYn
			 , @LIMIT_ORDER_PRICE         = A.LIMIT_ORDER_PRICE
			 , @LIMIT_ORDER_COUNT         = A.LIMIT_ORDER_COUNT
			 , @LIMIT_DELIVERY_REGION_STR = A.LIMIT_DELIVERY_REGION_STR
		FROM    (
					SELECT ROW_NUMBER() OVER(ORDER BY REG_DATE ASC) AS ROWNUM
						 , ISNULL(FREE_GIFT_SEQ, 0)                 AS FREE_GIFT_SEQ
						 , ISNULL(CARD_SEQ, 0)                      AS FREE_GIFT_CARD_SEQ
						 , ISNULL(CARD_CODE, '')                    AS CARD_CODE
						 , ISNULL(WeddingHall, '')                  AS WeddingHall
						 , ISNULL(SALES_GUBUN, '')                  AS site_div
						 , ISNULL(ITEM_TYPE, '')                    AS FREE_GIFT_ITEM_TYPE
						 , ISNULL(EcoCardYn, 0)                     AS EcoCardYn
						 , LIMIT_ORDER_PRICE                        AS LIMIT_ORDER_PRICE
						 , LIMIT_ORDER_COUNT			            AS LIMIT_ORDER_COUNT
						 , ISNULL(LIMIT_DELIVERY_REGION_STR, '')    AS LIMIT_DELIVERY_REGION_STR
					 FROM S2_CARD_SAMPLE_FREE_GIFT WITH(NOLOCK)
					WHERE SALES_GUBUN = @SALES_GUBUN
					  AND [START_DATE] <= GETDATE()
					  AND END_DATE >= GETDATE()
					  AND USE_YORN = 'Y'
					  AND QTY > 0

				) A
		WHERE A.ROWNUM = @i
        
        
		IF NOT EXISTS(SELECT * FROM CUSTOM_SAMPLE_ORDER_ITEM WHERE SAMPLE_ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @FREE_GIFT_CARD_SEQ)
		BEGIN

			------------------------------------------------------
			-- 친환경 상품 주문여부 체크(@FREE_GIFT_TARGET_CHK_1)
			------------------------------------------------------
			IF @EcoCardYn = 1
			BEGIN
				SELECT @CARD_CNT_1 = COUNT(*)
				  FROM CUSTOM_SAMPLE_ORDER_ITEM AS T1 WITH(NOLOCK)
				 INNER JOIN S2_CARD             AS T2 WITH(NOLOCK) ON (T1.CARD_SEQ = T2.Card_Seq AND T2.DISPLAY_YORN = 'Y')
				 INNER JOIN EVT_LEAFLET_CARD    AS T3 WITH(NOLOCK) ON (T2.Card_Code = T3.card_code)
				 WHERE T1.SAMPLE_ORDER_SEQ = @ORDER_SEQ

				 IF @CARD_CNT_1 > 0
				 BEGIN
					SET @FREE_GIFT_TARGET_CHK_1 = 'Y'
				 END
				 ELSE
				 BEGIN
					SET @FREE_GIFT_TARGET_CHK_1 = 'N'
				 END
			END

			------------------------------------------------------
			-- 예식장 구분 체크(@FREE_GIFT_TARGET_CHK_2)
			------------------------------------------------------
			IF @WeddingHall IS NOT NULL AND @WeddingHall <> ''
			BEGIN
				IF (@UID <> '' AND @WeddingHall = (SELECT TOP 1 WEDDING_HALL FROM VW_USER_INFO WHERE [uid] = @UID AND site_div = @SALES_GUBUN))
				BEGIN
					SET @FREE_GIFT_TARGET_CHK_2 = 'Y'
				END
				ELSE
				BEGIN
					SET @FREE_GIFT_TARGET_CHK_2 = 'N'
				END
			END

			------------------------------------------------------
			-- 단가&수량 제한 체크 (@FREE_GIFT_TARGET_CHK_3)
			------------------------------------------------------
			IF @LIMIT_ORDER_PRICE > 0 AND @LIMIT_ORDER_COUNT > 0
			BEGIN
			
				SELECT @CARD_CNT_3 = COUNT(*)
				  FROM CUSTOM_SAMPLE_ORDER_ITEM AS T1 WITH(NOLOCK)
				 INNER JOIN S2_CARD             AS T2 WITH(NOLOCK) ON (T1.CARD_SEQ = T2.Card_Seq AND T2.DISPLAY_YORN = 'Y' AND CardSet_Price >= @LIMIT_ORDER_PRICE)
				 WHERE T1.SAMPLE_ORDER_SEQ = @ORDER_SEQ

				IF @CARD_CNT_3 >= @LIMIT_ORDER_COUNT
				BEGIN
					SET @FREE_GIFT_TARGET_CHK_3 = 'Y'
				END
				ELSE
				BEGIN
					SET @FREE_GIFT_TARGET_CHK_3 = 'N'
				END
			END


			------------------------------------------------------
			-- 배송지역 제한 체크 (@@FREE_GIFT_TARGET_CHK_4)
			------------------------------------------------------
			IF @LIMIT_DELIVERY_REGION_STR <> ''
			BEGIN

				SELECT IndexNo
					 , Value AS DeliveryRegion
				  INTO #TempDeliveryRegion
				  FROM bar_shop1.dbo.SplitTableStr(@LIMIT_DELIVERY_REGION_STR, '|')

				SELECT @DELIVERY_REGION_MATCHING_CNT = COUNT(*)
				  FROM CUSTOM_SAMPLE_ORDER      AS T1 WITH(NOLOCK)
				 INNER JOIN #TempDeliveryRegion AS T2 ON(T2.DeliveryRegion = LEFT(T1.MEMBER_ADDRESS, 2))
				 WHERE T1.SAMPLE_ORDER_SEQ = @ORDER_SEQ

				IF @DELIVERY_REGION_MATCHING_CNT > 0
				BEGIN
					SET @FREE_GIFT_TARGET_CHK_4 = 'Y'
				END
				ELSE
				BEGIN
					SET @FREE_GIFT_TARGET_CHK_4 = 'N'
				END

				DROP TABLE #TempDeliveryRegion

			END

			------------------------------------------------------
			-- 증정품 지급(모두 해당되는 경우 발급)
			------------------------------------------------------
			IF @FREE_GIFT_TARGET_CHK_1 = 'Y' AND @FREE_GIFT_TARGET_CHK_2 = 'Y' AND @FREE_GIFT_TARGET_CHK_3 = 'Y' AND @FREE_GIFT_TARGET_CHK_4 = 'Y'
			BEGIN
				-- 지시서에 나오지 않도록, ischu = 9 로 만든다
				INSERT INTO CUSTOM_SAMPLE_ORDER_ITEM (CARD_SEQ, SAMPLE_ORDER_SEQ, CARD_PRICE, REG_DATE, isChu, md_recommend)
				VALUES ( @FREE_GIFT_CARD_SEQ, @ORDER_SEQ, 0, GETDATE(), 9, 'N')
						
				UPDATE  S2_CARD_SAMPLE_FREE_GIFT
				SET     QTY = QTY - 1
				WHERE   FREE_GIFT_SEQ = @FREE_GIFT_SEQ
			END


		END

		SET @i = @i + 1

	END

END