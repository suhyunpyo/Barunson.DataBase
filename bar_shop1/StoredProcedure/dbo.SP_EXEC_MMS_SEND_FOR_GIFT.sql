IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_GIFT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_GIFT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************    
    
2020-08-27 정혜련    
2020-11-30 (KT로 변경)  
  
- 답례품 관련 LMS 발송 요청  
- 조건 :  
 결혼예식일 D-15 (9/1일부터 발송시작) 데일리로 자동 발송요청  
 LMS 수신 동의 고객 (바, 더, 프, 몰, 비, 디 고객 전체)  
  
 service    
 SB(바른손카드)/ SA(비핸즈)/ SS(프리미어페이퍼)/ ST(더카드)/ B(바른손몰)    
 exec SP_EXEC_MMS_SEND_FOR_GIFT  
 -- 010-6476-6536 이종혁  
  
*********************************************************/    
    
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_GIFT]    
AS    
BEGIN    
  
 /****** 20201123 표수현 추가 START ****/  
 DECLARE @ErrNum   INT            
    , @ErrSev   INT            
    , @ErrState INT            
    , @ErrProc  VARCHAR(50)    
    , @ErrLine  INT            
    , @ErrMsg   VARCHAR(2000)  
 /****** 20201123 표수현 추가 END ****/  
  
    
    DECLARE @TIME AS VARCHAR(10)    
    DECLARE @Today_Dt AS VARCHAR(8)    
    DECLARE @GUBUN AS VARCHAR(1)  
    
 --커서를 이용하여 해당되는 고객정보를 얻는다.    
 DECLARE cur_AutoInsert_For_Gift CURSOR FAST_FORWARD    
 FOR    
  
 SELECT  ( CASE   
   WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN   
    CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END  
   ELSE   
    CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END  
  END ) as site_div    
  , hphone  
  ,UID  
  ,'C' GUBUN  
 FROM VW_USER_INFO AS A    
 WHERE LEN(A.HPHONE) > 12     
  AND A.DupInfo IS NOT NULL      
  AND A.ConnInfo IS NOT NULL    
  and a.INTERGRATION_DATE >= CONVERT(CHAR(10), GETDATE() -2, 23)  
  and a.INTERGRATION_DATE < CONVERT(CHAR(10), GETDATE() -1 , 23)      
  AND A.chk_sms = 'Y'    
  AND site_div ='SB'  
  
--  테스트문자  
-- SELECT  'SB' as site_div    
--  , '010-6476-6536'  
--  ,UID  
--  ,'C' GUBUN  
-- FROM VW_USER_INFO AS A    
-- WHERE LEN(A.HPHONE) > 12     
--  and uid ='s4guest'   
--  AND site_div ='SB'  
  
  
 OPEN cur_AutoInsert_For_Gift    
    
 DECLARE @MMS_DATE VARCHAR(100)    
 DECLARE @PHONE_NUM VARCHAR(100)    
 DECLARE @U_ID VARCHAR(100)    
 DECLARE @SERVICE VARCHAR(4)    
    
 DECLARE @MMS_MSG VARCHAR(MAX)    
 DECLARE @MMS_SUBJECT VARCHAR(60)    
 DECLARE @CALLBACK VARCHAR(50)    
 DECLARE @UID VARCHAR(50)    
    
    
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드    
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호   
  
 DECLARE @DEST_INFO VARCHAR(100)    
 DECLARE @RESERVED4      VARCHAR(50)  
  
 DECLARE @ORDER_CNT AS INT = 0  
  
 FETCH NEXT FROM cur_AutoInsert_For_Gift INTO @SERVICE,  @PHONE_NUM, @UID, @GUBUN  
    
 WHILE @@FETCH_STATUS = 0    
    
 BEGIN    
          
   IF @SERVICE = 'SB'    
    BEGIN    
     SET @NO_REC_BRAND = '바른손카드'        
     SET @CALLBACK  = '1644-0708'    
    END    
   ELSE IF @SERVICE = 'SA'    
    BEGIN    
     SET @NO_REC_BRAND = '비핸즈카드'        
     SET @CALLBACK  = '1644-9713'    
    END    
    
   ELSE IF @SERVICE = 'ST'    
    BEGIN    
     SET @NO_REC_BRAND = '더카드'         
     SET @CALLBACK  = '1644-7998'   
    END    
   ELSE IF @SERVICE = 'B'    
    BEGIN    
     SET @NO_REC_BRAND = '바른손몰'        
     SET @CALLBACK  = '1644-7413'    
    END    
   ELSE    
    BEGIN    
     SET @NO_REC_BRAND = '프리미어페이퍼'        
     SET @CALLBACK  = '1644-8796'    
    END    
  
SET @RESERVED4 = '2'  
    
  
begin  
SET @MMS_SUBJECT = '[광고] 미리 준비하는 예약 답례품!'  
  
  
SET @MMS_MSG = '[광고] 결혼준비 마무리 답례품!  
  
미리 잊지말고 준비하세요!  
  
담고자 하는 그 마음  
오롯이 전해질 수 있도록,  
주는 즐거움과 받는 기쁨이  
가득하길 바라는 마음으로  
정성껏 준비했습니다.  
  
답례품은 마음의 선물입니다.  
  
① 마누카 스틱 꿀 세트(5포)  
판매가 : 8,400원  
※ 현대백화점 ※  
    
② 오설록 블루밍 데이(9입)  
판매가 : 4,900원  
※ 바른손 단독 ※  
    
③ 히말라야 소금(200g)  
판매가 : 3,100원  
※ 천연 암염 ※  
   
④ 드립 커피 선물세트(6입)  
 판매가 : 4,500원  
※ 할리스커피 ※  
  
답례품 선택은 바른손카드  
아래▼ 사이트에서!  
지금 바로 클릭☜클릭☜  
  
▼답례품 미리 예약하기▼  
https://barunsongshop.com/ 
   
[수신거부] '+ @NO_REC_BRAND+' 고객센터  
 '+ @CALLBACK + '로 수신거부 문자 전송'  
  
end  
    
        
  SET @DEST_INFO = @UID+'^'+@PHONE_NUM  
   
 select @ORDER_CNT  = count(c.order_seq)  
 from	custom_etc_order_item ci, custom_Etc_order c  
 where	c.order_seq = ci.order_seq   and 
		c.member_id =  @UID  AND 
		c.order_date >= getdate() - 150  and 
		ci.card_Seq in (   
							SELECT card_seq  FROM S2_cARD WHERE Card_Div = 'C08' 
					   )     
  
 /*답례품 주문한 고객 제외*/  
 IF @ORDER_CNT = 0   
 begin  
    
  /* 2020-11-23 KT 문자 서비스 작업 변경 */  
  SET @PHONE_NUM = '^' + @PHONE_NUM  
  
  EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, @MMS_SUBJECT, @MMS_MSG, '', @CALLBACK, 1, @PHONE_NUM, 0, '', 0, @SERVICE, '', '', @RESERVED4, '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT  
      
  insert into GIFT_DAILY_MMS (send_dt,uid) values (left(CONVERT(CHAR(19), getdate(), 20),10),@UID)  
 end  
  
      
  FETCH NEXT FROM cur_AutoInsert_For_Gift INTO  @SERVICE,  @PHONE_NUM, @UID, @GUBUN  
 END    
    
 CLOSE cur_AutoInsert_For_Gift    
 DEALLOCATE cur_AutoInsert_For_Gift    
END
GO
