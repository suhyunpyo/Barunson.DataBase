IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT_BAK_to_remove', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT_BAK_to_remove
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		황새롬
-- Create date: 2016-06-10
-- Description:	바른손카드 식전영상쿠폰발급

-- EXEC 쿠폰타입, 회원아이디, 사이트코드
-- EXEC dbo.SP_INSERT_MOVIE_EVENT '114009', 's5guest', 5001
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT_BAK_to_remove]
	@COUPON_TYPE_CODE 					AS VARCHAR(6),
	@UID								AS VARCHAR(50),
	@COMPANY_SEQ						AS INT
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
	DECLARE		@END_DATE						AS	VARCHAR(50)	= ''
	DECLARE		@MSG							AS	VARCHAR(150) = ''
	DECLARE		@SUBJECT						AS	VARCHAR(50) = ''
	DECLARE		@USERPHONE						AS	VARCHAR(50) = ''
	DECLARE		@COMPANY_NM						AS	VARCHAR(50) = ''
	DECLARE		@SEND_PHONE						AS	VARCHAR(15) = ''

DECLARE @SITE_TYPE AS VARCHAR(8) = 'SB'
DECLARE	@ErrNum   INT          
	  , @ErrSev   INT          
	  , @ErrState INT          
	  , @ErrProc  VARCHAR(50)  
	  , @ErrLine  INT          
	  , @ErrMsg   VARCHAR(2000)


	SET @SEND_PHONE = '1644-0708';	--바른손사용

	-- 이미 발급된 쿠폰이 있는 지 확인
	IF	NOT EXISTS(
		SELECT		*
		FROM		S4_COUPON			SC
		INNER JOIN	S4_MYCOUPON			SMC	ON SC.COUPON_CODE = SMC.COUPON_CODE
		WHERE		1 = 1
		AND			SMC.UID = @UID
		AND			SMC.COMPANY_SEQ = @COMPANY_SEQ
		AND			SC.COUPON_TYPE_CODE = @COUPON_TYPE_CODE
		
	)

	-- 발급이력이 없다면 영상쿠폰 발급
	BEGIN
			
		-- 발급안된 쿠폰번호 검색 후, 쿠폰발급
		SELECT	TOP(1) @COUPON_CODE =  COUPON_CODE
		FROM	S4_COUPON
		WHERE	1 = 1
		AND		COUPON_TYPE_CODE = @COUPON_TYPE_CODE
		AND		isYN = 'Y'
		AND		end_date >= getdate()

		SET		@END_DATE		=	'2018-06-30' 

		INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, @COMPANY_SEQ, 'Y', @END_DATE)

		-- 쿠폰발급 후, 문자메세지 전송
		if @COMPANY_SEQ = 5001 		
			BEGIN	
				SET @COMPANY_NM = '바른손카드';
				SET	@MSG		=	'식전영상쿠폰이 발급되었습니다.' + CHAR(10)+ '▷ 쿠폰번호' + CHAR(10)+ '▷ ' + @COUPON_CODE + CHAR(10) + ' 마이페이지 > 쿠폰보관함에서' + CHAR(10)+ ' 확인가능';
				SET @SITE_TYPE = 'SB'
			END
		else if @COMPANY_SEQ = 5003 
			BEGIN
				SET @COMPANY_NM = '프리미어페이퍼';
				SET	@MSG		=	'식전영상쿠폰이 발급되었습니다.' + CHAR(10)+ '▷ 쿠폰번호' + CHAR(10)+ '▷ ' + @COUPON_CODE;

				SET @SEND_PHONE = '1644-8796';	--프페사용
				SET @SITE_TYPE = 'SS'
			END


		
		SET		@SUBJECT		=	'[' + @COMPANY_NM + '] 쿠폰이 발급되었습니다.'

		SELECT	@USERPHONE = UNAME + '^' + HAND_PHONE1 + HAND_PHONE2 + HAND_PHONE3
		FROM	S2_USERINFO
		WHERE	UID = @UID

		--프페 비회원 이용후기 작성시 주문자 핸드폰번호로 발급하기 위해 추가함 : 2017.02.21
		IF @COMPANY_SEQ = 5003 AND @USERPHONE = ''
		BEGIN
				SET @SITE_TYPE = 'SS'

				SELECT TOP 1 @USERPHONE = ORDER_NAME + '^' + ORDER_HPHONE
				FROM CUSTOM_ORDER
				WHERE ORDER_EMAIL= @UID
				AND ORDER_HPHONE <> ''
				AND ORDER_HPHONE IS NOT NULL
		END


		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND @UID, 0, @SUBJECT, @MSG, '', @SEND_PHONE, 1, @USERPHONE, 0, '', 0, @SITE_TYPE, '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT

		UPDATE S4_COUPON SET isYN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

	END
END
GO
