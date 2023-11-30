IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND
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
 
 010-8934-4814 - 원덕규팀장님
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('SB','010-8934-4814','20191104','N')
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('ST','010-8934-4814','20190723','N')
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('SB','010-9484-4697','20191104','N')
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('B','010-8934-4814','20190905','N')
 exec [SP_EXEC_JEHU_MMS_SEND]
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
  
    --SET @TIME = ' 16:00:00'  
    SET @TIME = ' 14:00:00'
	SET @Today_Dt = '20200804'  
  
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT CONVERT(VARCHAR(10), getdate(), 120) + @TIME AS SEND_DATE, SERVICE, PHONE_NUM, ETC_INFO  
  FROM JEHU_SEND_MMS  
  WHERE SEND_DT = @Today_Dt  
  AND SEND_CHK ='N'  
  
 OPEN cur_AutoInsert_For_Order  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @MMS_PHONE VARCHAR(50)  
 DECLARE @ETC_INFO VARCHAR(50)  
  
  
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  
  
 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @SERVICE,  @PHONE_NUM, @ETC_INFO
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @SERVICE = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @MMS_PHONE  = '1644-0708'  
	 set @evt_url = 'http://m.barunsoncard.com/event/event_affiliated_kyobo.asp'
    END  
  
   ELSE IF @SERVICE = 'SA'  
    BEGIN  
     SET @NO_REC_BRAND = '비핸즈카드'      
     SET @MMS_PHONE  = '1644-9713'  
	 set @evt_url = 'http://ehyundai2.net/cosmeticfair'
    END  
  
  
   ELSE IF @SERVICE = 'ST'  
    BEGIN  
     SET @NO_REC_BRAND = '더카드'       
     SET @MMS_PHONE  = '1644-7998' 
	 set @evt_url = 'http://m.thecard.co.kr/mobile/event/event_affiliated_kyobo.asp' 
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
	 set @evt_url = 'http://m.premierpaper.co.kr/mobile/event/event_2019kyobo.asp'
    END  
  
  
  
  
SET @MMS_SUBJECT = '(광고) [' + @NO_REC_BRAND+'] 청첩장 신상품 1만원 쿠폰 이벤트!'

SET @MMS_MSG = '
(광고) [' + @NO_REC_BRAND+'] 청첩장 신상품 1만원 쿠폰 이벤트!

바른손카드 청첩장 신상품 1만원 쿠폰 이벤트!

어려운 시기
새롭게 출발하는
신랑 신부님들을 위해
바른손카드 FW 신상 웨딩카드
특별 할인쿠폰을 선물합니다!

＊쿠폰 발급 기간 : ~8월 31일까지
＊쿠폰 사용 기간 : ~9월 30일 까지

추가 이벤트!
신상 청첩장 구매고객 중 5분께
런드리고 10만원 이용권을 드려요!

▶ 이벤트 보러가기 : https://bit.ly/3idB7O3

[수신거부]' + @NO_REC_BRAND+' 고객센터
'+ @MMS_PHONE + ' 로 수신거부 문자 전송'
					
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
  
  
update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @Today_Dt AND service = @SERVICE and  phone_num =  @PHONE_NUM  and send_chk ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @MMS_DATE, @SERVICE,  @PHONE_NUM, @ETC_INFO 
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
