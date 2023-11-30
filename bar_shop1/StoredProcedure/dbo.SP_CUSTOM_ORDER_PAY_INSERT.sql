USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]    Script Date: 2023-07-05 ���� 9:29:35 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]    Script Date: 2023-07-05 ���� 9:29:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_INSERT
-- Author        : ������
-- Create date   : 2023-04-04
-- Description   : �ֹ� ���� ���� ���
-- Update History: 2023-06-30 :����/BizTalk �ϰ� ó�� �߰�(������)
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]     
     @order_seq                      INT                        --�ֹ���ȣ     
    ,@sales_gubun                    VARCHAR(2)      = NULL     --B:����,H:���� ����, SA:������, SS:����,SB: �ٸ���, ST:��ī��,D:�븮�� , P:�ƿ��ٿ��, Q:�����븮��
    ,@company_seq                    INT             = NULL     --
    ,@order_category                 VARCHAR(1)      = NULL     --�ֹ� ���� ("W":ûø�� "S":���� "E":�ΰ���ǰ,���ǰ) 
    ,@order_type                     VARCHAR(2)      = NULL     --�ֹ�Ÿ�� 

    ,@card_div                       VARCHAR(5)      = NULL     --ī�屸�� (A01:ī�� A02:���� A03:�λ縻ī�� .... C08:���ǰ...)
    ,@settle_method                  CHAR(1)         = NULL     --�������(1:������ü,3:������,2,6:ī��, 8:īī������)
    ,@settle_price                   INT             = NULL     --�����ݾ�
    ,@pg_shopid                      VARCHAR(20)     = NULL     --PG���̵�
    ,@dacom_tid                      VARCHAR(200)    = NULL     --PG�� �ŷ���ȣ

    ,@card_installmonth              VARCHAR(10)     = NULL     --ī�� �Һΰ�����
    ,@card_nointyn                   CHAR(1)         = NULL     --ī�� �����ڿ���    
    ,@card_issuercode                VARCHAR(3)      = NULL     --ī�� �߱޻��ڵ�
    ,@card_approveno                 VARCHAR(20)      = NULL    --ī�����ι�ȣ    
    ,@bank_code                      VARCHAR(3)      = NULL     --�����ڵ�(�������/������ü)

    ,@vaccount_number                VARCHAR(50)     = NULL     --������¹�ȣ
    ,@vaccount_name                  VARCHAR(50)     = NULL     --������� �Ա��ڸ�
    ,@due_date                       VARCHAR(50)     = NULL     --������� �Աݱ���
    ,@secret                         VARCHAR(50)     = NULL     --������� ����Ű
    ,@receipt_url                    VARCHAR(200)    = NULL     --������ URL

    ,@isascrow                       CHAR(1)         = NULL     --�ֽ�ũ��
    ,@easypay_provider               VARCHAR(50)     = NULL     --������� ������ 
    ,@device_type                    CHAR(1)                    --����̽� (P:PC M:Mobile)    
    ,@member_id                      VARCHAR(50)     = NULL     --ȸ��/��ȸ�� ���̵� 
    ,@uid                            VARCHAR(50)     = NULL     --ȸ�����̵� 

    ,@guid                           VARCHAR(50)     = NULL     --������ GUID?
    ,@coupon_seq_list                VARCHAR(100)    = NULL     --�������� ����Ʈ

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
        DECLARE @status_seq                 INT = 0
        DECLARE @src_printer_seq            SMALLINT = 0 
        DECLARE @src_confirm_date           SMALLDATETIME
        DECLARE @src_ap_date                SMALLDATETIME
        DECLARE @settle_date                SMALLDATETIME
        DECLARE @order_date                 SMALLDATETIME
        DECLARE @settle_status              TINYINT
        DECLARE @isreceipt                  CHAR(1) = '0'
        DECLARE @auto_choan_status_code     VARCHAR(6)
        DECLARE @org_up_order_seq           INT = NULL
        DECLARE @org_order_count            INT = NULL
        DECLARE @org_order_type             VARCHAR(2)
        DECLARE @org_order_email            VARCHAR(50)
        DECLARE @org_member_id              VARCHAR(50)
        DECLARE @printW_status              TINYINT 
        DECLARE @pg_resultinfo              VARCHAR(1000)   = ''
        DECLARE @pg_resultinfo2             VARCHAR(1000)   = '' 
        DECLARE @pg_tid                     VARCHAR(200) 
        DECLARE @bank_name                  VARCHAR(30) 
        DECLARE @last_total_price           INT 

        -------------------------------------------------------
        -- �Ķ���� ��ȿ�� üũ
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0 
           OR ISNULL(@settle_method,'') = ''
           OR ISNULL(@company_seq,0) = 0 
           OR ISNULL(@sales_gubun,'') = ''
           OR ISNULL(@order_category,'') = ''
           OR ISNULL(@order_type,'') = ''
           OR ISNULL(@member_id,'') = '' BEGIN    
            SET @ErrNum = 2001
            SET @ErrMsg = '�����Ͱ� ��ȿ���� �ʽ��ϴ�.'            
            RETURN
        END

        -------------------------------------------------------
        -- �ֹ����� ��ȸ
        -------------------------------------------------------     
        --ûø��
        IF @order_category = 'W' BEGIN 

            SELECT @status_seq             = STATUS_SEQ
                  ,@src_printer_seq        = SRC_PRINTER_SEQ 
                  ,@src_confirm_date       = SRC_CONFIRM_DATE
                  ,@settle_date            = SETTLE_DATE
                  ,@src_ap_date            = SRC_AP_DATE
                  ,@order_date             = ORDER_DATE
                  ,@auto_choan_status_code = AUTO_CHOAN_STATUS_CODE
                  ,@org_up_order_seq       = ISNULL(UP_ORDER_SEQ,0)
                  ,@org_order_count        = ORDER_COUNT
                  ,@org_order_type         = ORDER_TYPE
                  ,@org_order_email        = ORDER_EMAIL
                  ,@org_member_id          = MEMBER_ID
                  ,@printW_status          = PRINTW_STATUS   
                  ,@settle_status          = SETTLE_STATUS
                  ,@pg_tid                 = PG_TID
                  ,@last_total_price       = LAST_TOTAL_PRICE
            FROM   CUSTOM_ORDER 
            WHERE  ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2500
                SET @ErrMsg = '�ֹ������� �����ϴ�.'                     
                RETURN                                
            END

            IF @settle_status = 2 BEGIN
                SET @ErrNum = 2501
                SET @ErrMsg = '�̹� ������ �Ϸ�� ���Դϴ�.'                     
                RETURN        
            END

            --0�� ������ ������ȣ ���� �� ��� ���� �ݾװ� ��
            IF ISNULL(@settle_price,0) = 0 AND TRIM(ISNULL(@coupon_seq_list,'')) = '' BEGIN
                IF ISNULL(@last_total_price,0) <> 0 BEGIN
                    SET @ErrNum = 2502
                    SET @ErrMsg = '������� �ݾ��� ��ġ���� �ʽ��ϴ�.(������ȣ ����)'                     
                    RETURN    
                END
            END


        END
        --���ǰ/�ΰ���ǰ
        ELSE IF @order_category = 'E' BEGIN

            SELECT  @status_seq      = STATUS_SEQ
                   ,@settle_date     = SETTLE_DATE                   
                   ,@order_date      = ORDER_DATE                   
                   ,@org_order_type  = ORDER_TYPE
                   ,@org_order_email = ORDER_EMAIL
                   ,@org_member_id   = MEMBER_ID
                   ,@pg_tid          = PG_TID
            FROM    CUSTOM_ETC_ORDER 
            WHERE   ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2505
                SET @ErrMsg = '�ֹ������� �����ϴ�.'                     
                RETURN
            END

            IF @status_seq = 4 BEGIN                
                SET @ErrNum = 2507
                SET @ErrMsg = '�̹� ������ �Ϸ�� ���Դϴ�.' 
                RETURN
            END
        END
        --�����ֹ�
        ELSE IF @order_category = 'S' BEGIN
            SELECT  @status_seq    = STATUS_SEQ
                   ,@settle_date   = SETTLE_DATE                   
                   ,@order_date    = REQUEST_DATE                                  
                   ,@org_member_id = MEMBER_ID
                   ,@pg_tid        = PG_TID
            FROM    CUSTOM_SAMPLE_ORDER 
            WHERE   SAMPLE_ORDER_SEQ = @order_seq  
            IF @@ROWCOUNT <> 1 BEGIN                
                SET @ErrNum = 2509
                SET @ErrMsg = '�ֹ������� �����ϴ�.'                     
                RETURN
            END

            IF @status_seq = 4 BEGIN                
                SET @ErrNum = 2511
                SET @ErrMsg = '�̹� ������ �Ϸ�� ���Դϴ�.' 
                RETURN
            END
        
        END
         ELSE BEGIN            
            SET @ErrNum = 2513
            SET @ErrMsg = '��ǰ ���� ����'                       
            RETURN    
        END

        IF @settle_method = '1' AND ISNULL(@bank_code,'')<>'' BEGIN
            SELECT @pg_resultinfo = CODE_VALUE
            FROM MANAGE_CODE
            WHERE CODE_TYPE='toss_bank'
            AND CODE= @bank_code

            IF ISNULL(@pg_resultinfo,'') = '' BEGIN 
                SET @pg_resultinfo = @bank_code
            END

            IF ISNULL(@easypay_provider,'')<>'' BEGIN
                SET @pg_resultinfo2 = @easypay_provider
            END
        END
        ELSE IF @settle_method = '2' AND ISNULL(@card_issuercode,'')<>'' BEGIN
            SELECT @pg_resultinfo = CODE_VALUE
            FROM MANAGE_CODE
            WHERE CODE_TYPE='toss_card'
            AND CODE= @card_issuercode

            SET @pg_resultinfo = @pg_resultinfo+' '+@card_approveno

            IF ISNULL(@easypay_provider,'')<>'' BEGIN
                SET @pg_resultinfo2 = @easypay_provider
            END
        END
        ELSE IF @settle_method = '3' AND ISNULL(@bank_code,'')<>'' BEGIN
            SELECT @bank_name = CODE_VALUE
            FROM MANAGE_CODE
            WHERE CODE_TYPE='toss_bank'
            AND CODE= @bank_code

            IF ISNULL(@bank_name,'') = '' BEGIN 
                SET @bank_name = @bank_code
            END

            SET @pg_resultinfo = @bank_name+' '+@vaccount_number
            SET @pg_resultinfo2 = @vaccount_name
        END
        ELSE IF @settle_method = '9' BEGIN
            SET @pg_resultinfo = '������� ' + ISNULL(@easypay_provider,'')
        END

        If ISNULL(@receipt_url,'')<>'' BEGIN
            SET @isreceipt = '1'
        END 

        -------------------------------------------------------
        -- Ʈ����� ����
        -------------------------------------------------------     
        BEGIN TRAN 


        
         --ûø���ΰ��
        IF @order_category = 'W' BEGIN
            
            
            --���� ��� ó��, �ٸ��ո��� ��� ������ ��ó����
            IF ISNULL(@coupon_seq_list,'')<>'' AND @sales_gubun NOT IN ('B','SA')  BEGIN

               

                EXEC SP_COUPON_COMPLETE_INNER @member_id, @order_seq, @coupon_seq_list, @settle_price, @device_type
                                             ,@ErrNum OUT, @ErrMsg OUT               
               
               --���� ��� ����
               IF ISNULL(@ErrNum,1) <> 0 BEGIN
                     ROLLBACK TRAN
                     SET @ErrNum = 9999
                     SET @ErrMsg = '���� ��� �ݾ��� ��ġ���� �ʽ��ϴ� '
                     RETURN     
                END
            END                              

            --��Ư���� ���
            IF @order_type = 'WS' BEGIN
                --�����̾�������,�ٸ���ī��
                IF  @sales_gubun = 'SS' OR (@sales_gubun IN ('SB','SA','B') AND @status_seq NOT IN (6, 7, 8, 9, 10, 11, 12, 13, 14, 15)) BEGIN
                    SET @status_seq = 1                     
                END  
                
                --�ٸ��ո�
                IF @sales_gubun IN ( 'SA','B') BEGIN
                    SET @printW_status = 0
                END

                SET @order_date = GETDATE()                
            END
            ELSE BEGIN
                --�����̾�������
                IF  @sales_gubun = 'SS' BEGIN
                    SET @status_seq = 9   
                    SET @src_confirm_date = GETDATE()
                END
                --�ٸ���ī��
                ELSE IF @sales_gubun = 'SB' BEGIN
                    IF @auto_choan_status_code = '138003' BEGIN
                        SET @auto_choan_status_code = '138001'
                    END
                END
            END

            --�����̾�������
            IF  @sales_gubun = 'SS' BEGIN
                SET @src_printer_seq  = 2
            END

            IF TRIM(ISNULL(@org_member_id,'')) = '' BEGIN
                SET @org_member_id = @org_order_email
            END  

           --������� �߱��� ���
            IF @settle_method = '3' BEGIN
                SET @settle_status = 1                
                SET @card_installmonth =''
                SET @card_nointyn = ''
            END
            --�׿� ���� �Ϸ��� ���(������ü/�ſ�ī���)
            ELSE BEGIN
                SET @settle_status = 2
                SET @settle_date = GETDATE()
                SET @src_ap_date = @settle_date                                              
            END
            

            BEGIN TRY
                UPDATE CUSTOM_ORDER
                SET    STATUS_SEQ             = @status_seq
                      ,PRINTW_STATUS          = @printW_status
                      ,ORDER_DATE             = @order_date
                      ,SETTLE_STATUS          = @settle_status
                      ,SETTLE_METHOD          = @settle_method
                      ,SRC_PRINTER_SEQ        = @src_printer_seq
                      ,SRC_CONFIRM_DATE       = @src_confirm_date
                      ,INFLOW_ROUTE_SETTLE    = CASE @device_type WHEN 'P' THEN 'PC' ELSE 'Mobile' END
                      ,SETTLE_DATE            = @settle_date
                      ,SRC_AP_DATE            = @src_ap_date
                      ,SETTLE_PRICE           = @settle_price
                      ,PG_RESULTINFO          = @pg_resultinfo
                      ,PG_RESULTINFO2         = @pg_resultinfo2
                      ,PG_SHOPID              = @pg_shopid                        
                      ,DACOM_TID              = @dacom_tid
                      ,ISRECEIPT              = @isreceipt
                      ,ISASCROW               = @isascrow
                      ,CARD_INSTALLMONTH      = @card_installmonth
                      ,CARD_NOINTYN           = @card_nointyn
                      ,AUTO_CHOAN_STATUS_CODE = @auto_choan_status_code
                      ,RECEIPTURL              = @receipt_url
                WHERE  ORDER_SEQ  = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2517
                    SET @ErrMsg = '�������� ��� ����'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '�������� ��� ���� ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH
                        

            --��Ư���� �ƴѰ�� 
            IF @order_type <> 'WS' BEGIN
                
                BEGIN TRY     
                    --�ʾ� Ȯ�� ���·� ������Ʈ
                    UPDATE PREVIEW
                    SET    PSTATUS   = 9
                    WHERE  ORDER_SEQ = @order_seq  
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2524
                    SET @ErrMsg = '�ʾ� Ȯ�� ���� ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH  
            END
            

            --�ٸ���ī��,�����̾�������
            IF @sales_gubun IN ('SB','SS') AND @settle_price >= 50000 AND @settle_method <> '3' AND ISNULL(@uid,'') <> '' BEGIN 
                BEGIN TRY
                    INSERT INTO S2_EVENT (SALES_GUBUN, COMPANY_SEQ, [UID], CHARGE_USE, CHARGE_USE_SEQ, CHARGE_USE_NUM)
                                  VALUES (@sales_gubun,@company_seq, @uid, 'A',1,1)
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2528
                    SET @ErrMsg = '�̺�Ʈ ��� ���� ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END           
        END
        --���ǰ �Ǵ� �ΰ���ǰ�ΰ��  
        ELSE IF @order_category = 'E' BEGIN

            IF @settle_method = '3' BEGIN
                SET @status_seq = 1                                
                SET @card_installmonth =''
                SET @card_nointyn = ''
            END
            ELSE BEGIN
               SET @status_seq = 4 
               SET @settle_date = GETDATE()               
            END

             BEGIN TRY
                UPDATE CUSTOM_ETC_ORDER
                SET     STATUS_SEQ        = @status_seq
                       ,SETTLE_METHOD     = @settle_method
                       ,SETTLE_DATE       = @settle_date
                       ,SETTLE_PRICE      = @settle_price
                       ,PG_RESULTINFO     = @pg_resultinfo
                       ,PG_RESULTINFO2    = @pg_resultinfo2
                       ,PG_SHOPID         = @pg_shopid                        
                       ,DACOM_TID         = @dacom_tid
                       ,ISRECEIPT         = @isreceipt
                       ,ISASCROW          = @isascrow
                       ,CARD_INSTALLMONTH = @card_installmonth
                       ,CARD_NOINTYN      = @card_nointyn
                       ,RECEIPTURL        = @receipt_url
                WHERE   ORDER_SEQ         = @order_seq           
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2532
                    SET @ErrMsg = '�������� ��� ����(ETC)'            
                    RETURN
                END  
               END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2005
                SET @ErrMsg = '�������� ��� ����(ETC) ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

            --���ǰ ERP �������̺� ������Ʈ
            IF ISNULL(@card_div,'') = 'C08' BEGIN
                BEGIN TRY                
                    UPDATE CUSTOM_ETC_ORDER_GIFT_ITEM
                    SET    USE_YN   = 'Y'
                          ,MOD_DATE =  GETDATE()
                    WHERE  ORDER_SEQ = @order_seq                
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2534
                    SET @ErrMsg = '���ǰ ERP ���� ���� ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END

            --�ٸ��ո�
            IF @sales_gubun IN ('SA','B') AND @order_type in ('D','K','R') AND ISNULL(@uid,'') <> '' BEGIN 
                BEGIN TRY
                    -- ��ٱ��� ����                
                    DELETE FROM S2_USRBASKET
                    WHERE  [uid] = @uid                    
                    AND    CARD_SEQ IN (SELECT CARD_SEQ 
                                        FROM CUSTOM_ETC_ORDER_ITEM 
                                        WHERE ORDER_SEQ = @order_seq)                                               
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2536
                    SET @ErrMsg = '���� ��ٱ��� ���� ���� ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END
        END
        --�����ֹ�
        ELSE IF @order_category = 'S' BEGIN           

            IF @settle_method = '3' BEGIN
                set @status_seq = 1                                
                SET @card_installmonth =''
                SET @card_nointyn = ''
            END
            ELSE BEGIN
               set @status_seq = 4 
               set @settle_date = GETDATE()
               SET @order_date = GETDATE()                
            END

            BEGIN TRY
                UPDATE CUSTOM_SAMPLE_ORDER
                SET     STATUS_SEQ        = @status_seq
                       ,SETTLE_METHOD     = @settle_method
                       ,SETTLE_DATE       = @settle_date
                       ,REQUEST_DATE      = @order_date
                       ,SETTLE_PRICE      = @settle_price
                       ,PG_RESULTINFO     = @pg_resultinfo
                       ,PG_RESULTINFO2    = @pg_resultinfo2
                       ,PG_MERTID         = @pg_shopid                        
                       ,DACOM_TID         = @dacom_tid
                       ,ISDACOM           = @isreceipt
                       ,ISASCROW          = @isascrow
                       ,CARD_INSTALLMONTH = @card_installmonth
                       ,CARD_NOINTYN      = @card_nointyn
                       ,RECEIPTURL        = @receipt_url
                WHERE   SAMPLE_ORDER_SEQ  = @order_seq  
                IF @@ROWCOUNT <> 1 BEGIN
                    ROLLBACK TRAN
                    SET @ErrNum = 2538
                    SET @ErrMsg = '�������� ��� ����(SAMPLE)'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2540
                SET @ErrMsg = '�������� ��� ����(SAMPLE) ' + ERROR_MESSAGE()            
                RETURN                
            END CATCH

            BEGIN TRY
                --���� ��ٱ��� ����� �ֹ�ī�� ����
                IF ISNULL(@uid,'') <> '' BEGIN 
                    DELETE FROM s2_samplebasket
                    WHERE  [uid] = @uid
                    AND    COMPANY_SEQ = @company_seq       -- �ٸ��ո��� ��� real_company_seq���� �Ѿ��
                    AND    CARD_SEQ IN (SELECT CARD_SEQ 
                                        FROM   CUSTOM_SAMPLE_ORDER_ITEM 
                                        WHERE   SAMPLE_ORDER_SEQ = @order_seq)               
                END
                ELSE IF ISNULL(@guid,'') <> ''  BEGIN  
                    DELETE FROM s2_samplebasket
                    WHERE  [guid] = @guid
                    AND    COMPANY_SEQ = @company_seq       -- �ٸ��ո��� ��� real_company_seq���� �Ѿ��
                    AND    CARD_SEQ IN (SELECT CARD_SEQ 
                                        FROM   CUSTOM_SAMPLE_ORDER_ITEM 
                                        WHERE  SAMPLE_ORDER_SEQ = @order_seq)    
                END 
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2542
                SET @ErrMsg = '���� ��ٱ��� ���� ���� ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

        END 

        --������� �߱� ���� ���
        IF @settle_method='3' BEGIN
            BEGIN TRY
                 INSERT INTO TOSS_VACCOUNT ( ORDER_TYPE, ORDER_SEQ, TOSS_SECRET, TOSS_ORDERID, SETTLE_PRICE
                                            ,DUE_DATE, BANK_NAME, VACCT_NUMBER, VACCT_NAME, [STATUS])
                                    VALUES ( @order_category, @order_seq, @secret, @pg_tid,@settle_price
                                            ,@due_date, @bank_name, @vaccount_number, @vaccount_name,1)
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2544
                SET @ErrMsg = '������� ���� ��� ���� ' + ERROR_MESSAGE()                        
                RETURN                            
            END CATCH          
        END

        --�����߱�(���翵��/��������/���������� ���� ��) �� BizTalk �߼�
        BEGIN TRY

            EXEC SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC @order_seq, @sales_gubun, @company_seq, @order_category, @order_type
                                            ,@member_id, @uid, NULL, NULL, NULL
                                            ,NULL, NULL,NULL
        END TRY
        BEGIN CATCH
            -- ����ó�� ����
        END CATCH          
       
       --�ֹ� �Ϸ� BIZTALK ����
       BEGIN TRY         
            EXEC SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC @order_seq, @sales_gubun, @company_seq, @order_category, @order_type
                                            ,@settle_method, @settle_price, NULL, NULL, NULL
                                            ,NULL, NULL,NULL
        END TRY
        BEGIN CATCH
            -- ����ó�� ����
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


