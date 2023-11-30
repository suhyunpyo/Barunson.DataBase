IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_DD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_DD
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

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,etc_info) values ('SD','010-9484-4697','20220112','N','s4guest') -- 정혜련
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-9189-5018','20210203','N','BHF0069671') -- 강주연

 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_DD] 
 
 이미지 첨부 프로시저 발송
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_KT_DD]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	--DECLARE @RESERVED4      VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = '20220112' 
	SET @TIME = '163000'

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
        

     SET @NO_REC_BRAND = '디얼디어'      
     SET @CALLBACK  = '1661-2646'  
     SET @CHK_SMS  = 'Y'
     SET @SCHEDULE_TYPE = 0
     SET @SEND_DATE = ''
	 SET @DEST_INFO = 'AA^'+@PHONE_NUM

SET @MMS_SUBJECT = '안녕하세요 디얼디어 입니다.'


SET @MMS_MSG =  '[디얼디어] 고객님. 죄송하게도 선택하신 화이트/그레이 식권 품절되어 그린/핑크 식권으로 대체되어 발송 드리는 점 양해 부탁드립니다. 불편 드려 죄송합니다.'
					
	
	EXEC PROC_SMS_MMS_SEND @ETC_INFO, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','','','','','','','','',''

	update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @SEND_DT AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE,  @PHONE_NUM, @ETC_INFO 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
