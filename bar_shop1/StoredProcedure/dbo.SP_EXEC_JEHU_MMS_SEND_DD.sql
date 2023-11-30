IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_DD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_DD
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
 
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('SD','010-9484-4697','20200626','N')
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('SD','010-9487-2411','20200626','N')
  insert into jehu_send_mms (service, phone_num,send_dt,send_chk) values ('SD','010-8934-4814','20200626','N')


  010-8934-4814, 010-9487-2411, 010-5396-0277, 010-2357-5995

 exec [SP_EXEC_JEHU_MMS_SEND_DD]
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_DD]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
  
    SET @TIME = ' 17:00:00'
	SET @Today_Dt = '20200626'  
  
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  SELECT CONVERT(VARCHAR(10), getdate(), 120) + @TIME AS SEND_DATE, SERVICE, PHONE_NUM, ETC_INFO  
  FROM JEHU_SEND_MMS  
  WHERE SEND_DT = @Today_Dt  
  AND SEND_CHK ='N'  
  AND PHONE_NUM NOT IN (SELECT HPHONE FROM DD_BANLIST) 
  
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
         
   SET @NO_REC_BRAND = '디얼디어'      
   SET @MMS_PHONE  = '1661-2646'  
   SET @evt_url = ''
    
SET @MMS_SUBJECT = '(광고)'+@NO_REC_BRAND+' 회원분들께 드리는 이벤트 혜택 안내'

SET @MMS_MSG = '(광고)'+@NO_REC_BRAND+' 회원분들께 드리는 이벤트 혜택 안내  

[현대백화점 신촌점 X 디얼디어] 
골든듀 창사 31주년 기념
"GOOD LUCK 31"

상세보기 : https://bit.ly/골든듀_31주년
ㆍ기간 : 6.26(금)~7.12(일)
ㆍ장소 : 신촌점 2F 골든듀 매장
■ 창사기념 혜택
 ① 전품목 20% 할인
 ② 31개 대표아이템 31% 할인
 ③ 캐럿 & 리미티드 제품 10% 할인
■ Wedding Special
 *창사기념혜택과 중복가능
 *청첩장 소지고객 한정

 ① 1/2/3백만 이상 구매시
     5/10/15만원 즉시 할인
 ② 1/2/3/5/7백만 이상 구매시
     특별 사은증정
 ③ 캐럿 10/20/30/50백만 구매시
     5% 상품권 증정
※ 문의 : 현대백화점 신촌점 골든듀
             02-3145-2116

[수신거부] '+@NO_REC_BRAND+' 고객센터 '+@MMS_PHONE					

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
