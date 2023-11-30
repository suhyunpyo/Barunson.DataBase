USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]    Script Date: 2023-07-05 오전 9:30:17 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]    Script Date: 2023-07-05 오전 9:30:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC
-- Author        : 변미정
-- Create date   : 2023-06-29
-- Description   : 주문 결제 완료시 mail및 Biz톡 발송 처리
-- Update History: 
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC]     
     @order_seq                      INT                        --주문번호     
    ,@sales_gubun                    VARCHAR(2)      = NULL     --B:제휴,H:프페 제휴, SA:비핸즈, SS:프페,SB: 바른손, ST:더카드,D:대리점 , P:아웃바운드, Q:지역대리점
    ,@company_seq                    INT             = NULL     --
    ,@order_category                 VARCHAR(1)      = NULL     --주문 구분 ("W":청첩장 "S":샘플 "E":부가상품,답례품) 
    ,@order_type                     VARCHAR(2)      = NULL     --주문타입 

    ,@settle_method                  CHAR(1)         = NULL     --결제방법(1:계좌이체,3:무통장,2,6:카드, 8:카카오페이)
    ,@settle_price                   INT             = NULL     --결제금액                

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
        DECLARE @thank_coupon               VARCHAR(50) = ''    --감사장 할인 쿠폰 번호
        DECLARE @evt_video_coupon_mst_seq   INT         = 0     --식전영상쿠폰
        DECLARE @thk_video_coupon_mst_seq   INT         = 0     --감사영상쿠폰

        -------------------------------------------------------
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0  OR ISNULL(@sales_gubun,'') = '' OR ISNULL(@settle_method,'') = ''  BEGIN    
            SET @ErrNum = 3001
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END
        
         --청첩장인경우
        IF @order_category = 'W' BEGIN

            --주문정보 조회
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
                SET @ErrMsg = '청첩장 주문정보가 없습니다.'            
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
                
            --초특급인 경우
            IF @order_type = 'WS' BEGIN
                SET @resultinfo  = @pg_resultinfo

                IF @custom_card_yn > 0 BEGIN                        
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '선결제1' ELSE '선결제2' END
                END
                ELSE BEGIN                    
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '초특급결제1' ELSE '초특급결제2' END
                END
            END
            ELSE BEGIN
                IF @diff_num = 1 BEGIN
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '선결제1' ELSE '선결제2' END
                END
                ELSE BEGIN
                    SET @msg_div = CASE @settle_method WHEN 3 THEN '초대장결제1' ELSE '초대장결제2' END
                END

                SET @resultinfo  = @pg_resultinfo +' '+FORMAT(@settle_price,'#,###') + '원'                    
            END
                
            --메일발송 및 BizTalk 발송
            EXEC sp_MailSend_order_biztalk @order_seq, @order_name, @order_hphone, @order_email, @card_img, @resultinfo, @sales_gubun, @msg_div,''
        END
        ELSE IF @order_category = 'E' BEGIN
            
            IF @order_type = 'U' AND @sales_gubun IN ('SB','SS') BEGIN
                EXEC SP_SAMPLEBOOK_BIZTALK_PROC @order_seq,'샘플북주문완료' 
            END

            IF @order_type = '3'  AND @sales_gubun IN ('SS') BEGIN
                EXEC SP_CONCIERGE_BIZTALK_PROC  @order_seq
            END
            
        END
        ELSE IF @order_category = 'S' BEGIN
         
            IF @settle_method = 3 BEGIN
	            EXEC SP_SAMPLE_BIZTALK_PROC @order_seq,'샘플무통장결제'
            END
            ELSE BEGIN
	            EXEC SP_SAMPLE_BIZTALK_PROC @order_seq,'샘플주문완료'	            
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
		SET @ErrMsg   = 'BIZTALK 전송 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END

GO


