IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_PAY_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_PAY_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****************************************************************************************************************
-- SP Name       : SP_ORDERPHOTO_PAY_INSERT
-- Author        : 변미정
-- Create date   : 2023-03-06
-- Description   : 결제 정보(성공) 등록
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_PAY_INSERT]
     @IoSeq	                INT    
    ,@IoNo	                VARCHAR(18)
    ,@BuyerName	            NVARCHAR(100)   = NULL
    ,@ProductInfo	        NVARCHAR(40)    = NULL
    ,@SettlePrice	        INT             = NULL

    ,@PayType	            TINYINT         = NULL    
    ,@PgShopId	            VARCHAR(20)     = NULL
    ,@PgTId 	            VARCHAR(64)     = NULL
    ,@DacomTId	            VARCHAR(200)    = NULL    
    ,@CashReceiptYN	        CHAR(1)         = NULL

    ,@ReceiptUrl	        VARCHAR(200)    = NULL
    ,@EscrowYN	            CHAR(1)         = NULL
    ,@CardInstallMonth      VARCHAR(10)     = NULL
    ,@CardNointYN	        CHAR(1)         = NULL
    ,@PgRespCode	        VARCHAR(50)     = NULL
    
    ,@PgRespMsg	            NVARCHAR(1024)  = NULL
    ,@FinanceCode	        VARCHAR(10)     = NULL
    ,@FinanceName	        VARCHAR(20)     = NULL
    ,@FinanceAuthnum	    VARCHAR(20)     = NULL
    ,@PgRequestDate	        DATETIME        = NULL

    ,@PgResulDdate	        DATETIME        = NULL    

    ,@ErrNum                INT                     OUTPUT
    ,@ErrSev                INT                     OUTPUT
    ,@ErrState              INT                     OUTPUT
    ,@ErrProc               VARCHAR(50)             OUTPUT
    ,@ErrLine               INT                     OUTPUT
    ,@ErrMsg                VARCHAR(2000)           OUTPUT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------
-- Declare Block
----------------------------
DECLARE  @OrderStatus    TINYINT     --주문상태 (1:주문요청 2:결제완료 3:결제취소 9:결제실패)     
        ,@PayStatus      TINYINT     --주문상태 (1:결제완료 2:결제취소 9:결제실패)     
        ,@IoPgSeq	     INT

BEGIN
    BEGIN TRY        
        
        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@IoSeq,0) = 0             
            OR ISNULL(@IoNo,'')=''
            OR ISNULL(@DacomTId,'')='' BEGIN    
            SET @ErrNum = 2001
            SET @ErrMsg = '입력데이터가 유효하지 않습니다.'            
            RETURN
        END

        SELECT @OrderStatus = ORDER_STATUS
        FROM   IMAGE_ORDER
        WHERE  IO_SEQ = @IoSeq
        AND    IO_NO  = @IoNo
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2003
            SET @ErrMsg = '주문정보가 존재하지 않습니다.'            
            RETURN
        END

        IF @OrderStatus <> 1 BEGIN
            SET @ErrNum = 2005
            SET @ErrMsg = '주문 상태가 올바르지 않습니다.'            
            RETURN
        END

        IF EXISTS(SELECT IO_PG_SEQ  
                  FROM IMAGE_ORDER_PG
                  WHERE IO_NO = @IoNo) BEGIN
            SET @ErrNum = 2007
            SET @ErrMsg = '이미 결제정보가 존재합니다.'            
            RETURN
        END 
        

        BEGIN TRAN    

        -------------------------------------------------------
        -- 결제 정보 등록
        -------------------------------------------------------        
        INSERT INTO IMAGE_ORDER_PG (io_no,buyer_name,productinfo,settle_price,pay_type
                                    ,pay_status,pg_shopid,pg_tid,dacom_tid,cash_receipt_yn
                                    ,receipt_url,escrow_yn,card_install_month,card_noint_yn,pg_resp_code
                                    ,pg_resp_msg,finance_code,finance_name,finance_authnum,pg_request_date
                                    ,pg_result_date,reg_date)    
                            VALUES(  @IoNo,@BuyerName,@ProductInfo,@SettlePrice,@PayType
                                    ,1,@PgShopId,@PgTId,@DacomTId,@CashReceiptYN
                                    ,@ReceiptUrl,@EscrowYN,@CardInstallMonth,@CardNointYN,@PgRespCode
                                    ,@PgRespMsg,@FinanceCode,@FinanceName,@FinanceAuthnum,@PgRequestDate
                                    ,@PgResulDdate,GETDATE())

        SET @IoPgSeq = @@IDENTITY
        
        -------------------------------------------------------
        --주문정보 수정
        -------------------------------------------------------        
        UPDATE IMAGE_ORDER
        SET    ORDER_STATUS = 2
              ,IO_PG_SEQ    = @IoPgSeq
        WHERE  IO_SEQ = @IoSeq
        IF @@ROWCOUNT <> 1 BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2007
            SET @ErrMsg = '주문 정보 업데이트 실패.'            
            RETURN
        END                                    

        COMMIT TRAN

        SET @ErrNum = 0
        SET @ErrMsg = 'OK'
        RETURN
    
    END TRY
    BEGIN CATCH
        IF ( XACT_STATE() ) <> 0  BEGIN            
            ROLLBACK TRAN                                 
        END

        SET @ErrNum   = ERROR_NUMBER()
		SET @ErrSev   = ERROR_SEVERITY()
		SET @ErrState = ERROR_STATE()
		SET @ErrProc  = ERROR_PROCEDURE()
		SET @ErrLine  = ERROR_LINE()
		SET @ErrMsg   = ERROR_MESSAGE()

        RETURN   
    END CATCH

END
GO
