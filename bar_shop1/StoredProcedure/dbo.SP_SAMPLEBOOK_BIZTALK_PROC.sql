IF OBJECT_ID (N'dbo.SP_SAMPLEBOOK_BIZTALK_PROC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SAMPLEBOOK_BIZTALK_PROC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************
-- div : 
샘플북반납신청완료
샘플북발송완료
샘플북주문완료

CUSTOM_ETC_ORDER ORDER_TYPE ='U'
2018-07-31	정혜련
EXEC [SP_SAMPLEBOOK_BIZTALK_PROC] 1369835,'샘플북반납신청완료'
EXEC [SP_SAMPLEBOOK_BIZTALK_PROC] 1369835,'샘플북발송완료'
EXEC [SP_SAMPLEBOOK_BIZTALK_PROC] 1369835,'샘플북주문완료'

EXEC [SP_SAMPLEBOOK_BIZTALK_PROC] '3178243,3178244','샘플북반납신청완료'


프페 샘플북 테스트 프로시저
*********************************************************/

CREATE PROCEDURE [dbo].[SP_SAMPLEBOOK_BIZTALK_PROC]
	@ORDER_SEQ   VARCHAR(1000),
	@DIV         VARCHAR(100) 
AS

BEGIN


	DECLARE @TMP_ORDER_SEQ AS VARCHAR(1000);	--실제저장변수
	DECLARE @STR_ORDER_SEQ AS VARCHAR(1000);	--반복문사용변수
	DECLARE @splitStr AS VARCHAR(1);	--문자열구분자(|)


    DECLARE @Mem_name AS VARCHAR(20)
    DECLARE @Mem_Hphone AS VARCHAR(15)
    DECLARE @Sales_gubun AS VARCHAR(2)
    DECLARE @Item_name AS VARCHAR(30)
    
    DECLARE @CONTENT AS VARCHAR(800) -- 알림톡내용
    DECLARE @TEMPLATE_CODE AS VARCHAR(30)
    DECLARE @SENDER_KEY AS VARCHAR(40)
    DECLARE @MSG_TYPE AS INT 
    DECLARE @KKO_BTN_TYPE AS char(1)
    DECLARE @KKO_BTN_INFO AS VARCHAR(4000)
    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
    DECLARE @DELIVERY_CODE_NUM AS VARCHAR(15)
    DECLARE @today_dt as varchar(10)
    DECLARE @company_seq as INT 

	SET NOCOUNT ON;

	SET @splitStr			= ',';
	SET @STR_ORDER_SEQ		= @ORDER_SEQ+',';

	WHILE CharIndex(@splitStr, @STR_ORDER_SEQ, 0) > 0
	  BEGIN

		SET @TMP_ORDER_SEQ	=  SUBSTRING(@STR_ORDER_SEQ,1,CHARINDEX(@splitStr,@STR_ORDER_SEQ)-1)
		SET @STR_ORDER_SEQ	=  SUBSTRING(@STR_ORDER_SEQ,CHARINDEX(@splitStr,@STR_ORDER_SEQ)+LEN(@splitStr),LEN(@STR_ORDER_SEQ))
						
			-------------------------------------------------------
			-- 바른손카드 샘플북 주문정보 확인
			-------------------------------------------------------
			SELECT  @Mem_name       =   ORDER_NAME	
			,   @item_name          =   CASE WHEN Sales_gubun = 'SS' THEN '프리미엄 샘플북' ELSE ITEM_NAME END	
			,   @Mem_Hphone         =   RECV_HPHONE	
			,   @Sales_gubun        =   Sales_gubun
			,   @company_seq        =   company_Seq
			,   @DELIVERY_CODE_NUM  =  DELIVERY_CODE
			,   @today_dt           =   convert(varchar(10),getdate(),23)
			FROM    ( 
				    SELECT  ORDER_NAME
				    ,   (  SELECT TOP 1 CARD_NAME 
					    FROM CUSTOM_ETC_ORDER_ITEM SI , S2_CARD C 
					    WHERE SI.CARD_SEQ = C.CARD_SEQ AND ORDER_SEQ = S.ORDER_SEQ  ) ITEM_NAME
				    ,   RECV_HPHONE
						,   ( case 
					    when company_seq = 5001 then 'SB'
							    WHEN company_seq = 5003 then 'SS'
							    WHEN company_seq = 5006 then 'SA'
							    WHEN company_seq = 5007 then 'ST'
							ELSE 'B' 
					  END ) Sales_gubun
					    ,   DELIVERY_CODE
					    ,   company_seq 
				    FROM    CUSTOM_ETC_ORDER S
				    WHERE   ORDER_SEQ = @TMP_ORDER_SEQ AND ORDER_TYPE ='U'
				) A 	


			-- 바른손
			if @Sales_gubun = 'SB' OR @Sales_gubun = 'SS' 
			
			BEGIN 
				-------------------------------------------------------
				-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK
				-------------------------------------------------------
				SELECT  
					@CONTENT = CONTENT
				    ,   @TEMPLATE_CODE = TEMPLATE_CODE
				    ,   @SENDER_KEY = SENDER_KEY 
				    ,   @MSG_TYPE = MSG_TYPE 
				    ,   @kko_btn_type = kko_btn_type 
				    ,   @KKO_BTN_INFO = KKO_BTN_INFO 
				    ,   @CALLBACK = callback
				    ,   @LMS_SUBJECT = lms_subject
				FROM    WEDD_BIZTALK
				WHERE   SALES_GUBUN = @Sales_gubun
				AND     DIV = @DIV
				AND     USE_YORN ='Y'

				-- 고객명
				IF CHARINDEX('#{name}',@CONTENT) > 0
				BEGIN
				    SET @CONTENT = Replace(@CONTENT , '#{name}' , @Mem_name);  
				END     
				
				-- 주문번호
				IF CHARINDEX('#{0000000}',@CONTENT) > 0
				BEGIN
				    SET @CONTENT = Replace(@CONTENT , '#{0000000}' , @TMP_ORDER_SEQ);  
				END        

				-- 상품명
				IF CHARINDEX('#{상품명}',@CONTENT) > 0
				BEGIN
				    SET @CONTENT = Replace(@CONTENT , '#{상품명}' , @item_name);  
				END       
				
				--운송장번호
				IF CHARINDEX('#{000000000000}',@CONTENT) > 0
				BEGIN
				    SET @CONTENT = Replace(@CONTENT , '#{000000000000}' , @DELIVERY_CODE_NUM);
				END 
				
				-- 반납신청일 / 주문일
				IF CHARINDEX('#{0000-00-00}',@CONTENT) > 0
				BEGIN
				    SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , @today_dt);
				END        

		 

				IF @CONTENT <> ''
			
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
								    ,   @Mem_Hphone 
								    ,   @msg_type
								    ,   @sender_key
								    ,   @template_code
								    ,   @kko_btn_type 
								    ,   @kko_btn_info
								    ,   @Sales_gubun
								    ,   'sp_samplebook_biztalk_proc'
								    ,   @company_seq	
								)
				END
			END
	  END

	SET NOCOUNT OFF;	
END
GO
