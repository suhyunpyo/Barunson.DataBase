IF OBJECT_ID (N'dbo.PROC_BIZTALK_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_BIZTALK_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************************
-- SP Name       : PROC_BIZTALK_TEST
-- Author        : 박혜림
-- Create date   : 2022-06-16
-- Description   : 알림톡 발송 테스트용
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_BIZTALK_TEST]
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
			SET @TEMPLATE_CODE = 'BH0148'
			SET @COMPANY_SEQ = '5001'
			SET @SALES_GUBUN = 'SB'

			--IF @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'C'	-- 바른손몰
			--BEGIN
			--	SET @TEMPLATE_CODE = 'BM0152'
			--	SET @COMPANY_SEQ = '5000'
			--	SET @SALES_GUBUN = 'B'
			--END
			--ELSE IF @SALES_GUBUN = 'SB'	-- 바른손카드
			--	SET @TEMPLATE_CODE = 'BH0131'
			--ELSE IF @SALES_GUBUN = 'SS'	-- 프리미어페이퍼
			--	SET @TEMPLATE_CODE = 'P046'
			--ELSE IF @SALES_GUBUN = 'ST'	-- 더카드
			--	SET @TEMPLATE_CODE = 'thebiz078'
			--ELSE
			--BEGIN
			--	SET @TEMPLATE_CODE = ''
			--END

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
				SET @CONTENT = Replace(@CONTENT , '#{0000000}' , 'T123456789')
				SET @CONTENT = Replace(@CONTENT , '#{상품명}' , '고급사진보정')
				SET @CONTENT = Replace(@CONTENT , '#{금액}' , '60,000원')
			END

			IF @CONTENT <> ''
			BEGIN
				INSERT INTO ata_mmt_tran (
					  date_client_req
					, subject
					, content
					, callback
					, msg_status
					, recipient_num
					, msg_type
					, sender_key
					, template_code
					, kko_btn_type
					, kko_btn_info
					, etc_text_1	-- sales_gubun
					, etc_text_2	-- 호출프로시저
					, etc_num_1		-- company_Seq 
				) VALUES (
					  GETDATE()
					, @LMS_SUBJECT 
					, @CONTENT
					, @CALLBACK 
					, '1' 
					, @MEMBER_HPHONE 
					, @msg_type
					, @sender_key
					, @template_code
					, @kko_btn_type 
					, @kko_btn_info
					, @SALES_GUBUN
					, 'PROC_BIZTALK_TEST'
					, @COMPANY_SEQ
				)
			END

	  COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		BEGIN
			print ERROR_LINE()
			print ERROR_MESSAGE()
		     ROLLBACK TRAN
        END
	END CATCH

END

-- EXEC PROC_BIZTALK_TEST 'ST', 5007, '테스터', '010-8973-8286'
-- EXEC PROC_BIZTALK_TEST 'SS', 5003, '테스터', '010-8973-8286'
-- EXEC PROC_BIZTALK_TEST 'SB', 5001, '테스터', '010-8973-8286'
-- EXEC PROC_BIZTALK_TEST 'B', 5000, '테스터', '010-8973-8286'
-- EXEC PROC_BIZTALK_TEST 'B', 5000, '테스터', '010-5590-3718'
GO
