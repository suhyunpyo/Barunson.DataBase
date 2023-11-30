IF OBJECT_ID (N'dbo.PROC_MEMBER_JOIN_BIZTALK_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_MEMBER_JOIN_BIZTALK_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/****************************************************************************************************************
-- SP Name       : PROC_MEMBER_JOIN_BIZTALK
-- Author        : 박혜림
-- Create date   : 2022-06-10
-- Description   : 회원가입 완료시 알림톡 발송
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_MEMBER_JOIN_BIZTALK_TEST]
	   @SALES_GUBUN   VARCHAR(10)
	 , @COMPANY_SEQ   INT
     , @MEMBER_NAME   VARCHAR(50)
	 , @MEMBER_HPHONE VARCHAR(50)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @CONTENT       VARCHAR(800) -- 알림톡내용
      , @TEMPLATE_CODE VARCHAR(30)
	  , @SENDER_KEY    VARCHAR(40)
	  , @MSG_TYPE      INT
	  , @KKO_BTN_TYPE  CHAR(1)
	  , @KKO_BTN_INFO  VARCHAR(4000)
	  , @CALLBACK      VARCHAR(15)
	  , @LMS_SUBJECT   VARCHAR(200)
	  

BEGIN
	BEGIN TRY		
		BEGIN TRAN

			-------------------------------------------------------
			-- 사이트별 템플릿 코드 셋팅
			-------------------------------------------------------
			IF @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'C'	-- 바른손몰
			BEGIN
				SET @TEMPLATE_CODE = 'BM0152'
				SET @COMPANY_SEQ = '5000'
				SET @SALES_GUBUN = 'B'
			END
			ELSE IF @SALES_GUBUN = 'SB'	-- 바른손카드
				SET @TEMPLATE_CODE = 'BH0151'
			ELSE IF @SALES_GUBUN = 'SS'	-- 프리미어페이퍼
				SET @TEMPLATE_CODE = 'P046'
			ELSE IF @SALES_GUBUN = 'ST'	-- 더카드
				SET @TEMPLATE_CODE = 'thebiz078'
			ELSE
			BEGIN
				SET @TEMPLATE_CODE = ''
			END

			-------------------------------------------------------
			-- 발송 비즈톡 정보 조회
			-------------------------------------------------------
			SELECT @CONTENT = CONTENT
					, @SENDER_KEY = SENDER_KEY
					, @MSG_TYPE = MSG_TYPE
					, @kko_btn_type = kko_btn_type
					, @KKO_BTN_INFO = KKO_BTN_INFO 
					, @CALLBACK = callback
					, @LMS_SUBJECT = lms_subject
				FROM WEDD_BIZTALK
			WHERE sales_gubun = @SALES_GUBUN
				AND template_code = @TEMPLATE_CODE
				AND USE_YORN ='Y'

			-- 고객명
			IF CHARINDEX('#{name}',@CONTENT) > 0
			BEGIN
				SET @CONTENT = Replace(@CONTENT , '#{name}' , @MEMBER_NAME)
			END

			IF @CONTENT <> ''
			BEGIN

				DECLARE @SCHEDULE_TYPE INT = 0  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)  
				SET @SCHEDULE_TYPE = 0  

				DECLARE @SEND_DATE  VARCHAR(8)    
				SET @SEND_DATE = '' --CONVERT(VARCHAR(8), GETDATE(), 112) -- '20221216'  

				DECLARE @MMS_MSG VARCHAR(MAX) 
				SET @MMS_MSG = REPLACE(@CONTENT, '    ', CHAR(13) + CHAR(10) ) 
				
				DECLARE @MMS_SUBJECT VARCHAR(60) 
				SET  @MMS_SUBJECT = @LMS_SUBJECT 
				
				DECLARE @ETC_INFO VARCHAR(50)= 'S4GUEST' 
				DECLARE @DEST_INFO VARCHAR(100) 
				SET @DEST_INFO = @ETC_INFO +'^'+ @MEMBER_HPHONE   
				DECLARE @SERVICE VARCHAR(4)  = @SALES_GUBUN
				DECLARE @RESERVED4  VARCHAR(50) = '1'        --(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)  

				--SET @RESERVED4 = 'SB'

select ETC_INFO = @ETC_INFO
		  
select SCHEDULE_TYPE = @SCHEDULE_TYPE
		  
select MMS_SUBJECT = @MMS_SUBJECT
		  
select MMS_MSG = @MMS_MSG
		  
select SEND_DATE = @SEND_DATE

select CALLBACK = @CALLBACK
select DEST_INFO = @DEST_INFO
select SERVICE = @SERVICE
select RESERVED4 = @RESERVED4

				EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''  


				--INSERT INTO ata_mmt_tran (
				--	  date_client_req
				--	, subject
				--	, content
				--	, callback
				--	, msg_status
				--	, recipient_num
				--	, msg_type
				--	, sender_key
				--	, template_code
				--	, kko_btn_type
				--	, kko_btn_info
				--	, etc_text_1	-- sales_gubun
				--	, etc_text_2	-- 호출프로시저
				--	, etc_num_1		-- company_Seq 
				--) VALUES (
				--	  GETDATE()
				--	, @LMS_SUBJECT 
				--	, @CONTENT
				--	, @CALLBACK 
				--	, '1' 
				--	, @MEMBER_HPHONE 
				--	, @msg_type
				--	, @sender_key
				--	, @template_code
				--	, @kko_btn_type 
				--	, @kko_btn_info
				--	, @SALES_GUBUN
				--	, 'PROC_MEMBER_JOIN_BIZTALK'
				--	, @COMPANY_SEQ
				--)
			END

	  COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		BEGIN
		     ROLLBACK TRAN
        END
	END CATCH

END

-- EXEC PROC_MEMBER_JOIN_BIZTALK 'ST', 5007, '테스터', '010-8973-8286'
-- EXEC PROC_MEMBER_JOIN_BIZTALK 'SS', 5003, '테스터', '010-8973-8286'
-- EXEC PROC_MEMBER_JOIN_BIZTALK 'SB', 5001, '테스터', '010-8973-8286'
-- EXEC PROC_MEMBER_JOIN_BIZTALK 'B', 5000, '테스터', '010-8973-8286'


GO
