IF OBJECT_ID (N'dbo.SP_SMARTAD_SMS_INSERT', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SMARTAD_SMS_INSERT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김현기
-- Create date: 2017-02-16
-- Description:	롯데지문방명록_이벤트_초안등록시 고객 SMS 발송
-- TEST : EXEC SP_SMARTAD_SMS_INSERT 7, 'SECOND'
-- =============================================
 CREATE PROCEDURE [dbo].[SP_SMARTAD_SMS_INSERT]
	@P_EVENT_SEQ	int
	,@P_OP_CODE  AS VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRAN
		DECLARE @USER_NAME AS VARCHAR(30)
		DECLARE @USER_HPHONE AS VARCHAR(200)
		DECLARE @MSG AS VARCHAR(2000)
		DECLARE @TITLE AS VARCHAR(200)
		DECLARE @TIME AS VARCHAR(10)
		DECLARE @CALL_NUMBER AS VARCHAR(50)

		--고객명, 휴대폰 정보를 얻어온다.
		SELECT		@USER_NAME = USER_NAME
				,	@USER_HPHONE =  USER_HPHONE
		FROM	SMARTAD_EVENT_INFO
		WHERE	1 = 1
		AND		EVENT_SEQ = @P_EVENT_SEQ

		-- SMS 문구
		-- FIRST : 초안등록, SECOND : 재초안등록
		IF @P_OP_CODE = 'FIRST'
			BEGIN
				SET @MSG = '롯데면세점 웨딩트리 지문방명록 시안등록완료' + char(13) + char(10)
							+ char(13) + char(10)
							+ '바로가기' + char(13) + char(10)
							+ 'www.barunnwedding.com' + char(13) + char(10)
			END
		ELSE
			BEGIN
				SET @MSG = '롯데면세점 웨딩트리 지문방명록 시안수정완료' + char(13) + char(10)
							+ char(13) + char(10)
							+ '바로가기' + char(13) + char(10)
							+ 'www.barunnwedding.com' + char(13) + char(10)
			END

		SET @TITLE = '[스마트AD] 초안등록 완료';
		SET @CALL_NUMBER = '1644-7976';
		--SET @USER_HPHONE = '010-9880-2629'
		EXEC SP_EXEC_SMS_OR_MMS_SEND @CALL_NUMBER, @USER_HPHONE, @TITLE, @MSG, 'TR_ETC2', '스마트AD 초안완료', '', '', 0, ''


	COMMIT TRAN

END
GO
