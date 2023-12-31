IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT_GUEST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT_GUEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2017-09-19
-- Description:	바른손카드 비회원 식전영상쿠폰발급(통합쿠폰버전)

-- EXEC 회원아이디, 사이트코드
-- EXEC dbo.[SP_INSERT_MOVIE_EVENT_GUEST] 's5guest', 5001
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT_GUEST]
	@EMAIL								AS VARCHAR(50),
	@COMPANY_SEQ						AS INT
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
	DECLARE		@END_DATE						AS	VARCHAR(50)	= ''
	DECLARE		@SALES_GUBUN					AS	VARCHAR(2) = ''
	DECLARE		@COUPON_MST_SEQ 				AS	INT

	IF @COMPANY_SEQ = 5001 		
		BEGIN
			SET		@SALES_GUBUN = 'SB';
			SET		@COUPON_MST_SEQ = 301;
		END
	ELSE IF @COMPANY_SEQ = 5006
		BEGIN
			SET		@SALES_GUBUN = 'SA';
			SET		@COUPON_MST_SEQ = 302;
		END
	ELSE
		BEGIN
			SET		@SALES_GUBUN = 'ST';	
			SET		@COUPON_MST_SEQ = 303;
		END

	-- 이미 발급된 쿠폰이 있는 지 확인
	IF	NOT EXISTS(
		SELECT		*
		FROM		COUPON_DETAIL			CD
		INNER JOIN	COUPON_ISSUE			CI	ON CD.COUPON_DETAIL_SEQ= CI.COUPON_DETAIL_SEQ
		WHERE		1 = 1
		AND			CI.UID = @EMAIL
		AND			CI.COMPANY_SEQ = @COMPANY_SEQ
		AND			CD.COUPON_MST_SEQ = @COUPON_MST_SEQ
	)

	-- 발급이력이 없다면 영상쿠폰 발급
	BEGIN
			
		-- 발급안된 쿠폰번호 검색 후, 쿠폰발급
		SELECT	TOP(1) @COUPON_CODE =  COUPON_CODE
		FROM	COUPON_DETAIL
		WHERE	1 = 1
		AND		COUPON_MST_SEQ = @COUPON_MST_SEQ
		AND		DOWNLOAD_ACTIVE_YN = 'Y'

		EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE_NOWHERE @COMPANY_SEQ, @SALES_GUBUN, @EMAIL, @COUPON_CODE
		
		UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

	END
END
GO
