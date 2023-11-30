IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_COUPON', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_COUPON
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************************
-- SP Name       : SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_COUPON
-- Author        : 박혜림
-- Create date   : 2022-07-07
-- Description   : LMS 발송
-- Update History:
-- Comment       : 쿠폰코드 발송용

service
 SB : 바른손카드  
 SA : 비핸즈  
 SS : 프리미어페이퍼  
 ST : 더카드  
 B  : 바른손몰


insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SS','010-8973-8286','20220708','N','s4guest', '') -- 박혜림

insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SB','010-6476-6536','20220708','N','s4guest', '') -- 이종혁
insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SS','010-6476-6536','20220708','N','s4guest', '') -- 이종혁


exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_COUPON]

****************************************************************************************************************/

  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_COUPON]  
AS  
BEGIN

	DECLARE @TIME VARCHAR(10)  
    DECLARE @SEND_DT VARCHAR(8)  
    DECLARE @SEND_DATE VARCHAR(16)	-- (공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT		-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	DECLARE @RESERVED4 VARCHAR(50)	-- (공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)

	-- 하단은 기존 코드 참고하기!!
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20220708' 	-- 1. 여기 날짜를 바꿔
	SET @TIME = '173000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트

	SET @SEND_DATE = @SEND_DT+@TIME
	SET @RESERVED4 = ''	

    
  --커서를 이용하여 해당되는 고객정보를 얻는다.  
	DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
	FOR  
		SELECT s.SERVICE, s.PHONE_NUM, s.ETC_INFO, m.chk_sms, s.etc_text
		  FROM JEHU_SEND_MMS s, s2_userinfo_bhands  m
		 WHERE s.etc_info = m.uid
		   AND s.SEND_DT = @SEND_DT  
		   AND s.SEND_CHK ='N'  
  
	OPEN cur_AutoInsert_For_Order 

		DECLARE @MMS_DATE VARCHAR(100)  
		DECLARE @PHONE_NUM VARCHAR(100)  
		DECLARE @U_ID VARCHAR(100)  
		DECLARE @SERVICE VARCHAR(4)  
  
		DECLARE @MMS_MSG VARCHAR(MAX)  
		DECLARE @MMS_SUBJECT VARCHAR(60)  
		DECLARE @CALLBACK VARCHAR(50)  
		DECLARE @ETC_INFO VARCHAR(50)
		DECLARE @ETC_TEXT VARCHAR(100)
		DECLARE @chkCnt INT;  
		DECLARE @CHK_SMS VARCHAR(1);   
 
		DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
		DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
		--DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

		DECLARE @CONTENT_DATA   VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
		DECLARE @MSG_TYPE       INT			--(MMS)메시지 구분(TEXT:0, HTML:1)

		DECLARE @DEST_INFO	VARCHAR(100)

		FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE, @PHONE_NUM, @ETC_INFO, @CHK_SMS, @ETC_TEXT
  
		WHILE @@FETCH_STATUS = 0  
  
		BEGIN
 
			IF @SERVICE = 'SB'  
			BEGIN  
				SET @NO_REC_BRAND = '바른손카드'      
				SET @CALLBACK  = '1644-0708'  
				SET @EVT_URL = ''
			END   
			ELSE IF @SERVICE = 'SA'  
			BEGIN  
				SET @NO_REC_BRAND = '비핸즈카드'      
				SET @CALLBACK  = '1644-9713'  
				SET @EVT_URL = 'https://bit.ly/2XQecRZ'
			END
			ELSE IF @SERVICE = 'ST'  
			BEGIN  
				SET @NO_REC_BRAND = '더카드'       
				SET @CALLBACK  = '1644-7998' 
				SET @EVT_URL = '' 
			END 
			ELSE IF @SERVICE = 'B'  
			BEGIN  
				SET @NO_REC_BRAND = '바른손몰'      
				SET @CALLBACK  = '1644-7413'  
				SET @EVT_URL = ''
			END  
			ELSE IF @SERVICE = 'BM'
			BEGIN
				SET @NO_REC_BRAND = '바른손카드'      
				SET @CALLBACK  = '1644-7413'  
				SET @EVT_URL = ''
			END
			ELSE  
			BEGIN  
				SET @NO_REC_BRAND = '프리미어페이퍼'      
				SET @CALLBACK  = '1644-8796'  
				SET @EVT_URL = ''
			END  

			IF @ETC_INFO = 's4guest'  
			BEGIN  
				SET @CHK_SMS  = 'Y'
				--SET @SCHEDULE_TYPE = 0
				--SET @SEND_DATE = ''
				SET @SCHEDULE_TYPE = 1
				SET @SEND_DATE = @SEND_DT+@TIME
			END
			ELSE
			BEGIN
				SET @SCHEDULE_TYPE = 1
				SET @SEND_DATE = @SEND_DT+@TIME
			END

			IF @SERVICE = 'SB'  
			BEGIN  
				SET @MMS_SUBJECT = '[광고] 미리 전하는 결혼소식!'

				SET @MMS_MSG =  '결혼식이 가장 많은 9-11월!
올해 추석은 9월 10일로 지난 해보다 빠르답니다.
이에 맞춰 바른손카드가 기분 좋게 쿠폰을 쏩니다!
쿠폰은 마이 페이지 쿠폰 보관함에서 등록 가능하며,
9-11월 중에 결혼을 앞두고 계신 예비부부님들은
추석 전, 청첩장 미리 준비하셔서
남들보다 빠르게 행복한 소식을 전해보세요!

쿠폰번호 : 82B2-CF05-4F7A-A172
유효기간 : 2022.07.17

청첩장, 꼭 기억해야 될 네 가지!

1. 예상 주문 수량 정하기
2. 초대 인사말 정하기
3. 혼주 서열 확인하기
4. 예식장 약도 확인하기

청첩장은 바른손카드
아래▼ 사이트에서!
지금 바로 클릭☜클릭☜
 
▼청첩장 미리 준비하기▼
http://asq.kr/XztXXYyY

[수신거부] '+ @NO_REC_BRAND+' 고객센터 '+ @CALLBACK + '번호로 수신거부 문자 전송'


			END

			IF @SERVICE = 'SS'  
			BEGIN  
				SET @MMS_SUBJECT = '[광고] 미리 전하는 결혼소식'

				SET @MMS_MSG =  '9-11월은 결혼식이 가장 많은 달입니다.
그리고 올해 추석은 9월 10일로 지난 해보다 빠르기에
이에 맞춰 특별한 할인 쿠폰을 준비하였습니다.
쿠폰은 마이페이지 -> 쿠폰보관함에서 등록 가능하며,
9-11월 중에 결혼을 앞두고 계신 예비부부님들은
추석 전, 청첩장 미리 준비하셔서
행복한 소식을 빠르게 전해보시길 바랍니다.

쿠폰번호 : 82B2-CF05-4F7A-A172
유효기간 : 2022.07.17

청첩장, 꼭 기억해야 될 네 가지

1. 예상 주문 수량 정하기
2. 초대 인사말 정하기
3. 혼주 서열 확인하기
4. 예식장 약도 확인하기

청첩장은 프리미어페이퍼
아래▼ 사이트에서
쿠폰 적용하러 가기
 
▼청첩장 미리 준비하기▼
http://asq.kr/zQ6lfIGp

[수신거부] '+ @NO_REC_BRAND+' 고객센터 '+ @CALLBACK + '번호로 수신거부 문자 전송'


			END

			IF @CHK_SMS  = 'Y' 
			BEGIN 				

			  SET @DEST_INFO = @ETC_INFO+'^'+@PHONE_NUM
	
			  EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''
			END

			-- 발송 DB 상태값 업데이트
			UPDATE jehu_send_mms SET send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE AND phone_num = @PHONE_NUM  AND send_chk ='N'

		  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS, @ETC_TEXT
	 END  
  
	CLOSE cur_AutoInsert_For_Order  
	DEALLOCATE cur_AutoInsert_For_Order  
END
GO
