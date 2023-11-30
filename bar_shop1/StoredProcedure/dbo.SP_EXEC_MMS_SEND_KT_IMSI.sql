IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_KT_IMSI', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_KT_IMSI
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/****************************************************************************************************************
-- SP Name       : SP_EXEC_MMS_SEND_KT_IMSI
-- Author        : 박혜림
-- Create date   : 2022-08-01
-- Description   : LMS 발송
-- Update History:
-- Comment       :
****************************************************************************************************************/
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_KT_IMSI]

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @TIME          VARCHAR(10)
      , @SEND_DT       VARCHAR(8)  
      , @SEND_DATE     VARCHAR(16)	-- (공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
      , @SCHEDULE_TYPE INT			-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
      , @RESERVED4     VARCHAR(50)	-- (공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)

DECLARE @MMS_DATE      VARCHAR(100)
      , @PHONE_NUM     VARCHAR(100)
	  , @U_ID          VARCHAR(100)
	  , @MMS_MSG       VARCHAR(MAX)
	  , @MMS_SUBJECT   VARCHAR(60)
	  , @CALLBACK      VARCHAR(50)
	  , @ETC_INFO      VARCHAR(50) 
	  , @chkCnt        INT 
	  , @EVT_URL       VARCHAR(MAX)		-- 이벤트 주소
	  , @NO_REC_BRAND  VARCHAR(50)		-- 수신거부 브랜드 
	  , @NO_REC_TEL    VARCHAR(50)		-- 수신거부 전화번호  
	  , @CONTENT_DATA  VARCHAR(250)		--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
	  , @MSG_TYPE      INT				--(MMS)메시지 구분(TEXT:0, HTML:1)
      , @DEST_INFO     VARCHAR(100)

DECLARE @MEMBER_NAME   VARCHAR(50)	-- 고객명
	  , @MEMBER_HPHONE VARCHAR(50)	-- 휴대폰번호
	  , @SALES_GUBUN   VARCHAR(10)	-- 판매사이트 구분
	  , @COMPANY_SEQ   INT


SET @RESERVED4 = ''	
     	   
-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)

-- [즉시발송]
SET @SCHEDULE_TYPE = 0
SET @SEND_DATE = ''

-- [예약발송]
--SET @SCHEDULE_TYPE = 1

--SET @SEND_DT = '20220708'		-- 예약발송일
--SET @TIME = '170000'			-- 발송시각

--SET @SEND_DATE = @SEND_DT+@TIME

BEGIN 
	BEGIN TRY		
		BEGIN TRAN

			--SELECT 'SB' AS SALES_GUBUN
			--	 , '010-5590-3718' AS HPHONE
			--	 , '테스터' AS MEMBER_NAME
			--	 , '5001' AS COMPANY_SEQ
			--  INTO #SMS_SEND_LIST

			-- 인쇄대기 주문건
			SELECT T1.sales_Gubun AS SALES_GUBUN
			     , T1.order_hphone AS HPHONE
				 , T1.order_name AS MEMBER_NAME
				 , T1.company_seq AS COMPANY_SEQ
			  INTO #SMS_SEND_LIST
			  FROM bar_shop1.dbo.custom_order AS T1 WITH(NOLOCK)
			 INNER JOIN bar_shop1.dbo.s2_card AS T2 WITH(NOLOCK) ON (T1.card_seq = T2.Card_Seq AND T2.Card_Code IN ('BC1603', 'BC1605', 'BC1608', 'BC2605', 'BH0235', 'BH6039', 'BH7658', 'BH7660', 'BH8804', 'BH8828', 'BH8829', 'BH8830', 'BH8832', 'BC1608'))
			 WHERE T1.status_seq IN (9,10,11,12,13,14)
			   AND CONVERT(CHAR(10),T1.src_printW_date, 23) >= '2022-07-26' AND CONVERT(CHAR(10), T1.src_printW_date, 23) <= '2022-08-02'
			   AND LEN(T1.order_hphone) = 13
			   AND T1.Order_Seq NOT IN (4186338, 4181843, 4184668, 4186302, 4186707, 4188158)
     
		 --커서를 이용하여 해당되는 고객정보를 얻는다.  
		 DECLARE CURSOR_LMS_SEND CURSOR FAST_FORWARD  
		 FOR
			SELECT T1.MEMBER_NAME
			     , T1.HPHONE
				 , T1.SALES_GUBUN
				 , T1.COMPANY_SEQ
			  FROM #SMS_SEND_LIST AS T1
  
			OPEN CURSOR_LMS_SEND

			FETCH NEXT FROM CURSOR_LMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN, @COMPANY_SEQ
  
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @SALES_GUBUN = 'SB'  
				BEGIN  
					SET @NO_REC_BRAND = '바른손카드'      
					SET @CALLBACK  = '1644-0708'  
					SET @evt_url = 'https://bit.ly/2XQecRZ'
				END
				ELSE IF @SALES_GUBUN = 'ST'  
				BEGIN  
					SET @NO_REC_BRAND = '더카드'       
					SET @CALLBACK  = '1644-7998' 
					SET @evt_url = 'http://bit.ly/2QdlKJN' 
				END
				ELSE IF @SALES_GUBUN = 'SS'  
				BEGIN  
					SET @NO_REC_BRAND = '프리미어페이퍼'       
					SET @CALLBACK  = '1644-8796' 
					SET @evt_url = 'https://bit.ly/2XCihZA' 
				END
				ELSE IF @SALES_GUBUN = 'B'  
				BEGIN  
					SET @NO_REC_BRAND = '바른손몰'      
					SET @CALLBACK  = '1644-7413'  
					SET @evt_url = ''
				END
				ELSE IF @SALES_GUBUN = 'H'  
				BEGIN  
					SET @NO_REC_BRAND = '바른손몰'      
					SET @CALLBACK  = '1644-7413'  
					SET @evt_url = ''
				END 
				ELSE  
				BEGIN  
					SET @NO_REC_BRAND = ''      
					SET @CALLBACK  = ''  
					SET @evt_url = ''
				END  
	 
    
				SET @MMS_SUBJECT = '[공지] ' + @NO_REC_BRAND + ' 배송 지연 안내'


				SET @MMS_MSG = '[공지] ' + @NO_REC_BRAND + ' 배송 지연 안내 

안녕하세요 ' + @MEMBER_NAME + '님
바른손카드와 함께해 주셔서 감사합니다.

' + @MEMBER_NAME + '님께서 주문하신 제품의 배송은
알림톡으로 안내드린 일정보다
내부 사정으로 인하여 1-3일 지연될 수 있는 점 양해 말씀드립니다.

최대한 빠르게 제작하여 안전하게 발송 도와드리겠습니다!

*'+ @NO_REC_BRAND+' 고객센터 ' + @CALLBACK + ''


			SET @DEST_INFO = @MEMBER_NAME+'^'+@MEMBER_HPHONE

			EXEC PROC_SMS_MMS_SEND @MEMBER_NAME, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SALES_GUBUN,'','',@RESERVED4,'','','','','','',''

  
			FETCH NEXT FROM CURSOR_LMS_SEND INTO @MEMBER_NAME, @MEMBER_HPHONE, @SALES_GUBUN, @COMPANY_SEQ
		END  
  
		CLOSE CURSOR_LMS_SEND  
		DEALLOCATE CURSOR_LMS_SEND

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

-- EXEC SP_EXEC_MMS_SEND_KT_IMSI
GO
