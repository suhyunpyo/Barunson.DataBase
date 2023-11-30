IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2016-07-01 정혜련  
service  
 SB : 바른손카드  
 SA : 비핸즈  
 SS : 프리미어페이퍼  
 ST : 더카드  
 B  : 바른손몰
 BM : 모바일청첩장  
  
-- 발송용 임시 테이블
jehu_send_mms

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-8973-8286','20230224','N','s4guest', '테스트') -- 박혜림
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-5590-3718','20230106','N','s4guest', '김수흔') -- 김수흔

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-3355-7215','20230106','N','s4guest', '강선미') -- 강선미
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-8976-0489','20230106','N','s4guest', '테스트') -- 알로소

  insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SS','010-5768-7255','20230224','N','s4guest', '김학유') -- 김학유
  insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-5124-8752','20230224','N','s4guest', '이병헌') -- 이병헌
  insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('B','010-3372-4155','20230224','N','s4guest', '이상무') -- 이상무
  insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-5114-6605','20230224','N','s4guest', '테스트') -- 업체
  insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-8574-6210','20230224','N','s4guest', '테스트') -- 업체

 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT]
 
 이미지 첨부 프로시저 발송
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT]  
AS  
BEGIN  
  
    DECLARE @TIME VARCHAR(10)  
    DECLARE @SEND_DT VARCHAR(8)  
    DECLARE @SEND_DATE VARCHAR(16)	-- (공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT		-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	DECLARE @RESERVED4 VARCHAR(50)	-- (공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20230224' 	-- 1. 여기 날짜를 바꿔
	SET @TIME = '170000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트

	set @SEND_DATE = @SEND_DT+@TIME
	-- SET @RESERVED4 = ''
	SET @RESERVED4 = '1'	-- 광고제휴팀
     
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT s.SERVICE, s.PHONE_NUM, s.ETC_INFO, s.etc_text, m.chk_sms
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
 DECLARE @CHK_SMS VARCHAR(1)
 
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

DECLARE @CONTENT_DATA   VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
DECLARE @MSG_TYPE       INT			--(MMS)메시지 구분(TEXT:0, HTML:1)

DECLARE @DEST_INFO	VARCHAR(100)

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @ETC_TEXT, @CHK_SMS
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN
	 
	IF @SERVICE = 'SB'  
	BEGIN  
		SET @NO_REC_BRAND = '바른손카드'      
		SET @CALLBACK  = '1644-0708'  
		SET @evt_url = 'http://bit.ly/3X3UDki'
    END  
	ELSE IF @SERVICE = 'SA'  
	BEGIN  
		SET @NO_REC_BRAND = '바른손몰'      
		SET @CALLBACK  = '1644-7413'  
		SET @evt_url = ''
	END  
	ELSE IF @SERVICE = 'ST'  
	BEGIN  
		SET @NO_REC_BRAND = '더카드'       
		SET @CALLBACK  = '1644-7998' 
		SET @evt_url = 'http://bit.ly/2QdlKJN' 
	END  
	ELSE IF @SERVICE = 'B'  
	BEGIN  
		SET @NO_REC_BRAND = '바른손몰'      
		SET @CALLBACK  = '1644-7413'  
		SET @evt_url = 'http://bit.ly/3Zi0Tab'
	END  
	ELSE IF @SERVICE = 'BM'
	BEGIN
		SET @NO_REC_BRAND = '바른손M카드'      
		SET @CALLBACK  = '1644-0708'  
		SET @evt_url = ''
	END
	ELSE IF @SERVICE = 'SS'  
	BEGIN  
		SET @NO_REC_BRAND = '프리미어페이퍼'      
		SET @CALLBACK  = '1644-8796'  
		SET @evt_url = 'http://bit.ly/3jVcyeP'
	END
	ELSE
	BEGIN
		SET @NO_REC_BRAND = '바른손카드'      
		SET @CALLBACK  = '1644-0708'  
		SET @evt_url = 'http://bit.ly/3X3UDki'
	END

	-- SET @NO_REC_BRAND = '바른손M카드'      
	-- SET @CALLBACK  = '1644-0708'  
	-- SET @evt_url = 'bit.ly/3pFqBou'
  
   
   IF @ETC_INFO = 's4guest'	-- 테스트용
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
	 

	SET @MMS_SUBJECT = '(광고) ' + @NO_REC_BRAND + 'X LG전자 베스트샵'

	SET @MMS_MSG = '(광고) 『 ' + @NO_REC_BRAND + ' X LG전자 베스트샵 제휴 혜택』

' + @ETC_TEXT + '고객님!
공동 가입하시는 고객님들께만 드리는
특별한 혜택이 도착했습니다.

가입 혜택 바로가기 : http://bit.ly/3xK826D

LG베스트샵에서 필요한 제품
구매하시고 3백만원 이상 구매 시 50,000P 혜택받아가세요

★ 바른손카드 고객님 특별 혜택 ★
☞ 300만원 이상 구매 시 5만 추가 혜택
☞ 행사 제품군 구매 시 최대 340만 추가 혜택(상세페이지 참고)
☞  LG전자 멤버십 동의 시 혜택받을 수 있습니다.

※ 본 문자는 2023. 02. 23 기준
SMS 수신동의한 고객님께
발송되었습니다.

[수신거부] '+ @NO_REC_BRAND+' 고객센터
수신거부 문자: '+ @CALLBACK + '
무료 수신거부: 080-938-0850'

   IF @CHK_SMS  = 'Y' 
 
   BEGIN 				

	  SET @DEST_INFO = @ETC_INFO+'^'+@PHONE_NUM
	
	  EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''

   END

  
   UPDATE jehu_send_mms SET send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE AND phone_num = @PHONE_NUM  AND send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @ETC_TEXT, @CHK_SMS 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
