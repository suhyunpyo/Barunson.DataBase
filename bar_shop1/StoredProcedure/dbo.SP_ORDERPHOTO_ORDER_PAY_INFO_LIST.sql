IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_ORDER_PAY_INFO_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_ORDER_PAY_INFO_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/******************************************************
-- SP Name       : SP_ORDERPHOTO_ORDER_PAY_INFO_LIST
-- Author        : 변미정
-- Create date   : 2023-03-09
-- Description   : 이미지보정 주문결제정보 리스트
-- Update History:
-- Comment       : 
*******************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_ORDER_PAY_INFO_LIST]
     @Uid                 VARCHAR(50) 
    ,@PageSize            INT     = 10
    ,@PageNo              INT     = 1   

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
         --절대 중간에 컬럼 추가하거나 빼지 말것 (추가시 맨 하위에 추가)

        DECLARE @StartRowNum    INT 
        DECLARE @EndRowNum      INT 

        SELECT COUNT(*)  as TotalRecordCnt
        FROM   IMAGE_ORDER 
	    WHERE  [UID] = @Uid
        AND    ORDER_STATUS IN (2,3)
        

        SELECT   IO_SEQ
                ,IO_NO
                ,IO_PG_SEQ
                ,[UID]
                ,ORDER_PRICE
                ,SETTLE_PRICE
                ,ORDER_NAME
                ,ORDER_PHONE
                ,ORDER_HPHONE
                ,ORDER_EMAIL
                ,ORDER_STATUS
                ,ORDER_DEVICE
                ,REG_DATE
                ,ORDER_YMD
                ,IO_ITEM_SEQ
                ,ITEM_TYPE
                ,ITEM_COUNT
                ,ITEM_UNIT_PRICE
                ,ITEM_PRICE
                ,BUYER_NAME
                ,PRODUCTINFO            
                ,PAY_TYPE
                ,PAY_STATUS
                ,PG_SHOPID
                ,PG_TID
                ,DACOM_TID
                ,CASH_RECEIPT_YN
                ,RECEIPT_URL
                ,ESCROW_YN
                ,CARD_INSTALL_MONTH
                ,CARD_NOINT_YN
                ,PG_RESP_CODE
                ,PG_RESP_MSG
                ,FINANCE_CODE
                ,FINANCE_NAME
                ,FINANCE_AUTHNUM
                ,PG_REQUEST_DATE
                ,PG_RESULT_DATE     
                ,PAY_REG_DATE
                ,PAY_YMD
                ,CANCEL_DATE
                ,ROW_NUM
        FROM (
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
                        ,ROW_NUMBER() OVER(ORDER BY O.REG_DATE DESC) AS ROW_NUM
	             FROM IMAGE_ORDER O 
	             INNER JOIN IMAGE_ORDER_ITEM I ON O.IO_SEQ = I.IO_SEQ 
                 INNER JOIN IMAGE_ORDER_PG P ON O.IO_PG_SEQ = P.IO_PG_SEQ 
	             WHERE  O.[UID] = @Uid
                 AND    O.ORDER_STATUS IN (2,3)
            ) A
         WHERE ROW_NUM >  (@PageSize*(@PageNo-1))
         AND   ROW_NUM <= (@PageSize*@PageNo)

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
