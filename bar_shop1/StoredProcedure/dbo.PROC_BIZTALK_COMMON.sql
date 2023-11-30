IF OBJECT_ID (N'dbo.PROC_BIZTALK_COMMON', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_BIZTALK_COMMON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****************************************************************************************************************
-- SP Name       : PROC_BIZTALK_COMMON (ORG - PROC_BIZTALK_TEST)
-- Author        : 박혜림
-- Editor        : 차재원
-- Create date   : 2022-06-16
-- Modify date   : 2022-07-28
-- Description   : 알림톡 발송
-- Update History:
-- Comment       : 
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_BIZTALK_COMMON]
	   @SALES_GUBUN   VARCHAR(10)
	 , @COMPANY_SEQ   INT
	 , @TEMPLATE_CODE VARCHAR(30)
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
					, 'PROC_BIZTALK_COMMON'
					, @COMPANY_SEQ
				)
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

-- EXEC PROC_BIZTALK_COMMON 'SB', 5001, 'BH0140', N'테스터', '010-8973-8286'
GO
