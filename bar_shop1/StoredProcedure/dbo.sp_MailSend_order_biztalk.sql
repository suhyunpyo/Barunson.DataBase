IF OBJECT_ID (N'dbo.sp_MailSend_order_biztalk', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_order_biztalk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*  
sp_MailSend_order 2538241,'시스템테스트','010-9484-4697','developer@barunn.net','','2017-09-22 오후 4:58:00','SA','초대장주문',''  

청첩장주문 - 초대장주문
*/  
CREATE  PROCEDURE [dbo].[sp_MailSend_order_biztalk] 
            @order_seq      INTEGER
        ,   @order_name     VARCHAR(50)
        ,   @order_hphone   VARCHAR(50)
        ,   @order_email    VARCHAR(100)
        ,   @card_img       VARCHAR(2000)
        ,   @etc            VARCHAR(100)
        ,   @sales_gubun    VARCHAR(2)
        ,   @div            VARCHAR(20)
        ,   @mypage_url     VARCHAR(200)
AS  

	/* 20201123 추가 START */
	DECLARE	@ERRNUM INT,
			@ERRSEV INT, 
			@ERRSTATE INT, 
			@ERRPROC VARCHAR(50), 
			@ERRLINE INT, 
			@ERRMSG VARCHAR(2000)
	/* 20201123 추가 END */

        DECLARE      @sms_phone     [varchar](20)  
        DECLARE      @sms_msg       [varchar](200)  
        DECLARE      @email         [varchar](100)  
        DECLARE      @email_sender  [varchar](50)  
        DECLARE      @email_title   [varchar](50)  
        DECLARE      @email_msg     [varchar](8000)   
        DECLARE      @sms_new_msg   [varchar](200)
        DECLARE      @company_seq   AS INT   

		declare @date datetime
	 
        --########## 메일발송 내용 ##########
        SELECT     @sms_phone = sms_phone  
           ,       @sms_msg = sms_msg  
           ,       @email_sender = email_sender  
           ,       @email = email  
           ,       @email_title = email_title  
           ,       @email_msg = email_msg   
        FROM       wedd_mail   
        WHERE      sales_gubun = @sales_gubun   
        AND        div = @div  
        AND        USE_YORN = 'Y'  
  
        SET @sms_msg   = Replace(@sms_msg, ':::etc:::', @etc)  -- 결제정보(무통장)
        SET @email_msg = Replace(@email_msg, ':::order_seq:::', @order_seq)  
        SET @email_msg = Replace(@email_msg, ':::order_name:::', @order_name)  
        SET @email_msg = Replace(@email_msg, ':::card_img:::', @card_img)  
        SET @email_msg = Replace(@email_msg, ':::etc:::', @etc)  

        IF @mypage_url <> ''  
        BEGIN
           set @email_msg = Replace(@email_msg, ':::mypage_url:::', @mypage_url)  
        END
        --###################################
         
        --########## 알림톡 시작 ############ 
        DECLARE     @CONTENT        AS VARCHAR(800) 
        DECLARE     @TEMPLATE_CODE  AS VARCHAR(30)
        DECLARE     @SENDER_KEY     AS VARCHAR(40)
        DECLARE     @MSG_TYPE       AS INT 
        DECLARE     @KKO_BTN_TYPE   AS char(1)
        DECLARE     @KKO_BTN_INFO   AS VARCHAR(4000)
        DECLARE     @CALLBACK       AS VARCHAR(15)
        DECLARE     @LMS_SUBJECT    AS VARCHAR(200)

        -- 알림톡 컨텐츠 가져오기
        SELECT      @content  = content  
	        ,       @msg_type = msg_type
	        ,       @sender_key = sender_key
	        ,       @template_code = template_code
	        ,       @kko_btn_type = kko_btn_type  
	        ,       @kko_btn_info = kko_btn_info	
            ,       @CALLBACK = callback
	        ,       @LMS_SUBJECT = lms_subject
        FROM        wedd_biztalk   
        WHERE       sales_gubun = @sales_gubun   
        AND         div = @div  
        AND         USE_YORN = 'Y'  

        DECLARE     @card_name          [varchar](20)  
        DECLARE     @bank_name          [varchar](200)  
        DECLARE     @bank_account       [varchar](100)  
        DECLARE     @last_total_price   integer 
        DECLARE     @settle_method      [varchar](50)  
        DECLARE     @settle_price       integer   
        DECLARE     @TARGET_DT          [varchar](10)  
        DECLARE     @TARGET_DT2         [varchar](10)  /*2021-10-05 수정 */

        -- 결제정보
        SELECT       @card_name = card_name, 
                     @bank_name = bank_name, 
                     @bank_account = bank_account, 
                     @last_total_price = isnull(last_total_price,0), 
                     @settle_price = isnull(settle_price,0), 
                     @settle_method = ( CASE WHEN a.settle_method = '카드' THEN bank_name ELSE settle_method END ) 
        FROM     (
                    SELECT 
                            (SELECT card_name FROM  s2_card WHERE  card_seq = c.card_seq) card_name 
							,   (CASE WHEN c.settle_method = '1' or c.settle_method = '0' THEN pg_resultinfo ELSE LEFT(C.pg_resultinfo, CHARINDEX(' ', C.pg_resultinfo) - 1) END ) bank_name
                        ,   RIGHT(C.pg_resultinfo, LEN(C.pg_resultinfo) - CHARINDEX(' ', C.pg_resultinfo)) bank_account
                        ,   last_total_price
                        ,   ( CASE 
                                    WHEN c.settle_method = '1' THEN '계좌이체' 
                                    WHEN c.settle_method = '3' THEN '무통장' 
                                    WHEN c.settle_method = '2' THEN '카드' 
                                    WHEN c.settle_method = '6' THEN '카드' 
                                    ELSE '기타' 
                              END )  settle_method
                        ,   settle_price 
                    FROM    custom_order c 
                    WHERE   order_seq = @order_seq
                 ) a 

        -- 초안신청완료일 계산
        SELECT
            @sms_new_msg = '초안신청이완료'
        ,   @TARGET_DT = dbo.fn_IsWorkDay(CONVERT(varchar(10), a.new_order_date, 120), dbo.FN_GET_BAESONG_CHOAN(a.card_seq, a.new_order_date) + 1)
        ,   @company_seq  = company_Seq
        FROM
        (
            SELECT 
                a.card_seq,
                a.company_Seq,
                -- 주문일이 휴일이라면 가장 가까운 평일 오전 9시로 주문일을 변경합니다.
                (SELECT TOP 1 confirm_date FROM dbo.FN_GET_ConfirmDate_holiday(a.order_date)) AS new_order_date
            FROM 
                custom_order a
            WHERE 
                order_seq = @order_seq
        ) a

        -- 변수세팅
        IF @TARGET_DT <> '' AND CHARINDEX('#{0000-00-00}',@content) > 0
        BEGIN 
            SET @content = Replace(@content, '#{0000-00-00}', @TARGET_DT) -- 초안등록
        END

        IF @order_name <> '' AND CHARINDEX('#{name}',@content) > 0
        BEGIN  
            SET @content = Replace(@content, '#{name}', @order_name)
        END

        IF @order_seq <> '' AND (CHARINDEX('#{0000000}',@content) > 0 OR CHARINDEX('#{주문번호}',@content) > 0)
        BEGIN
            SET @content = Replace(@content, '#{0000000}', @order_seq)
            SET @content = Replace(@content, '#{주문번호}', @order_seq)
        END

        IF @card_name <> '' AND CHARINDEX('#{상품명}',@content) > 0
        BEGIN
            SET @content = Replace(@content, '#{상품명}', @card_name)
        END
 
        IF @bank_name <> '' AND CHARINDEX('#{입금은행명}',@content) > 0
        BEGIN
            SET @content = Replace(@content, '#{입금은행명}', @bank_name)
        END

        IF @bank_account <> '' AND CHARINDEX('#{가상계좌번호}',@content) > 0
        BEGIN
			SET @content = Replace(@content, '#{가상계좌번호}', @bank_account)
        END

        IF @last_total_price >= 0  AND CHARINDEX('#{입금금액}',@content) > 0
        BEGIN
            SET @content = Replace(@content, '#{입금금액}', @last_total_price)
		END

        IF @settle_price >= 0  AND (CHARINDEX('#{결제금액}',@content) > 0 OR CHARINDEX('#{금액}',@content) > 0) 
        BEGIN
            SET @content = Replace(@content, '#{결제금액}', @settle_price)
            SET @content = Replace(@content, '#{금액}', @settle_price) -- 더카드는 금액으로 들어감.
        END

        IF @settle_method <> '' AND (CHARINDEX('#{결제카드정보}',@content) > 0 OR CHARINDEX('#{결제수단}',@content) > 0)
        BEGIN
            SET @content = Replace(@content, '#{결제카드정보}', @settle_method)
            SET @content = Replace(@content, '#{결제수단}', @settle_method)
        END

	

        IF @div = '초대장주문'   
        BEGIN
            IF @sms_new_msg <> ''  
            BEGIN  
		

			    INSERT INTO ata_mmt_tran (
				                            date_client_req
			                            ,   subject
			                            ,   content
			                            ,   callback
			                            ,   msg_status
			                            ,   recipient_num
			                            ,   msg_type
			                            ,   sender_key
			                            ,   template_code
			                            ,   kko_btn_type
			                            ,   kko_btn_info
			                            ,   etc_text_1	-- sales_gubun
			                            ,   etc_text_2	-- 호출프로시저
			                            ,   etc_num_1	-- company_Seq 
			                            ) VALUES (
				                            GETDATE() 
				                        ,   @LMS_SUBJECT 
				                        ,   @CONTENT
				                        ,   @CALLBACK 
				                        ,   '1' 
				                        ,   @order_hphone 
				                        ,   @msg_type
				                        ,   @sender_key
				                        ,   @template_code
				                        ,   @kko_btn_type 
				                        ,   @kko_btn_info
				                        ,   @Sales_gubun
				                        ,   'sp_MailSend_order_biztalk'
				                        ,   @company_seq	
			                            )
            END  
        END
        ELSE
        BEGIN
            IF @sms_msg <> ''  
            BEGIN  
			

                INSERT INTO ata_mmt_tran (
				                            date_client_req
			                            ,   subject
			                            ,   content
			                            ,   callback
			                            ,   msg_status
			                            ,   recipient_num
			                            ,   msg_type
			                            ,   sender_key
			                            ,   template_code
			                            ,   kko_btn_type
			                            ,   kko_btn_info
			                            ,   etc_text_1	-- sales_gubun
			                            ,   etc_text_2	-- 호출프로시저
			                            ,   etc_num_1	-- company_Seq 
			                            ) VALUES (
				                            GETDATE() 
				                      ,   @LMS_SUBJECT 
				                        ,   @CONTENT
				                        ,   @CALLBACK 
				                        ,   '1' 
				                        ,   @order_hphone 
				                        ,   @msg_type
				                        ,   @sender_key
				                        ,   @template_code
				                        ,   @kko_btn_type 
				                        ,   @kko_btn_info
				                        ,   @Sales_gubun
				                        ,   'sp_MailSend_order_biztalk'
				                        ,   @company_seq	
			                            )
  END  
        END
        
        --IF @email_msg <> ''  
        --BEGIN
        --    EXEC sp_sendtNeoMail_wedd @email_sender,@email,@order_name,@order_email,@email_title,@email_msg 
        --END
GO
