IF OBJECT_ID (N'dbo.SP_INSERT_FREE_GIFT_temp', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_FREE_GIFT_temp
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT * FROM S2_CARD_FREE_GIFT
SELECT * FROM S2_CARD_FREE_GIFT_LOG

EXEC SP_INSERT_FREE_GIFT_temp 2175735

*/

CREATE PROCEDURE [dbo].[SP_INSERT_FREE_GIFT_temp]
    @ORDER_SEQ                  AS INT

AS
BEGIN

DECLARE @FREE_GIFT_SEQ AS INT
DECLARE @FREE_GIFT_CARD_SEQ AS INT
DECLARE @TOTAL_QTY AS INT
DECLARE @COMPANY_SEQ AS INT
DECLARE @UID AS VARCHAR(50)
DECLARE @FREE_GIFT_TARGET_YORN AS CHAR(1)


SET @FREE_GIFT_SEQ = 0

SELECT  TOP 1 
        @FREE_GIFT_SEQ = ISNULL(SCFG.FREE_GIFT_SEQ, 0)
    ,   @FREE_GIFT_CARD_SEQ = ISNULL(SCFG.CARD_SEQ, 0)
    ,   @UID = ISNULL(CO.MEMBER_ID, '')
FROM    S2_CARD_FREE_GIFT SCFG
JOIN    CUSTOM_ORDER CO 
	ON CO.SALES_GUBUN = SCFG.SALES_GUBUN
		AND     SCFG.START_DATE <= GETDATE()
		AND     SCFG.END_DATE >= GETDATE()
		AND     SCFG.USE_YORN = 'Y'
		AND     SCFG.QTY > 0
		AND		CHARINDEX(CO.ORDER_TYPE, SCFG.LIMIT_ORDER_TYPE_STR, 1 ) > 0

WHERE   1 = 1
AND     CO.ORDER_SEQ = @ORDER_SEQ
AND     CO.UP_ORDER_SEQ IS NULL
AND     ISNULL(SCFG.LIMIT_ORDER_PRICE, 0) <= ISNULL(CO.SETTLE_PRICE, 0)
AND     ISNULL(SCFG.LIMIT_ORDER_COUNT, 0) <= ISNULL(CO.ORDER_COUNT, 0)


IF @FREE_GIFT_SEQ > 0 
    BEGIN

        IF NOT EXISTS(SELECT * FROM CUSTOM_ORDER_ITEM WHERE ORDER_SEQ = @ORDER_SEQ AND CARD_SEQ = @FREE_GIFT_CARD_SEQ)
            BEGIN
                
                SET @FREE_GIFT_TARGET_YORN = 'N'
                IF EXISTS(SELECT TOP 1 CARD_SEQ FROM S2_CARD_FREE_GIFT_TARGET_CARD WHERE FREE_GIFT_SEQ = @FREE_GIFT_SEQ)
                    BEGIN
                        
                        IF  EXISTS  (
                                        SELECT  TOP 1 SCFGTC.CARD_SEQ 
                                        FROM    S2_CARD_FREE_GIFT_TARGET_CARD SCFGTC
                                        JOIN    CUSTOM_ORDER CO ON SCFGTC.CARD_SEQ = CO.CARD_SEQ
                                        WHERE   1 = 1
                                        AND     SCFGTC.FREE_GIFT_SEQ = @FREE_GIFT_SEQ
                                        AND     CO.ORDER_SEQ = @ORDER_SEQ
                                    )
                            BEGIN
                                
                                SET @FREE_GIFT_TARGET_YORN = 'Y'

                            END
                        ELSE
                            BEGIN
                                
                                SET @FREE_GIFT_TARGET_YORN = 'N'

                            END

                    END
                ELSE
                    BEGIN
                        
                        SET @FREE_GIFT_TARGET_YORN = 'Y'

                    END

				select @FREE_GIFT_TARGET_YORN
                
                --IF @FREE_GIFT_TARGET_YORN = 'Y' 
                --    BEGIN

                --        INSERT INTO CUSTOM_ORDER_ITEM (ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE, ITEM_SALE_PRICE, DISCOUNT_RATE, MEMO1, ADDNUM_PRICE)
		              --  VALUES (@ORDER_SEQ, @FREE_GIFT_CARD_SEQ, 'H', 1, 0, 0, 0, '', 0)

                --        INSERT INTO S2_CARD_FREE_GIFT_LOG (FREE_GIFT_SEQ, CARD_SEQ, ORDER_SEQ, UID)
                --        VALUES (@FREE_GIFT_SEQ, @FREE_GIFT_CARD_SEQ, @ORDER_SEQ, @UID)

                --        UPDATE  S2_CARD_FREE_GIFT
                --        SET     QTY = QTY - 1
                --        WHERE   FREE_GIFT_SEQ = @FREE_GIFT_SEQ

                --    END

            END

    END

END

GO
