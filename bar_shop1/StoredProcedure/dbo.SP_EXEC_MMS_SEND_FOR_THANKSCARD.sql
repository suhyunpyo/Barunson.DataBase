IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_THANKSCARD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_THANKSCARD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2021-05-03 정혜련  

[바른손카드] 청첩장 주문 고객 배송후 2일후 영업일기준, 감사장안내 문자발송(알림톡x)

 EXEC SP_EXEC_MMS_SEND_FOR_THANKSCARD
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_THANKSCARD]  
AS  
BEGIN  

	/****** 20201123 표수현 추가 START ****/
	DECLARE	@ErrNum   INT          
		  , @ErrSev   INT          
		  , @ErrState INT          
		  , @ErrProc  VARCHAR(50)  
		  , @ErrLine  INT          
		  , @ErrMsg   VARCHAR(2000)
	/****** 20201123 표수현 추가 END ****/

  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @Today_Dt AS VARCHAR(8)  
 
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Gift CURSOR FAST_FORWARD  
 FOR  

	SELECT (CASE WHEN sales_gubun IN ('B', 'H', 'C') THEN 'B' ELSE 'SB' end ) sales_Gubun, order_hphone
	FROM CUSTOM_ORDER c
	WHERE SALES_GUBUN = 'SB'
	and src_send_date >= CONVERT(CHAR(10), GETDATE() -1 , 23)
	and src_send_date < CONVERT(CHAR(10), GETDATE() , 23)
	AND pay_type <> '4'
	and order_type in ('1','6','7')

	-- test 문자 발송 --
	--SELECT (CASE WHEN sales_gubun IN ('B', 'H', 'C') THEN 'B' ELSE 'SB' end ) sales_Gubun, '010-9484-4697' order_hphone
	--FROM CUSTOM_ORDER c
	--WHERE SALES_GUBUN = 'SB'
	--and MEMBER_ID ='S4GUEST'
	--AND ORDER_SEQ IN (3147028, 3146283 )

	--SELECT dbo.fn_IsWorkDay(getdate(),  3) as last_Dt  


	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS

	SET		@SCHEDULE_TYPE = 1 
	SELECT  @SEND_DT = replace(dbo.fn_IsWorkDay(getdate(),  2),'-','')    --날짜
	SET		@TIME = '123000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트

	set @SEND_DATE = @SEND_DT+@TIME

 OPEN cur_AutoInsert_For_Gift  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @CALLBACK VARCHAR(50)  
 DECLARE @UID VARCHAR(50)  
 DECLARE @LINK_URL VARCHAR(100)
  
  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호 

 DECLARE @DEST_INFO	VARCHAR(100)  
 DECLARE @RESERVED4      VARCHAR(50)
	   
 FETCH NEXT FROM cur_AutoInsert_For_Gift INTO @SERVICE,  @PHONE_NUM
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
        
   IF @SERVICE = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @CALLBACK  = '1644-0708'
	 SET @LINK_URL =  'https://m.barunsoncard.com/exhibition/thankyou.asp' 
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
     SET @LINK_URL =  ''   
    END  
   ELSE  
    BEGIN  
     SET @NO_REC_BRAND = '프리미어페이퍼'      
     SET @CALLBACK  = '1644-8796'  
    END  

  
SET @MMS_SUBJECT = '['+ @NO_REC_BRAND+'] 진심을 담은, 감사장으로 마음을 표현하세요!'

SET @MMS_MSG = '어려운 시기,
진심 어린 축하의 마음을 보내주신
고마운 분들께
정성 어린 마음을 담은
감사장으로 마음을 표현하세요!

□ 한지형 감사장
- 고급 한지에 디자인 포인트를 더한
메시지형 감사장으로 정성 어린 마음을 담아보세요.

□ 돈봉투형 감사장
- 상품권/교통비 등을 담을 수 있는
돈봉투형 감사장으로 감사한 마음을 전해보세요.

■ '+ @NO_REC_BRAND+' 회원 전용 혜택
- 청첩장 결제 완료 시 감사장 15% 할인쿠폰 자동 발급

▶ '+ @NO_REC_BRAND+' 감사장 보러 가기 : ' + @LINK_URL + '


[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @CALLBACK + '로 수신거부 문자 전송'
					 
 	  SET @DEST_INFO = 'AA^'+@PHONE_NUM
	
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
		SET @PHONE_NUM = '^' + @PHONE_NUM
       EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE, '', '', @RESERVED4, '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

  FETCH NEXT FROM cur_AutoInsert_For_Gift INTO  @SERVICE,  @PHONE_NUM
 END  
  
 CLOSE cur_AutoInsert_For_Gift  
 DEALLOCATE cur_AutoInsert_For_Gift  
END
GO
