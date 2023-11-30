IF OBJECT_ID (N'dbo.SP_EXEC_BHANDSCARD_ONLY_DIGITALCARD_GIFT_PRESENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_BHANDSCARD_ONLY_DIGITALCARD_GIFT_PRESENT
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

    EXEC SP_EXEC_BHANDSCARD_ONLY_DIGITALCARD_GIFT_PRESENT 57977

*/
CREATE PROCEDURE [dbo].[SP_EXEC_BHANDSCARD_ONLY_DIGITALCARD_GIFT_PRESENT]
    @P_SEQ AS INT
AS
BEGIN

DECLARE @ORDER_SEQ AS INT    
DECLARE @UP_ORDER_SEQ AS INT
DECLARE @FLOWER_PRINTING AS INT

SET @FLOWER_PRINTING = 35370
SET @UP_ORDER_SEQ = ISNULL((SELECT ISNULL(ORDER_SEQ, 0) FROM S2_USERCOMMENT WHERE SEQ = @P_SEQ), 0)

IF @UP_ORDER_SEQ > 0 
    BEGIN
        
        DECLARE @tbSeq TABLE(Seq INT)
        INSERT @tbSeq EXEC SP_GET_ORDER_SEQ 'C'

        SELECT @ORDER_SEQ =SEQ FROM @tbSeq
        

        INSERT INTO CUSTOM_ORDER    (
                                            order_seq,sales_Gubun,site_Gubun,isCorel,company_Seq,status_seq,up_order_seq,card_seq,member_id,order_name,order_email,order_phone,order_hphone,card_opt,order_type,print_type,weddinfo_id,pg_tid,isVar,isColorInpaper
                                        ,   ORDER_ADD_TYPE
                                        ,   ORDER_ADD_FLAG
                                        ,   ORDER_COUNT
                                        ,   SETTLE_STATUS
                                        ,   SETTLE_DATE
                                        ,   SETTLE_PRICE
                                        ,   SETTLE_METHOD
                                        ,   ISCOMPOSE
                                        ,   SRC_CONFIRM_DATE

                                    )

        SELECT  @ORDER_SEQ
            ,   SALES_GUBUN
            ,   SITE_GUBUN
            ,   0
            ,   COMPANY_SEQ
            ,   9
            ,   @UP_ORDER_SEQ
            ,   CARD_SEQ
            ,   MEMBER_ID
            ,   ORDER_NAME
            ,   ORDER_EMAIL
            ,   ORDER_PHONE
            ,   ORDER_HPHONE
            ,   CARD_OPT
            ,   ORDER_TYPE
            ,   PRINT_TYPE
            ,   WEDDINFO_ID
            ,   PG_SHOPID
            ,   ''
            ,   ISCOLORINPAPER
            ,   0
            ,   0
            ,   0
            ,   2
            ,   GETDATE()
            ,   0
            ,   0
            ,   1
            ,   GETDATE()
        FROM    CUSTOM_ORDER
        WHERE   ORDER_SEQ = @UP_ORDER_SEQ

        INSERT INTO CUSTOM_ORDER_ITEM (order_seq,card_seq,item_type,item_count,item_price,item_sale_price,discount_rate,memo1,addnum_price)
        VALUES (@ORDER_SEQ, @FLOWER_PRINTING, 'H', 1, 0, 0, 0, null, 0)



        INSERT INTO DELIVERY_INFO   (
                                            ORDER_SEQ
                                        ,   DELIVERY_SEQ
                                        ,   NAME
                                        ,   EMAIL
                                        ,   PHONE
                                        ,   HPHONE
                                        ,   ZIP
                                        ,   ADDR
                                        ,   ADDR_DETAIL
                                        ,   PACKING_DATE
                                        ,   DELIVERY_DATE
                                        ,   DELIVERY_CODE_NUM
                                        ,   DELIVERY_COM
                                        ,   PACKING_ADMIN_ID
                                        ,   DELIVERY_PRICE
                                        ,   DELIVERY_METHOD
                                        ,   DELIVERY_PAY
                                        ,   DELIVERY_INFO
                                        ,   receivecode
                                        ,   receiveShopname
                                        ,   DELIVERY_MEMO
                                        ,   savepack_date
                                        ,   savepack_admin_id
                                        ,   isNewCopy
                                        ,   nt_code
                                    )

        SELECT  @ORDER_SEQ
            ,   DELIVERY_SEQ
            ,   NAME
            ,   EMAIL
            ,   PHONE
            ,   HPHONE
            ,   ZIP
            ,   ADDR
            ,   ADDR_DETAIL
            ,   PACKING_DATE
            ,   DELIVERY_DATE
            ,   DELIVERY_CODE_NUM
            ,   DELIVERY_COM
            ,   PACKING_ADMIN_ID
            ,   DELIVERY_PRICE
            ,   DELIVERY_METHOD
            ,   DELIVERY_PAY
            ,   DELIVERY_INFO
            ,   receivecode
            ,   receiveShopname
            ,   DELIVERY_MEMO
            ,   null
            ,   null
            ,   isNewCopy
            ,   nt_code
        FROM    DELIVERY_INFO 
        WHERE   ORDER_SEQ = @UP_ORDER_SEQ
        AND     DELIVERY_SEQ = 1



    END

END


GO
