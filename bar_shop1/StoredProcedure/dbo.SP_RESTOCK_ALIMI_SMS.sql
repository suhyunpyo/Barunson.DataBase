IF OBJECT_ID (N'dbo.SP_RESTOCK_ALIMI_SMS', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_RESTOCK_ALIMI_SMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Create date: 2020.01.30
-- Description:	재입고 알리미

--exec SP_RESTOCK_ALIMI_SMS
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[SP_RESTOCK_ALIMI_SMS] 
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
    
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
	select seq, s.company_seq, sc.card_code, hand_phone1+hand_phone2+hand_phone3 AS hphone, sc.card_name 
	from S4_Stock_Alarm s, S2_CardSalesSite c, s2_Card sc
	where s.company_seq =  c.company_seq
	and s.isAlarm_send = 'N' 
	and s.card_seq = sc.card_Seq
	and s.card_seq = c.card_seq
	and IsJumun  = 1
	and IsDisplay = '1' 
  
 OPEN cur_AutoInsert_For_Order  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MSG VARCHAR(MAX)  
 DECLARE @TITLE VARCHAR(60)  
 DECLARE @CALL_NUMBER VARCHAR(50)  
 DECLARE @ETC_INFO VARCHAR(50)  
  
  
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

 DECLARE @company_seq VARCHAR(4)
 DECLARE @seq INT
 DECLARE @card_code VARCHAR(10)
 DECLARE @USER_HPHONE VARCHAR(20)
 DECLARE @card_name VARCHAR(30)
   
 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @seq, @company_seq, @card_code, @USER_HPHONE, @card_name
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @company_seq = '5001'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @CALL_NUMBER  = '1644-0708'  
    END  
   ELSE IF @company_seq = '5006'  
    BEGIN  
     SET @NO_REC_BRAND = '비핸즈카드'      
     SET @CALL_NUMBER  = '1644-9713'  
    END  
   ELSE IF @company_seq = '5007'  
    BEGIN  
     SET @NO_REC_BRAND = '더카드'       
     SET @CALL_NUMBER  = '1644-7998' 
    END  
   ELSE IF @company_seq = '5003'  
    BEGIN  
     SET @NO_REC_BRAND = '프리미어페이퍼'      
     SET @CALL_NUMBER  = '1644-8796'  
    END  
   ELSE  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @CALL_NUMBER  = '1644-7413'  
    END  
  
SET @TITLE = '['+ @NO_REC_BRAND+'] '+@CARD_CODE+' 제품이 입고되었습니다'

SET @MSG = '['+ @NO_REC_BRAND+']고객님! '+@CARD_CODE+'('+@CARD_name+')제품이 입고되었습니다. '+ @NO_REC_BRAND+ '사이트에서 확인하세요'
					
   -- 전송    
    EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @USER_HPHONE, @TITLE, @MSG, 'TR_ETC2', '재입고 알리미', '', '', 0, ''
	
	update S4_Stock_Alarm set isAlarm_send = 'Y' , send_date = getdate() WHERE seq = @seq and isAlarm_send ='N'
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @seq, @company_seq, @card_code, @USER_HPHONE , @card_name
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
