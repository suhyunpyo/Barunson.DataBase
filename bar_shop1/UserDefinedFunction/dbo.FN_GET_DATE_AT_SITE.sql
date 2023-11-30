USE [bar_shop1]
GO
/****** Object:  UserDefinedFunction [dbo].[FN_GET_DATE_AT_SITE]    Script Date: 2023-10-11 오전 10:39:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
-- =============================================  
-- Author: 개발팀 임승인
-- Create date: 2023-10-10
-- Description: 예상 초안/배송 작업일수 (웹사이트 마이페이지)
-- =============================================  
*/
ALTER FUNCTION [dbo].[FN_GET_DATE_AT_SITE](
	@TYPE			CHAR(1)				--O:초안등록 예정일 B:발송 예정일
	,@CARD_SEQ		INT				-- 카드번호,주문번호	
	,@ORDER_DATE	DATETIME
)
RETURNS DATETIME
AS
BEGIN

	DECLARE @DUE_DATE DATETIME
	DECLARE @CONFIRM_DATE DATETIME	

	/* 날짜 표기 제어 */

	DECLARE @START_DATE DATETIME
	DECLARE @END_DATE DATETIME
	DECLARE @USE_YN CHAR(1)

	SELECT TOP 1 @START_DATE = START_DATE,
			@END_DATE = END_DATE,
			@USE_YN = USE_YN
	FROM ADMIN_LIMIT_SETTING
	WHERE TYPE = @TYPE 	
	
	-- 결과 반환	

	IF @USE_YN = 'N' OR (@USE_YN = 'Y' AND (GETDATE() <= @START_DATE OR GETDATE() >= @END_DATE))	
	BEGIN 
		IF @TYPE = 'O'
		BEGIN
			SELECT TOP 1 @CONFIRM_DATE = CONFIRM_DATE FROM dbo.FN_GET_ConfirmDate_holiday(@ORDER_DATE)

			SET @DUE_DATE = dbo.fn_IsWorkDay(CONVERT(varchar(10), @CONFIRM_DATE, 120), dbo.FN_GET_BAESONG_CHOAN(@CARD_SEQ, @CONFIRM_DATE) + 1) 
		END
		ELSE
		BEGIN
			SELECT TOP 1 @DUE_DATE = SendDate FROM dbo.FN_GET_Days_of_making_cards(@CARD_SEQ)		
		END
	END	

	RETURN @DUE_DATE	
END





