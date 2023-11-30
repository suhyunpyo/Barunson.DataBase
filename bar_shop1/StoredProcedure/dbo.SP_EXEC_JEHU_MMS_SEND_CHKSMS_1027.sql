IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_1027', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS_1027
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
 
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('B','010-8934-4814','20200710','N','s4guest') -- 원덕규팀장님

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('ST','010-9484-4697','20201030','N','s4guest') -- 정혜련
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('ST','010-9880-2629','20201027','N','s4guest') -- 김보미
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('ST','010-4720-0722','20201027','N','s4guest') -- 강솔
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-2670-4019','20201027','N','s4guest') -- 제휴업체


 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-5502-1221','20201015','N','s4guest') -- 최지민
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-5918-2106','20200916','N','s4guest') -- 윤선화
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-6557-0310','20200916','N','s4guest') -- 박보미
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('ST','010-5396-0277','20201030','N','s4guest') -- 강주연
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('B','010-6764-0922','20201014','N','s4guest') -- 차재원
 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS_1027]
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS_1027]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
  
    --SET @TIME = ' 16:00:00'  
    SET @TIME = ' 17:00:00'
	SET @Today_Dt = '20201030' 
  
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT CONVERT(VARCHAR(10), getdate(), 120) + @TIME AS SEND_DATE, s.SERVICE, s.PHONE_NUM, s.ETC_INFO, m.chk_sms
  FROM JEHU_SEND_MMS s, s2_userinfo_bhands  m 
  WHERE s.etc_info = m.uid and s.SEND_DT = @Today_Dt  
  AND s.SEND_CHK ='N'  
  
 OPEN cur_AutoInsert_For_Order  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @MMS_PHONE VARCHAR(50)  
 DECLARE @ETC_INFO VARCHAR(50)  
 DECLARE @chkCnt INT;  
 DECLARE @CHK_SMS VARCHAR(1);   
 
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  
  
 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @SERVICE = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @MMS_PHONE  = '1644-0708'  
	 set @evt_url = 'https://bit.ly/2XQecRZ'
    END  
  
   ELSE IF @SERVICE = 'SA'  
    BEGIN  
     SET @NO_REC_BRAND = '비핸즈카드'      
     SET @MMS_PHONE  = '1644-9713'  
	 set @evt_url = ''
    END  
  
  
   ELSE IF @SERVICE = 'ST'  
    BEGIN  
     SET @NO_REC_BRAND = '더카드'       
     SET @MMS_PHONE  = '1644-7998' 
	 set @evt_url = 'http://bit.ly/2QdlKJN' 
    END  
   ELSE IF @SERVICE = 'B'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @MMS_PHONE  = '1644-7413'  
	 set @evt_url = ''
    END  
   ELSE  
    BEGIN  
     SET @NO_REC_BRAND = '프리미어페이퍼'      
     SET @MMS_PHONE  = '1644-8796'  
	 set @evt_url = 'https://bit.ly/2XCihZA'
    END  
  
	-- 테스트를 윈한
   IF @ETC_INFO = 's4guest'  
    BEGIN  
     set @CHK_SMS  = 'Y' 
    END    
  
 SET @MMS_SUBJECT = '(광고) ' + @NO_REC_BRAND+' 회원 전용 사이트 OPEN♥'
--SET @MMS_SUBJECT = '(광고) ★예비 신혼부부 주목★'

SET @MMS_MSG = '(광고) ' + @NO_REC_BRAND+' 회원 전용 사이트 OPEN♥

MASKAFE 바이오-셀룰로오스 마스크팩이 
샵에서 관리받은 피부를 약속합니다-♥

에스테틱 원장님들이 사용하는 바로 그 제품

▶집에서 손쉽게 하는 에스테틱 관리◀
#1. 고품격 스페셜 데일리 
바이오셀룰로오스 마스크팩을
' + @NO_REC_BRAND+' 전용 특가 페이지에서 만나보세요
- 링크 : http://urof.linkapp.co.kr/

▶홈에스테틱으로 만드는 꿀피부◀
#2. 30분의 기적이라 불리는 마법같은 
코코넛 테라피 마스크팩을 소개합니다
- 링크 : http://asq.kr/hOxtD52B5NnF

이런 분들 기다립니다~
☞ 비용적,시간적 여유 없으신 분
☞ 화장 뜨고 각질 일어나는 분
☞ 마스크 속 트러블로 스트레스 받으시는 분
☞ 에스테틱 관리받은 듯한 피부 원하시는 분
☞ 이 문자를 받으신 모든 분들 :)

마스크팩 관련 문의 및 상담은 
02-2055-1240으로 연락주세요.

[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @MMS_PHONE + '로 수신거부 문자 전송'
	
   IF @CHK_SMS  = 'Y' 
   
   BEGIN 				
	   --MMS 전송  
	   INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE)  
	   VALUES (  @MMS_SUBJECT  
		 , @PHONE_NUM  
		 , @MMS_PHONE  
		 , '0'  
		 , @MMS_DATE  
		 , @MMS_MSG  
		 , '0' 
		 )  
   END

  
   update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @Today_Dt AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @MMS_DATE, @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
