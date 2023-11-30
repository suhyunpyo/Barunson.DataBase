IF OBJECT_ID (N'dbo.SP_EXEC_SMS_SEND_KT_ONLINE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_SEND_KT_ONLINE
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

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-9484-4697','20210128','N','s4guest') -- 정혜련

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-5502-1221','20201215','N','s4guest') -- 최지민
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-5918-2106','20210111','N','s4guest') -- 윤선화
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-5396-0277','20210127','N','s4guest') -- 강주연

 exec [SP_EXEC_SMS_SEND_KT_ONLINE]
 -- SMS 보내기--
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_SEND_KT_ONLINE]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	--DECLARE @RESERVED4      VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20210128' 
	SET @TIME = '170000'

	set @SEND_DATE = @SEND_DT+@TIME
	--SET @RESERVED4 = '1'
     
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT s.SERVICE, s.PHONE_NUM, s.ETC_INFO, m.chk_sms
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

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @SERVICE = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @CALLBACK  = '1644-0708'  
     SET @evt_url = 'https://bit.ly/37Y65pL'
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
     SET @evt_url = 'https://bit.ly/2W9x9gj' 
    END  
   ELSE IF @SERVICE = 'B'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @CALLBACK  = '1644-7413'  
     SET @evt_url = 'https://bit.ly/2KrS23D'
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

SET @MMS_SUBJECT = ''


SET @MMS_MSG =  '바른손카드 고객님'
	
   IF @CHK_SMS  = 'Y' 
 
   BEGIN 				

	  SET @DEST_INFO = @ETC_INFO+'^'+@PHONE_NUM
	
	  EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','','','','','','','','',''

   END

   update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
