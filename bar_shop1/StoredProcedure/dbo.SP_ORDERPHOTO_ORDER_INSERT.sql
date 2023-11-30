IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_ORDER_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_ORDER_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*********************************************************
-- SP Name       : SP_ORDERPHOTO_ORDER_INSERT
-- Author        : 변미정
-- Create date   : 2023-03-06
-- Description   : 주문정보 등록
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_ORDER_INSERT] 
     @UId	                VARCHAR(50)    = NULL
    ,@OrderPrice	        INT		           	       
    ,@OrderName	            NVARCHAR(100)  
    ,@OrderPhone	        VARCHAR(20)    = NULL
    ,@OrderHphone	        VARCHAR(20)    

    ,@OrderEmail	        VARCHAR(100)   = NULL
    ,@OrderStatus	        TINYINT  		        --주문상태 (1:주문요청 2:결제완료 3:결제취소 9:결제실패)     
    ,@OrderDevice	        TINYINT	      
    ,@ItemType              TINYINT                 --상품구분 (1:고급보정 2:스피드보정)
    ,@ItemCount             INT

    ,@ItemUnitPrice         INT    
    
    ,@ErrNum                INT             OUTPUT
    ,@ErrSev                INT             OUTPUT
    ,@ErrState              INT             OUTPUT
    ,@ErrProc               VARCHAR(50)     OUTPUT
    ,@ErrLine               INT             OUTPUT
    ,@ErrMsg                VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------
-- Declare Block
----------------------------
DECLARE @CheckPrice     INT = 0
       ,@IoSeq	        INT	            
       ,@IoNo	        VARCHAR(18)     

BEGIN
    BEGIN TRY        

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@OrderPrice,0) = 0  
            OR ISNULL(@ItemType,0) = 0  
            OR ISNULL(@ItemCount,0) = 0
            OR ISNULL(@UId,'')=''
            OR ISNULL(@OrderName,'')='' BEGIN    
            SET @ErrNum = 2001
            SET @ErrMsg = '입력데이터가 유효하지 않습니다.'            
            RETURN
        END

        SET @CheckPrice = @ItemCount * @ItemUnitPrice

        IF @CheckPrice <> @OrderPrice BEGIN
            SET @ErrNum = 2003
            SET @ErrMsg = '주문금액이 올바르지 않습니다.'            
            RETURN
        END       

        BEGIN TRAN     

        -------------------------------------------------------
        -- 주문정보 정보 등록
        -------------------------------------------------------        
        INSERT INTO IMAGE_ORDER ([UID], ORDER_PRICE, SETTLE_PRICE, ORDER_NAME, ORDER_PHONE
                                ,ORDER_HPHONE, ORDER_EMAIL, ORDER_STATUS, ORDER_DEVICE, REG_DATE)    
                          VALUES(  @UId,@OrderPrice,@OrderPrice,@OrderName,@OrderPhone
                                  ,@OrderHphone,@OrderEmail,@OrderStatus,@OrderDevice, GETDATE())
        IF @@ROWCOUNT <> 1 OR @@ERROR <> 0BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2004
            SET @ErrMsg = '주문 아이템 정보 등록 실패.'            
            RETURN
        END  

        SET @IoSeq = @@IDENTITY

        --고유 주문번호생성 (바른이미지 전달 값)
        SET @IoNo = 'IO'+CONVERT(VARCHAR(8),GETDATE(),112)+RIGHT('000000'+CAST(@IoSeq AS VARCHAR),6)

        -------------------------------------------------------
        --주문정보 수정 IoNo 업데이트
        -------------------------------------------------------    
        UPDATE IMAGE_ORDER
        SET    IO_NO  = @IoNo              
        WHERE  IO_SEQ = @IoSeq
        IF @@ROWCOUNT <> 1 OR @@ERROR <> 0BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2005
            SET @ErrMsg = '주문 정보 업데이트 실패.'            
            RETURN
        END    
        
        -------------------------------------------------------
        --주문 아이템 정보 등록
        -------------------------------------------------------        
        INSERT INTO IMAGE_ORDER_ITEM (IO_SEQ,ITEM_TYPE, ITEM_COUNT, ITEM_UNIT_PRICE, ITEM_PRICE
                                     ,REG_DATE)
                              VALUES (@IoSeq, @ItemType, @ItemCount, @ItemUnitPrice, @OrderPrice
                                     ,GETDATE())
        IF @@ROWCOUNT <> 1 OR @@ERROR <> 0BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2007
            SET @ErrMsg = '주문 아이템 정보 등록 실패.'            
            RETURN
        END                                    

        COMMIT TRAN        

        SET @ErrNum = 0
        SET @ErrMsg = 'OK'

        SELECT @IoSeq AS IoSeQ, @IoNo AS IoNo

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
		SET @ErrMsg   = '주문 정보 등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO
