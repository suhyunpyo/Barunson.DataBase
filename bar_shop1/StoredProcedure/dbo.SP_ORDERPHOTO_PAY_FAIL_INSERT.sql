IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_PAY_FAIL_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_PAY_FAIL_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****************************************************************************************************************
-- SP Name       : SP_ORDERPHOTO_PAY_FAIL_INSERT
-- Author        : 변미정
-- Create date   : 2023-03-06
-- Description   : 결제 실패 정보 등록
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_PAY_FAIL_INSERT]
     @IoSeq	               INT    
    ,@IoNo	               VARCHAR(18)
    ,@BuyerName	           NVARCHAR(100)   = NULL
    ,@ProductInfo	       NVARCHAR(40)    = NULL
    ,@SettlePrice	       INT             = NULL
                           
    ,@PgRespCode	       VARCHAR(50)     = NULL    
    ,@PgRespMsg	           NVARCHAR(1024)  = NULL        
    
    ,@ErrNum              INT             OUTPUT
    ,@ErrSev              INT             OUTPUT
    ,@ErrState            INT             OUTPUT
    ,@ErrProc             VARCHAR(50)     OUTPUT
    ,@ErrLine             INT             OUTPUT
    ,@ErrMsg              VARCHAR(2000)   OUTPUT
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
            OR ISNULL(@IoNo,'')='' BEGIN    
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
        -- 결제 실패 정보 등록
        -------------------------------------------------------        
        INSERT INTO IMAGE_ORDER_PG (io_no,buyer_name,productinfo,settle_price,pay_status
                                    ,pg_resp_code,pg_resp_msg,reg_date)    
                            VALUES(  @IoNo,@BuyerName,@ProductInfo,@SettlePrice,9
                                    ,@PgRespCode,@PgRespMsg,GETDATE())                                    

        SET @IoPgSeq = @@IDENTITY
        
        -------------------------------------------------------
        --주문 정보 수정
        -------------------------------------------------------        
        UPDATE IMAGE_ORDER
        SET    ORDER_STATUS = 9
              ,IO_PG_SEQ    = @IoPgSeq
        WHERE  IO_SEQ       = @IoSeq
        IF @@ROWCOUNT <> 1 BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2009
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
