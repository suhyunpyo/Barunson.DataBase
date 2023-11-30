IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_GIFT_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_GIFT_TEST
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
 exec SP_EXEC_MMS_SEND_FOR_GIFT_TEST
 -- 010-8929-6592 나요셉님

*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_GIFT_TEST]  
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
    DECLARE @GUBUN AS VARCHAR(1)
	 
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Gift CURSOR FAST_FORWARD  
 FOR  


	SELECT ( CASE 
			WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
				CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
			ELSE 
				CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
		END ) as site_div  
		,  '010-8929-6592'
		, UID 
		,'B'
	FROM VW_USER_INFO AS A  
	WHERE LEN(A.HPHONE) > 12   
		AND A.DupInfo IS NOT NULL    
		AND A.ConnInfo IS NOT NULL  
		AND site_div ='SB'
		AND uid ='s4guest' 

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

 DECLARE @DEST_INFO	VARCHAR(100)  
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
  

-- 1차 결혼예식일 D-15데일리로 자동 발송요청
IF @GUBUN = 'A'
 begin
SET @MMS_SUBJECT = '[광고] 결혼식 답례품 준비하셨나요?'


SET @MMS_MSG = '[광고] 결혼식 답례품 준비하셨나요?

2주앞으로 찾아온 결혼예식!

센스있는 신부,신랑의 선택!
직장동료및 지인들에게
감사의 마음을 전하세요♡

답례품은 선택이 아닌 필수!

① 오설록 블루밍데이(9입)
판매가 : 4,900원
※ 바른손단독 ※

② 히말라야소금(200g)
판매가 : 3,100원

③ 벌집꿀(240g)
판매가 : 8,900원

④ 원더커피 5종
판매가 : 6,900원

새로운 답례품으로
감사의 마음을 전하고
사은품도 받아가세요!

▼답례품 미리 예약하기▼
http://asq.kr/Os54zRdOPapk
 
[수신거부] '+ @NO_REC_BRAND+' 고객센터
'+ @CALLBACK + '로 수신거부 문자 전송'

end
-- 2차 결혼예식일 D-5데일리로 자동 발송요청
ELSE IF @GUBUN = 'B'  
begin
SET @MMS_SUBJECT = '[광고] 결혼준비 마무리 답례품!'


SET @MMS_MSG = '[광고] 결혼준비 마무리 답례품!

일주일 앞으로 찾아온 결혼예식!

답례품 꼼꼼하게 따져보고
준비하셨나요? 바른손에서만
구매할수 있는 답례품으로
감사의 마음을 전하세요♡

답례품은 선택이 아닌 필수!

① 오설록 블루밍데이(9입)
판매가 : 4,900원
※ 바른손단독 ※

② 히말라야소금(200g)
판매가 : 3,100원

③ 벌집꿀(240g)
판매가 : 8,900원

④ 원더커피 5종
판매가 : 6,900원

색다른 답례품으로
감사의 마음을 전하고
사은품도 받아가세요!

▼답례품 미리 예약하기▼
http://asq.kr/uTom0K7ApHvq58
 
[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @CALLBACK + '로 수신거부 문자 전송'
end
					 
 	SET @DEST_INFO = @UID+'^'+@PHONE_NUM
	
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
