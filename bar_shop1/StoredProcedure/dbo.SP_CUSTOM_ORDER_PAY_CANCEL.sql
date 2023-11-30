IF OBJECT_ID (N'dbo.SP_CUSTOM_ORDER_PAY_CANCEL', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CUSTOM_ORDER_PAY_CANCEL
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_CANCEL
-- Author        : 변미정
-- Create date   : 2023-04-06
-- Description   : 결제/주문 취소
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_CANCEL]     
     
     @order_seq                      INT                        --주문번호     
    ,@pg_shopid                      VARCHAR(20)     = NULL     --PG아이디
    ,@company_seq                    INT             = NULL     --서비스구분
    ,@pg_tid                         VARCHAR(200)    = NULL     --PG 주문번호
    ,@dacom_tid                      VARCHAR(200)    = NULL     --PG사 거래번호

    ,@order_type                     VARCHAR(2)      = NULL     --주문타입 (1:청첩장 2:감사장 3:초대장 4,시즌카드 5:미니청첩장 6:포토/디지탈 7:이니셜 8:포토미니)
    ,@settle_status                  INT             = NULL
    ,@status_seq                     INT             = NULL
    ,@settle_price                   INT             = NULL     --결제금액
    ,@settle_method                  CHAR(1)         = NULL     --결제방법(1:계좌이체,3:무통장,2,6:카드, 8:카카오페이,9:간편결제)    

    ,@admin_id                       VARCHAR(50)     = NULL     --관리자아이디
    ,@cancel_reason                  VARCHAR(200)    = NULL     --취소사유    
    ,@pg_cancel                      CHAR(1)         = NULL     --PG사 취소여부 (1:PG취소)
    ,@repay                          CHAR(1)         = NULL     --재결제 요청
    ,@isclosecopy                    CHAR(1)         = NULL     --지시서 검증 취소여부

    ,@cancel_type                    INT             = NULL    
    ,@order_cancel_type_comment      VARCHAR(200)    = NULL     --취소사유    

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
    BEGIN TRY        
        DECLARE @member_id            VARCHAR(50)
        DECLARE @order_email          VARCHAR(100)
        DECLARE @order_g_seq          INT          
        DECLARE @npg_tid              VARCHAR(200) 
        DECLARE @ment                 VARCHAR(2000)
        DECLARE @pcheck               TINYINT        
        DECLARE @next_settle_status   TINYINT        
        DECLARE @next_statue_seq      TINYINT        
        DECLARE @next_settle_status_g TINYINT        
        DECLARE @next_statue_seq_g    TINYINT        

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0 OR ISNULL(@order_type,'') = '' BEGIN    
            SET @ErrNum = 2422
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END
        
        -------------------------------------------------------
        -- 주문정보 조회
        -------------------------------------------------------     
        --청첩장
        IF @order_type = 'W' BEGIN 

            SELECT @member_id   = MEMBER_ID 
                  ,@order_email = ORDER_EMAIL                  
                  ,@order_g_seq = ORDER_G_SEQ 
                  ,@npg_tid     = PG_TID
            FROM   CUSTOM_ORDER 
            WHERE  ORDER_SEQ    = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2424
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN                                
            END 

            --custom_order_group 기본 상태값
            SET @next_settle_status_g  = 5
            SET @next_statue_seq       = 5

            --custom_order 기본 상태값
            SET @next_settle_status    = 5
            SET @next_statue_seq       = 5

            --재결제 요청 시 pg_tid 생성 
            IF ISNULL(@repay,'') = '1' BEGIN                       
                SET @npg_tid = CASE LEFT(@pg_tid,2)
                                    WHEN 'IC' THEN 'ID'+CAST(@order_seq AS VARCHAR)
                                    WHEN 'ID' THEN 'IE'+CAST(@order_seq AS VARCHAR)
                                    WHEN 'IE' THEN 'IF'+CAST(@order_seq AS VARCHAR)
                                    WHEN 'IT' THEN 'IH'+CAST(@order_seq AS VARCHAR)
                                    ELSE 'IG'+CAST(@order_seq AS VARCHAR)
                                END                                                      
                                
                SET @next_settle_status  = 0
                SET @next_statue_seq     = @status_seq
                              
                IF ISNULL(@pg_cancel,'') = '1' BEGIN
                    SET @next_settle_status_g  = 0
                    SET @next_statue_seq_g     = @status_seq
                END                

            END
            ElSE BEGIN                   
                IF ISNULL(@pg_cancel,'') <> '1' AND @settle_status <> 2 BEGIN                                                             
                    SET @next_settle_status  = 3
                    SET @next_statue_seq     = 3                    
                END
            END      
            
            SET @cancel_reason = @order_cancel_type_comment

        END        
        ELSE BEGIN 
            IF  @order_type = 'E' BEGIN

                SELECT @member_id   = MEMBER_ID 
                      ,@order_email = ORDER_EMAIL                  
                      ,@order_g_seq = ORDER_G_SEQ 
                FROM   CUSTOM_ETC_ORDER 
                WHERE  ORDER_SEQ = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN                
                    SET @ErrNum = 2426
                    SET @ErrMsg = '주문정보가 없습니다.'                     
                    RETURN
                END          
              
            END
            --샘플주문
            ELSE IF @order_type = 'S' BEGIN
                SELECT @member_id   = MEMBER_ID 
                      ,@order_email = MEMBER_EMAIL                  
                      ,@order_g_seq = ORDER_G_SEQ 
                FROM   CUSTOM_SAMPLE_ORDER 
                WHERE  SAMPLE_ORDER_SEQ = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN                
                    SET @ErrNum = 2428
                    SET @ErrMsg = '주문정보가 없습니다.'                     
                    RETURN
                END
               
            END
             ELSE BEGIN            
                SET @ErrNum = 2513
                SET @ErrMsg = '상품 구분 오류'                       
                RETURN    
            END
                        
            IF ISNULL(@pg_cancel,'') = '1' BEGIN
                SET @next_settle_status    = 5
                SET @next_statue_seq       = 5
            END
            ELSE BEGIN
                IF @settle_status >= 4 BEGIN
                    SET @next_settle_status = 5
                    SET @next_statue_seq    = 5
                END
                ELSE BEGIN
                    SET @next_settle_status = 3
                    SET @next_statue_seq    = 3
                END
            END
        END


        -------------------------------------------------------
        -- 트랜잭션 시작
        -------------------------------------------------------     
        BEGIN TRAN       
    
        
         --청첩장인경우
        IF @order_type = 'W' BEGIN

            --더카드 청첩장이고 PG취소 연동이 아닌 경우
            IF  @company_seq = 5007 AND ISNULL(@order_g_seq,0) <> 0  BEGIN
                BEGIN TRY
                UPDATE   CUSTOM_ORDER_GROUP
                SET      STATUS_SEQ          = @next_statue_seq_g
                        ,SRC_CANCEL_ADMIN_ID = @admin_id
                        ,SETTLE_STATUS       = @next_settle_status_g
                        ,SETTLE_CANCEL_DATE  = GETDATE()                        
                        ,PG_TID              = @npg_tid
                WHERE  ORDER_G_SEQ = @order_g_seq
                IF @@ROWCOUNT > 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2434
                    SET @ErrMsg = '청첩장 그룹 주문 취소 실패 ' + ERROR_MESSAGE()                        
                    RETURN
                END
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2436
                    SET @ErrMsg = '청첩장 그룹 주문 취소 실패 ' + ERROR_MESSAGE()                        
                    RETURN
                ENd CATCH
            END

             --바른손카드, 프리미어페이퍼,비핸즈카드,더카드인 경우 쿠폰 취소 처리
            IF @company_seq IN (5001,5003,5006,5007) AND ISNULL(@member_id,'')<>'' BEGIN
                BEGIN TRY
                    EXEC SP_COUPON_CANCEL @order_seq, @member_id
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2438
                    SET @ErrMsg = '쿠폰 취소 실패 ' + ERROR_MESSAGE()                        
                    RETURN  
                END CATCH
            END                       

            BEGIN TRY
                UPDATE CUSTOM_ORDER
                SET    STATUS_SEQ             = @next_statue_seq
                      ,SRC_CANCEL_DATE        = GETDATE()
                      ,SRC_CANCEL_ADMIN_ID    = @admin_id
                      ,SETTLE_STATUS          = @next_settle_status
                      ,SETTLE_CANCEL_DATE     = GETDATE()
                      ,PG_TID                 = @npg_tid
                      ,ISPRINTCOPY            = CASE ISNULL(@isclosecopy,'') WHEN '1' THEN '0' ELSE ISPRINTCOPY END
                      ,SRC_PRINTCOPY_DATE     = CASE ISNULL(@isclosecopy,'') WHEN '1' THEN NULL ELSE SRC_PRINTCOPY_DATE END
                      ,SRC_PRINTCOPY_ADMIN_ID = CASE ISNULL(@isclosecopy,'') WHEN '1' THEN NULL ELSE SRC_PRINTCOPY_ADMIN_ID END
                      ,CANCEL_TYPE            = CASE WHEN ISNULL(@cancel_type,'')<>'' AND ISNULL(@order_cancel_type_comment,'')<>'' THEN @cancel_type ELSE CANCEL_TYPE END
                      ,CANCEL_TYPE_COMMENT    = CASE WHEN ISNULL(@cancel_type,'')<>'' AND ISNULL(@order_cancel_type_comment,'')<>'' THEN @order_cancel_type_comment ELSE CANCEL_TYPE_COMMENT END
                      ,CANCEL_USER_TYPE       = CASE WHEN ISNULL(@cancel_type,'')<>'' AND ISNULL(@order_cancel_type_comment,'')<>'' THEN 1 ELSE CANCEL_USER_TYPE END
                WHERE  ORDER_SEQ            = @order_seq
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2440
                    SET @ErrMsg = '청첩장 주문 취소 실패 ' + ERROR_MESSAGE()                        
                    RETURN
                END
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2442
                SET @ErrMsg = '청첩장 주문 취소 실패 ' + ERROR_MESSAGE()                        
                RETURN
            END CATCH

            
            --재결제 요청시 'africa' 동의 삭제
            IF ISNULL(@pg_cancel,'') = '1'BEGIN

                IF ISNULL(@repay,'') = '1'  BEGIN
                    BEGIN TRY
                        DELETE CUSTOM_ORDER_AGREEMENT
                        WHERE AGREEMENT_TYPE = 'africa'
                        AND   ORDER_SEQ      = @order_seq
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRAN
                        SET @ErrNum = 2444
                        SET @ErrMsg = 'africa 동의 삭제 실패 ' + ERROR_MESSAGE()                        
                        RETURN
                    END CATCH           

                    SET @ment = '(PG결제취소 & 재결제처리)' + replace(@cancel_reason,'''','''''')
                END
                ELSE BEGIN
                    SET @ment = '(PG결제취소)' + replace(@cancel_reason,'''','''''')
                END

                SET @pcheck = 5
            END
            ELSE BEGIN
                IF ISNULL(@repay,'') = '1'  BEGIN
                    SET @ment = '(주문취소 & 재결제처리)' + replace(@cancel_reason,'''','''''')
                END
                ELSE BEGIN
                    SET @ment = '(주문취소)' + replace(@cancel_reason,'''','''''')
                END

                SET @pcheck = 3
            END

            BEGIN TRY                
                INSERT INTO CUSTOM_ORDER_ADMIN_MENT(ISWORDER,ORDER_SEQ,MENT,PCHECK,ADMIN_ID, MType, Category) 
                VALUES('1', @order_seq, @ment, @pcheck, @admin_id, 'AM01', 'AMC0701')
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2446
                SET @ErrMsg = '관리자 취소 메세지 등록 실패 ' + ERROR_MESSAGE()                        
                RETURN
            END CATCH   
        END       
        ELSE IF @order_type IN ('E','S') BEGIN

            IF @pg_cancel = '1' AND ISNULL(@order_g_seq,0) > 0 BEGIN
                 BEGIN TRY
                    UPDATE   CUSTOM_ORDER_GROUP
                    SET      STATUS_SEQ          = 5
                            ,SRC_CANCEL_ADMIN_ID = @admin_id
                            ,SETTLE_STATUS       = 5
                            ,SETTLE_CANCEL_DATE  = GETDATE()                                                    
                    WHERE  ORDER_G_SEQ = @order_g_seq
                    IF @@ROWCOUNT > 1 BEGIN
                        ROLLBACK TRAN
                        SET @ErrNum = 2437
                        SET @ErrMsg = '그룹 주문 취소 실패 ' + ERROR_MESSAGE()                        
                        RETURN
                    END
                    END TRY
                    BEGIN CATCH
                        ROLLBACK TRAN
                        SET @ErrNum = 2437
                        SET @ErrMsg = ' 그룹 주문 취소 실패 ' + ERROR_MESSAGE()                        
                        RETURN
                    END CATCH
            END

            IF @order_type = 'E' BEGIN            

                BEGIN TRY
                    UPDATE CUSTOM_ETC_ORDER
                    SET     STATUS_SEQ         = @next_statue_seq
                           ,SETTLE_CANCEL_DATE = GETDATE()
                           ,ADMIN_ID           = @admin_id                                                      
                    WHERE   ORDER_SEQ          = @order_seq           
                    IF @@ROWCOUNT <> 1 BEGIN
                        ROLLBACK TRAN
                        SET @ErrNum = 2448
                        SET @ErrMsg = '결제취소 실패(ETC)'            
                        RETURN
                    END  
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2450
                    SET @ErrMsg = '결제 취소 실패(ETC) ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END
            --샘플
            ELSE IF @order_type = 'S' BEGIN     

                BEGIN TRY
                    UPDATE  CUSTOM_SAMPLE_ORDER
                    SET     STATUS_SEQ        = @next_statue_seq
                           ,CANCEL_DATE       = GETDATE()
                           ,CANCEL_REASON     = @cancel_reason
                           ,ADMIN_ID          = @admin_id                       
                    WHERE   SAMPLE_ORDER_SEQ  = @order_seq  
                    IF @@ROWCOUNT <> 1 BEGIN
                        ROLLBACK TRAN
                        SET @ErrNum = 2452
                        SET @ErrMsg = '결제 취소 실패(SAMPLE)'            
                        RETURN
                    END  
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2454
                    SET @ErrMsg = '결제 취소 실패(SAMPLE) ' + ERROR_MESSAGE()            
                    RETURN                
                END CATCH

            END  
        END
        --지시서 검증 취소처리.
        IF ISNULL(@isclosecopy,'') = '1' BEGIN
            BEGIN TRY
                UPDATE DELIVERY_INFO
                SET  SAVEPACK_DATE     = NULL
                    ,SAVEPACK_ADMIN_ID = NULL
                WHERE ORDER_SEQ = @order_seq
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2456
                SET @ErrMsg = '지시서 검증 취소 실패(1) ' + ERROR_MESSAGE()            
                RETURN    
            END CATCH

            BEGIN TRY
                DELETE FROM CUSTOM_ORDER_COPY_DETAIL                
                WHERE ORDER_SEQ = @order_seq
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2458
                SET @ErrMsg = '지시서 검증 취소 실패(2) ' + ERROR_MESSAGE()            
                RETURN    
            END CATCH

            BEGIN TRY
                DELETE FROM CUSTOM_ORDER_COPY                
                WHERE ORDER_SEQ = @order_seq
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2460
                SET @ErrMsg = '지시서 검증 취소 실패(3) ' + ERROR_MESSAGE()            
                RETURN    
            END CATCH

            BEGIN TRY
                INSERT INTO CUSTOM_ORDER_HISTORY(ORDER_SEQ,HTYPE,ADMIN_ID,MEMO,SYSTEM_SQL)
                                          VALUES(@order_seq, '검증취소', @admin_id, '지시서 검증 취소', '')
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2462
                SET @ErrMsg = '지시서 검증 취소 실패(4) ' + ERROR_MESSAGE()            
                RETURN    
            END CATCH
        END

        --가상계좌 취소처리
        IF @settle_method = '3' BEGIN
            BEGIN TRY
               UPDATE TOSS_VACCOUNT
               SET    [STATUS] = 4
               WHERE  ORDER_TYPE = @order_type
               AND    ORDER_SEQ  = @order_seq
               AND    TOSS_ORDERID = @pg_tid
            END TRY
            BEGIN CATCH
               -- 오류처리 하지 않음
            END CATCH
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
		SET @ErrMsg   = '결제 취소 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


