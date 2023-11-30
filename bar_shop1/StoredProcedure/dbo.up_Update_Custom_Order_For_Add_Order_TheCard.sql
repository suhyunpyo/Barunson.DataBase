IF OBJECT_ID (N'dbo.up_Update_Custom_Order_For_Add_Order_TheCard', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Update_Custom_Order_For_Add_Order_TheCard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT  ORDER_SEQ, order_g_seq, UP_ORDER_SEQ, ORDER_ADD_FLAG, STATUS_SEQ, SRC_COMPOSE_DATE, SRC_COMPOSE_MOD_DATE, SRC_CONFIRM_DATE
    ,   * 
FROM    CUSTOM_ORDER 
WHERE   order_seq = 2319089 

SELECT  * 
FROM    CUSTOM_ORDER 
WHERE   1 = 1 
AND     COMPANY_SEQ = 5007 
AND     STATUS_SEQ <= 7 
AND     STATUS_SEQ <> 3
AND     SETTLE_STATUS = 2 
AND     ORDER_ADD_FLAG = 0 
AND     UP_ORDER_SEQ IS NOT NULL 
--AND     ORDER_DATE >= '2015-07-01' 

UPDATE CUSTOM_ORDER SET STATUS_SEQ = 9
WHERE   order_seq = 2198077 

EXEC up_Update_Custom_Order_For_Add_Order_TheCard 2319089 

*/

CREATE PROCEDURE [dbo].[up_Update_Custom_Order_For_Add_Order_TheCard]
    @ORDER_SEQ AS INT

AS
BEGIN

    IF EXISTS   (
                    SELECT  TOP 1 * 
                    FROM    CUSTOM_ORDER 
                    WHERE   ORDER_SEQ = @ORDER_SEQ 
                    AND     UP_ORDER_SEQ IS NOT NULL 
                    AND     COMPANY_SEQ = 5007 
                    AND     STATUS_SEQ IN ( 1, 6, 7, 8, 9 )
                    AND     ORDER_ADD_FLAG IN (0, 1)
                )

        BEGIN
            
            UPDATE  CUSTOM_ORDER
            SET     STATUS_SEQ              =   CASE   
                                                        WHEN ORDER_ADD_FLAG = 0 THEN 9 
                                                        WHEN ORDER_ADD_FLAG = 1 THEN 6
                                                        ELSE STATUS_SEQ
                                                END
                ,   SRC_COMPOSE_DATE        =   GETDATE()
                ,   SRC_COMPOSE_MOD_DATE    =   GETDATE()
                ,   SRC_CONFIRM_DATE        =   CASE   
                                                        WHEN ORDER_ADD_FLAG = 0 THEN GETDATE()
                                                        ELSE NULL
                                                END

                ,   ISCOMPOSE               =   CASE   
                                                        WHEN ORDER_ADD_FLAG = 0 THEN '0'
                                                        ELSE ISCOMPOSE
                                                END

                ,   ISCOREL                 =   '1'

            WHERE   ORDER_SEQ = @ORDER_SEQ
                                        

        END

END




GO
