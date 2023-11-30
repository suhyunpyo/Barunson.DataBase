IF OBJECT_ID (N'dbo.SP_EXEC_CREATE_DIRECTIONS_TITLE_FOR_REORDER', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_CREATE_DIRECTIONS_TITLE_FOR_REORDER
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*


*/
CREATE PROCEDURE [dbo].[SP_EXEC_CREATE_DIRECTIONS_TITLE_FOR_REORDER]
    @TITLE AS VARCHAR(20)
,   @ORDER_SEQ AS INT
AS
BEGIN


SELECT  ISNULL(

(
    SELECT  ETC1
    FROM    CUSTOM_ORDER_COPY_DETAIL COCD
    JOIN    (
                SELECT  ISNULL  (
                                    (
                                        SELECT  ISNULL  (
                                                            (
                                                                SELECT  ISNULL  (
                                                                                    (
                                                                                        SELECT  ISNULL  (
                                                                                                            (
                                                                                                                SELECT  ISNULL  (
                                                                                                                                (
                                                                                                                                    SELECT  ISNULL(CO5.UP_ORDER_SEQ, CO5.ORDER_SEQ)
                                                                                                                                    FROM    CUSTOM_ORDER CO5
                                                                                                                                    WHERE   CO5.ORDER_SEQ = CO4.UP_ORDER_SEQ
                                                                                                                                )
                                                                                                                                , CO4.ORDER_SEQ
                                                                                                                            ) 
                                                                                                                FROM    CUSTOM_ORDER CO4 
                                                                                                                WHERE   CO4.ORDER_SEQ = CO3.UP_ORDER_SEQ
                                                                                                            )
                                                                                                            , CO3.ORDER_SEQ
                                                                                                        )
                                                                                        FROM    CUSTOM_ORDER CO3
                                                                                        WHERE   CO3.ORDER_SEQ = CO2.UP_ORDER_SEQ
                                                                                    )
                                                                                    , CO2.ORDER_SEQ
                                                                                ) 
                                                                FROM    CUSTOM_ORDER CO2 
                                                                WHERE   CO2.ORDER_SEQ = CO1.UP_ORDER_SEQ
                                                            )
                                                            , CO1.ORDER_SEQ
                                                        )
                                        FROM    CUSTOM_ORDER CO1
                                        WHERE   CO1.ORDER_SEQ = CO.UP_ORDER_SEQ
                                    )
                                    , CO.UP_ORDER_SEQ
                                ) AS ORDER_SEQ


       
                FROM    CUSTOM_ORDER CO

                WHERE   1 = 1
        
                AND     CO.ORDER_ADD_FLAG = 0
                AND     CO.ORDER_SEQ = @ORDER_SEQ
                AND     CO.UP_ORDER_SEQ IS NOT NULL
            ) OS ON COCD.ORDER_SEQ = OS.ORDER_SEQ

    AND     RTRIM(LTRIM(ITEM_TITLE)) = RTRIM(LTRIM(@TITLE))
    AND     DELIVERY_SEQ = 1
)
    
    , '') AS ETC1

END


GO
