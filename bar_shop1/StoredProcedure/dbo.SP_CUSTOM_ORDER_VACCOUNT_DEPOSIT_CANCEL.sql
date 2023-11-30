USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT_CANCEL]    Script Date: 2023-04-26 오전 7:41:08 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT_CANCEL]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT_CANCEL]    Script Date: 2023-04-26 오전 7:41:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : [SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT_CANCEL
-- Author        : 변미정
-- Create date   : 2023-04-25
-- Description   : 가상계좌 입금처리 취소 (결제 취소가 아닌 입금대기상태로 되돌린다)
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT_CANCEL]     
     @toss_secret                    VARCHAR(50)                --거래 검증키
    ,@toss_orderid                   VARCHAR(50)                --주문번호 (각 주문테이블의 pg_tid)    
    
    ,@ErrNum                         INT             OUTPUT
    ,@ErrSev                         INT             OUTPUT
    ,@ErrState                       INT             OUTPUT
    ,@ErrProc                        VARCHAR(50)     OUTPUT
    ,@ErrLine                        INT             OUTPUT
    ,@ErrMsg                         VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

BEGIN
       
    DECLARE  @order_seq             INT                       
    DECLARE  @order_type            VARCHAR(2)      = NULL    
    DECLARE  @status                TINYINT         = NULL
    DECLARE  @status_seq            TINYINT         = NULL    
    DECLARE  @settle_status         TINYINT         = NULL    
    DECLARE  @member_id             VARCHAR(50)     = NULL    
    DECLARE  @company_seq           INT             = NULL
    DECLARE  @last_upd_date         DATETIME

    BEGIN TRY        

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@toss_secret,'') = '' OR ISNULL(@toss_orderid,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 주문정보 조회
        -------------------------------------------------------     
        SELECT  @order_type     = ORDER_TYPE
               ,@order_seq      = ORDER_SEQ
               ,@status         = [STATUS]            
               ,@last_upd_date  = ISNULL(UPD_DATE, GETDATE())
        FROM    TOSS_VACCOUNT 
        WHERE   toss_orderid = @toss_orderid
        AND     toss_secret  = @toss_secret
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2302
            SET @ErrMsg = '가상계좌 발급정보가 존재하지 않습니다.'            
            RETURN
        END

        --이미 입금 대기상태이면 OR처리
        IF @status = 1 BEGIN
            SET @ErrNum = 0
            SET @ErrMsg = 'OK'            
            RETURN
        END

        --은행에서 일시적으로 나타다는 이슈로 (1~2초사이) 10분이상 지연 후 noti는 문제가 있는것으로 판단한다
        IF DATEDIFF(MINUTE,@last_upd_date,getdate()) > 10 BEGIN
            SET @ErrNum = 2303
            SET @ErrMsg = '입금 처리 후 10분 이내에만 입금 대기 전환이 가능합니다.'            
            RETURN
        END


        
        -------------------------------------------------------
        -- 트랜잭션 시작
        -------------------------------------------------------     
        BEGIN TRAN         

        --청첩장
        IF @order_type = 'W' BEGIN 

           BEGIN TRY
                UPDATE CUSTOM_ORDER
                SET    SETTLE_STATUS   = 1
                      ,SETTLE_DATE  = NULL
                      ,SRC_AP_DATE  = NULL
                      ,@member_id   = MEMBER_ID
                      ,@company_seq = COMPANY_SEQ
                WHERE  ORDER_SEQ    = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '결제정보가 존재하지 않습니다.'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '입금 취소 실패 ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

        END
        --답례품/부가상품
        ELSE IF @order_type = 'E' BEGIN           

           BEGIN TRY
                UPDATE CUSTOM_ETC_ORDER
                SET    STATUS_SEQ  = 1
                      ,SETTLE_DATE =NULL                   
                WHERE  ORDER_SEQ   = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '결제정보가 존재하지 않습니다.'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '입금 취소 실패 ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH
        END

        --샘플주문
        ELSE IF @order_type = 'S' BEGIN
            
            BEGIN TRY
                UPDATE CUSTOM_SAMPLE_ORDER
                SET    STATUS_SEQ       = 1
                      ,SETTLE_DATE      = NULL                                        
                WHERE  SAMPLE_ORDER_SEQ = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '결제정보가 존재하지 않습니다.'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '입금 취소 실패 ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

        END
         ELSE BEGIN      
            ROLLBACK TRAN
            SET @ErrNum = 2308
            SET @ErrMsg = '상품 구분 오류'                       
            RETURN    
        END   

        BEGIN TRY
            UPDATE TOSS_VACCOUNT
            SET   [STATUS] = 1  
                  ,UPD_DATE = GETDATE()
            WHERE  ORDER_SEQ    = @order_seq 
            AND    TOSS_ORDERID = @toss_orderid
            AND    TOSS_SECRET  = @toss_secret
        END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2310
                SET @ErrMsg = '가상계좌 상태 수정 실패 ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH
        
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
		SET @ErrMsg   = '입금 정보 수정 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


