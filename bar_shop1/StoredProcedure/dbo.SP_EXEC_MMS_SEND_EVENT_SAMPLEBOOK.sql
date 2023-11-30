IF OBJECT_ID (N'dbo.SP_EXEC_MMS_SEND_EVENT_SAMPLEBOOK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_MMS_SEND_EVENT_SAMPLEBOOK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************

2016-07-01	정혜련
service
	SB : 바른손카드
	SA : 비핸즈
	SS : 프리미어페이퍼
	ST : 더카드
	B  : 바른손몰

table
jehu_send_mms (
	service		varchar(2)	not null
	, phone_num	varchar(15)	not null
	, send_Dt	varchar(8)	not null
	, send_chk	varchar(1)	not null

*********************************************************/

CREATE PROCEDURE [dbo].[SP_EXEC_MMS_SEND_EVENT_SAMPLEBOOK]
AS
BEGIN

    DECLARE @TIME AS VARCHAR(10)
    DECLARE @Today_Dt AS VARCHAR(8)

    SET @TIME = ' 15:05:00'
    SET @Today_Dt = '20181106'

	--커서를 이용하여 해당되는 고객정보를 얻는다.
	DECLARE cur_AutoInsert_For_Order CURSOR FAST_FORWARD
	FOR
		SELECT CONVERT(VARCHAR(10), getdate(), 120) + @TIME AS SEND_DATE, SERVICE, PHONE_NUM
		FROM JEHU_SEND_MMS
		WHERE SEND_DT = @Today_Dt
		AND SEND_CHK ='N'

	OPEN cur_AutoInsert_For_Order

	DECLARE @MMS_DATE VARCHAR(100)
	DECLARE @PHONE_NUM VARCHAR(100)
	DECLARE @U_ID VARCHAR(100)
	DECLARE @SERVICE VARCHAR(4)
	DECLARE @ETC_INFO VARCHAR(50)

	DECLARE @MMS_MSG VARCHAR(MAX)
	DECLARE @MMS_SUBJECT VARCHAR(50)
	DECLARE @MMS_PHONE VARCHAR(50)



	DECLARE @EVT_URL		VARCHAR(MAX)		--4.이벤트 주소
	DECLARE @NO_REC_BRAND	VARCHAR(50)	--4.수신거부 브랜드
	--DECLARE @NO_REC_TEL		VARCHAR(50)	--4.수신거부 전화번호

	FETCH NEXT FROM cur_AutoInsert_For_Order INTO @MMS_DATE, @SERVICE,  @PHONE_NUM

	WHILE @@FETCH_STATUS = 0

	BEGIN
						
			IF @SERVICE = 'SB'
				BEGIN
					SET @NO_REC_BRAND	= '바른손카드'				
					SET @MMS_PHONE		= '1644-0708'
				END

			ELSE IF @SERVICE = 'SA'
				BEGIN
					SET @NO_REC_BRAND	= '비핸즈카드'				
					SET @MMS_PHONE		= '1644-9713'
				END


			ELSE IF @SERVICE = 'ST'
				BEGIN
					SET @NO_REC_BRAND	= '더카드'					
					SET @MMS_PHONE		= '1644-7998'
				END
			ELSE IF @SERVICE = 'B'
				BEGIN
					SET @NO_REC_BRAND	= '바른손몰'				
					SET @MMS_PHONE		= '1644-7413'
				END
			ELSE
				BEGIN
					SET @NO_REC_BRAND	= '프리미어페이퍼'				
					SET @MMS_PHONE		= '1644-8796'
				END




SET @MMS_SUBJECT = '[바른손카드] 샘플북 이용고객 추가 쿠폰 발급'

SET @MMS_MSG ='[바른손카드] 샘플북 이용고객 추가 쿠폰 발급!
바른손카드 스페셜 샘플북, 잘 받아보셨나요?
아깝게 회수 기간을 놓친 고객을 위한 특별한 혜택!

▶ 11월 20일(화)까지 회수 신청 가능!
- 연장된 기간 안에 회수 완료 시 15,000원 페이백 쿠폰♥

▶ 청첩장 15만원 이상 구매 시 7% 추가 쿠폰!
- 페이백 쿠폰+10%할인 기본 쿠폰에 추가 7% 할인까지♥

예식일이 가까워지기 전에 미리미리 청첩장 구매하고
바른손카드만의 스페셜한 할인 혜택을 놓치지 마세요~

* 샘플북 회수 신청은 최초 샘플북 이용 ID로 가능합니다.
* 페이백 쿠폰, 10% 할인 쿠폰은 샘플북 회수 완료 시 발급됩니다.
* 7% 추가 할인 쿠폰은 최초 샘플북 이용 ID 앞으로 발급됩니다.' 						

			--MMS 전송
			INSERT INTO invtmng.MMS_MSG(subject, phone, callback, status, reqdate, msg, TYPE)
			VALUES (  @MMS_SUBJECT
					, @PHONE_NUM
					, @MMS_PHONE
					, '0'
					, @MMS_DATE
					, @MMS_MSG
					, '0' )


			update jehu_send_mms set send_chk = 'Y' WHERE SEND_DT = @Today_Dt AND service = @SERVICE and  phone_num =  @PHONE_NUM

		FETCH NEXT FROM cur_AutoInsert_For_Order INTO  @MMS_DATE, @SERVICE,  @PHONE_NUM
	END

	CLOSE cur_AutoInsert_For_Order
	DEALLOCATE cur_AutoInsert_For_Order
END
GO
