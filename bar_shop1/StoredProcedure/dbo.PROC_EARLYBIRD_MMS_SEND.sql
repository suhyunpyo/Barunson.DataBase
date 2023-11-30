IF OBJECT_ID (N'dbo.PROC_EARLYBIRD_MMS_SEND', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_EARLYBIRD_MMS_SEND
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_EARLYBIRD_MMS_SEND
-- Author        : 박혜림
-- Create date   : 2022-07-22
-- Description   : 바른손카드 Early Bird 구매독려 MMS 예약 발송
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_EARLYBIRD_MMS_SEND]

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @SUBJECT        VARCHAR(64)		-- 제목
      , @SEND_DATE      VARCHAR(30)		-- 발송희망시간(YYYYMMDDHHMMSS)
	  , @SALES_GUBUN    VARCHAR(10)		-- 판매구분
	  , @SITE_NAME      VARCHAR(30)		-- 사이트명 
      , @SITE_URL       VARCHAR(50)		-- 사이트 URL
	  , @MEMBER_ID      VARCHAR(50)	    -- 아이디
	  , @MEMBER_NAME    VARCHAR(50)		-- 고객명
	  , @MEMBER_HPHONE  VARCHAR(50)		-- 휴대폰번호
	  , @DEST_INFO      VARCHAR(50)		-- 수신자이름^전화번호
	  , @COMPANY_SEQ    INT				-- 사이트 SEQ
	  , @CALLBACK       VARCHAR(20)		-- 회신번호
	  , @MSG            VARCHAR(4000)	-- 발송 메시지
	  , @COUPON_CODE    VARCHAR(50)		-- 발행 쿠폰코드

SET @SEND_DATE = CONVERT(VARCHAR(10), GETDATE(), 120) + ' 17:30:00'
SET @SEND_DATE = REPLACE(REPLACE(REPLACE(@SEND_DATE, '-', ''), ':', ''), ' ', '')
SET @COUPON_CODE = 'ED4B-E8ED-4FC7-A571'

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			--SELECT 'SB' AS SALES_GUBUN
			--     , 'whdgur6536' AS MEMBER_ID
			--	 , '010-6476-6536' AS HPHONE
			--	 , '테스터' AS MEMBER_NAME
			--	 , '5001' AS COMPANY_SEQ
			--  INTO #SMS_SEND_LIST

			-- 문자 수신동의 회원 & 샘플 발송일 7일 후 & 예식일 120~200일 이내인 고객 & 주문건 X
			SELECT T1.SALES_GUBUN AS SALES_GUBUN
			     , T1.MEMBER_ID AS MEMBER_ID
				 , T1.MEMBER_HPHONE AS HPHONE
				 , REPLACE(T1.MEMBER_NAME,' ','') AS MEMBER_NAME
				 , T1.COMPANY_SEQ AS COMPANY_SEQ
			  INTO #SMS_SEND_LIST
			  FROM bar_shop1.dbo.custom_sample_order AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.vw_user_info   AS T2 WITH(NOLOCK) ON (T1.MEMBER_ID = T2.uid AND T1.SALES_GUBUN = T2.site_div AND T2.chk_sms = 'Y' AND (T2.WEDDING_DAY >= CONVERT(CHAR(10), GETDATE() + 120, 23) AND T2.WEDDING_DAY <= CONVERT(CHAR(10), GETDATE() + 200, 23)))
			  LEFT OUTER JOIN bar_shop1.dbo.custom_order AS T3 WITH(NOLOCK) ON (T1.MEMBER_ID = T3.member_id)
			 WHERE T1.SALES_GUBUN = 'SB'
			   AND(T1.DELIVERY_DATE >= CONVERT(CHAR(10), GETDATE() - 8, 23) AND T1.DELIVERY_DATE < CONVERT(CHAR(10), GETDATE() - 7, 23))
			   AND LEN(T1.MEMBER_HPHONE) = 13
			   AND T3.order_seq IS NULL

			DECLARE CURSOR_MMS_SEND CURSOR FOR

			SELECT T1.MEMBER_NAME
			     , T1.HPHONE
				 , T1.SALES_GUBUN
				 , T1.COMPANY_SEQ
				 , T1.MEMBER_ID
			  FROM #SMS_SEND_LIST AS T1

			OPEN CURSOR_MMS_SEND
				
			FETCH NEXT FROM CURSOR_MMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN, @COMPANY_SEQ, @MEMBER_ID

			WHILE @@fetch_status = 0
			BEGIN

				IF @SALES_GUBUN = 'SB'
				BEGIN
					SET @SITE_NAME = '바른손카드'
					SET @SITE_URL = 'https://bit.ly/2J2Gzqr'
					SET @CALLBACK = '1644-0708'
				END
				ELSE
				BEGIN
					SET @SITE_NAME = '바른손카드'
					SET @SITE_URL = 'https://bit.ly/2J2Gzqr'
					SET @CALLBACK = '1644-0708'
				END

				--수신자이름^전화번호
				SET @DEST_INFO = @MEMBER_NAME + '^' + @MEMBER_HPHONE

				SET @SUBJECT = '[광고] 바른손카드 시크릿 쿠폰'

				SET @MSG = '[광고] 시크릿 쿠폰이 도착했어요♥

안녕하세요 ' + @MEMBER_NAME + '님. 바른손카드입니다.
고르신 청첩장은 마음에 드셨나요?

결혼 준비로 바쁘실 ' + @MEMBER_NAME + '님을 위해 
바른손카드에서 시크릿 쿠폰이 도착했어요!

가격이 고민되신다면?
여유 있는 예식일을 활용하고 싶다면?
청첩장을 미리 준비해 보세요!

10% 할인된 가격으로
청첩장을 준비할 수 있는 
시크릿 쿠폰을 지금 바로 사용해 보세요! 
※유효기간 10일※
				
▼쿠폰 확인하기▼
https://bit.ly/3yAUwCe

[수신거부] ' + @SITE_NAME + ' 고객센터
' + @CALLBACK + '로 수신거부 문자 전송'

				----------------------------------------------------------------------------------
				-- 쿠폰 발행
				----------------------------------------------------------------------------------
				EXEC bar_shop1.dbo.SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @MEMBER_ID, @COUPON_CODE


				----------------------------------------------------------------------------------
				-- KT
				----------------------------------------------------------------------------------
				EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND @MEMBER_ID, 1, @SUBJECT, @MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SALES_GUBUN, '', '', '', '', '', '', '', '', '', ''

				
				FETCH NEXT FROM CURSOR_MMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN, @COMPANY_SEQ, @MEMBER_ID
							
			END
				
			CLOSE CURSOR_MMS_SEND
						
			DEALLOCATE CURSOR_MMS_SEND

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

-- EXEC PROC_EARLYBIRD_MMS_SEND
GO
