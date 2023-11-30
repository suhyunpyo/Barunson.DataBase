IF OBJECT_ID (N'dbo.PROC_THANKCARD_MMS_SEND', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_THANKCARD_MMS_SEND
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_THANKCARD_MMS_SEND
-- Author        : 박혜림
-- Create date   : 2020-11-24
-- Description   : 경상도 고객 감사장 판매 촉진 MMS 예약 발송
-- Update History:
-- Comment       : 바른손카드 프페청첩장 제안 AGENT 조회건 제외 후 발송
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_THANKCARD_MMS_SEND]

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
	  , @MEMBER_NAME    VARCHAR(50)		-- 고객명
	  , @MEMBER_HPHONE  VARCHAR(50)		-- 휴대폰번호
	  , @DEST_INFO      VARCHAR(50)		-- 수신자이름^전화번호
	  , @CALLBACK       VARCHAR(20)		-- 회신번호
	  , @MSG            VARCHAR(4000)	-- 발송 메시지

SET @SEND_DATE = CONVERT(VARCHAR(10), GETDATE(), 120) + ' 12:40:00'
SET @SEND_DATE = REPLACE(REPLACE(REPLACE(@SEND_DATE, '-', ''), ':', ''), ' ', '') -- KT용

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			-- 샘플 수령 주소가 경상도인 고객 & 샘플 출고일 4일 후
			SELECT T1.SALES_GUBUN AS SALES_GUBUN
				 , T1.MEMBER_HPHONE AS HPHONE
				 , REPLACE(T1.MEMBER_NAME,' ','') AS MEMBER_NAME
				 --, T1.MEMBER_ADDRESS
			  INTO #SMS_SEND_LIST
			  FROM bar_shop1.dbo.custom_sample_order AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.vw_user_info   AS T2 WITH(NOLOCK) ON (T1.MEMBER_ID = T2.uid AND T1.SALES_GUBUN = T2.site_div AND T2.chk_sms = 'Y')
			 WHERE (T1.DELIVERY_DATE >= CONVERT(CHAR(10), GETDATE() - 5, 23) AND T1.DELIVERY_DATE < CONVERT(CHAR(10), GETDATE() - 4 , 23))
			   AND LEN(T1.MEMBER_HPHONE) = 13
			   AND T1.SALES_GUBUN <> 'SD'	--디얼디어 사이트 제외
			   AND (T1.MEMBER_ADDRESS LIKE '경남%' 
				OR T1.MEMBER_ADDRESS LIKE '경북%' 
				OR T1.MEMBER_ADDRESS LIKE '부산%' 
				OR T1.MEMBER_ADDRESS LIKE '대구%' 
				OR T1.MEMBER_ADDRESS LIKE '울산%' )


			-- 바른손카드 프페청첩장 제안 AGENT 조회건 제외(프로시저명: SP_EXEC_MMS_SEND_FOR_SAMPLE_SB)
			SELECT SALES_GUBUN, HPHONE
			  INTO #SMS_SEND_EXCEPTION_LIST
			  FROM (
						SELECT c.sales_gubun AS SALES_GUBUN
							 , m.hphone AS HPHONE
							 , c.sample_order_seq
							 , m.WEDDING_HALL
							 , ISNULL((SELECT TOP  1 'Y' FROM bar_shop1.dbo.CUSTOM_ORDER WHERE member_id = uid AND status_Seq > 0 AND status_seq NOT IN ('3','5') AND order_type IN ('1','6','7') ),'N') AS orderYN 
							 , (SELECT COUNT(ci.card_seq) FROM bar_shop1.dbo.CUSTOM_SAMPLE_ORDER_ITEM ci, bar_shop1.dbo.s2_Card s WHERE ci.card_seq = s.card_seq AND sample_order_seq = c.sample_order_seq AND cardSet_price >= 1200 ) cardCnt
						  FROM bar_shop1.dbo.CUSTOM_SAMPLE_ORDER c, bar_shop1.dbo.vw_user_info m
						 WHERE c.member_id = m.uid
						   AND M.site_div ='SB'
						   AND m.chk_sms ='Y'
						   AND LEN(m.HPHONE) > 12
						   AND (m.WEDDING_DAY < convert(char(10),dateadd(month,6,getdate()),23) AND m.WEDDING_DAY > convert(char(10),dateadd(month,1,getdate()),23))
						   AND c.sales_gubun ='SB'
						   AND c.DELIVERY_DATE >= CONVERT(CHAR(10), GETDATE() - 5, 23)
						   AND c.DELIVERY_DATE < CONVERT(CHAR(10), GETDATE() - 4 , 23)
					) a
			 WHERE orderYN = 'N' AND(WEDDING_HALL ='H' OR cardCnt >= 2)


			DECLARE CURSOR_MMS_SEND CURSOR FOR

			SELECT T1.MEMBER_NAME
			     , T1.HPHONE
				 , T1.SALES_GUBUN
			  FROM #SMS_SEND_LIST AS T1
			  LEFT OUTER JOIN #SMS_SEND_EXCEPTION_LIST AS T2 ON (T1.HPHONE = T2.HPHONE AND T1.SALES_GUBUN = T2.SALES_GUBUN)
			 WHERE T2.HPHONE IS NULL

			OPEN CURSOR_MMS_SEND
				
			FETCH NEXT FROM CURSOR_MMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN

			WHILE @@fetch_status = 0
			BEGIN

				IF @SALES_GUBUN = 'SB'
				BEGIN
					SET @SITE_NAME = '바른손카드'
					SET @SITE_URL = 'https://bit.ly/2J2Gzqr'
					SET @CALLBACK = '1644-0708'
				END
				ELSE IF @SALES_GUBUN = 'B' OR @SALES_GUBUN = 'H' OR @SALES_GUBUN = 'C'
				BEGIN
					SET @SITE_NAME = '바른손몰'
					SET @SITE_URL = 'https://bit.ly/3e4PVxt'
					SET @CALLBACK = '1644-7413'
				END
				ELSE IF @SALES_GUBUN = 'ST'
				BEGIN
					SET @SITE_NAME = '더카드'
					SET @SITE_URL = 'https://bit.ly/35Ct5tm'
					SET @CALLBACK = '1644-7998'
				END
				ELSE IF @SALES_GUBUN = 'SS'
				BEGIN
					SET @SITE_NAME = '프리미어페이퍼'
					SET @SITE_URL = 'https://bit.ly/35I39w7'
					SET @CALLBACK = '1644-8796'
				END
				ELSE IF @SALES_GUBUN = 'SA'
				BEGIN
					SET @SITE_NAME = '비핸즈카드'
					SET @SITE_URL = 'https://bit.ly/328RPs1'
					SET @CALLBACK = '1644-9713'
				END
				ELSE
				BEGIN
					SET @SITE_NAME = '바른손카드'
					SET @SITE_URL = 'https://bit.ly/2J2Gzqr'
					SET @CALLBACK = '1644-0708'
				END

				--수신자이름^전화번호
				SET @DEST_INFO = @MEMBER_NAME + '^' + @MEMBER_HPHONE

				SET @SUBJECT = '[광고] ' + @SITE_NAME + ' 감사장으로 따뜻한 마음을 전하세요.'
				SET @MSG = '힘든 시기, 어려운 발걸음을 해주신 소중한 하객 분들께 감사장으로 따뜻한 마음을 전하세요.

				[감사의 마음을 담은 메세지형]
				시기와 상황에 맞게 직접 입력이 가능하신 인사말로 감사한 마음을 담아 주세요.

				[상품권/교통비 답례금봉투]
				식사를 하지 않거나 멀리서 오신 하객 분들께 정성을 담은 소정의 금액을 전달 주세요.

				경상도 지역에서는 결혼을 축하해 주신 분들께 감사한 마음을 소정의 현금으로 답례하는 결혼문화가 이어지고 있습니다.

				결혼 준비에 도움을 주신 분들 또는 먼 거리에서 결혼식에 참석해 주신 분들께 메세지와 함께 마음을 전할 수 있는 감사장을 준비해보세요.

				※ 청첩장 최종 결제 시, 즉시 사용 가능한 감사장 15% 할인 쿠폰이 자동 발급 됩니다.

				▶ 감사장 보러 가기 : ' + @SITE_URL

				-- SELECT @DEST_INFO, @SUBJECT, @MSG, @SALES_GUBUN

				----------------------------------------------------------------------------------
				-- KT
				----------------------------------------------------------------------------------
				EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 1, @SUBJECT, @MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SALES_GUBUN, '', '', '', '', '', '', '', '', '', ''

				----------------------------------------------------------------------------------
				-- LG 데이콤(구버전)
				----------------------------------------------------------------------------------
				--INSERT INTO bar_shop1.invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE)
				--VALUES
				--     ( @SUBJECT
				--	 , @MEMBER_HPHONE
				--	 , @CALLBACK
				--	 , '0'
				--	 , @SEND_DATE
				--	 , @MSG
				--	 , '0' 
				--	)

				
				FETCH NEXT FROM CURSOR_MMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN
							
			END
				
			CLOSE CURSOR_MMS_SEND
						
			DEALLOCATE CURSOR_MMS_SEND

			DROP TABLE #SMS_SEND_EXCEPTION_LIST
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

-- EXEC PROC_THANKCARD_MMS_SEND
GO
