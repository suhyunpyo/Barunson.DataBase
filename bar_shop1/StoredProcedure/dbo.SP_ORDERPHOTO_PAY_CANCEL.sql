IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_PAY_CANCEL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_PAY_CANCEL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/****************************************************************************************************************
-- SP Name       : SP_ORDERPHOTO_PAY_CANCEL
-- Author        : 변미정
-- Create date   : 2023-03-06
-- Description   : 결제 취소처리
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_PAY_CANCEL]
     @IoSeq	              INT    
    ,@IoPGSeq             INT  
    ,@PgRespCode	      VARCHAR(50)     = NULL    
    ,@PgRespMsg	          NVARCHAR(1024)  = NULL    
    
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

BEGIN
    BEGIN TRY        
        
        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@IoSeq,0) = 0 
            OR ISNULL(@IoPgSeq,0) = 0 BEGIN    
            SET @ErrNum = 2001
            SET @ErrMsg = '입력데이터가 유효하지 않습니다.'            
            RETURN
        END

        SELECT @OrderStatus = O.ORDER_STATUS
              ,@PayStatus   = P.PAY_STATUS
        FROM   IMAGE_ORDER O
        INNER JOIN IMAGE_ORDER_PG P ON O.IO_PG_SEQ = P.IO_PG_SEQ
        WHERE  O.IO_SEQ     = @IoSeq
        AND    O.IO_PG_SEQ  = @IoPGSeq
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2003
            SET @ErrMsg = '주문/결제 정보가 존재하지 않습니다.'            
            RETURN
        END

        IF @OrderStatus <> 2 OR @PayStatus<>1 BEGIN
            SET @ErrNum = 2005
            SET @ErrMsg = '결제완료 상태가 아닙니다.'            
            RETURN
        END

        BEGIN TRAN    

        -------------------------------------------------------
        -- 결제 정보 수정(취소처리)
        -------------------------------------------------------        
        UPDATE IMAGE_ORDER_PG
        SET    PAY_STATUS   = 2
              ,CANCEL_DATE  = GETDATE()
              ,PG_RESP_CODE = @PgRespCode
              ,PG_RESP_MSG  = @PgRespMsg
        WHERE IO_PG_SEQ  = @IoPGSeq
        AND   PAY_STATUS = 1
        IF @@ROWCOUNT <> 1 BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2007
            SET @ErrMsg = '결제 정보 업데이트 실패.'            
            RETURN
        END                                    

        -------------------------------------------------------
        --주문정보 수정(취소 처리)
        -------------------------------------------------------        
        UPDATE IMAGE_ORDER
        SET    ORDER_STATUS = 3
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
