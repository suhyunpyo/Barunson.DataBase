IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_FOR_FINDPROPERTY', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_FOR_FINDPROPERTY
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_FOR_FINDPROPERTY]  
/***************************************************************
작성자	:	표수현
작성일	:	2022-05-17
DESCRIPTION	:	
  
  LMS정기 발송 세팅 요청드립니다.
기존에 진행하였던 원샵부동산 세팅건과 동일하여 참고해주시고 혹시 궁금하신 사항있으시면 말씀주세요!

- 발송요건 : 회원가입 D+14이상, 예식일 D-60 이상 남아있는 서울/경기/인천 고객
- 주 500건/월2,000건 제한
- 일별 발송건수 구관리자 현재 세팅되어있는 원샵MMS집계화면으로 잡아주세요

- 매주 화요일 16시(목~월 가입고객 대상) / 목요일 11시(화~수 가입고객 대상)

- 발송문안
(광고) $$$카드X신혼집 맞춤 찾아줘부동산

(광고) 온라인부동산#찾아줘부동산 에서 나만의신혼집도 찾으시고
비스포크 냉장고를 무료로 받아가세요.
자세한 내용은 하단의 링크 에서 확인하세요.
HTTPS://FINDB.KR/E/BARUNSON01

#바른손고객특전#브이패스50%할인

※ 본 문자는 2022. 3. 30 기준,
SMS 수신동의한 고객님께
발송되었습니다.

[수신거부] 바른손카드 고객센터
1644-0708 로 수신거부 문자 전송

비핸즈   1644-9713
           더카드   1644-7998
           프리미어 1644-8796
           바른손몰 1644-7413

--> 수신동의 일자 LMS발송 전일자로 세팅요청드립니다.

#############################################################################
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

******************************************************************
MODIFICATION
******************************************************************
수정일           작업자                DESCRIPTION
==================================================================
******************************************************************/
AS  
BEGIN  

	DECLARE @NOWWEEKDAY CHAR(2) 

	SELECT @NOWWEEKDAY = CASE DATEPART(WEEKDAY, GETDATE()) 
				WHEN '3' THEN '화'
				WHEN '5' THEN '목'
		   END 

	DECLARE @MMSCOUNT INT

	SELECT @MMSCOUNT = COUNT(1) 
	FROM EVENT_MMS_LOG 
	WHERE EVENT_GB = 'FINDPROPERTY' AND 
		  CONVERT(VARCHAR(7), SEND_DT, 120) = CONVERT(VARCHAR(7), GETDATE(), 120)

	--SET @NOWWEEKDAY = '목'

	--SELECT @NOWWEEKDAY
	/****** 20201123 표수현 추가 START ****/
	DECLARE	@ERRNUM   INT          
		  , @ERRSEV   INT          
		  , @ERRSTATE INT          
		  , @ERRPROC  VARCHAR(50)  
		  , @ERRLINE  INT          
		  , @ERRMSG   VARCHAR(2000)
	/****** 20201123 표수현 추가 END ****/

  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @TODAY_DT AS VARCHAR(8)  

    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) EX)YYYYMMDDHHMMSS
    DECLARE @CHK_WEEKDAY AS VARCHAR(1) -- 요일계산
	
	SET @SCHEDULE_TYPE = 0  	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)

	
--	SELECT @CHK_WEEKDAY = DATEPART(WEEKDAY, GETDATE())

		-- 발송날짜 및 발송 시간
