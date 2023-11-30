IF OBJECT_ID (N'dbo.SP_ORDERPHOTO_ORDER_UPDATE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_ORDERPHOTO_ORDER_UPDATE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*********************************************************
-- SP Name       : SP_ORDERPHOTO_ORDER_UPDATE
-- Author        : 변미정
-- Create date   : 2023-03-06
-- Description   : 주문정보 수정
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_ORDERPHOTO_ORDER_UPDATE] 
     @IoSeq	                INT	           
    ,@UId	                VARCHAR(50)    = NULL
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

    ,@ErrNum            INT             OUTPUT
    ,@ErrSev            INT             OUTPUT
    ,@ErrState          INT             OUTPUT
    ,@ErrProc           VARCHAR(50)     OUTPUT
    ,@ErrLine           INT             OUTPUT
    ,@ErrMsg            VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------
-- Declare Block
----------------------------
DECLARE @CheckPrice         INT = 0
       ,@CheckOrderStatus   TINYINT = 0
       ,@IoItemSeq          INT = 0
BEGIN
    BEGIN TRY        

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@IoSeq,0) = 0  
            OR ISNULL(@OrderPrice,0) = 0  
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

        SELECT @CheckOrderStatus = O.ORDER_STATUS
               ,@IoItemSeq       = I.IO_ITEM_SEQ
        FROM IMAGE_ORDER O
        INNER JOIN IMAGE_ORDER_ITEM I ON O.IO_SEQ = I.IO_SEQ
        WHERE O.IO_SEQ = @IoSeq
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2004
            SET @ErrMsg = '주문정보가 없습니다.'            
            RETURN
        END

        IF @CheckOrderStatus <> 1 BEGIN
            SET @ErrNum = 2005
            SET @ErrMsg = '수정할 수 없는 주문 상태입니다.'            
            RETURN
        END


        BEGIN TRAN     

        -------------------------------------------------------
        -- 주문정보 정보 수정
        -------------------------------------------------------        
        UPDATE IMAGE_ORDER
        SET  [uid]         = @UId
            ,ORDER_PRICE   = @OrderPrice
            ,SETTLE_PRICE  = @OrderPrice
            ,ORDER_NAME    = @OrderName
            ,ORDER_PHONE   = @OrderPhone
            ,ORDER_HPHONE  = @OrderHphone
            ,ORDER_EMAIL   = @OrderEmail       
            ,ORDER_DEVICE  = @OrderDevice    
            ,ORDER_STATUS  = @OrderStatus
        WHERE IO_SEQ =  @IoSeq      
        
        IF @@ROWCOUNT <> 1 OR @@ERROR <> 0BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2007
            SET @ErrMsg = '주문정보 업데이트 실패.'            
            RETURN
        END  
     
        -------------------------------------------------------
        --주문 아이템 정보 등록
        -------------------------------------------------------        
        UPDATE IMAGE_ORDER_ITEM
        SET  ITEM_TYPE       = @ItemType
            ,ITEM_COUNT      = @ItemCount
            ,ITEM_UNIT_PRICE = @ItemUnitPrice
            ,ITEM_PRICE      = @OrderPrice
        WHERE IO_ITEM_SEQ = @IoItemSeq

        IF @@ROWCOUNT <> 1 OR @@ERROR <> 0BEGIN
            ROLLBACK TRAN
            SET @ErrNum = 2009
            SET @ErrMsg = '주문 아이템 정보 업데이트 실패.'            
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
