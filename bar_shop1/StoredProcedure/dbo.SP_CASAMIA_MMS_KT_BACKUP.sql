IF OBJECT_ID (N'dbo.SP_CASAMIA_MMS_KT_BACKUP', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_CASAMIA_MMS_KT_BACKUP
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************  
  
2021-12-21 
까사미아 DB제휴 중복고객 대상 자동 LMS발송 프로시저

service  
 SB : 바른손카드  
 SA : 비핸즈  
 SS : 프리미어페이퍼  
 ST : 더카드  
 B  : 바른손몰  
   
 exec [SP_CASAMIA_MMS_KT] 
 
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_CASAMIA_MMS_KT_BACKUP]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	DECLARE @RESERVED4      VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	SET @SCHEDULE_TYPE = 1 

	SET @SEND_DT = convert(varchar, getdate(), 112) -- 1. 여기 날짜를 바꿔
	SET @TIME = '113000'		-- 2. 요청 하는 시간으로 바꿔, 3. 제목과 내용을 수정하여, 4.s4guest 로 테스트 발송(요청자와 제휴업체 번호도), 5.JEHU_SEND_MMS 에 대상자들 인서트

	set @SEND_DATE = @SEND_DT+@TIME
	SET @RESERVED4 = '1'	
     
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD  
 FOR  
  
  SELECT barun_reg_site, uid, hand_phone, replace(convert(varchar(10), casamia_send_date, 120),'-','.') casamia_send_dt
  FROM CASAMIA_DAILY_INFO 
  WHERE CREATE_DATE > convert(varchar(10), getdate()-5, 120)
  AND casamia_rst_cd ='209'
  AND mms_send_date is null

 OPEN cur_AutoInsert_For_Order  
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @UID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)
 DECLARE @CASAMIA_SEND_DT VARCHAR(10)  
  
 DECLARE @MMS_MSG VARCHAR(MAX)  
 DECLARE @MMS_SUBJECT VARCHAR(60)  
 DECLARE @CALLBACK VARCHAR(50)  
 DECLARE @ETC_INFO VARCHAR(50)  
 DECLARE @chkCnt INT;  
 DECLARE @CHK_SMS VARCHAR(1);   
 
 DECLARE @EVT_URL  VARCHAR(MAX)  --4.이벤트 주소  
 DECLARE @NO_REC_BRAND VARCHAR(50) --4.수신거부 브랜드  
 --DECLARE @NO_REC_TEL  VARCHAR(50) --4.수신거부 전화번호  

DECLARE @CONTENT_DATA   VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
DECLARE @MSG_TYPE       INT			--(MMS)메시지 구분(TEXT:0, HTML:1)

DECLARE @DEST_INFO	VARCHAR(100)

 FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE, @UID, @PHONE_NUM, @CASAMIA_SEND_DT
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN
	 
   IF @SERVICE = 'SB'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손카드'      
     SET @CALLBACK  = '1644-0708'  
     SET @evt_url = 'https://bit.ly/2XQecRZ'
    END  
  
   ELSE IF @SERVICE = 'SA'  
    BEGIN  
     SET @NO_REC_BRAND = '비핸즈카드'      
     SET @CALLBACK  = '1644-9713'  
     SET @evt_url = ''
    END  
  
   ELSE IF @SERVICE = 'ST'  
    BEGIN  
     SET @NO_REC_BRAND = '더카드'       
     SET @CALLBACK  = '1644-7998' 
     SET @evt_url = 'http://bit.ly/2QdlKJN' 
    END  
   ELSE IF @SERVICE = 'B'  
    BEGIN  
     SET @NO_REC_BRAND = '바른손몰'      
     SET @CALLBACK  = '1644-7413'  
     SET @evt_url = ''
    END  
   ELSE IF @SERVICE = 'BM'
    BEGIN
     SET @NO_REC_BRAND = '바른손카드'      
     SET @CALLBACK  = '1644-7413'  
     SET @evt_url = ''
    END
   ELSE  
    BEGIN  
     SET @NO_REC_BRAND = '프리미어페이퍼'      
     SET @CALLBACK  = '1644-8796'  
     SET @evt_url = 'https://bit.ly/2XCihZA'
    END  
  
    
SET @MMS_SUBJECT = '(광고)' + @NO_REC_BRAND + ' X 까사미아'

SET @MMS_MSG = '(광고)이 문자는 '+@NO_REC_BRAND+'에 가입하신 까사미아 회원님들께만 발송됩니다.

까사미아 웨딩클럽까지 가입하셔서 풍성한 혜택으로 신혼가구 졸업하세요:)

<웨딩클럽 혜택>
① 10% 상시 할인(정상가 기준, 행사시 5%)
② 10만원 쿠폰(100만원 이상 구매시)
③ 굳포인트 1% 추가 적립
④ 온라인 3종 할인 쿠폰(2/5/10만원)

<가입서류>
가입자와 예식일이 표기된 청첩장, 웨딩홀, 스튜디오, 컨설팅 계약서 중 1개

<유지기간>
클럽 승인 후 6개월간

웨딩클럽 가입하기☞https://vo.la/2ipTy

*유의사항*
- 회원명과 가입서류의 이름이 다르거나 예식일이 6개월이 지난 경우 승인이 거절될 수 있습니다
- 상시할인은 오프라인 매장에 한하며 일부상품은 적용이 안됩니다.
- 혜택 등 자세한 내용은 매장 직원 또는 까사미아 고객센터(1588-3408)에 문의 바랍니다.

※ 본 문자는 '+ @CASAMIA_SEND_DT+' 기준, 
   SMS 수신동의한 고객님께 
   발송되었습니다. 


[수신거부] '+ @NO_REC_BRAND+' 고객센터
 '+ @CALLBACK + '로 수신거부 문자 전송'
					

	  SET @DEST_INFO = @UID+'^'+@PHONE_NUM
	
	  EXEC PROC_SMS_MMS_SEND @UID, @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','',@RESERVED4,'','','','','','',''

	  update CASAMIA_DAILY_INFO set mms_send_date = GETDATE() WHERE UID = @UID AND  hand_phone =  @PHONE_NUM  and mms_send_date IS NULL
  
  FETCH NEXT FROM cur_AutoInsert_For_Order INTO @SERVICE, @UID, @PHONE_NUM, @CASAMIA_SEND_DT
 END  
  
 CLOSE cur_AutoInsert_For_Order  
 DEALLOCATE cur_AutoInsert_For_Order  
END
GO
