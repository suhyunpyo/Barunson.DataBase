IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_SETTLE_INFORMATION_CHECK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_SETTLE_INFORMATION_CHECK
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
/*

EXEC [SP_SELECT_CUSTOM_ORDER_SETTLE_INFORMATION_CHECK] 2185810

*/
CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_SETTLE_INFORMATION_CHECK]
@order_seq AS int
AS
BEGIN

SET NOCOUNT ON

SELECT  ORDER_SEQ

FROM    CUSTOM_ORDER

WHERE   1 = 1

AND     ORDER_SEQ = @order_seq

AND     (
            (
                -- 정산 주문건들에 대한 결제 정보 체크
                        SETTLE_STATUS = 2 
                AND     SETTLE_PRICE >= 0
                AND     SETTLE_PRICE IS NOT NULL
                AND     SETTLE_METHOD IS NOT NULL
                AND     SETTLE_METHOD IN ('1', '2', '3', '8', '9', '6')
				/** 2019-01-03 디얼디어에서는 DACOM_TID 등록 하지 않음 */
                AND     ((DACOM_TID IS NOT NULL AND SALES_GUBUN <> 'SD' AND PG_RESULTINFO IS NOT NULL) OR SALES_GUBUN = 'SD')
            )
            OR
            (
                -- 제휴사 후불
                        SETTLE_STATUS = 2 
                AND     SETTLE_PRICE >= 0
                AND     SETTLE_PRICE IS NOT NULL
                AND     SETTLE_METHOD IS NOT NULL
                AND     SETTLE_METHOD IN ('7')
            )
            OR
            (
                -- P, Q 건과, 사고건은 제외
                SALES_GUBUN IN ( 'P' , 'Q' ) OR TROUBLE_TYPE <> 0
            )
            OR
            (
                SETTLE_METHOD IN ('4', '5')
            )
        )

END
GO
