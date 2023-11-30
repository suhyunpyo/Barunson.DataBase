IF OBJECT_ID (N'dbo.SP_EXEC_BIZTALK_SEND_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_BIZTALK_SEND_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_BIZTALK_SEND_TEST]
		@P_PHONE_RECEIVER		VARCHAR(15)			    /* 받는 사람 핸드폰 번호 */
	,	@P_REMARKS				VARCHAR(120)			/* 호출 프로시저명  */
	,	@P_SALES_GUBUN			VARCHAR(32) = ''		/* SALES_GUBUN ex) SA, ST, SS, SB, B, H 기타 등등, SMS일때는 TR_ETC2, MMS는 ETC2 */
	,	@P_ORDER_SEQ			INTEGER = 0
	,	@P_DIV			VARCHAR(64) = ''		        /* DIV WEDD_BIZTALK 템플릿구분값 */
	,	@P_RESERVATION_DATE		VARCHAR(19) = null		/* 예약 발송, 날짜 형식 스트링을 넣는다. ex) 2016-11-10 14:49:00, DATETIME으로 자동변환이 안되는 형태의 스트링을 넣으면 오류가 나서 문자 메세지 전송이 안될수 있음 */
	,	@P_ETC				VARCHAR(100) = ''
AS

/*


--바른손카드
EXEC SP_EXEC_BIZTALK_SEND '010-5590-3718','SP_EXEC_BIZTALK_SEND','SB', 4131256, '초대장인쇄'

SP_EXEC_BIZTALK_SEND_TEST  '010-2227-6303','SP_EXEC_BIZTALK_SEND','SB', 4131256, '초대장인쇄'
--더카드
EXEC SP_EXEC_BIZTALK_SEND '010-5590-3718','SP_EXEC_BIZTALK_SEND','ST', 4136344, '초대장인쇄'
--바른손몰
EXEC SP_EXEC_BIZTALK_SEND '010-5590-3718','SP_EXEC_BIZTALK_SEND','B', 4144489, '초대장인쇄'
--프리미어페이퍼
EXEC SP_EXEC_BIZTALK_SEND '010-5590-3718','SP_EXEC_BIZTALK_SEND','SS', 4140726, '초대장인쇄'

*/
BEGIN
	DECLARE @Mem_name AS VARCHAR(20)
	DECLARE @card_name AS VARCHAR(30) 
	DECLARE @CONTENT AS VARCHAR(1000) -- 알림톡내용
	DECLARE @TEMPLATE_CODE AS VARCHAR(30)
	DECLARE @SENDER_KEY AS VARCHAR(40)
	DECLARE @MSG_TYPE AS INT 
	DECLARE @KKO_BTN_TYPE AS char(1)
	DECLARE @KKO_BTN_INFO AS VARCHAR(4000)
    DECLARE @CALLBACK AS VARCHAR(15)
    DECLARE @LMS_SUBJECT AS VARCHAR(200)
	DECLARE @company_seq as INT 
	DECLARE @SEND_DATE	AS DATETIME

	-------------------------------------------------------
	-- 비즈톡 관련 내용 테이블 WEDD_BIZTAIK
	-------------------------------------------------------
	SELECT @CONTENT = CONTENT, @TEMPLATE_CODE = TEMPLATE_CODE,  @SENDER_KEY = SENDER_KEY , @MSG_TYPE = MSG_TYPE , @kko_btn_type = kko_btn_type , @KKO_BTN_INFO = KKO_BTN_INFO 
	,@CALLBACK = callback, @LMS_SUBJECT = lms_subject 
	FROM WEDD_BIZTALK
	WHERE SALES_GUBUN = @P_SALES_GUBUN
	AND DIV = @P_DIV
	AND USE_YORN ='Y'
	AND template_code <> 'BH0142' /* 왜 이게 계속 나가는 것인가. 강제 제어 */

	IF @P_ORDER_SEQ > 0
	
		BEGIN
		  SELECT @Mem_name = ORDER_NAME 
			,@card_name = (SELECT card_name from s2_Card where card_seq = c.card_seq)  
			,@COMPANY_SEQ = company_seq 
		  FROM CUSTOM_ORDER c
		  WHERE ORDER_SEQ = @P_ORDER_SEQ 
		
          -- 더카드 질문답변에 이름이 들어가기때문에 이용함
          IF @P_ETC <> '' AND CHARINDEX('#{name}',@CONTENT) > 0 AND @P_DIV = '질문답변'
            BEGIN	
                SET @CONTENT = Replace(@CONTENT , '#{name}' , @P_ETC);
            END 

		  IF @Mem_name <> '' AND CHARINDEX('#{name}',@CONTENT) > 0
			BEGIN
			SET @CONTENT = Replace(@CONTENT , '#{name}' , @Mem_name);
			END
		   -- 상품명
		  IF @card_name <> '' AND CHARINDEX('#{상품명}',@CONTENT) > 0
			BEGIN
			SET @CONTENT = Replace(@CONTENT , '#{상품명}' , @card_name);
			END

		   -- 주문번호
		  IF @P_ORDER_SEQ <> '' AND CHARINDEX('#{0000000}',@CONTENT) > 0
			BEGIN
			SET @CONTENT = Replace(@CONTENT , '#{0000000}' , @P_ORDER_SEQ);
			END

		  IF @P_ETC <> '' AND CHARINDEX('#{0000-00-00}',@CONTENT) > 0 
			BEGIN	
			SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , @P_ETC);
			END 

		  --배송예정일
		  IF @P_DIV = '초대장인쇄' AND CHARINDEX('#{0000-00-00}',@CONTENT) > 0 
			BEGIN	
			SET @CONTENT = Replace(@CONTENT , '#{0000-00-00}' , dbo.FN_GET_EXPECTED_DELIVERY_DATE(@P_ORDER_SEQ));
			END 
		END 
	
	else
		
		BEGIN
			if @P_SALES_GUBUN = 'SA'
				BEGIN	
				SET @COMPANY_SEQ = 5006;
				END 			
			ELSE IF @P_SALES_GUBUN = 'SB'
				BEGIN	
				SET @COMPANY_SEQ = 5001;
				END 
            ELSE IF @P_SALES_GUBUN = 'ST'
                BEGIN
                SET @COMPANY_SEQ = 5007;
                END
            ELSE IF @P_SALES_GUBUN = 'SS'
                BEGIN
                SET @COMPANY_SEQ = 5003;
                END
            ELSE IF @P_SALES_GUBUN = 'SD'
                BEGIN
                SET @COMPANY_SEQ = 7717;
                END
            ELSE  -- 몰)추가
                BEGIN
                SET @COMPANY_SEQ = 5000;
                END

		END

        IF @P_ETC <> '' AND CHARINDEX('#{name}',@CONTENT) > 0 AND @P_DIV = '질문답변'
        BEGIN	
            SET @CONTENT = Replace(@CONTENT , '#{name}' , @P_ETC);
        END 


	IF @P_RESERVATION_DATE <> ''
		BEGIN
		SET @SEND_DATE = CONVERT(DATETIME, CONvERT(varchar(20), @P_RESERVATION_DATE)) ;
		END
	ELSE 
		BEGIN
		SET @SEND_DATE = GETDATE();
		END


		--select @CONTENT
		--select @P_PHONE_RECEIVER
	IF @CONTENT <> '' and  DATALENGTH(@P_PHONE_RECEIVER) >= 10
		BEGIN

				DECLARE @SCHEDULE_TYPE INT = 0  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)  
				SET @SCHEDULE_TYPE = 0  

				--DECLARE @SEND_DATE  VARCHAR(8)    
				SET @SEND_DATE = '' --CONVERT(VARCHAR(8), GETDATE(), 112) -- '20221216'  

				DECLARE @MMS_MSG VARCHAR(MAX) 
				SET @MMS_MSG = REPLACE(@CONTENT, '    ', CHAR(13) + CHAR(10) ) 
				
				DECLARE @MMS_SUBJECT VARCHAR(60) 
				SET  @MMS_SUBJECT = @LMS_SUBJECT 
				
				DECLARE @ETC_INFO VARCHAR(50)= 'S4GUEST' 
				DECLARE @DEST_INFO VARCHAR(100) 
				SET @DEST_INFO = @ETC_INFO +'^'+ @P_PHONE_RECEIVER   
				DECLARE @SERVICE VARCHAR(4)  = @P_SALES_GUBUN
				DECLARE @RESERVED4  VARCHAR(50) = '1'        --(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)  

				
				
