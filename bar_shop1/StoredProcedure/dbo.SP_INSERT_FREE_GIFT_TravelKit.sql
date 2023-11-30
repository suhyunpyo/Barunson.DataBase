IF OBJECT_ID (N'dbo.SP_INSERT_FREE_GIFT_TravelKit', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_FREE_GIFT_TravelKit
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S2_CARD_FREE_GIFT
SELECT * FROM S2_CARD_FREE_GIFT_LOG

SELECT  *
FROM    CUSTOM_ORDER_ITEM 
WHERE   ORDER_SEQ = 2180316

DELETE CUSTOM_ORDER_ITEM WHERE ORDER_SEQ = 2180316 AND CARD_SEQ = 35488

EXEC SP_INSERT_FREE_GIFT_TEST 2180316
EXEC SP_INSERT_FREE_GIFT 2180316


SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_DEFINITION LIKE '%split%'
        AND ROUTINE_TYPE='PROCEDURE'
        order by ROUTINE_NAME

 2018.04.10 비핸즈 신상카드 구매시 SKINRx_Travel Kit Kit 증정
*/

CREATE PROCEDURE [dbo].[SP_INSERT_FREE_GIFT_TravelKit]
    @ORDER_SEQ                  AS INT

AS
BEGIN

DECLARE @FREE_GIFT_SEQ AS INT = 0
DECLARE @FREE_GIFT_CARD_SEQ AS INT = 0
DECLARE @FREE_GIFT_ITEM_TYPE AS VARCHAR(2) = ''
DECLARE @TOTAL_QTY AS INT = 0
DECLARE @COMPANY_SEQ AS INT = 0
DECLARE @UID AS VARCHAR(50) = ''
DECLARE @FREE_GIFT_TARGET_YORN AS CHAR(1) = ''
DECLARE @LIMIT_DELIVERY_REGION_STR AS VARCHAR(500) = ''
DECLARE @LIMIT_DELIVERY_GU_STR AS VARCHAR(500) = ''

DECLARE @MAX_CNT AS INT = 0
DECLARE @i AS INT = 1

DECLARE @EVENT_REPLY_CNT AS INT = 0
DECLARE @SALES_GUBUN AS VARCHAR(50) = ''
DECLARE @MEMBER_ID AS VARCHAR(50) = ''
DECLARE @FLOW AS INT = 0;
DECLARE @ORDER_CNT AS INT = 0

SELECT		@SALES_GUBUN = SALES_GUBUN
		,	@MEMBER_ID   = MEMBER_ID
FROM	CUSTOM_ORDER
WHERE	ORDER_SEQ = @ORDER_SEQ

SELECT  @MAX_CNT = ISNULL(COUNT(*), 0)

FROM    S2_CARD_FREE_GIFT SCFG
JOIN    CUSTOM_ORDER CO 
	ON CO.SALES_GUBUN IN (SELECT value FROM dbo.[ufn_SplitTable] (SCFG.SALES_GUBUN, '|'))
		AND     SCFG.START_DATE <= GETDATE()
		AND     SCFG.END_DATE >= GETDATE()
		AND     SCFG.USE_YORN = 'Y'
		AND     SCFG.QTY > 0
		AND		(SCFG.LIMIT_ORDER_TYPE_STR = '' or CHARINDEX(CO.ORDER_TYPE, SCFG.LIMIT_ORDER_TYPE_STR, 1 ) > 0)
WHERE   CO.ORDER_SEQ = @ORDER_SEQ
AND     CO.UP_ORDER_SEQ IS NULL
AND     ISNULL(SCFG.LIMIT_ORDER_PRICE, 0) <= ISNULL(CO.SETTLE_PRICE, 0)
AND     ISNULL(SCFG.LIMIT_ORDER_COUNT, 0) <= ISNULL(CO.ORDER_COUNT, 0)
AND		FREE_GIFT_SEQ = 67



WHILE @i <= @MAX_CNT
BEGIN

    SELECT  @FREE_GIFT_SEQ              = A.FREE_GIFT_SEQ
        ,   @FREE_GIFT_CARD_SEQ         = A.FREE_GIFT_CARD_SEQ
        ,   @UID                        = A.UID
        ,   @LIMIT_DELIVERY_REGION_STR  = A.LIMIT_DELIVERY_REGION_STR
	,   @LIMIT_DELIVERY_GU_STR	= A.LIMIT_DELIVERY_GU_STR
        ,   @FREE_GIFT_ITEM_TYPE        = A.FREE_GIFT_ITEM_TYPE  
    FROM    (
                SELECT  ROW_NUMBER() OVER(ORDER BY REG_DATE ASC) AS ROWNUM
                    ,   ISNULL(SCFG.FREE_GIFT_SEQ, 0) AS FREE_GIFT_SEQ
                    ,   ISNULL(SCFG.CARD_SEQ, 0) AS FREE_GIFT_CARD_SEQ
                    ,   ISNULL(CO.MEMBER_ID, '') AS UID
                    ,   ISNULL(SCFG.LIMIT_DELIVERY_REGION_STR, '') AS LIMIT_DELIVERY_REGION_STR
                    ,   ISNULL(SCFG.LIMIT_DELIVERY_GU_STR, '') AS LIMIT_DELIVERY_GU_STR
                    ,   ISNULL(SCFG.ITEM_TYPE, '') AS FREE_GIFT_ITEM_TYPE
                FROM    S2_CARD_FREE_GIFT SCFG
                JOIN    CUSTOM_ORDER CO 
	                ON CO.SALES_GUBUN IN (SELECT value FROM dbo.[ufn_SplitTable] (SCFG.SALES_GUBUN, '|'))
		                AND     SCFG.START_DATE <= GETDATE()
		                AND     SCFG.END_DATE >= GETDATE()
		                AND     SCFG.USE_YORN = 'Y'
		                AND     SCFG.QTY > 0
						AND		SCFG.FREE_GIFT_SEQ = 67
		                AND		(SCFG.LIMIT_ORDER_TYPE_STR = '' or CHARINDEX(CO.ORDER_TYPE, SCFG.LIMIT_ORDER_TYPE_STR, 1 ) > 0)

                WHERE   1 = 1
                AND     CO.ORDER_SEQ = @ORDER_SEQ
                AND     CO.UP_ORDER_SEQ IS NULL
                AND     ISNULL(SCFG.LIMIT_ORDER_PRICE, 0) <= ISNULL(CO.SETTLE_PRICE, 0)
                AND     ISNULL(SCFG.LIMIT_ORDER_COUNT, 0) <= ISNULL(CO.ORDER_COUNT, 0)
            ) A
    WHERE   A.ROWNUM = @i

        
        
    IF NOT EXISTS(SELECT * FROM CUSTOM_ORDER_ITEM WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @FREE_GIFT_CARD_SEQ)
    
    BEGIN
		
		-- SKINRx_Travel Kit 증정
		IF @FREE_GIFT_CARD_SEQ = '36662'
 
			BEGIN

				INSERT INTO CUSTOM_ORDER_ITEM (ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE, ITEM_SALE_PRICE, DISCOUNT_RATE, MEMO1, ADDNUM_PRICE)
				VALUES (@ORDER_SEQ, @FREE_GIFT_CARD_SEQ, @FREE_GIFT_ITEM_TYPE, 1, 0, 0, 0, '', 0)

				INSERT INTO S2_CARD_FREE_GIFT_LOG (FREE_GIFT_SEQ, CARD_SEQ, ORDER_SEQ, UID)
				VALUES (@FREE_GIFT_SEQ, @FREE_GIFT_CARD_SEQ, @ORDER_SEQ, @UID)

				UPDATE  S2_CARD_FREE_GIFT
				SET     QTY = QTY - 1
				WHERE   FREE_GIFT_SEQ = @FREE_GIFT_SEQ

			END

    END --END

    SET @i = @i + 1
	
END


END
GO