IF OBJECT_ID (N'dbo.SP_EXEC_SMS_OR_MMS_SEND_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_SMS_OR_MMS_SEND_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_EXEC_SMS_OR_MMS_SEND_TEST]
		@P_PHONE_SENDER     VARCHAR(15)			/* 보내는 사람 핸드폰 번호 */
	,	@P_PHONE_RECEIVER   VARCHAR(15)			/* 받는 사람 핸드폰 번호 */
	,	@P_SUBJECT          VARCHAR(120)		/* MMS 용 제목, SMS일때 사용 안함 */
	,	@P_MSG              VARCHAR(4000)		/* VARCHAR(160)이 넘어가면 MMS로 전송, 160 이하는 SMS로 전송 */
	,	@P_SALES_GUBUN      VARCHAR(32) = ''	/* SALES_GUBUN ex) SA, ST, SS, SB, B, H 기타 등등, SMS일때는 TR_ETC2, MMS는 ETC2 */
	,	@P_SMS_TYPE         VARCHAR(32) = ''	/* 문자 메세지 용도를 넣는다. ex) 광고, 단계별 DM, 빠른손, 사이트, 기타등등, SMS일때는 TR_ETC3, MMS는 ETC3 */
	,	@P_REMARKS          VARCHAR(64) = ''	/* 비고, 기타 내용을 넣는다. SMS일때는 TR_ETC1, MMS는 ETC1 */
	,	@P_RESERVATION_DATE VARCHAR(19) = null	/* 예약 발송, 날짜 형식 스트링을 넣는다. ex) 2016-11-10 14:49:00, DATETIME으로 자동변환이 안되는 형태의 스트링을 넣으면 오류가 나서 문자 메세지 전송이 안될수 있음, SMS일때는 TR_SENDDATE, MMS는 SENDDATE */
	,	@P_FILE_CNT         INT = 0				/* MMS에서 사용. 이미지 첨부를 할때 사용한다. 이미지가 1개면 1, 없으면 0 */
	,	@P_FILE_PATH        VARCHAR(512) = ''	/* 이미지 경로 ex) http://mcard.barunnfamily.com/Photos/202010/ST3021030/mmscard.jpg */

AS

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @DEST_INFO     VARCHAR(50)
      , @SCHEDULE_TYPE INT


SET @DEST_INFO = 'AA^' + @P_PHONE_RECEIVER
SET @SCHEDULE_TYPE = 0	--즉시전송

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN

	IF @P_RESERVATION_DATE IS NULL
	BEGIN
		SET @P_RESERVATION_DATE = ''
	END

	-- 예약발송인 경우
	IF @P_RESERVATION_DATE <> ''
	BEGIN
		SET @P_RESERVATION_DATE = REPLACE(REPLACE(REPLACE(@P_RESERVATION_DATE, '-', ''), ':', ''), ' ', '')	-- 발송희망시간(YYYYMMDDHHMMSS)
		SET @SCHEDULE_TYPE = 1	--예약전송
	END


	-- 파일이 존재하는 경우(image는 jpg만 가능, 최대 3개까지 발송 가능)
	IF @P_FILE_CNT > 0 AND @P_FILE_PATH <> ''
	BEGIN
		SET @P_FILE_PATH = @P_FILE_PATH + '^1^0'	-- image는 jpg만 가능, 파일명^컨텐츠타입(IMAGE:1)^컨텐츠서브타입(JPG:0)|~~|~~
	END

	----------------------------------------------------------------------------------
	-- KT
	----------------------------------------------------------------------------------
	EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND_TEST '', @SCHEDULE_TYPE, @P_SUBJECT, @P_MSG, @P_RESERVATION_DATE, @P_PHONE_SENDER, 1, @DEST_INFO, @P_FILE_CNT, @P_FILE_PATH, 0, @P_SALES_GUBUN, @P_SMS_TYPE, @P_REMARKS, '', '', '', '', '', '', '', ''

	----------------------------------------------------------------------------------
	-- LG 데이콤(구버전)
	----------------------------------------------------------------------------------
	--IF (DATALENGTH(@P_MSG) <= 160 AND @P_FILE_CNT = 0 AND DATALENGTH(@P_FILE_PATH) = 0)
	--BEGIN
	--	INSERT INTO invtmng.SC_TRAN 
	--	(
	--			TR_ID
	--		,	TR_SENDSTAT
	--		,	TR_RSLTSTAT
	--		,	TR_CALLBACK
	--		,	TR_PHONE
	--		,	TR_MSG
	--		,	TR_SENDDATE
	--		,	TR_ETC1
	--		,	TR_ETC2
	--		,	TR_ETC3
	--	)
	--	SELECT	'SM136890_001'
	--		,	'0'
	--		,	'00'
	--		,	@P_PHONE_SENDER		
	--		,	@P_PHONE_RECEIVER				
	--		,	@P_MSG				
	--		,	CASE WHEN @P_RESERVATION_DATE = '' OR @P_RESERVATION_DATE IS NULL THEN GETDATE() ELSE @P_RESERVATION_DATE END
	--		,	@P_REMARKS			
	--		,	CASE WHEN @P_SALES_GUBUN = '' OR @P_SALES_GUBUN IS NULL THEN '' ELSE @P_SALES_GUBUN END
	--		,	@P_SMS_TYPE			
	--END
	--ELSE
	--BEGIN
	--	INSERT INTO invtmng.MMS_MSG
	--	(
	--			STATUS
	--		,	TYPE
	--		,	SUBJECT
	--		,	CALLBACK
	--		,	PHONE
	--		,	MSG
	--		,	REQDATE
	--		,	ETC1
	--		,	ETC2
	--		,	ETC3
	--		,	FILE_CNT
	--		,	FILE_PATH1
	--	)
	--	SELECT	'0'
	--		,	'0'
	--		,	@P_SUBJECT
	--		,	@P_PHONE_SENDER		
	--		,	@P_PHONE_RECEIVER				
	--		,	@P_MSG				
	--		,	CASE WHEN @P_RESERVATION_DATE = '' OR @P_RESERVATION_DATE IS NULL THEN GETDATE() ELSE @P_RESERVATION_DATE END
	--		,	@P_REMARKS			
	--		,	CASE WHEN @P_SALES_GUBUN = '' OR @P_SALES_GUBUN IS NULL THEN '' ELSE @P_SALES_GUBUN END		
	--		,	@P_SMS_TYPE	
	--		,	@P_FILE_CNT	
	--		,	@P_FILE_PATH
	--END
END

GO
