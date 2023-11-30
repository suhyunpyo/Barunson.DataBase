USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]    Script Date: 2023-07-05 ���� 9:30:17 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]    Script Date: 2023-07-05 ���� 9:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC
-- Author        : ������
-- Create date   : 2023-06-29
-- Description   : �ֹ� ���� �Ϸ�� mail�� Biz�� �߼� ó��
-- Update History: 
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]     
     @order_seq                      INT                        --�ֹ���ȣ     
    ,@sales_gubun                    VARCHAR(2)      = NULL     --B:����,H:���� ����, SA:������, SS:����,SB: �ٸ���, ST:��ī��,D:�븮�� , P:�ƿ��ٿ��, Q:�����븮��
    ,@company_seq                    INT             = NULL     --
    ,@order_category                 VARCHAR(1)      = NULL     --�ֹ� ���� ("W":ûø�� "S":���� "E":�ΰ���ǰ,���ǰ) 
    ,@order_type                     VARCHAR(2)      = NULL     --�ֹ�Ÿ�� 

    ,@settle_method                  CHAR(1)         = NULL     --�������(1:������ü,3:������,2,6:ī��, 8:īī������)
    ,@settle_price                   INT             = NULL     --�����ݾ�                

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
        DECLARE @diff_num                   INT = 0
        DECLARE @custom_card_yn             INT = 0
        DECLARE @order_email                VARCHAR(50)
        DECLARE @order_name                 VARCHAR(50)
        DECLARE @order_hphone               VARCHAR(50)        
        DECLARE @pg_resultinfo              VARCHAR(1000)   = ''
        DECLARE @pg_resultinfo2             VARCHAR(1000)   = ''
        DECLARE @resultinfo                 VARCHAR(1000)   = ''
        DECLARE @card_img                   VARCHAR(150)  
        DECLARE @msg_div                    VARCHAR(20)
        DECLARE @org_order_type             VARCHAR(2)      = ''

        DECLARE @up_order_seq               INT = 0
        DECLARE @order_count                INT = 0
        DECLARE @thank_coupon               VARCHAR(50) = ''    --������ ���� ���� ��ȣ
        DECLARE @evt_video_coupon_mst_seq   INT         = 0     --������������
        DECLARE @thk_video_coupon_mst_seq   INT         = 0     --���翵������

        -------------------------------------------------------
        -- �Ķ���� ��ȿ�� üũ
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0  OR ISNULL(@sales_gubun,'') = '' OR ISNULL(@settle_method,'') = ''  BEGIN    
            SET @ErrNum = 3001
            SET @ErrMsg = '�����Ͱ� ��ȿ���� �ʽ��ϴ�.'            
            RETURN
        END
        
         --ûø���ΰ��
        IF @order_category = 'W' BEGIN

            --�ֹ����� ��ȸ
            SELECT @up_order_seq   = UP_ORDER_SEQ
                  ,@order_count    = ORDER_COUNT
                  ,@diff_num       = CASE WHEN DATEDIFF(SECOND, ISNULL(SRC_CONFIRM_DATE, GETDATE() + 1), SETTLE_DATE) < 0 THEN 1 ELSE 0 END 
                  ,@custom_card_yn = ISNULL((SELECT COUNT(1) FROM S2_CARDKIND WITH(NOLOCK) WHERE CARD_SEQ = A.CARD_SEQ AND CARDKIND_SEQ = 14),0)
                  ,@order_name     = ORDER_NAME
                  ,@order_email    = ORDER_EMAIL
                  ,@order_hphone   = ORDER_HPHONE
                  ,@pg_resultinfo  = PG_RESULTINFO  
                  ,@card_img       = CARD_IMAGE
            FROM   CUSTOM_ORDER A WITH(NOLOCK)
            INNER JOIN S2_CARD B WITH(NOLOCK) ON A.CARD_SEQ = B.CARD_SEQ
            WHERE  ORDER_SEQ = @order_seq
            IF @@ROWCOUNT <> 1 BEGIN
                SET @ErrNum = 3103
                SET @ErrMsg = 'ûø�� �ֹ������� �����ϴ�.'            
                RETURN
            END           

                
            IF ISNULL(@card_img,'') <> '' BEGIN
                IF @sales_gubun = 'SB' BEGIN
                    SET @card_img = 'https://file.barunsoncard.com/barunsoncard/'+@card_img
                END
                IF @sales_gubun = 'SS' BEGIN
                    SET @card_img = 'https://file.barunsoncard.com/common_img/'+@card_img
                END
                ELSE BEGIN
                    SET @card_img = 'https://file.barunsoncard.com/barunsonmall/'+@card_img
                END
            END
                
            --��Ư���� ���
            IF @order_type = 'WS' BEGIN
                SET @resultinfo  = @pg_resultinfo

                IF @custom_card_yn > 0 BEGIN                        
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '������1' ELSE '������2' END
                END
                ELSE BEGIN                    
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '��Ư�ް���1' ELSE '��Ư�ް���2' END
                END
            END
            ELSE BEGIN
                IF @diff_num = 1 BEGIN
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '������1' ELSE '������2' END
                END
                ELSE BEGIN
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '�ʴ������1' ELSE '�ʴ������2' END
                END

                SET @resultinfo  = @pg_resultinfo +' '+FORMAT(@settle_price,'#,###') + '��'                    
            END
                
            --���Ϲ߼� �� BizTalk �߼�
            EXEC sp_MailSend_order_biztalk @order_seq, @order_name, @order_hphone, @order_email, @card_img, @resultinfo, @sales_gubun, @msg_div,''
        END
        ELSE IF @order_category = 'E' BEGIN
            
            IF @order_type = 'U' AND @sales_gubun IN ('SB','SS') BEGIN
                EXEC SP_SAMPLEBOOK_BIZTALK_PROC @order_seq,'���ú��ֹ��Ϸ�' 
            END

            IF @order_type = '3'  AND @sales_gubun IN ('SS') BEGIN
                EXEC SP_CONCIERGE_BIZTALK_PROC  @order_seq
            END
            
        END
        ELSE IF @order_category = 'S' BEGIN
         
            IF @settle_method = 3 BEGIN
	            EXEC SP_SAMPLE_BIZTALK_PROC @order_seq,'���ù��������'
            END
            ELSE BEGIN
	            EXEC SP_SAMPLE_BIZTALK_PROC @order_seq,'�����ֹ��Ϸ�'	            
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
		SET @ErrMsg   = 'BIZTALK ���� ���� (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END

GO


