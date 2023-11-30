IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_DELIVERY_DUPLICATION_CHECK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_DELIVERY_DUPLICATION_CHECK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_DELIVERY_DUPLICATION_CHECK]
@order_seq AS int
AS
BEGIN

SET NOCOUNT ON



SELECT  CO.ORDER_SEQ
    ,   DI_1.ADDR
    ,   DI_2.ADDR
    ,   DI_3.ADDR
FROM    CUSTOM_ORDER CO
JOIN    DELIVERY_INFO DI_1 ON CO.ORDER_SEQ = DI_1.ORDER_SEQ AND DI_1.DELIVERY_SEQ = 1
LEFT JOIN    DELIVERY_INFO DI_2 ON CO.ORDER_SEQ = DI_2.ORDER_SEQ AND DI_2.DELIVERY_SEQ = 2
LEFT JOIN    DELIVERY_INFO DI_3 ON CO.ORDER_SEQ = DI_3.ORDER_SEQ AND DI_3.DELIVERY_SEQ = 3
WHERE   1 = 1
AND     CO.STATUS_SEQ = 10 
AND     CO.SALES_GUBUN <> 'XB'
AND     ( 

            (DI_2.ADDR IS NOT NULL AND DI_1.ADDR = DI_2.ADDR)
            OR
            (DI_3.ADDR IS NOT NULL AND DI_1.ADDR = DI_3.ADDR)
            OR
            (DI_2.ADDR IS NOT NULL AND DI_3.ADDR IS NOT NULL AND DI_2.ADDR = DI_3.ADDR)

        )

AND     CO.ORDER_SEQ = @order_seq

END




GO
