IF OBJECT_ID (N'dbo.SP_WeddingNewsBiztalk', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_WeddingNewsBiztalk
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : SP_WeddingNewsBiztalk
-- Author        : 임승인
-- Create date   : 2023-03-13
-- Description   : 웨딩뉴스 알림톡 발송
****************************************************************************************************************/

--[SP_WeddingNewsBiztalk] 6, 'BH0156'

CREATE PROCEDURE [dbo].[SP_WeddingNewsBiztalk]
	@WeddingNewsIdx int,
	@TemplateCode varchar(10)
AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @MEMBER_NAME   VARCHAR(50)	-- 고객명
	  , @MEMBER_HPHONE VARCHAR(50)	-- 휴대폰번호
	  , @SALES_GUBUN   VARCHAR(10)	-- 판매사이트 구분
	  , @COMPANY_SEQ   INT

DECLARE @CONTENT       VARCHAR(800) -- 알림톡내용
      , @TEMPLATE_CODE VARCHAR(30)
	  , @SENDER_KEY    VARCHAR(40)
	  , @MSG_TYPE      INT
	  , @KKO_BTN_TYPE  CHAR(1)
	  , @KKO_BTN_INFO  VARCHAR(4000)
	  , @CALLBACK      VARCHAR(15)
	  , @LMS_SUBJECT   VARCHAR(200)
	  
SET @SALES_GUBUN = 'SB'
SET @COMPANY_SEQ = 5001
	  

BEGIN
	BEGIN TRY		
		BEGIN TRAN		
		
			SELECT @SALES_GUBUN AS SALES_GUBUN, hand_phone1 + '-' + hand_phone2 + '-' + hand_phone3 AS HPHONE, uname AS MEMBER_NAME, @COMPANY_SEQ AS COMPANY_SEQ	
			INTO #SMS_SEND_LIST
			FROM WeddingNews a INNER JOIN S2_UserInfo b ON a.UserId=b.uid		
			WHERE a.WeddingNewsIdx = @WeddingNewsIdx
				AND b.site_div = @SALES_GUBUN


			SELECT @MEMBER_NAME = T1.MEMBER_NAME
			     , @MEMBER_HPHONE = T1.HPHONE				 
			FROM #SMS_SEND_LIST AS T1
		
			-------------------------------------------------------
			-- 발송 비즈톡 정보 조회
			-------------------------------------------------------
			SELECT @CONTENT = CONTENT
				    , @TEMPLATE_CODE = TEMPLATE_CODE
					, @SENDER_KEY = SENDER_KEY
					, @MSG_TYPE = MSG_TYPE
					, @kko_btn_type = kko_btn_type
					, @KKO_BTN_INFO = KKO_BTN_INFO 
					, @CALLBACK = callback
					, @LMS_SUBJECT = lms_subject
				FROM WEDD_BIZTALK
			WHERE sales_gubun = @SALES_GUBUN
				AND template_code = @TemplateCode
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
					, 'SP_WeddingNewsBiztalk'
					, @COMPANY_SEQ
				)
			END			
		
			DROP TABLE #SMS_SEND_LIST

	  COMMIT TRAN
	
	END TRY


	BEGIN CATCH
		IF ( XACT_STATE() ) <> 0
		BEGIN
		     ROLLBACK TRAN
        END
	END CATCH

END

--SELECT * FROM S2_UserInfo WHERE UID='S4GUEST'

--UPDATE S2_UserInfo SET hand_phone2='9576',hand_phone3='0728' WHERE UID='S4GUEST'

--UPDATE S2_UserInfo SET hand_phone2='8707',hand_phone3='8818' WHERE UID='S4GUEST'



GO
