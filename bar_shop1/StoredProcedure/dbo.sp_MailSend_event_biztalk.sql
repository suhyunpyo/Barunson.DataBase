IF OBJECT_ID (N'dbo.sp_MailSend_event_biztalk', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_MailSend_event_biztalk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
div : 트래블패키지 배송완료, ST
*/

CREATE procedure [dbo].[sp_MailSend_event_biztalk] 
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
	DECLARE @order_hphone as varchar(15)
	DECLARE @sales_gubun as varchar(2)
	 DECLARE @SEND_DATE AS DATETIME  

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert CURSOR FAST_FORWARD
	FOR

	-- 주문자 및 핸드폰번호
	select c.order_name , c.order_hphone , c.sales_gubun
	from custom_order  c , custom_order_item ci
	where c.order_Seq = ci.order_seq
	and ci.card_seq in ( 37409 ,37410 ) and c.status_Seq = 15
	AND C.src_send_Date >= convert(varchar(10),GETDATE()-2,23) 
	AND C.src_send_Date <  convert(varchar(10),GETDATE()-1,23) 
	AND c.sales_gubun ='ST' 



	OPEN cur_AutoInsert
	
	FETCH NEXT FROM cur_AutoInsert INTO @order_name,  @order_hphone, @sales_gubun

	WHILE @@FETCH_STATUS = 0

	BEGIN

	-------------------------------------------------------
	-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK
	-------------------------------------------------------
	SELECT @CONTENT = CONTENT, @TEMPLATE_CODE = TEMPLATE_CODE,  @SENDER_KEY = SENDER_KEY , @MSG_TYPE = MSG_TYPE , @kko_btn_type = kko_btn_type , @KKO_BTN_INFO = KKO_BTN_INFO 
	,@CALLBACK = callback, @LMS_SUBJECT = lms_subject 
	FROM WEDD_BIZTALK
	WHERE SALES_GUBUN = @sales_gubun
	AND DIV = '트래블패키지 배송완료'
	AND USE_YORN ='Y'
	
	  SET @content = Replace(@CONTENT , '#{name}' , @order_name);  -- 주문자명	
	  SET @SEND_DATE = GETDATE();  
	  
	
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
			, 'sp_MailSend_event_biztalk'
			, @company_seq	
		)

		FETCH NEXT FROM cur_AutoInsert INTO @order_name, @order_hphone, @sales_gubun
	
	
	END

	CLOSE cur_AutoInsert
	DEALLOCATE cur_AutoInsert
END
GO
