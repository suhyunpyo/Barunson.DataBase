USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]    Script Date: 2023-07-05 ���� 11:40:57 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]    Script Date: 2023-07-05 ���� 11:40:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC
-- Author        : ������
-- Create date   : 2023-06-29
-- Description   : �ֹ� ���� �Ϸ�� ���� ���� ó��
-- Update History: 
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC]     
     @order_seq                      INT                        --�ֹ���ȣ     
    ,@sales_gubun                    VARCHAR(2)      = NULL     --B:����,H:���� ����, SA:������, SS:����,SB: �ٸ���, ST:��ī��,D:�븮�� , P:�ƿ��ٿ��, Q:�����븮��
    ,@company_seq                    INT             = NULL     --
    ,@order_category                 VARCHAR(1)      = NULL     --�ֹ� ���� ("W":ûø�� "S":���� "E":�ΰ���ǰ,���ǰ) 
    ,@order_type                     VARCHAR(2)      = NULL     --�ֹ�Ÿ�� 
    
    ,@member_id                      VARCHAR(50)     = NULL     --ȸ��/��ȸ�� ���̵� 
    ,@uid                            VARCHAR(50)     = NULL     --ȸ�����̵� 

    ,@ErrNum                         INT             OUTPUT
    ,@ErrSev                         INT             OUTPUT
    ,@ErrState                       INT             OUTPUT
    ,@ErrProc                        VARCHAR(50)     OUTPUT
    ,@ErrLine                        INT             OUTPUT
    ,@ErrMsg                         VARCHAR(2000)   OUTPUT
AS

