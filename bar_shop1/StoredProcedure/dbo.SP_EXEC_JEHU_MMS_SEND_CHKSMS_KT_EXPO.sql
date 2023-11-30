IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_EXPO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_EXPO
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

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('B','010-9484-4697','20210707','N','BHF0069671') -- 정혜련
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('B','010-9189-5018','20210203','N','BHF0069671') -- 강주연

 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_EXPO] 
 
 이미지 첨부 프로시저 발송
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_EXPO]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	--DECLARE @RESERVED4      VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20210820' 
	SET @TIME = '161000'

	set @SEND_DATE = @SEND_DT+@TIME
	--SET @RESERVED4 = '1'
     
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT s.SERVICE, s.PHONE_NUM, s.ETC_INFO
  FROM JEHU_SEND_MMS s
  WHERE  s.SEND_DT = @SEND_DT  
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

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @SERVICE = 'B'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @CALLBACK  = '1644-7413'  
     SET @evt_url = 'https://bit.ly/2KrS23D'
    END  
 
     SET @CHK_SMS  = 'Y'
     SET @SCHEDULE_TYPE = 0
     SET @SEND_DATE = ''
	SET @DEST_INFO = 'AA^'+@PHONE_NUM

SET @MMS_SUBJECT = '안녕하세요 바른손 카드 입니다. '


SET @MMS_MSG =  '안녕하세요 바른손카드 입니다. 
지난 호텔ICC 웨딩쇼케이스 에서
저희 바른손카드 부스에서 설문조사를 응해주신 고객분들께만 드리는 
특별한 혜택!!!

제휴할인과 함께 5% 중복적용이 가능한 쿠폰입니다. 
마이페이지-쿠폰보관함에서 아래 쿠폰번호를 입력하시면 됩니다.
행복한 결혼 준비되세요!!!
(청첩장주문건에 1회사용이 가능/제휴할인 중복적용 가능)

쿠폰번호 : '+@ETC_INFO+'
쿠폰기한 : 2021.12.31

★사이트 접속방법★
1. www.barunsonmall.com 접속
2. 제휴사코드 입력 hotelicc


[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @CALLBACK + '로 수신거부 문자 전송'
					
	
	EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','','','','','','','','',''

	update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
