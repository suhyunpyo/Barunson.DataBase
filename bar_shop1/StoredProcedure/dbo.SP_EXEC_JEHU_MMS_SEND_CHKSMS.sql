IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_CHKSMS
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

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-9484-4697','20201113','N','s4guest') -- 정혜련
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('ST','010-9880-2629','20201113','N','s4guest') -- 김보미
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('ST','010-4720-0722','20201113','N','s4guest') -- 강솔
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-3179-6204','20201113','N','s4guest') -- 제휴업체


 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-5502-1221','20200910','N','s4guest') -- 최지민
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-5918-2106','20200916','N','s4guest') -- 윤선화
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SS','010-6557-0310','20200916','N','s4guest') -- 박보미
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('SB','010-5396-0277','20200923','N','s4guest') -- 강주연

 exec [SP_EXEC_JEHU_MMS_SEND_CHKSMS]
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_CHKSMS]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
  
    --SET @TIME = ' 16:00:00'  
    SET @TIME = ' 15:00:00'
	SET @Today_Dt = '20201113' 
  
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
  
SET @MMS_SUBJECT = '(광고)롯데백화점 X' + @NO_REC_BRAND+' 단독혜택'


SET @MMS_MSG = '(광고)롯데백화점 웨딩멤버스

오직 ' + @NO_REC_BRAND+' 고객님께만 드리는 
롯데백화점 웨딩멤버스 신규가입 혜택!

아래 링크를 통해 롯데백화점 웨딩멤버스에 신규가입 하시면 웨딩마일리지 10만점을 드립니다!
[' + @NO_REC_BRAND+' 전용 링크]
▶ https://url.kr/G5Qevf

※ 웨딩멤버스란? 
9개월동안 롯데백화점 전점에서의 구매 내역이 마일리지로 적립되며 9개월 후 적립금액에 따라 
5~7% 롯데상품권 리워드 혜택
[문의] https://url.kr/MFesaw


※ 본 문자는 2020. 11. 12 기준, 
   SMS 수신동의한 고객님께 
   발송되었습니다. 

[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @MMS_PHONE + '로 수신거부 문자 전송'
	
   IF @CHK_SMS  = 'Y' 
   
   BEGIN 				
	   --MMS 전송  
	   INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE,etc4)  
	   VALUES (  @MMS_SUBJECT  
		 , @PHONE_NUM  
		 , @MMS_PHONE  
		 , '0'  
		 , @MMS_DATE  
		 , @MMS_MSG  
		 , '0' 
		 , 1)  
   END

  
   update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @Today_Dt AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @MMS_DATE, @SERVICE,  @PHONE_NUM, @ETC_INFO, @CHK_SMS 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
