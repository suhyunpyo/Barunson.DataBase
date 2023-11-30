IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_ORDER_PAY_INFO_GET', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_ORDER_PAY_INFO_GET
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************
-- SP Name       : SP_ORDERPHOTO_ORDER_PAY_INFO_GET
-- Author        : 변미정
-- Create date   : 2023-03-09
-- Description   : 이미지보정 주문결제정보 조회
-- Update History:
-- Comment       : 
*******************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_ORDER_PAY_INFO_GET]
      @IoSeq               INT          = NULL
     ,@IoNo                VARCHAR(18)  = NULL     
     ,@Uid                 VARCHAR(50) 

     ,@ErrNum              INT             OUTPUT
     ,@ErrSev              INT             OUTPUT
     ,@ErrState            INT             OUTPUT
     ,@ErrProc             VARCHAR(50)     OUTPUT
     ,@ErrLine             INT             OUTPUT
     ,@ErrMsg              VARCHAR(2000)   OUTPUT
AS
SET NOCOUNT ON

BEGIN
    BEGIN TRY

        IF ISNULL(@IoSeq,0) = 0 AND ISNULL(@IoNo,0) = 0 BEGIN
            RETURN
        END


        SELECT   O.IO_SEQ
                ,O.IO_NO
                ,O.IO_PG_SEQ
                ,O.[UID]
                ,O.ORDER_PRICE
                ,O.SETTLE_PRICE
                ,O.ORDER_NAME
                ,O.ORDER_PHONE
                ,O.ORDER_HPHONE
                ,O.ORDER_EMAIL
                ,O.ORDER_STATUS
                ,O.ORDER_DEVICE
                ,O.REG_DATE
                ,CONVERT(CHAR(8),O.REG_DATE,112) AS ORDER_YMD
                ,I.IO_ITEM_SEQ
                ,I.ITEM_TYPE
                ,I.ITEM_COUNT
                ,I.ITEM_UNIT_PRICE
                ,I.ITEM_PRICE
                ,P.BUYER_NAME
                ,P.PRODUCTINFO            
                ,P.PAY_TYPE
                ,P.PAY_STATUS
                ,P.PG_SHOPID
                ,P.PG_TID
                ,P.DACOM_TID
                ,P.CASH_RECEIPT_YN
                ,P.RECEIPT_URL
                ,P.ESCROW_YN
                ,P.CARD_INSTALL_MONTH
                ,P.CARD_NOINT_YN
                ,P.PG_RESP_CODE
                ,P.PG_RESP_MSG
                ,P.FINANCE_CODE
                ,P.FINANCE_NAME
                ,P.FINANCE_AUTHNUM
                ,P.PG_REQUEST_DATE
                ,P.PG_RESULT_DATE     
                ,P.REG_DATE AS PAY_REG_DATE
                ,CONVERT(CHAR(8),P.REG_DATE,112) AS PAY_YMD
                ,P.CANCEL_DATE
	     FROM IMAGE_ORDER O 
	     INNER JOIN IMAGE_ORDER_ITEM I ON O.IO_SEQ = I.IO_SEQ 
         INNER JOIN IMAGE_ORDER_PG P ON O.IO_PG_SEQ = P.IO_PG_SEQ 
	     WHERE O.IO_SEQ = CASE WHEN ISNULL(@IoSeq,0) <> 0 THEN @IoSeq ELSE O.IO_SEQ END
         AND   O.IO_NO = CASE WHEN ISNULL(@IoNo,'') <> '' THEN @IoNo ELSE O.IO_NO END
         AND   O.[UID] = @Uid
    END TRY
    BEGIN CATCH
    
        SET @ErrNum   = ERROR_NUMBER()
        SET @ErrSev   = ERROR_SEVERITY()
        SET @ErrState = ERROR_STATE()
        SET @ErrProc  = ERROR_PROCEDURE()
        SET @ErrLine  = ERROR_LINE()
        SET @ErrMsg   = ERROR_MESSAGE();

        RETURN  
        
    END CATCH
END
 

GO
