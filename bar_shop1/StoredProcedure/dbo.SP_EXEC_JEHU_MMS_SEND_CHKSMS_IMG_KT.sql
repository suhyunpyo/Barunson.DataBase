IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_IMG_KT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_IMG_KT
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

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SS','010-8973-8286','20230109','N','s4guest', '') -- 박혜림

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SB','010-5768-7255','20230109','N','s4guest', '')	-- 김학유
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SB','010-5124-8752','20230109','N','s4guest', '')	-- 제휴업체
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SB','010-3013-8827','20230109','N','s4guest', '')	-- 제휴업체
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO,etc_text) values ('SB','010-9062-9022','20230109','N','s4guest', '')	-- 제휴업체


 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_IMG_KT] 
 
 이미지 첨부 프로시저 발송
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_IMG_KT]
AS  
BEGIN
    DECLARE @TIME          VARCHAR(10)  
    DECLARE @SEND_DT       VARCHAR(8)  
    DECLARE @SEND_DATE     VARCHAR(16)  --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT			--(공통)발송시점 구분(즉시전송:0, 예약전송:1)
	DECLARE @RESERVED4     VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20230109'
	SET @TIME = '123000'

	set @SEND_DATE = @SEND_DT+@TIME
	SET @RESERVED4 = '1'
     
	--커서를 이용하여 해당되는 고객정보를 얻는다.  
	DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD
	FOR  
	  SELECT s.SERVICE, s.PHONE_NUM, s.ETC_INFO, m.chk_sms
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
	 DECLARE @chkCnt INT;  
	 DECLARE @CHK_SMS VARCHAR(1);   
 
	 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
	 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
	 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

	DECLARE @CONTENT_DATA   VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
	DECLARE @CONTENT_COUNT INT
	DECLARE @MSG_TYPE       INT			--(MMS)메시지 구분(TEXT:0, HTML:1)

	DECLARE @DEST_INFO	VARCHAR(100)


	FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS
  
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

		SET @MMS_SUBJECT = '(광고)' + @NO_REC_BRAND+' X 삼성 디지털프라자 검단본점'

		SET @MMS_MSG = '[광고] ' + @NO_REC_BRAND+' 회원분들께 드리는 혼수 상담 이벤트

♡It''s ONLY for you♡

삼성 디지털프라자 검단본점에서 
혼수 상담만 받아도 
트래블 파우치 증정♥

500만원 이상 혼수 구입하시는 분들께
오드 소형가전 3종세트 증정♥
※카플친에서 쿠폰 발행해주세요

자세히 확인하기 > https://url.kr/u8ap67

2023년 1월 검단본점 가장 큰 혜택
삼성전자 세일 페스타 
선착순 한정 할인 제품부터 추가 사은품까지
만나보시길 바랍니다! 

검단본점 삼세페 바로가기 >https://url.kr/yb17jx

------------------------------
삼성 디지털프라자 검단본점은 
카카오톡 채널 또는 
전화/ 문자를 통해 
전국 비대면 상담이 가능한 
매장입니다.

1. 검단본점 카카오톡 채널 
http://pf.kakao.com/_xbgdyV

2. 검단본점 전화 상담 
tel:010-5522-0570

※ 본 문자는 2023. 1. 3 기준,
   SMS 수신동의한 고객님께
   발송되었습니다.

[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @CALLBACK + '로 수신거부 문자 전송
080-938-0850 수신거부 무료통화'

		--(MMS)파일명^컨텐츠타입^컨텐츠서브타입  파일명^1:이미지^0:JPG
		SET @CONTENT_DATA = 'https://postfiles.pstatic.net/MjAyMzAxMDNfMTAz/MDAxNjcyNzEzNTE4NDQy.ezShbvXoa5hrNqu_ZguaLOK3LSCNABm0Y5giQ5AN4t4g.g2XPwt2TUsPlbQh2pmacAG3euaEax060ZiJYIB5CHNAg.JPEG.rjaeks4207/Artboard_1_copy_5-100.jpg?type=w966^1^0'	
		SET @CONTENT_COUNT = 1 


		IF @CHK_SMS  = 'Y' 
		BEGIN 				
			SET @DEST_INFO = @ETC_INFO+'^'+@PHONE_NUM
			EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, @CONTENT_COUNT, @CONTENT_DATA, 0, @SERVICE,'','',@RESERVED4,'','','','','','',''
		END

		UPDATE jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE AND phone_num =  @PHONE_NUM  AND send_chk ='N'
  
		FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS 
	END
 
	CLOSE cur_AutoInsert_For_Order  
	DEALLOCATE cur_AutoInsert_For_Order  
END
GO
