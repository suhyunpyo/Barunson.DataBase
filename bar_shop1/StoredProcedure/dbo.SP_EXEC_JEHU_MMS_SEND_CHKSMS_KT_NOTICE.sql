IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_NOTICE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_NOTICE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
2022-10-07 박혜림  
  
-- 발송용 임시 테이블
jehu_send_mms

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-8973-8286','20221011','N','s4guest', '코페아 (공정무역 드립백&커피백 선물세트)') -- 박혜림
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-3755-9609','20221011','N','s4guest', '테스트') -- 이선주

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-3355-7215','20221011','N','s4guest', '메리어트 코트야드 서울 보타닉 파크 (숙박권 1박 + 조식 2인)') -- 강선미
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO, etc_text) values ('SB','010-8976-0489','20221011','N','s4guest', '테스트') -- 알로소

 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_NOTICE]
 
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_NOTICE]  
AS  
BEGIN  
  
    DECLARE @TIME VARCHAR(10)  
    DECLARE @SEND_DT VARCHAR(8)  
    DECLARE @SEND_DATE VARCHAR(16)	-- (공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT		-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	DECLARE @RESERVED4 VARCHAR(50)	-- (공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20221011' 	-- 1. 여기 날짜를 바꿔
	SET @TIME = '084000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트

	set @SEND_DATE = @SEND_DT+@TIME
	SET @RESERVED4 = ''	
     
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
		SET @evt_url = 'https://bit.ly/2XQecRZ'
    END  
	ELSE IF @SERVICE = 'SA'  
	BEGIN  
		SET @NO_REC_BRAND = '비핸즈카드'      
		SET @CALLBACK  = '1644-9713'  
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
		SET @evt_url = ''
	END  
	ELSE IF @SERVICE = 'BM'
	BEGIN
		SET @NO_REC_BRAND = '바른손카드'      
		SET @CALLBACK  = '1644-7413'  
		SET @evt_url = ''
	END
	ELSE  
	BEGIN  
		SET @NO_REC_BRAND = '프리미어페이퍼'      
		SET @CALLBACK  = '1644-8796'  
		SET @evt_url = 'https://bit.ly/2XCihZA'
	END

	--SET @NO_REC_BRAND = '바른손M카드'      
 --   SET @CALLBACK  = '1644-0708'  
 --   SET @evt_url = 'bit.ly/3pFqBou'
  
   
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
	 
    
--SET @MMS_SUBJECT = '(광고) ' +@NO_REC_BRAND+' 회원 초청 알로소 팝업스토어'
SET @MMS_SUBJECT = '[바른손카드] 이벤트 당첨안내'

SET @MMS_MSG = '[바른손카드] 이벤트 당첨안내

5번째 바른손카드 웨딩박스 이벤트에 당첨되신 고객님 축하드립니다! :D

당첨공지 확인하기 ▶ http://m.barunsoncard.com/customer/notice.asp

* 당첨 내용 : 5번째 바른손카드 웨딩박스 이벤트
* 당첨 경품 : '+ @ETC_TEXT +'

아래 정보를 기입하시어 10월 13일 목요일까지
barunson03@naver.com 으로 메일 주시면 확인 후 경품을 발송해 드립니다. (기한 준수)
위 기한 내에 메일 회신이 완료되지 않을 경우 당첨이 취소되오니, 이 점 유의 부탁 드립니다.

- 메일제목 : 바른손카드 5차 웨딩박스 당첨자
- 당첨자명 :
- 바른손카드 ID : 
- 경품 수령을 위한 개인정보 활용 동의여부 
(미동의 시 경품 수령 불가, 해당 개인 정보는 경품 발송이 완료된 후 모두 폐기됩니다.)
- 경품 수령하실 주소 :
* 원활한 배송과 안내를 위하여 당첨자 정보는 당첨된 브랜드에 전달됩니다.

다시 한 번 당첨을 축하드립니다! :D

바른손카드 바로가기 ▶ http://m.barunsoncard.com'

--SET @MMS_MSG = '[바른손카드] 이벤트 당첨안내

--5번째 바른손카드 웨딩박스 이벤트에 당첨되신 고객님 축하드립니다! :D

--당첨공지 확인하기 ▶ http://m.barunsoncard.com/customer/notice.asp

--* 당첨 내용 : 5번째 바른손카드 웨딩박스 이벤트
--* 당첨 경품 : '+ @ETC_TEXT +'
--* 아래 정보를 기입하시어 10월 13일 목요일까지
-- barunson03@naver.com 으로 메일 주시면 확인 후 10월 14일 이후 각 업체에서 연락드릴 예정입니다. (기한 준수)
--그 이후 배송일정 및 기타 문의사항들은 해당 브랜드로 연락주시면 됩니다.

--- 메일제목 : 바른손카드 5차 웨딩박스 당첨자
--- 당첨자명 :
--- 바른손카드 ID : 
--- 경품 수령을 위한 개인정보 활용 동의여부 (미동의 시 경품 수령 불가, 해당 개인 정보는 경품 발송이 완료된 후 모두 폐기됩니다.)

--기한 내에 메일 회신이 완료되지 않을 경우 당첨이 취소될 수 있으니, 이 점 유의 부탁 드립니다.

--* 원활한 배송과 안내를 위하여 당첨자 정보는 당첨된 브랜드에 전달됩니다.

--다시 한 번 당첨을 축하드립니다! :D
--바른손카드 바로가기 ▶ http://m.barunsoncard.com '

   --IF @CHK_SMS  = 'Y' 
 
   --BEGIN 				

	  SET @DEST_INFO = @ETC_INFO+'^'+@PHONE_NUM
	
	  EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''

   --END

  
   UPDATE jehu_send_mms SET send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE AND phone_num = @PHONE_NUM  AND send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @ETC_TEXT, @CHK_SMS 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