SET NOCOUNT ON
BEGIN

    BEGIN TRY        
        DECLARE @up_order_seq               INT = 0
        DECLARE @order_count                INT = 0        
        DECLARE @thank_coupon               VARCHAR(50) = ''    --������ ���� ���� ��ȣ
        DECLARE @evt_video_coupon_mst_seq   INT         = 0     --������������
        DECLARE @thk_video_coupon_mst_seq   INT         = 0     --���翵������
        DECLARE @card_seq                   INT
        DECLARE @coupon_seq                 VARCHAR(50)
        DECLARE @addition_couponseq         VARCHAR(50)
        DECLARE @org_order_type             VARCHAR(2) 

        DECLARE @is_member                   BIT         = 0     --1:ȸ�� 0:��ȸ�� �ֹ�
        DECLARE @is_org_order                BIT         = 0     --1:���ֹ� 0:�߰��ֹ�

        -------------------------------------------------------
        -- �Ķ���� ��ȿ�� üũ
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0  OR ISNULL(@sales_gubun,'') = '' OR ISNULL(@member_id,'') = '' BEGIN    
            SET @ErrNum = 3001
            SET @ErrMsg = '�����Ͱ� ��ȿ���� �ʽ��ϴ�.'            
            RETURN
        END

        --ȸ������ 
        IF ISNULL(@uid,'') <> '' BEGIN
            SET @is_member = 1
        END        
        
         --ûø���ΰ��
        IF @order_category = 'W' BEGIN

            --�ֹ����� ��ȸ
            SELECT @up_order_seq   = UP_ORDER_SEQ
                  ,@order_count    = ORDER_COUNT
                  ,@card_seq       = CARD_SEQ
                  ,@coupon_seq     = ISNULL(COUPONSEQ,'')
                  ,@addition_couponseq = ISNULL(ADDITION_COUPONSEQ,'')
                  ,@org_order_type = order_type
            FROM   CUSTOM_ORDER WITH(NOLOCK)
            WHERE  ORDER_SEQ = @order_seq
            IF @@ROWCOUNT <> 1 BEGIN
                SET @ErrNum = 3003
                SET @ErrMsg = 'ûø�� �ֹ������� �����ϴ�.'            
                RETURN
            END

            --���ֹ� ���� 
            IF ISNULL(@up_order_seq,0) = 0 BEGIN
                SET @is_org_order = 1
            END

            ------------------------------------------------------------------
            -- ����������/��������/���翵�� ���� ���� SET
            ------------------------------------------------------------------
            --�ٸ���ī�� 
            IF @sales_gubun = 'SB'  BEGIN                              
                SET @thank_coupon = 'C600-1862-412D-AA73'
                SET @evt_video_coupon_mst_seq = 301
                SET @thk_video_coupon_mst_seq = 627
            END
            --�����̾������� 
            ELSE IF @sales_gubun = 'SS'  BEGIN           
                SET @thank_coupon = '5E3F-86BA-4EAE-B723'
                SET @evt_video_coupon_mst_seq = 291
                SET @thk_video_coupon_mst_seq = 292
            END 
            --�ٸ��ո�
            ELSE IF @sales_gubun IN ('SA','B')  BEGIN           
                SET @thank_coupon = 'BHS15THK0101'
            END                       
            
            ------------------------------------------------------------------
            -- ������� ó���� ����������/���翵��/�������� ���� �� �߱� ó��
            ------------------------------------------------------------------
            --�ٸ����� ��� ���޹�� �ٸ�
            IF @sales_gubun IN ('SA','B')  BEGIN  
                
                --���ֹ��ΰ�츸 
                IF @is_org_order = 1 BEGIN
                     -- 35108 // BH5009(35097) ��ƼĿ // (ī���û���ǰ)   
                    IF @card_seq = 35097  BEGIN
                        IF NOT EXISTS(SELECT ID 
                                      FROM   CUSTOM_ORDER_ITEM WITH(NOLOCK)
                                      WHERE  ORDER_SEQ = @order_seq
                                      AND    CARD_SEQ  = 35108
                                      AND    ITEM_TYPE = 'H') BEGIN
                            INSERT INTO CUSTOM_ORDER_ITEM(ORDER_SEQ,CARD_SEQ,ITEM_TYPE,ITEM_PRICE,ITEM_SALE_PRICE,ITEM_COUNT) 
                                                   VALUES(@order_seq,35108,'H',0,0,10)
                        END
                    END
                    -- 35107 // BH5005,5006 ��ƼĿ // (ī���û���ǰ)  
                    ELSE IF @card_seq IN (35203, 35202)  BEGIN
                        IF NOT EXISTS(SELECT ID 
                                      FROM   CUSTOM_ORDER_ITEM WITH(NOLOCK)
                                      WHERE  ORDER_SEQ = @order_seq
                                      AND    CARD_SEQ  = 35107
                                      AND    ITEM_TYPE = 'H') BEGIN
                            INSERT INTO CUSTOM_ORDER_ITEM(ORDER_SEQ,CARD_SEQ,ITEM_TYPE,ITEM_PRICE,ITEM_SALE_PRICE,ITEM_COUNT) 
                                                   VALUES(@order_seq,35107,'H',0,0,10)
                        END
                    END                
                    ELSE IF @card_seq IN (35382, 35385, 35386) AND @order_type <> 'WS' BEGIN --��Ư���� �ƴѰ�츸
                        IF NOT EXISTS(SELECT ID 
                                      FROM   CUSTOM_ORDER_ITEM WITH(NOLOCK)
                                      WHERE  ORDER_SEQ = @order_seq
                                      AND    CARD_SEQ  = 35387
                                      AND    ITEM_TYPE = 'H') BEGIN
                            INSERT INTO CUSTOM_ORDER_ITEM(ORDER_SEQ, CARD_SEQ, ITEM_TYPE, ITEM_COUNT, ITEM_PRICE
                                                         ,ITEM_SALE_PRICE, DISCOUNT_RATE, MEMO1, ADDNUM_PRICE, REG_DATE) 
                                                   values(@order_seq, 35387, 'H', 50, 0
                                                         , 0, NULL, NULL, 0, GETDATE())
                        END
                    END                    
                END             
                

                --���� ��� ó��
                IF @coupon_seq <> '' BEGIN
              
                    UPDATE S4_COUPON 
                    SET    ISYN='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @coupon_seq 
                    AND    ISRECYCLE   ='0' 
                    AND    ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                     --���ϸ��� ��������
                    IF @company_seq = 6802 BEGIN
                        UPDATE S4_COUPON 
                        SET   ISYN = 'N' 
                        WHERE COMPANY_SEQ = @company_seq 
                        AND   COUPON_CODE = @coupon_seq 
                        AND   ISRECYCLE   ='N' 
                        AND   ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                        UPDATE S4_MYCOUPON 
                        SET    ISMYYN = 'N' 
                        WHERE  COMPANY_SEQ = @company_seq 
                        AND    COUPON_CODE = @coupon_seq  
                        AND    [UID]       = @member_id
                    END

                    -- �ٸ��ո� > ���������� ��ȸ ��� ����
                    IF @coupon_seq NOT IN ('BARUNSONAMLL5R_JEHU', 'BARUNSONAMLL10R_JEHU', 'BARUNSONAMLL15R_JEHU', 'BARUNSONAMLL17R_JEHU', 'BARUNSONAMLL25R_JEHU') BEGIN
                        UPDATE S4_MYCOUPON 
                        SET   ISMYYN ='N' 
                        WHERE COUPON_CODE = @coupon_seq
                        AND   ISMYYN      = 'Y' 
                        AND   [UID]       = @member_id
                    END

                     --�������� ���� ��� ó��
                    IF SUBSTRING(@coupon_seq,2,4) = 'MRIB' BEGIN
                        UPDATE S4_MYCOUPON 
                        SET   ISMYYN ='N' 
                        WHERE COUPON_CODE = @coupon_seq
                        AND   ISMYYN      = 'Y' 
                        AND   [UID]       = @member_id
                    END
                END

                --�ߺ����� ���ó��
                IF @addition_couponseq <> '' BEGIN
                    
                    UPDATE S4_MYCOUPON 
                    SET    ISMYYN='N' 
                    WHERE  COMPANY_SEQ IN (@company_seq,5006 ) 
                    AND    COUPON_CODE = @addition_couponseq
                    AND    [UID]       = @member_id 
                END            
                          
                --ȸ��/���ֹ��� ���
                IF @is_org_order = 1 AND @is_member = 1 BEGIN                   

                    --������ ���� ���� ����
                    IF NOT EXISTS(SELECT ID 
                                    FROM S4_MYCOUPON WITH(NOLOCK)
                                    WHERE [UID]= @uid
                                    AND   COMPANY_SEQ = 5006
                                    AND   COUPON_CODE = @thank_coupon) BEGIN
                       
                        INSERT INTO S4_MYCOUPON([UID],COUPON_CODE,COMPANY_SEQ,END_DATE) 
                                        VALUES(@uid, @thank_coupon, 5006 , DATEADD(MONTH, 2, GETDATE())) 
                    END 

                    --��������/���翵�� ���� �߱�
                    EXEC SP_INSERT_MOVIE_EVENT_JEHU_V2 @uid                         
                    EXEC SP_INSERT_THK_MOVIE_EVENT_JEHU @uid 
                END
                
            END
            --�ٸ��� ī��, �����̾�������
            ELSE  BEGIN       
            
                --���� ��� ó��
                IF @coupon_seq <> '' BEGIN
                    UPDATE S4_COUPON 
                    SET    ISYN='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @coupon_seq 
                    AND    ISRECYCLE   ='0' 
                    AND    ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                    UPDATE S4_MYCOUPON 
                    SET    ISMYYN ='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @coupon_seq                 
                    AND    [UID] = @member_id 
                END

                --�ߺ����� ���ó��
                IF @addition_couponseq <> '' BEGIN
                    UPDATE S4_COUPON 
                    SET    ISYN='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @addition_couponseq 
                    AND    ISRECYCLE   ='0' 
                    AND    ([UID] = @member_id OR [UID]='' OR [UID] IS NULL)

                    UPDATE S4_MYCOUPON 
                    SET    ISMYYN ='N'
                    WHERE  COMPANY_SEQ = @company_seq 
                    AND    COUPON_CODE = @addition_couponseq                 
                    AND    [UID] = @member_id 
                END 

                --ȸ��/���ֹ��� ���
                IF @is_org_order = 1 AND @is_member = 1 BEGIN    
                    --������ ���� ���� ���� 
                    EXEC SP_EXEC_COUPON_ISSUE_FOR_ONE @company_seq, @sales_gubun, @uid, @thank_coupon                               
                    
                    --��������/���翵�� �����߱�                     
                    EXEC SP_INSERT_COUPON_MST_SEQ @evt_video_coupon_mst_seq, @uid, @company_seq   
                    EXEC SP_INSERT_COUPON_MST_SEQ @thk_video_coupon_mst_seq, @uid, @company_seq                    
                END
            END

            ------------------------------------------------------------------
            --�������� �̺�Ʈ ����ǰ ���� (�ٸ���ī�常)
            ------------------------------------------------------------------
            IF ISNULL(@uid,'')<>'' AND @sales_gubun ='SB' BEGIN
                EXEC SP_INSERT_EVT_REGIST_GIFT @order_seq, @company_seq
            END

            ------------------------------------------------------------------
            -- ����ǰ ����
            ------------------------------------------------------------------            
            EXEC SP_INSERT_FREE_GIFT @order_seq
            
        END        
        ELSE IF @order_category = 'S' BEGIN
            
            IF @sales_gubun IN ('SB','SS')  BEGIN                                             

                EXEC SP_INSERT_SAMPLE_FREE_GIFT @order_seq,@company_seq            
            END 
            --�ٸ��ո�
            ELSE IF @sales_gubun IN ('SA','B')  BEGIN           
                EXEC SP_INSERT_SAMPLE_FREE_GIFT @order_seq,5006
            END 
            
        END

        SET @ErrNum = 0
        SET @ErrMsg = 'OK'
        RETURN
    
    END TRY
    BEGIN CATCH

        SET @ErrNum   = ERROR_NUMBER()
		SET @ErrSev   = ERROR_SEVERITY()
		SET @ErrState = ERROR_STATE()
		SET @ErrProc  = ERROR_PROCEDURE()
		SET @ErrLine  = ERROR_LINE()
		SET @ErrMsg   = '���� �߱� ���� (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END

GO


