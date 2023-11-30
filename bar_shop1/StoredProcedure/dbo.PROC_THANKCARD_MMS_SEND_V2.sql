IF OBJECT_ID (N'dbo.PROC_THANKCARD_MMS_SEND_V2', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_THANKCARD_MMS_SEND_V2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : PROC_THANKCARD_MMS_SEND_V2
-- Author        : 박혜림
-- Create date   : 2022-09-22
-- Description   : 바른손카드 경상도 고객 감사장 구매유도 MMS 발송
-- Update History:
-- Comment       : 청첩장 결제완료 후 1일 경과인 고객 & 예식장/배송지/봉투 주소가 경상도인 고객 & 감사장을 주문하지 않은 고객에게 발송
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[PROC_THANKCARD_MMS_SEND_V2]

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

SET ANSI_WARNINGS OFF

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @SUBJECT        VARCHAR(64)		-- 제목
      , @SEND_DATE      VARCHAR(30)		-- 발송희망시간(YYYYMMDDHHMMSS)
	  , @SALES_GUBUN    VARCHAR(10)		-- 판매구분
	  , @MEMBER_NAME    VARCHAR(50)		-- 고객명
	  , @MEMBER_HPHONE  VARCHAR(50)		-- 휴대폰번호
	  , @DEST_INFO      VARCHAR(50)		-- 수신자이름^전화번호
	  , @CALLBACK       VARCHAR(20)		-- 회신번호
	  , @MSG            VARCHAR(4000)	-- 발송 메시지

SET @SEND_DATE = CONVERT(VARCHAR(10), GETDATE(), 120) + ' 12:40:00'
SET @SEND_DATE = REPLACE(REPLACE(REPLACE(@SEND_DATE, '-', ''), ':', ''), ' ', '')
SET @CALLBACK = '1644-0708'

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	BEGIN TRY		
		BEGIN TRAN

			-- 청첩장 결제완료 후 1일 경과인 고객 & (예식장 OR 배송지 OR 봉투 주소가 경상도인 고객)
			SELECT T1.SALES_GUBUN AS SALES_GUBUN
				 , MAX(T1.order_hphone) AS HPHONE
				 , REPLACE(T1.order_name,' ','') AS MEMBER_NAME
				 , MAX(T3.order_seq) AS Wedd_order_Seq
				 , MAX(T4.order_seq) AS delivery_order_Seq
				 , MAX(T5.order_seq) AS env_order_Seq
				 , T1.member_id AS MEMBER_ID
			  INTO #SMS_SEND_LIST
			  FROM bar_shop1.dbo.custom_order                     AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.vw_user_info                AS T2 WITH(NOLOCK) ON (T1.MEMBER_ID = T2.uid AND T1.SALES_GUBUN = T2.site_div AND T2.chk_sms = 'Y')
			  LEFT OUTER JOIN bar_shop1.dbo.custom_order_WeddInfo AS T3 WITH(NOLOCK) ON (T1.order_seq = T3.order_seq AND ((T3.wedd_addr LIKE '경남%' 
			                                                                                                          OR T3.wedd_addr LIKE '경북%'
																												      OR T3.wedd_addr LIKE '부산%'
																												      OR T3.wedd_addr LIKE '대구%'
																												      OR T3.wedd_addr LIKE '울산%')
																												      OR (T3.wedd_road_Addr LIKE '경남%'
																												      OR T3.wedd_road_Addr LIKE '경북%'
																												      OR T3.wedd_road_Addr LIKE '부산%'
																												      OR T3.wedd_road_Addr LIKE '대구%'
																												      OR T3.wedd_road_Addr LIKE '울산%')))
			  LEFT OUTER JOIN bar_shop1.dbo.DELIVERY_INFO      AS T4 WITH(NOLOCK) ON (T1.order_seq = T4.order_seq AND (T4.ADDR LIKE '경남%' OR T4.ADDR LIKE '경북%' OR T4.ADDR LIKE '부산%' OR T4.ADDR LIKE '대구%' OR T4.ADDR LIKE '울산%'))
			  LEFT OUTER JOIN bar_shop1.dbo.custom_order_plist AS T5 WITH(NOLOCK) ON (T1.order_seq = T5.order_seq AND T5.print_type = 'E' AND T5.env_addr IS NOT NULL AND (T5.env_addr LIKE '경남%' OR T5.env_addr LIKE '경북%' OR T5.env_addr LIKE '부산%' OR T5.env_addr LIKE '대구%' OR T5.env_addr LIKE '울산%'))
			 WHERE T1.settle_status = 2				-- 결제완료건
			   AND T1.status_seq NOT IN (3,5)		-- 주문/결제취소 제외
			   AND T1.order_type IN ('1','6','7')	-- 청첩장 주문건
			   AND T1.up_order_seq IS NULL			-- 추가주문 제외
			   AND T1.SALES_GUBUN = 'SB'
			   AND LEN(T1.order_hphone) = 13
			   AND (T1.settle_date >= CONVERT(CHAR(10), GETDATE() - 2, 23) AND T1.settle_date < CONVERT(CHAR(10), GETDATE() - 1 , 23))
			 GROUP BY T1.member_id, T1.sales_Gubun, T1.order_name
			HAVING (MAX(T3.order_seq) IS NOT NULL OR MAX(T4.order_seq) IS NOT NULL OR MAX(T5.order_seq) IS NOT NULL)


			DECLARE CURSOR_MMS_SEND CURSOR FOR

			SELECT T1.MEMBER_NAME
			     , T1.HPHONE
				 , T1.SALES_GUBUN
			  FROM #SMS_SEND_LIST AS T1
			  LEFT OUTER JOIN bar_shop1.dbo.custom_order AS T2 WITH(NOLOCK) ON (T1.MEMBER_ID = T2.MEMBER_ID AND T2.order_type = '2' AND T1.SALES_GUBUN = T2.SALES_GUBUN AND T2.settle_status = 2 AND T2.status_seq NOT IN (3,5))
			 WHERE T2.Order_Seq IS NULL

			OPEN CURSOR_MMS_SEND
				
			FETCH NEXT FROM CURSOR_MMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN

			WHILE @@fetch_status = 0
			BEGIN

				--수신자이름^전화번호
				SET @DEST_INFO = @MEMBER_NAME + '^' + @MEMBER_HPHONE

				SET @SUBJECT = '[광고] 바른손카드 돈봉투로 따뜻한 마음을 전하세요.'

				SET @MSG = '[광고] 바른손카드 돈봉투로 따뜻한 마음을 전하세요.

결혼식을 축하해 주러 오신
소중한 하객분들께
따뜻한 마음을 전해보세요.

경상도 지역에서는
결혼을 축하해 주신 분들께
감사한 마음을
소정의 현금으로 답례하는
결혼문화가 이어지고 있습니다.

결혼 준비에 도움을 주신 분들
또는 먼 거리에서 결혼식에
참석해 주신 분들께
메시지와 함께 마음을 전할 수 있는
감사장을 준비해 보세요.

※
청첩장을 구매하신 고객분들께만 드리는 감사장 15% 할인 쿠폰이 발급되었습니다.
마이페이지 내 쿠폰 보관함을 확인해 보세요!

▶ 감사장 보러 가기 : http://me2.kr/1bnur'

				--SELECT @DEST_INFO, @SUBJECT, @MSG, @SALES_GUBUN

				----------------------------------------------------------------------------------
				-- KT
				----------------------------------------------------------------------------------
				EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 1, @SUBJECT, @MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SALES_GUBUN, '', '', '', '', '', '', '', '', '', ''
				--EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 1, @SUBJECT, @MSG, '', @CALLBACK, 0, @DEST_INFO, 0, '', 0, @SALES_GUBUN, '', '', '', '', '', '', '', '', '', ''

				
				FETCH NEXT FROM CURSOR_MMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN
							
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

-- EXEC PROC_THANKCARD_MMS_SEND_V2
GO
