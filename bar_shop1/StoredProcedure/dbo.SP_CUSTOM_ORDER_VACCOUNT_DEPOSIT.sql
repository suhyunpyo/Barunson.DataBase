USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT]    Script Date: 2023-04-26 ���� 7:40:48 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT]    Script Date: 2023-04-26 ���� 7:40:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : [SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT
-- Author        : ������
-- Create date   : 2023-04-10
-- Description   : ������� �Ա�ó��
-- Update History:
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_VACCOUNT_DEPOSIT]      
     @toss_secret                    VARCHAR(50)                --�ŷ� ����Ű
    ,@toss_orderid                   VARCHAR(50)                --�ֹ���ȣ (�� �ֹ����̺��� pg_tid)    
    
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

    BEGIN TRY        

        -------------------------------------------------------
        -- �Ķ���� ��ȿ�� üũ
        -------------------------------------------------------            
        IF ISNULL(@toss_secret,'') = '' OR ISNULL(@toss_orderid,'') = '' BEGIN    
            SET @ErrNum = 2300
            SET @ErrMsg = '�����Ͱ� ��ȿ���� �ʽ��ϴ�.'            
            RETURN
        END

        -------------------------------------------------------
        -- �ֹ����� ��ȸ
        -------------------------------------------------------     
        SELECT  @order_type = ORDER_TYPE
               ,@order_seq  = ORDER_SEQ
               ,@status    = [STATUS]             
        FROM    TOSS_VACCOUNT 
        WHERE   toss_orderid = @toss_orderid
        AND     toss_secret  = @toss_secret
        IF @@ROWCOUNT <> 1 BEGIN
            SET @ErrNum = 2302
            SET @ErrMsg = '������� �߱������� �������� �ʽ��ϴ�.'            
            RETURN
        END

        --�̹� �ԱݿϷ�� ���¸� ���Ƽ������ �����Ͽ� ����ó��
        IF @status = 2 BEGIN
            SET @ErrNum = 0
            SET @ErrMsg = 'OK'            
            RETURN
        END

        
        -------------------------------------------------------
        -- Ʈ����� ����
        -------------------------------------------------------     
        BEGIN TRAN         

        --ûø��
        IF @order_type = 'W' BEGIN 

           BEGIN TRY
                UPDATE CUSTOM_ORDER
                SET    SETTLE_STATUS   = 2
                      ,SETTLE_DATE  = GETDATE()
                      ,SRC_AP_DATE  = GETDATE()   
                      ,@member_id   = MEMBER_ID
                      ,@company_seq = COMPANY_SEQ
                WHERE  ORDER_SEQ    = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '���������� �������� �ʽ��ϴ�.'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '�������� ��� ���� ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

            IF LEFT(@toss_orderid,2) <> 'IS' AND LEFT(@toss_orderid,2) <> 'ET' BEGIN
                BEGIN TRY                    
                    --����ǰ ���� Ȯ��
                    EXEC SP_INSERT_FREE_GIFT @order_seq                                      
                END TRY
                BEGIN CATCH  
                END CATCH    
            END

            --�ٸ���ī��
            IF @company_seq = 5001 BEGIN
                BEGIN TRY                    
                    --�������� ���� �߱�
                    EXEC SP_INSERT_MOVIE_EVENT_SB @order_seq, @member_id
                END TRY
                BEGIN CATCH  
                END CATCH    
            END

            --�ٸ��� ��
            IF @company_seq = 5006 BEGIN
                BEGIN TRY                    
                    --�������� ���� �߱�
                    EXEC SP_INSERT_MOVIE_EVENT_SA @order_seq, @member_id
                END TRY
                BEGIN CATCH  
                END CATCH    
            END
        END
        --���ǰ/�ΰ���ǰ
        ELSE IF @order_type = 'E' BEGIN           

           BEGIN TRY
                UPDATE CUSTOM_ETC_ORDER
                SET    STATUS_SEQ  = 4
                      ,SETTLE_DATE = GETDATE()                      
                WHERE  ORDER_SEQ   = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '���������� �������� �ʽ��ϴ�.'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '�������� ��� ���� ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH
        END

        --�����ֹ�
        ELSE IF @order_type = 'S' BEGIN
            
            BEGIN TRY
                UPDATE CUSTOM_SAMPLE_ORDER
                SET    STATUS_SEQ       = 4
                      ,SETTLE_DATE      = GETDATE()                                        
                WHERE  SAMPLE_ORDER_SEQ = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '���������� �������� �ʽ��ϴ�.'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '�������� ��� ���� ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

        END
         ELSE BEGIN      
            ROLLBACK TRAN
            SET @ErrNum = 2308
            SET @ErrMsg = '��ǰ ���� ����'                       
            RETURN    
        END   

        BEGIN TRY
            UPDATE TOSS_VACCOUNT
            SET   [STATUS] = 2   
                  ,UPD_DATE = GETDATE()
            WHERE  ORDER_SEQ    = @order_seq 
            AND    TOSS_ORDERID = @toss_orderid
            AND    TOSS_SECRET  = @toss_secret
        END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2310
                SET @ErrMsg = '������� ���� ���� ���� ' + ERROR_MESSAGE()                        
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
		SET @ErrMsg   = '���� ���� ��� ���� (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


