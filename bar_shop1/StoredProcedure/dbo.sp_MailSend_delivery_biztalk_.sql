IF OBJECT_ID (N'dbo.sp_MailSend_delivery_biztalk_', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_delivery_biztalk_
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
sp_MailSend_delivery 에서 호출 (카카오 알림톡)
초특급배송, 초대장배송

EXEC sp_MailSend_delivery_biztalk @order_seq, @ORDER_HPHONE, @SALES_GUBUN, @DIV  

exec sp_MailSend_delivery_biztalk_  4136435,'010-5590-3718','SB','초대장배송테스트'
exec sp_MailSend_delivery_biztalk_  4140183,'010-5590-3718','B','초대장배송테스트'
exec sp_MailSend_delivery_biztalk_  4136549,'010-5590-3718','SS','초대장배송테스트'
exec sp_MailSend_delivery_biztalk_  4138059,'010-5590-3718','ST','초대장배송테스트'


--- 주문번호 : #{0000000}
--- 주문내용 : #{상품명}
--- 송장정보 : CJ대한통운 
--- 운송장번호: #{000000000000}}

*/

CREATE procedure [dbo].[sp_MailSend_delivery_biztalk_]
	@order_seq integer
	, @ORDER_HPHONE varchar(15)
	, @sales_gubun varchar(2)
	, @div varchar(20)
	 , @P_RESERVATION_DATE  VARCHAR(19) = null  /* 예약 발송, 날짜 형식 스트링을 넣는다. ex) 2016-11-10 14:49:00, DATETIME으로 자동변환이 안되는 형태의 스트링을 넣으면 오류가 나서 문자 메세지 전송이 안될수 있음 */  
as
BEGIN
	
	DECLARE @CONTENT AS VARCHAR(800) -- 알림톡내용
	DECLARE @TEMPLATE_CODE AS VARCHAR(30)
	DECLARE @SENDER_KEY AS VARCHAR(40)
	DECLARE @MSG_TYPE AS INT 
	DECLARE @KKO_BTN_TYPE AS char(1)
	DECLARE @KKO_BTN_INFO AS VARCHAR(4000)
	
	DECLARE @ORDER_NAME AS VARCHAR(50)
	DECLARE @CARD_NAME AS VARCHAR(30)
	DECLARE @DELIVERY_CODE_NUM AS VARCHAR(15)
	DECLARE @HPHONE AS VARCHAR(15)

    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
	DECLARE @company_seq as INT 	
    DECLARE @DELIVERY_DATE as varchar(10)
	DECLARE @deliveryname as varchar(50)

	 DECLARE @SEND_DATE AS DATETIME  

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert CURSOR FAST_FORWARD
	FOR
	-- 주문내용 및 택배정보
	SELECT   c.order_name
		 ,(SELECT card_name FROM s2_card WHERE card_seq = c.card_seq)
		 ,delivery_code_num
		, c.company_seq 
        , convert(varchar(10),DELIVERY_DATE,23) AS DELIVERY_DATE
	FROM CUSTOM_ORDER c, delivery_info d
	WHERE c.order_Seq = d.order_seq 
	 AND c.ORDER_SEQ =  @order_seq

	OPEN cur_AutoInsert
	
	FETCH NEXT FROM cur_AutoInsert INTO @order_name, @card_name, @delivery_code_num, @company_seq, @DELIVERY_DATE

	WHILE @@FETCH_STATUS = 0

	BEGIN

	SELECT @deliveryname = ISNULL(a.CODE_NAME,'CJ대한통운')  FROM DELIVERY_CODE a 
	LEFT JOIN DELIVERY_INFO b on a.CODE = b.DELIVERY_COM
	WHERE b.ORDER_SEQ = @order_seq

	-------------------------------------------------------
	-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK  (2022.01.25 배송문자 중지 :강구완님 요청 'Y' -> 'X')
	-------------------------------------------------------
	SELECT @CONTENT = CONTENT, @TEMPLATE_CODE = TEMPLATE_CODE,  @SENDER_KEY = SENDER_KEY , @MSG_TYPE = MSG_TYPE , @kko_btn_type = kko_btn_type , @KKO_BTN_INFO = KKO_BTN_INFO 
	,@CALLBACK = callback, @LMS_SUBJECT = lms_subject 
	FROM WEDD_BIZTALK
	WHERE SALES_GUBUN = @SALES_GUBUN
	AND DIV = @DIV
	AND USE_YORN ='Y'


	  SET @content = Replace(@CONTENT , '#{name}' , @order_name);  -- 주문자명	
	  SET @content = Replace(@CONTENT , '#{deliveryname}' , @deliveryname);  -- 택배사	
	  SET @content = Replace(@CONTENT , '#{0000000}' , @order_seq);  -- 주문번호
	  SET @content = Replace(@CONTENT , '#{상품명}' , @card_name);  -- 주문내용
	  SET @content = Replace(@CONTENT , '#{000000000000}' , @delivery_code_num);  -- 주문내용

        IF CHARINDEX('#{0000-00-00}',@CONTENT) > 0
        BEGIN
            SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , @DELIVERY_DATE);  
        END 
		

	 IF @P_RESERVATION_DATE <> ''  
		BEGIN  
			SET @SEND_DATE = CONVERT(DATETIME, CONvERT(varchar(20), @P_RESERVATION_DATE)) ;  
		END  
	ELSE   
	  BEGIN  
		SET @SEND_DATE = GETDATE();  
	  END  

	
	IF @CONTENT <> ''
		INSERT INTO ata_mmt_tran (
			date_client_req
			,subject
			,content
			,callback
			,msg_status
			,recipient_num
			,msg_type
			,sender_key
			,template_code
			, kko_btn_type
			, kko_btn_info
			,etc_text_1	-- sales_gubun
			,etc_text_2	-- 호출프로시저
			,etc_num_1	-- company_Seq 
		)
		VALUES(
			  @SEND_DATE
			, @LMS_SUBJECT
			, @CONTENT
			, @CALLBACK 
			, '1' 
			, @ORDER_HPHONE
			, @msg_type
			, @sender_key
			, @template_code
			, @kko_btn_type 
			, @kko_btn_info
			, @sales_gubun
			, 'sp_MailSend_delivery_biztalk'
			, @company_seq	
		)

		FETCH NEXT FROM cur_AutoInsert INTO @order_name, @card_name, @delivery_code_num, @company_seq, @DELIVERY_DATE
	
	
	END

	CLOSE cur_AutoInsert
	DEALLOCATE cur_AutoInsert
END
GO
