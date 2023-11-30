IF OBJECT_ID (N'dbo.PROC_ORDER_REVIEW_BIZTALK', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_ORDER_REVIEW_BIZTALK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_ORDER_REVIEW_BIZTALK
-- Author        : 박혜림
-- Create date   : 2022-06-03
-- Description   : 구매후기 독려 알림톡 발송
-- Update History:
-- Comment       : 청첩장 발송완료일 기준, +3일 이후 자동 발송
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_ORDER_REVIEW_BIZTALK]

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

			--SELECT 'SS' AS SALES_GUBUN
			--	 --, '010-8973-8286' AS HPHONE
			--	 , '010-5590-3718' AS HPHONE
			--	 , '프페테스트' AS MEMBER_NAME
			--	 , '5003' AS COMPANY_SEQ
			--  INTO #SMS_SEND_LIST
			
			-- 회원 & 청첩장 발송완료 3일 후
			SELECT T2.site_div AS SALES_GUBUN
				 , T1.order_hphone AS HPHONE
				 , REPLACE(T1.order_name,' ','') AS MEMBER_NAME
				 , T1.company_seq AS COMPANY_SEQ
			  INTO #SMS_SEND_LIST
			  FROM bar_shop1.dbo.custom_order AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.vw_user_info   AS T2 WITH(NOLOCK) ON (T1.MEMBER_ID = T2.uid AND T2.site_div = CASE WHEN T1.SALES_GUBUN IN ('B','C','H') THEN 'B' ELSE T1.SALES_GUBUN END AND T2.chk_sms = 'Y')
			 WHERE T1.status_seq = 15
			   AND (T1.src_send_date >= CONVERT(CHAR(10), GETDATE() - 4, 23) AND T1.src_send_date < CONVERT(CHAR(10), GETDATE() - 3, 23))
			   AND LEN(T1.order_hphone) = 13

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
				-- 사이트별 템플릿 코드 셋팅
				-------------------------------------------------------
				IF @SALES_GUBUN = 'B'	-- 바른손몰
				BEGIN
					SET @TEMPLATE_CODE = 'BM0155'
					SET @COMPANY_SEQ = '5000'
				END
				ELSE IF @SALES_GUBUN = 'SB'	-- 바른손카드
					SET @TEMPLATE_CODE = 'BH0160'
				ELSE IF @SALES_GUBUN = 'SS'	-- 프리미어페이퍼
					SET @TEMPLATE_CODE = 'P050'
				ELSE IF @SALES_GUBUN = 'ST'	-- 더카드
					SET @TEMPLATE_CODE = 'thebiz081'
				ELSE
					SET @TEMPLATE_CODE = ''

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
						, 'PROC_ORDER_REVIEW_BIZTALK'
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

-- EXEC PROC_ORDER_REVIEW_BIZTALK
GO
