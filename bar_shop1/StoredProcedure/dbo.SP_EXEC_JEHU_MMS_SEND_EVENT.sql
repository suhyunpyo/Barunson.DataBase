IF OBJECT_ID (N'dbo.SP_EXEC_JEHU_MMS_SEND_EVENT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_JEHU_MMS_SEND_EVENT
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

 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('B','010-9484-4697','20210707','N','BHF0069671') -- 정혜련
 insert into jehu_send_mms (service, phone_num,send_dt,send_chk,ETC_INFO) values ('B','010-9189-5018','20210203','N','BHF0069671') -- 강주연


 
 이미지 첨부 프로시저 발송
*********************************************************/  
  
CREATE PROCEDURE [dbo].[SP_EXEC_JEHU_MMS_SEND_EVENT]  
AS  
BEGIN  
  
    DECLARE @TIME AS VARCHAR(10)  
    DECLARE @SEND_DT AS VARCHAR(8)  
    DECLARE @SEND_DATE AS VARCHAR(16)   --(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
    DECLARE @SCHEDULE_TYPE INT  -- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	--DECLARE @RESERVED4      VARCHAR(50)	--(공통)여분필드_4 ('': 온사팀, 1:광고제휴 2:신규사업)
     	   
	-- (공통)발송시점 구분(즉시전송:0, 예약전송:1)
	--SET @SCHEDULE_TYPE = 1 
  
 DECLARE @MMS_DATE VARCHAR(100)  
 DECLARE @PHONE_NUM VARCHAR(100)  
 DECLARE @U_ID VARCHAR(100)  
 DECLARE @SERVICE VARCHAR(4)  
  
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

  
 BEGIN  

-- 010-8279-9366
--010-6778-8262
--010-9137-1026
--010-2901-8732



-- exec [SP_EXEC_JEHU_MMS_SEND_EVENT] 
 	       
   SET @SERVICE = 'SB'   
   SET @NO_REC_BRAND = '바른손카드'      
   SET @CALLBACK  = '1644-0708'  
   SET @SCHEDULE_TYPE = 0
   SET @SEND_DATE = ''
   SET @DEST_INFO = 'AA^010-2901-8732'

	SET @MMS_SUBJECT = '[바른손카드] 이벤트 당첨안내'


	SET @MMS_MSG =  '[바른손카드] 이벤트 당첨안내 (재공지)
	1st 바른손카드 웨딩박스 이벤트에 당첨되신 고객님 축하드립니다! :D

	당첨공지 확인하기 ▶ http://m.barunsoncard.com/customer/notice.asp

	* 당첨 내용 : 1st 바른손카드 웨딩박스 이벤트
	* 당첨 경품 : 데스커 (800폭 원형테이블)

	현행법 상 5만원 이상의 현물 경품에 대한 제세공과금 22%는 당첨자 본인 부담으로, 아래와 같이 입금 계좌와 경품 수령 방법을 안내 드립니다.

	* 입금하셔야 할 제세공과금 : 48,180원 (219,000*0.22)
	* 입금계좌 : 국민은행 407537-01-003476 (바른컴퍼니)
	* 입금기한 : 8월 24일(화요일)

	* 위 계좌로 제세공과금을 입금해 주신 후, 아래 정보를 기입하시어 8월 24일(화요일)까지
	 barunson03@naver.com 으로 메일 주시면 확인 후 경품을 발송해 드립니다. (기한 준수)
	*원활한 배송을 위하여 당첨자 정보는 당첨된 브랜드에 전달됩니다.

	- 당첨자명
	- 제세공과금 입금자명
	- 입금하신 분의 신분증 사본 이미지 (주민등록번호 13자리가 반드시 보이게끔 전달 부탁드립니다.)
	- 경품 수령하실 주소
	- 경품 수령을 위한 개인정보 활용 동의여부 (미동의 시 경품 수령 불가, 해당 개인 정보는 경품 발송이 완료된 후 모두 폐기됩니다.)

	기한 내에 제세공과금 입금 및 메일 회신이 완료되지 않을 경우 당첨이 취소될 수 있으니, 이 점 유의 부탁 드립니다.



	다시 한 번 당첨을 축하드립니다! :D

	바른손카드 바로가기 ▶ http://m.barunsoncard.com'
					
	
	EXEC PROC_SMS_MMS_SEND '', @SCHEDULE_TYPE, @MMS_SUBJECT, @MMS_MSG, @SEND_DATE, @CALLBACK, 1, @DEST_INFO, 0, '', 0, @SERVICE,'','','','','','','','','',''

 END  
  

END
GO
