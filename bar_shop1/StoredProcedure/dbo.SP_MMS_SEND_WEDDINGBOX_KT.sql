IF OBJECT_ID (N'dbo.SP_MMS_SEND_WEDDINGBOX_KT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_MMS_SEND_WEDDINGBOX_KT
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
  
table  
jehu_send_mms (  
 service  varchar(2) not null  
 , phone_num varchar(15) not null  
 , send_Dt varchar(8) not null  
 , send_chk varchar(1) not null  


 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-9484-4697','20220210','N','s4guest') -- 정혜련
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-3355-7215','20220210','N','s4guest') -- 강선미

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,ETC_TEXT) values ('SB','010-9484-4697','20220329','N','s4guest','필프레임 (UHD 프리미엄 샤이닝 실버 아크릴 액자 16inx20in)
') -- 정혜련

 exec [SP_MMS_SEND_WEDDINGBOX_KT] 
 
 이미지 첨부 프로시저 발송
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_MMS_SEND_WEDDINGBOX_KT]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	DECLARE @RESERVED4      VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
    DECLARE @ETC_TEXT		VARCHAR(100) 	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20220329' 	-- 1. 여기 날짜를 바꿔
	SET @TIME = '164000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트

	set @SEND_DATE = @SEND_DT+@TIME
	SET @RESERVED4 = '1'	
     
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT s.SERVICE, s.PHONE_NUM, s.ETC_INFO, 'Y' AS chk_sms, s.etc_text
  FROM JEHU_SEND_MMS s, s2_userinfo_bhands  m 
  WHERE s.etc_info = m.uid and s.SEND_DT = @SEND_DT  
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
 DECLARE @chkCnt INT;  
 DECLARE @CHK_SMS VARCHAR(1);   
 
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

DECLARE @CONTENT_DATA   VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
DECLARE @MSG_TYPE       INT			--(MMS)메시지 구분(TEXT:0, HTML:1)

DECLARE @DEST_INFO	VARCHAR(100)

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS, @ETC_TEXT
  
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
  
   -- 테스트를 윈한
   
   IF @ETC_INFO = 's4guest'  
    BEGIN  
     SET @CHK_SMS  = 'Y'
     SET @SCHEDULE_TYPE = 0
     SET @SEND_DATE = ''
    END
	else
	begin
		set @SEND_DATE = @SEND_DT+@TIME
		SET @RESERVED4 = '1'	
	end
	 
SET @MMS_SUBJECT = '[바른손카드] 이벤트 당첨안내'

SET @MMS_MSG = '4번째 바른손카드 웨딩박스 이벤트에 당첨되신 고객님 축하드립니다! :D

당첨공지 확인하기 ▶ http://m.barunsoncard.com/customer/notice.asp

* 당첨 내용 : 4번째 바른손카드 웨딩박스 이벤트
* 당첨 경품 : '+@ETC_TEXT+'

* 원활한 배송과 안내를 위하여 당첨자 정보는 당첨된 브랜드에 전달됩니다.
* 오늘 5시 이후 각 업체에서 연락드릴 예정입니다.
그 이후 배송일정 및 기타 문의사항들은 해당 브랜드로 연락주시면 됩니다.
* 해당 개인 정보는 경품 발송이 완료된 후 모두 폐기됩니다.

다시 한 번 당첨을 축하드립니다! :D

바른손카드 바로가기 ▶ http://m.barunsoncard.com'
	
   IF @CHK_SMS  = 'Y' 
 
   BEGIN 				

	  SET @DEST_INFO = @ETC_INFO+'^'+@PHONE_NUM
	
	  EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''

   END

  
   update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS, @ETC_TEXT
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
