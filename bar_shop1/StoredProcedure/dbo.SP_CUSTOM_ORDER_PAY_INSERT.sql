USE [bar_shop1]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]    Script Date: 2023-07-05 오전 9:29:35 ******/
DROP PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]
GO

/****** Object:  StoredProcedure [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]    Script Date: 2023-07-05 오전 9:29:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*********************************************************
-- SP Name       : SP_CUSTOM_ORDER_PAY_INSERT
-- Author        : 변미정
-- Create date   : 2023-04-04
-- Description   : 주문 결제 정보 등록
-- Update History: 2023-06-30 :쿠폰/BizTalk 일괄 처리 추가(변미정)
-- Comment       : 
**********************************************************/
CREATE PROCEDURE [dbo].[SP_CUSTOM_ORDER_PAY_INSERT]     
     @order_seq                      INT                        --주문번호     
    ,@sales_gubun                    VARCHAR(2)      = NULL     --B:제휴,H:프페 제휴, SA:비핸즈, SS:프페,SB: 바른손, ST:더카드,D:대리점 , P:아웃바운드, Q:지역대리점
    ,@company_seq                    INT             = NULL     --
    ,@order_category                 VARCHAR(1)      = NULL     --주문 구분 ("W":청첩장 "S":샘플 "E":부가상품,답례품) 
    ,@order_type                     VARCHAR(2)      = NULL     --주문타입 

    ,@card_div                       VARCHAR(5)      = NULL     --카드구분 (A01:카드 A02:내지 A03:인사말카드 .... C08:답례품...)
    ,@settle_method                  CHAR(1)         = NULL     --결제방법(1:계좌이체,3:무통장,2,6:카드, 8:카카오페이)
    ,@settle_price                   INT             = NULL     --결제금액
    ,@pg_shopid                      VARCHAR(20)     = NULL     --PG아이디
    ,@dacom_tid                      VARCHAR(200)    = NULL     --PG사 거래번호

    ,@card_installmonth              VARCHAR(10)     = NULL     --카드 할부개월수
    ,@card_nointyn                   CHAR(1)         = NULL     --카드 무이자여부    
    ,@card_issuercode                VARCHAR(3)      = NULL     --카드 발급사코드
    ,@card_approveno                 VARCHAR(20)      = NULL    --카드사승인번호    
    ,@bank_code                      VARCHAR(3)      = NULL     --은행코드(가상계좌/계좌이체)

    ,@vaccount_number                VARCHAR(50)     = NULL     --가상계좌번호
    ,@vaccount_name                  VARCHAR(50)     = NULL     --가상계좌 입금자명
    ,@due_date                       VARCHAR(50)     = NULL     --가상계좌 입금기한
    ,@secret                         VARCHAR(50)     = NULL     --가상계좌 검증키
    ,@receipt_url                    VARCHAR(200)    = NULL     --영수증 URL

    ,@isascrow                       CHAR(1)         = NULL     --애스크로
    ,@easypay_provider               VARCHAR(50)     = NULL     --간편결제 제공사 
    ,@device_type                    CHAR(1)                    --디바이스 (P:PC M:Mobile)    
    ,@member_id                      VARCHAR(50)     = NULL     --회원/비회원 아이디 
    ,@uid                            VARCHAR(50)     = NULL     --회원아이디 

    ,@guid                           VARCHAR(50)     = NULL     --브라우저 GUID?
    ,@coupon_seq_list                VARCHAR(100)    = NULL     --할인쿠폰 리스트

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
        -- 파라메터 유효성 체크
        -------------------------------------------------------            
        IF ISNULL(@order_seq,0) = 0 
           OR ISNULL(@settle_method,'') = ''
           OR ISNULL(@company_seq,0) = 0 
           OR ISNULL(@sales_gubun,'') = ''
           OR ISNULL(@order_category,'') = ''
           OR ISNULL(@order_type,'') = ''
           OR ISNULL(@member_id,'') = '' BEGIN    
            SET @ErrNum = 2001
            SET @ErrMsg = '데이터가 유효하지 않습니다.'            
            RETURN
        END

        -------------------------------------------------------
        -- 주문정보 조회
        -------------------------------------------------------     
        --청첩장
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
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN                                
            END

            IF @settle_status = 2 BEGIN
                SET @ErrNum = 2501
                SET @ErrMsg = '이미 결제가 완료된 건입니다.'                     
                RETURN        
            END

            --0원 결제인 쿠폰번호 없을 시 경우 최종 금액과 비교
            IF ISNULL(@settle_price,0) = 0 AND TRIM(ISNULL(@coupon_seq_list,'')) = '' BEGIN
                IF ISNULL(@last_total_price,0) <> 0 BEGIN
                    SET @ErrNum = 2502
                    SET @ErrMsg = '무료결제 금액이 일치하지 않습니다.(쿠폰번호 없음)'                     
                    RETURN    
                END
            END


        END
        --답례품/부가상품
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
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN
            END

            IF @status_seq = 4 BEGIN                
                SET @ErrNum = 2507
                SET @ErrMsg = '이미 결제가 완료된 건입니다.' 
                RETURN
            END
        END
        --샘플주문
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
                SET @ErrMsg = '주문정보가 없습니다.'                     
                RETURN
            END

            IF @status_seq = 4 BEGIN                
                SET @ErrNum = 2511
                SET @ErrMsg = '이미 결제가 완료된 건입니다.' 
                RETURN
            END
        
        END
         ELSE BEGIN            
            SET @ErrNum = 2513
            SET @ErrMsg = '상품 구분 오류'                       
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
            SET @pg_resultinfo = '간편결제 ' + ISNULL(@easypay_provider,'')
        END

        If ISNULL(@receipt_url,'')<>'' BEGIN
            SET @isreceipt = '1'
        END 

        -------------------------------------------------------
        -- 트랜잭션 시작
        -------------------------------------------------------     
        BEGIN TRAN 


        
         --청첩장인경우
        IF @order_category = 'W' BEGIN
            
            
            --쿠폰 사용 처리, 바른손몰의 경우 웹에서 선처리됨
            IF ISNULL(@coupon_seq_list,'')<>'' AND @sales_gubun NOT IN ('B','SA')  BEGIN

               

                EXEC SP_COUPON_COMPLETE_INNER @member_id, @order_seq, @coupon_seq_list, @settle_price, @device_type
                                             ,@ErrNum OUT, @ErrMsg OUT               
               
               --쿠폰 사용 실패
               IF ISNULL(@ErrNum,1) <> 0 BEGIN
                     ROLLBACK TRAN
                     SET @ErrNum = 9999
                     SET @ErrMsg = '쿠폰 사용 금액이 일치하지 않습니다 '
                     RETURN     
                END
            END                              

            --초특급인 경우
            IF @order_type = 'WS' BEGIN
                --프리미어페이퍼,바른손카드
                IF  @sales_gubun = 'SS' OR (@sales_gubun IN ('SB','SA','B') AND @status_seq NOT IN (6, 7, 8, 9, 10, 11, 12, 13, 14, 15)) BEGIN
                    SET @status_seq = 1                     
                END  
                
                --바른손몰
                IF @sales_gubun IN ( 'SA','B') BEGIN
                    SET @printW_status = 0
                END

                SET @order_date = GETDATE()                
            END
            ELSE BEGIN
                --프리미어페이퍼
                IF  @sales_gubun = 'SS' BEGIN
                    SET @status_seq = 9   
                    SET @src_confirm_date = GETDATE()
                END
                --바른손카드
                ELSE IF @sales_gubun = 'SB' BEGIN
                    IF @auto_choan_status_code = '138003' BEGIN
                        SET @auto_choan_status_code = '138001'
                    END
                END
            END

            --프리미어페이퍼
            IF  @sales_gubun = 'SS' BEGIN
                SET @src_printer_seq  = 2
            END

            IF TRIM(ISNULL(@org_member_id,'')) = '' BEGIN
                SET @org_member_id = @org_order_email
            END  

           --가상계좌 발급인 경우
            IF @settle_method = '3' BEGIN
                SET @settle_status = 1                
                SET @card_installmonth =''
                SET @card_nointyn = ''
            END
            --그외 결제 완료인 경우(계좌이체/신용카드등)
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
                    SET @ErrMsg = '결제정보 등록 실패'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2519
                SET @ErrMsg = '결제정보 등록 실패 ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH
                        

            --초특급이 아닌경우 
            IF @order_type <> 'WS' BEGIN
                
                BEGIN TRY     
                    --초안 확정 상태로 업데이트
                    UPDATE PREVIEW
                    SET    PSTATUS   = 9
                    WHERE  ORDER_SEQ = @order_seq  
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2524
                    SET @ErrMsg = '초안 확정 실패 ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH  
            END
            

            --바른손카드,프리미어페이퍼
            IF @sales_gubun IN ('SB','SS') AND @settle_price >= 50000 AND @settle_method <> '3' AND ISNULL(@uid,'') <> '' BEGIN 
                BEGIN TRY
                    INSERT INTO S2_EVENT (SALES_GUBUN, COMPANY_SEQ, [UID], CHARGE_USE, CHARGE_USE_SEQ, CHARGE_USE_NUM)
                                  VALUES (@sales_gubun,@company_seq, @uid, 'A',1,1)
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2528
                    SET @ErrMsg = '이벤트 등록 실패 ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END           
        END
        --답례품 또는 부가상품인경우  
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
                    SET @ErrMsg = '결제정보 등록 실패(ETC)'            
                    RETURN
                END  
               END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2005
                SET @ErrMsg = '결제정보 등록 실패(ETC) ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

            --답례품 ERP 연동테이블 업데이트
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
                    SET @ErrMsg = '답례품 ERP 연동 실패 ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END

            --바른손몰
            IF @sales_gubun IN ('SA','B') AND @order_type in ('D','K','R') AND ISNULL(@uid,'') <> '' BEGIN 
                BEGIN TRY
                    -- 장바구니 삭제                
                    DELETE FROM S2_USRBASKET
                    WHERE  [uid] = @uid                    
                    AND    CARD_SEQ IN (SELECT CARD_SEQ 
                                        FROM CUSTOM_ETC_ORDER_ITEM 
                                        WHERE ORDER_SEQ = @order_seq)                                               
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    SET @ErrNum = 2536
                    SET @ErrMsg = '심플 장바구니 삭제 실패 ' + ERROR_MESSAGE()                        
                    RETURN                
                END CATCH
            END
        END
        --샘플주문
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
                    SET @ErrMsg = '결제정보 등록 실패(SAMPLE)'            
                    RETURN
                END  
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2540
                SET @ErrMsg = '결제정보 등록 실패(SAMPLE) ' + ERROR_MESSAGE()            
                RETURN                
            END CATCH

            BEGIN TRY
                --샘플 장바구니 목록중 주문카드 삭제
                IF ISNULL(@uid,'') <> '' BEGIN 
                    DELETE FROM s2_samplebasket
                    WHERE  [uid] = @uid
                    AND    COMPANY_SEQ = @company_seq       -- 바른손몰인 경우 real_company_seq값이 넘어옴
                    AND    CARD_SEQ IN (SELECT CARD_SEQ 
                                        FROM   CUSTOM_SAMPLE_ORDER_ITEM 
                                        WHERE   SAMPLE_ORDER_SEQ = @order_seq)               
                END
                ELSE IF ISNULL(@guid,'') <> ''  BEGIN  
                    DELETE FROM s2_samplebasket
                    WHERE  [guid] = @guid
                    AND    COMPANY_SEQ = @company_seq       -- 바른손몰인 경우 real_company_seq값이 넘어옴
                    AND    CARD_SEQ IN (SELECT CARD_SEQ 
                                        FROM   CUSTOM_SAMPLE_ORDER_ITEM 
                                        WHERE  SAMPLE_ORDER_SEQ = @order_seq)    
                END 
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN
                SET @ErrNum = 2542
                SET @ErrMsg = '심플 장바구니 삭제 실패 ' + ERROR_MESSAGE()                        
                RETURN                
            END CATCH

        END 

        --가상계좌 발급 정보 등록
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
                SET @ErrMsg = '가상계좌 정보 등록 실패 ' + ERROR_MESSAGE()                        
                RETURN                            
            END CATCH          
        END

        --쿠폰발급(감사영상/식전영상/감사장할인 쿠폰 등) 및 BizTalk 발송
        BEGIN TRY

            EXEC SP_CUSTOM_ORDER_PAY_FINAL_COUPON_PROC @order_seq, @sales_gubun, @company_seq, @order_category, @order_type
                                            ,@member_id, @uid, NULL, NULL, NULL
                                            ,NULL, NULL,NULL
        END TRY
        BEGIN CATCH
            -- 오류처리 안함
        END CATCH          
       
       --주문 완료 BIZTALK 전송
       BEGIN TRY         
            EXEC SP_CUSTOM_ORDER_PAY_FINAL_BIZTALK_PROC @order_seq, @sales_gubun, @company_seq, @order_category, @order_type
                                            ,@settle_method, @settle_price, NULL, NULL, NULL
                                            ,NULL, NULL,NULL
        END TRY
        BEGIN CATCH
            -- 오류처리 안함
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
		SET @ErrMsg   = '결제 정보 등록 실패 (' + ERROR_MESSAGE() +')';

        RETURN       
    END CATCH

END
GO


