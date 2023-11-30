IF OBJECT_ID (N'dbo.SP_SELECT_OUTSOURCING_DELIVERY_ETC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_OUTSOURCING_DELIVERY_ETC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
/*

EXEC SP_SELECT_OUTSOURCING_DELIVERY_ETC '3199718'
EXEC SP_SELECT_OUTSOURCING_DELIVERY_ETC '3199747'

*/

CREATE PROCEDURE [dbo].[SP_SELECT_OUTSOURCING_DELIVERY_ETC]
	@P_ORDER_SEQ AS VARCHAR(20)

AS
BEGIN
    
    SELECT  ROW_NUMBER() OVER(ORDER BY A.DELIVERY_DATE ASC) AS ROW_NUM
		, A.ORDER_SEQ 
		, A.recv_address AS ADDR
		, 1 AS DELIVERY_SEQ
		, A.recv_address_detail AS ADDR_DETAIL
		, A.recv_hphone AS HPHONE
		, A.recv_phone AS PHONE
		, A.recv_name AS NAME
		--, A.recv_msg AS PHONE
		, A.recv_zip AS ZIP
		, ISNULL(A.DELIVERY_METHOD, 0) AS DELIVERY_METHOD
		, ISNULL(A.DELIVERY_COM, '') AS DELIVERY_COM_
		,CASE WHEN ISNULL(A.DELIVERY_COM, '') = '' THEN CASE WHEN ISNULL(D.Delivery_Ty,'') = '퀵발송' THEN 'QC' ELSE ISNULL(A.DELIVERY_COM, '') END 
        ELSE ISNULL(A.DELIVERY_COM, '') END DELIVERY_COM
		, ISNULL(A.DELIVERY_CODE, '') AS DELIVERY_CODE_NUM
		, A.RECV_MSG AS DELIVERY_INFO
		, A.DELIVERY_DATE
		, A.ETC_INFO_S AS ETC_INFO
		, A.PG_PAYDATE	AS HOPE_DATE
		, A.ADMIN_MEMO  AS PLACE
    FROM    CUSTOM_ETC_ORDER AS A
	INNER JOIN ( SELECT order_seq, max(card_seq) card_seq FROM CUSTOM_ETC_ORDER_ITEM GROUP BY order_seq ) C ON A.order_seq = C.order_seq 
    INNER JOIN ( SELECT card_seq, max(Delivery_Ty) Delivery_Ty FROM S2_CardDetailEtc GROUP BY card_seq ) D ON C.card_seq = D.Card_Seq
    WHERE   1 = 1
    AND     A.ORDER_SEQ  = @P_ORDER_SEQ

    

END

GO
