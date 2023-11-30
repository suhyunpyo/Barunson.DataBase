IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_BSTORE', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_BSTORE
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2020-08-27 정혜련  
2020-11-30 (KT로 변경)

- 신규사업 바른손스토어 관련 LMS 발송 요청

▶ LMS 수신 대상자
- 회원가입 D+14 이상인 고객 & 예식일 D-100~60 해당되는 고객

▶ 일정
- 발송시기: 매주 수요일 (주1회, 월 최대5회)
- 발송시간: 오전 8시40분
- 테스트 번호 :  010-7312-1252 (이지응)

 EXEC SP_EXEC_MMS_SEND_FOR_BSTORE
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_BSTORE]  
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

    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @CHK_WEEKDAY AS VARCHAR(1) -- 요일계산
	
	SET		@SCHEDULE_TYPE = 1  	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)

	
--	SELECT @CHK_WEEKDAY = DATEPART(WEEKDAY, GETDATE())

		-- 발송날짜 및 발송 시간
--	if @CHK_WEEKDAY = '1' or @CHK_WEEKDAY = '3' or @CHK_WEEKDAY = '5' 
--		SET @SEND_DT = CONVERT(CHAR(8), GETDATE() + 1, 112)
--	else if @CHK_WEEKDAY = '2' or @CHK_WEEKDAY = '4' or @CHK_WEEKDAY = '7'  
--		SET @SEND_DT = CONVERT(CHAR(8), GETDATE() + 2, 112) 
--	else if @CHK_WEEKDAY = '6'
--		SET @SEND_DT = CONVERT(CHAR(8), GETDATE() + 3, 112) 
	
	SET @SEND_DT = CONVERT(CHAR(8), GETDATE(), 112) 
	SET	@TIME = '123000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트
	
	SET @SEND_DATE = @SEND_DT+@TIME
 
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Gift CURSOR FAST_FORWARD  
 FOR  



	SELECT  TOP 1000 ( CASE 
			WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
				CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
			ELSE 
				CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
		END ) as site_div  
		, hphone
		,UID
	FROM VW_USER_INFO AS A  
	WHERE LEN(A.HPHONE) > 12   
		AND A.DupInfo IS NOT NULL    
		AND A.ConnInfo IS NOT NULL  
		and a.WEDDING_DAY >= CONVERT(CHAR(10), GETDATE() + 60, 23)
		--and a.WEDDING_DAY < CONVERT(CHAR(10), GETDATE() + 90 , 23)  
		and a.INTERGRATION_DATE < CONVERT(CHAR(10), GETDATE() - 14 , 23) 	
		AND A.chk_sms = 'Y'  
		AND site_div ='SB'
		and not exists ( select 'Y' FROM EVENT_MMS_LOG WHERE uid = a.uid )



--	SELECT TOP 1 ( CASE 
--			WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
--				CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
--			ELSE 
--				CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
--		END ) as site_div  
--		,  '010-9484-4697'
--		, UID 
--	FROM VW_USER_INFO AS A  
--	WHERE LEN(A.HPHONE) > 12   
--		AND A.DupInfo IS NOT NULL    
--		AND A.ConnInfo IS NOT NULL  
--		AND site_div ='SB'
--		AND uid ='s4guest' 

 OPEN cur_AutoInsert_For_Gift  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @CALLBACK VARCHAR(50)  
 DECLARE @UID VARCHAR(50)  
 DECLARE @DAILY_DT VARCHAR(10) 
  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호 

 DECLARE @DEST_INFO	VARCHAR(100)  
 DECLARE @RESERVED4      VARCHAR(50)
	   
 FETCH NEXT FROM cur_AutoInsert_For_Gift INTO @SERVICE,  @PHONE_NUM, @UID
  
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

SET @RESERVED4 = '1'
  
SET @MMS_SUBJECT = '[광고] '+ @NO_REC_BRAND+' X 신혼집전문 온택트 부동산 원샵'

SET @MMS_MSG = '['+ @NO_REC_BRAND+' X 신혼집전문 온택트 부동산 원샵]

▼찐 고객에게만 보여주는 좋은집 보러가기▼
www.1shop.co.kr/sub03

1) 중개 수수료 50% 할인
2) 중개 책임제도 시행
3) 집 투어시, 차량이동 서비스 제공
4) 온라인 부동산으로, 여러지역 동시 서칭까지

[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @CALLBACK + '로 수신거부 문자 전송'
					 
 	  SET @DEST_INFO = @UID+'^'+@PHONE_NUM
	
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
		SET @PHONE_NUM = '^' + @PHONE_NUM
       EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE, '', '', @RESERVED4, '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

	   SET @DAILY_DT = left(@SEND_DATE,4) +'-'+substring(@SEND_DATE,5,2)+'-'+substring(@SEND_DATE,7,2)

	   --insert into BSTORE_DAILY_MMS (send_dt,uid) values (@DAILY_DT,@UID)
	   INSERT INTO EVENT_MMS_LOG (UID, SEND_dT, SALES_GUBUN, EVENT_GB) values (@UID,@DAILY_DT,@SERVICE,'1SHOP')

  FETCH NEXT FROM cur_AutoInsert_For_Gift INTO  @SERVICE,  @PHONE_NUM, @UID
 END  
  
 CLOSE cur_AutoInsert_For_Gift  
 DEALLOCATE cur_AutoInsert_For_Gift  
END
GO