--	IF @CHK_WEEKDAY = '1' OR @CHK_WEEKDAY = '3' OR @CHK_WEEKDAY = '5' 
--		SET @SEND_DT = CONVERT(CHAR(8), GETDATE() + 1, 112)
--	ELSE IF @CHK_WEEKDAY = '2' OR @CHK_WEEKDAY = '4' OR @CHK_WEEKDAY = '7'  
--		SET @SEND_DT = CONVERT(CHAR(8), GETDATE() + 2, 112) 
--	ELSE IF @CHK_WEEKDAY = '6'
--		SET @SEND_DT = CONVERT(CHAR(8), GETDATE() + 3, 112) 
	
	--SET @SEND_DT = CONVERT(CHAR(8), GETDATE(), 112) 
	--SET	@TIME = '123000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.S4GUEST 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트
	
	--SET @SEND_DATE = @SEND_DT+@TIME
 

 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE CUR_AUTOINSERT_FOR_GIFT CURSOR FAST_FORWARD  
 FOR  

	--IF @NOWWEEKDAY = '화' BEGIN  -- (목~월 가입고객 대상

	--DECLARE @NOWWEEKDAY CHAR(2) 

	--SELECT @NOWWEEKDAY = CASE DATEPART(WEEKDAY, GETDATE()) 
	--			WHEN '3' THEN '화'
	--			WHEN '5' THEN '목'
	--	   END 

		 
	SELECT SITE_DIV = 'SB',
			HPHONE = '01022276303',
			UID = 'S4GUEST' 
			UNION 
	SELECT	SITE_DIV = 'SB',
			HPHONE = '01057687255',
			UID = 'S4GUEST'
			UNION

	SELECT  
	--INTO #TEMP
	--INTERGRATION_DATE_WEEKNAME
	SITE_DIV,
	HPHONE,
	UID
	FROM 
	(
		SELECT  TOP 250 ( CASE 
				WHEN ISNULL(SELECT_SALES_GUBUN, '') = '' THEN 
					CASE WHEN ISNULL(REFERER_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(REFERER_SALES_GUBUN, 'SB') END
				ELSE 
					CASE WHEN ISNULL(SELECT_SALES_GUBUN, 'SB') IN ('B', 'H', 'C') THEN 'B' ELSE ISNULL(SELECT_SALES_GUBUN, 'SB') END
			END ) AS SITE_DIV  
			, HPHONE
			,UID,
			A.INTERGRATION_DATE ,
			INTERGRATION_DATE_WEEKNAME = CASE DATEPART(WEEKDAY,  A.INTERGRATION_DATE ) 
				WHEN '1' THEN '일'
				WHEN '2' THEN '월'
				WHEN '3' THEN '화'
				WHEN '4' THEN '수'
				WHEN '5' THEN '목'
				WHEN '6' THEN '금'
				WHEN '7' THEN '토'
			END ,
			--매주 화요일 16시(목~월 가입고객 대상) / 목요일 11시(화~수 가입고객 대상)
				YN = CASE WHEN @NOWWEEKDAY = '화' AND  DATEPART(WEEKDAY,  A.INTERGRATION_DATE )  IN ('5','6', '7', '1', '2') THEN  'Y'  --('목','금', '토', '일', '월') THEN  'Y' 
						WHEN @NOWWEEKDAY = '목'  AND  DATEPART(WEEKDAY,  A.INTERGRATION_DATE )  IN ('3', '4') THEN 'Y' --('화', '수')
				ELSE 'N'		
				END ,
			ADDR = ADDRESS + ' ' + ADDR_DETAIL  
	

		FROM VW_USER_INFO AS A  
		WHERE LEN(A.HPHONE) > 12   
			AND A.DUPINFO IS NOT NULL    
			AND A.CONNINFO IS NOT NULL  
			AND A.WEDDING_DAY >= CONVERT(CHAR(10), GETDATE() + 60, 23) -- 예식일 D-60 이상
			--AND A.WEDDING_DAY < CONVERT(CHAR(10), GETDATE() + 90 , 23)  
			AND A.INTERGRATION_DATE < CONVERT(CHAR(10), GETDATE() - 14 , 23)  -- 회원가입 D+14이상 
			AND A.CHK_SMS = 'Y'  
			AND SITE_DIV ='SB'
			AND NOT EXISTS ( SELECT 'Y' FROM EVENT_MMS_LOG WHERE UID = A.UID )
	) TB
	WHERE YN = 'Y'  
		  AND (TB.ADDR LIKE '서울%' OR  TB.ADDR LIKE '경기%' OR  TB.ADDR LIKE '인천%') -- 서울/경기/인천 고객
		  AND @MMSCOUNT <= 1000
	
 OPEN CUR_AUTOINSERT_FOR_GIFT  
  
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
	   
 FETCH NEXT FROM CUR_AUTOINSERT_FOR_GIFT INTO @SERVICE,  @PHONE_NUM, @UID
  
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
  
  SET @MMS_SUBJECT = '(광고) '+ @NO_REC_BRAND+' X 찾아줘부동산'
--SET @MMS_SUBJECT = '(광고) '+ @NO_REC_BRAND+' X 신혼집 맞춤 찾아줘부동산'

SET @MMS_MSG = '(광고) 스마트폰으로 신혼집찾기#찾아줘부동산

나만의신혼집도 찾으시고 비스포크 냉장고를 무료로 받아가세요.
자세한 내용은  https://bit.ly/39wgVrp 에서 확인하세요.

#' + @NO_REC_BRAND + ' 고객특전#브이패스50%할인
#스마트하게 신혼집찾기
#매물검색부터 안전계약완료까지


[수신거부]

' + @NO_REC_BRAND+' 고객센터
' + @CALLBACK + '로 수신거부 문자 전송

무료 수신거부
080-938-0850'
					 
		SET @DEST_INFO = @UID+'^'+@PHONE_NUM
	
		/* 2020-11-23 KT 문자 서비스 작업 변경 */
		SET @PHONE_NUM = '^' + @PHONE_NUM

		EXEC BAR_SHOP1.DBO.PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, '', @CALLBACK, 1, @DEST_INFO, 0, '', 0, 
												@SERVICE, '', '', @RESERVED4, '', @ERRNUM OUTPUT, @ERRSEV OUTPUT, @ERRSTATE OUTPUT, @ERRPROC OUTPUT, @ERRLINE OUTPUT, @ERRMSG OUTPUT

		--SET @DAILY_DT = LEFT(@SEND_DATE,4) +'-'+SUBSTRING(@SEND_DATE,5,2)+'-'+SUBSTRING(@SEND_DATE,7,2)

		SELECT @DAILY_DT =  CONVERT(VARCHAR(10), GETDATE(), 120)

		INSERT INTO EVENT_MMS_LOG (UID, SEND_DT, SALES_GUBUN, EVENT_GB) VALUES (@UID,@DAILY_DT,@SERVICE,'FINDPROPERTY')

  FETCH NEXT FROM CUR_AUTOINSERT_FOR_GIFT INTO  @SERVICE,  @PHONE_NUM, @UID
 END  
  
 CLOSE CUR_AUTOINSERT_FOR_GIFT  
 DEALLOCATE CUR_AUTOINSERT_FOR_GIFT  

END

GO
