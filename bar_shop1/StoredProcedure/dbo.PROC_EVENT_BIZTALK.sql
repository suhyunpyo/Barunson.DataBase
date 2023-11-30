IF OBJECT_ID (N'dbo.PROC_EVENT_BIZTALK', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_EVENT_BIZTALK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_EVENT_BIZTALK
-- Author        : 박혜림
-- Create date   : 2022-04-28
-- Description   : 이벤트 알림톡 발송
-- Update History: 2022-06-07 (박혜림) - +2일 이후 자동 발송으로 변경
-- Comment       : 샘플 발송일 기준, +3일 이후 자동 발송
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_EVENT_BIZTALK]

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
	  

BEGIN
	BEGIN TRY		
		BEGIN TRAN

			--SELECT 'SB' AS SALES_GUBUN
			--	 , '010-8973-8286' AS HPHONE
			--	 , '테스터' AS MEMBER_NAME
			--	 , '5001' AS COMPANY_SEQ
			--  INTO #SMS_SEND_LIST
			
			-- 회원 & 샘플 발송일 2일 후
			SELECT T1.SALES_GUBUN AS SALES_GUBUN
				 , T1.MEMBER_HPHONE AS HPHONE
				 , REPLACE(T1.MEMBER_NAME,' ','') AS MEMBER_NAME
				 , T1.COMPANY_SEQ AS COMPANY_SEQ
			  INTO #SMS_SEND_LIST
			  FROM bar_shop1.dbo.custom_sample_order AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.vw_user_info   AS T2 WITH(NOLOCK) ON (T1.MEMBER_ID = T2.uid AND T1.SALES_GUBUN = T2.site_div)
			 WHERE (T1.DELIVERY_DATE >= CONVERT(CHAR(10), GETDATE() - 3, 23) AND T1.DELIVERY_DATE < CONVERT(CHAR(10), GETDATE() - 2, 23))
			   AND LEN(T1.MEMBER_HPHONE) = 13
			   AND T1.SALES_GUBUN = 'SB'

			DECLARE CURSOR_BIZTALK_SEND CURSOR FOR

			SELECT T1.MEMBER_NAME
			     , T1.HPHONE
				 , T1.SALES_GUBUN
				 , T1.COMPANY_SEQ
			  FROM #SMS_SEND_LIST AS T1

			OPEN CURSOR_BIZTALK_SEND
				
			FETCH NEXT FROM CURSOR_BIZTALK_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN, @COMPANY_SEQ

			WHILE @@fetch_status = 0
			BEGIN

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
				  AND template_code = 'BH0159'
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
						, 'PROC_EVENT_BIZTALK'
						, @COMPANY_SEQ
					)
				END

				
				FETCH NEXT FROM CURSOR_BIZTALK_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN, @COMPANY_SEQ
							
			END
				
			CLOSE CURSOR_BIZTALK_SEND
						
			DEALLOCATE CURSOR_BIZTALK_SEND

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

-- EXEC PROC_EVENT_BIZTALK
GO
