IF OBJECT_ID (N'dbo.PROC_SMS_MMS_SEND_TEST', N'P') IS NOT NULL DROP PROCEDURE dbo.PROC_SMS_MMS_SEND_TEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_SMS_MMS_SEND_TEST]
      @USER_ID       VARCHAR(20)	--(공통)회원 ID
	, @SCHEDULE_TYPE INT			--(공통)발송시점 구분(즉시전송:0, 예약전송:1)
	, @SUBJECT       VARCHAR(64)	--(공통)제목(MMS에서만 발송시 사용)
	, @MSG           VARCHAR(4000)	--(공통)발송 메시지
	, @SEND_DATE     VARCHAR(16)	--(공통)발송희망시간(예약발송시 사용) ex)YYYYMMDDHHMMSS
	, @CALLBACK      VARCHAR(20)	--(공통)회신번호
	, @DEST_COUNT    INT			--(공통)수신자 목록 개수(Max:100)
	, @DEST_INFO     TEXT			--(공통)수신자이름^전화번호 ex)홍길동^01012341234|홍길순^01012341234|~
	, @CONTENT_COUNT INT			--(MMS)전송파일수
	, @CONTENT_DATA  VARCHAR(250)	--(MMS)파일명^컨텐츠타입^컨텐츠서브타입 ex)http://www.test.com/test.jpg^1^0|http://www.test.com/test.jpg^1^0|~
	, @MSG_TYPE      INT			--(MMS)메시지 구분(TEXT:0, HTML:1)
	, @RESERVED1     VARCHAR(50)	--(공통)여분필드_1 > SALES_GUBUN ex)SA, ST, SS, SB, B, H 기타 등등
	, @RESERVED2     VARCHAR(50)	--(공통)여분필드_2 > 문자메시지 용도
	, @RESERVED3     VARCHAR(50)	--(공통)여분필드_3 > 비고, 기타 내용
	, @RESERVED4     VARCHAR(50)	--(공통)여분필드_4
	, @RESERVED5     VARCHAR(50)	--(공통)여분필드_5
-----------------------------------------------------------------------------------------------------------------     
    , @ErrNum   INT           OUTPUT
    , @ErrSev   INT           OUTPUT
    , @ErrState INT           OUTPUT
    , @ErrProc  VARCHAR(50)   OUTPUT
    , @ErrLine  INT           OUTPUT
    , @ErrMsg   VARCHAR(2000) OUTPUT

AS

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET LOCK_TIMEOUT 60000

----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @NOW_DATE     VARCHAR(30)	-- DB입력시간(YYYYMMDDHHMMSS)


SET @NOW_DATE = REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 120), '-', ''), ':', ''), ' ', '')

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
		
		

			----------------------------------------------------------------------------------
			-- 발송희망시간 공백인 경우
			----------------------------------------------------------------------------------
			IF @SEND_DATE = ''
			BEGIN
				SET @SEND_DATE = @NOW_DATE
			END
			
			IF DATALENGTH(@MSG) > 80 OR @SUBJECT <> '' OR @CONTENT_COUNT > 0
			BEGIN

			SELECT @CONTENT_COUNT
			select @CONTENT_DATA
				----------------------------------------------------------------------------------
				-- MMS 발송
				----------------------------------------------------------------------------------
				INSERT INTO MO_SVR.dbo.SDK_MMS_SEND
					    ( [USER_ID]		
						, SCHEDULE_TYPE		
						, [SUBJECT]		
						, MMS_MSG		
						, NOW_DATE	
						, SEND_DATE		
						, CALLBACK		
						, DEST_COUNT	
						, DEST_INFO	
						, CONTENT_COUNT
						, CONTENT_DATA
						, MSG_TYPE
						, RESERVED1
						, RESERVED2
						, RESERVED3
						, RESERVED4
						, RESERVED5
						)
				VALUES
					    ( @USER_ID
						, @SCHEDULE_TYPE		
						, @SUBJECT		
						, @MSG		
						, @NOW_DATE	
						, @SEND_DATE		
						, @CALLBACK		
						, @DEST_COUNT	
						, @DEST_INFO	
						, @CONTENT_COUNT	-- 최대 3개까지 발송 가능
						, @CONTENT_DATA		-- image는 jpg만 가능, 파일명^컨텐츠타입(IMAGE:1)^컨텐츠서브타입(JPG:0)|~~|~~
						, @MSG_TYPE
						, @RESERVED1
						, @RESERVED2
						, @RESERVED3
						, @RESERVED4
						, @RESERVED5
					)
			END
			ELSE
			BEGIN

			
			select 2
				----------------------------------------------------------------------------------
				-- SMS 발송
				----------------------------------------------------------------------------------
				--INSERT INTO MO_SVR.dbo.SDK_SMS_SEND
				--	    ( [USER_ID]		
				--		, SCHEDULE_TYPE		
				--		, [SUBJECT]		
				--		, SMS_MSG		
				--		, NOW_DATE	
				--		, SEND_DATE		
				--		, CALLBACK		
				--		, DEST_COUNT	
				--		, DEST_INFO
				--		, RESERVED1
				--		, RESERVED2
				--		, RESERVED3
				--		, RESERVED4
				--		, RESERVED5
				--		)
				--VALUES
				--	    ( @USER_ID
				--		, @SCHEDULE_TYPE		
				--		, @SUBJECT		
				--		, @MSG		
				--		, @NOW_DATE	
				--		, @SEND_DATE		
				--		, @CALLBACK		
				--		, @DEST_COUNT	
				--		, @DEST_INFO
				--		, @RESERVED1
				--		, @RESERVED2
				--		, @RESERVED3
				--		, @RESERVED4
				--		, @RESERVED5
				--	)
			END
			
		
END

-- Execute Sample
/*

DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)

-- SMS
EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', 'SMS 발송 테스트', '', '1644-0708', 1, 'AA^010-8973-8286', 0, '', 0, 'SS', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

-- MMS
--EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND 's4guest', 0, '제목선택', 'MMS 발송 테스트', '', '1644-0708', 1, 'AA^010-8973-8286', 1, 'http://mcard.barunnfamily.com/Photos/202010/ST3021030/mmscard.jpg^1^0', 0, 'SS', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrSta

te OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

SELECT @ErrNum
	 , @ErrSev 
	 , @ErrState
	 , @ErrProc
	 , @ErrLine
	 , @ErrMsg

*/

GO
