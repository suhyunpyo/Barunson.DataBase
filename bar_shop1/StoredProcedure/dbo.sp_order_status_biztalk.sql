IF OBJECT_ID (N'dbo.sp_order_status_biztalk', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_order_status_biztalk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
ex) 
@div = 초안확정완료

EXEC sp_order_status_biztalk @order_seq, @DIV   
EXEC sp_order_status_biztalk 3124290 , '초안확정완료'
*/

CREATE procedure [dbo].[sp_order_status_biztalk]
	@order_seq integer
	, @div varchar(20)
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
	DECLARE @ORDER_HPHONE AS VARCHAR(15)

    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
	DECLARE @company_seq as INT 	
    DECLARE @DELIVERY_DATE as varchar(10)
    DECLARE @sales_gubun as varchar(2)
    DECLARE @SEND_DATE AS DATETIME  
	DECLARE @etc_text AS VARCHAR(500)


	set @etc_text  = 'sp_order_status_biztalk' + @div

	-- 주문번호 받아 주문정보 가져오기
	SELECT   @order_name = order_name 
		, @ORDER_HPHONE = order_hphone
		, @sales_gubun = ( CASE WHEN sales_gubun IN ('B', 'H', 'C') THEN 'B' 
		ELSE sales_gubun END )
		,@company_seq = company_seq
	FROM CUSTOM_ORDER
	WHERE ORDER_SEQ =  @order_seq

	-------------------------------------------------------
	-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK
	-------------------------------------------------------
	SELECT @CONTENT = CONTENT
		, @TEMPLATE_CODE = TEMPLATE_CODE
		, @SENDER_KEY = SENDER_KEY 
		, @MSG_TYPE = MSG_TYPE , @kko_btn_type = kko_btn_type 
		, @KKO_BTN_INFO = KKO_BTN_INFO 
		, @CALLBACK = callback
		, @LMS_SUBJECT = lms_subject 
	FROM WEDD_BIZTALK
	WHERE SALES_GUBUN = @SALES_GUBUN
	AND DIV = @DIV
	AND USE_YORN ='Y'


	  SET @content = Replace(@CONTENT , '#{name}' , @order_name);  -- 주문자명	
--	  SET @content = Replace(@CONTENT , '#{0000000}' , @order_seq);  -- 주문번호
--	  SET @content = Replace(@CONTENT , '#{상품명}' , @card_name);  -- 주문내용
--	  SET @content = Replace(@CONTENT , '#{000000000000}' , @delivery_code_num);  -- 주문내용

 --       IF CHARINDEX('#{0000-00-00}',@CONTENT) > 0
 --       BEGIN
 --           SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , @DELIVERY_DATE);  
 --       END 
			
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
			  GETDATE() 
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
			, @etc_text
			, @company_seq	
		)
	
END
GO