select ETC_INFO = @ETC_INFO
		  
select SCHEDULE_TYPE = @SCHEDULE_TYPE
		  
select MMS_SUBJECT = @MMS_SUBJECT
		  
select MMS_MSG = @MMS_MSG
		  
select SEND_DATE = @SEND_DATE

select CALLBACK = @CALLBACK
select DEST_INFO = @DEST_INFO
select SERVICE = @SERVICE
select RESERVED4 = @RESERVED4

EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, '', @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''  




				--SET @RESERVED4 = 'SB'

--select ETC_INFO = @ETC_INFO
		  
--select SCHEDULE_TYPE = @SCHEDULE_TYPE
		  
--select MMS_SUBJECT = @MMS_SUBJECT
		  
--select MMS_MSG = @MMS_MSG
		  
--select SEND_DATE = @SEND_DATE

--select CALLBACK = @CALLBACK
--select DEST_INFO = @DEST_INFO
--select SERVICE = @SERVICE
--select RESERVED4 = @RESERVED4

		--INSERT INTO ata_mmt_tran (
		--	date_client_req
		--	,subject
		--	,content
		--	,callback
		--	,msg_status
		--	,recipient_num
		--	,msg_type
		--	,sender_key
		--	,template_code
		--	, kko_btn_type
		--	, kko_btn_info
		--	,etc_text_1	-- sales_gubun
		--	,etc_text_2	-- 호출프로시저
		--	,etc_num_1	-- company_Seq 
		--)
		--VALUES(
		--	  @SEND_DATE 
		--	, @LMS_SUBJECT 
		--	, @CONTENT
		--	, @CALLBACK
		--	, '1' 
		--	, @P_PHONE_RECEIVER 
		--	, @msg_type
		--	, @sender_key
		--	, @template_code
		--	, @kko_btn_type 
		--	, @kko_btn_info
		--	, @P_SALES_GUBUN
		--	, @P_REMARKS
		--	, @company_seq	
		--)
		end 				
END






GO
