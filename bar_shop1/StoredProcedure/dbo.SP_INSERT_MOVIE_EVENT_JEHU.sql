IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT_JEHU', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT_JEHU
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정혜련
-- Create date: 2017-04-01
-- Description:	제휴 식전영상쿠폰발급

-- EXEC 쿠폰타입, 회원아이디, 사이트코드
-- EXEC dbo.SP_INSERT_MOVIE_EVENT '114008', 's5guest', 5001
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT_JEHU]
	@COUPON_TYPE_CODE AS VARCHAR(6),
	@UID              AS VARCHAR(50),
	@COMPANY_SEQ      AS INT
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
	DECLARE		@END_DATE						AS	VARCHAR(50)	= ''
	DECLARE		@MSG							AS	VARCHAR(150) = ''
	DECLARE		@SUBJECT						AS	VARCHAR(50) = ''
	DECLARE		@USERPHONE						AS	VARCHAR(50) = ''
	DECLARE		@COMPANY_NM						AS	VARCHAR(50) = ''
	DECLARE		@SEND_PHONE						AS	VARCHAR(15) = ''

	SET @SEND_PHONE = '1644-7413';	--바른손몰
	

	-- 이미 발급된 쿠폰이 있는 지 확인
	IF	NOT EXISTS(
		SELECT		*
		FROM		S4_COUPON   AS SC
		INNER JOIN	S4_MYCOUPON AS SMC ON SC.COUPON_CODE = SMC.COUPON_CODE
		WHERE		SMC.UID = @UID
		AND		SC.COUPON_TYPE_CODE = @COUPON_TYPE_CODE
	)

	-- 발급이력이 없다면 영상쿠폰 발급
	BEGIN
			
		-- 발급안된 쿠폰번호 검색 후, 쿠폰발급
		SELECT	TOP(1) @COUPON_CODE =  COUPON_CODE
		FROM	S4_COUPON
		WHERE	COUPON_TYPE_CODE = @COUPON_TYPE_CODE
		AND	isYN = 'Y'
		AND		end_date >= getdate()

		SET		@END_DATE		=	'2017-06-30' 

		--INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, @COMPANY_SEQ, 'Y', @END_DATE)
		INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, '5006', 'Y', @END_DATE)
		
		-- 쿠폰발급 후, 문자메세지 전송
		BEGIN	
			SET @COMPANY_NM = '바른손몰';
			SET	@MSG		= '식전영상쿠폰이 발급되었습니다.' + CHAR(10)+ '▷ 쿠폰번호' + CHAR(10)+ '▷ ' + @COUPON_CODE + CHAR(10) + ' 마이페이지 > 쿠폰보관함에서' + CHAR(10)+ ' 확인가능';
		END

		SET @SUBJECT = '[' + @COMPANY_NM + '] 쿠폰이 발급되었습니다.'

		SELECT	TOP(1) @USERPHONE = 'AA^' + HPHONE
		FROM	VW_USER_INFO 
		WHERE	UID = @UID

		----------------------------------------------------------------------------------
		-- KT
		----------------------------------------------------------------------------------
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, @SUBJECT, @MSG, '', @SEND_PHONE, 1, @USERPHONE, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''

		----------------------------------------------------------------------------------
		-- LG 데이콤(구버전)
		----------------------------------------------------------------------------------
		--INSERT INTO invtmng.MMS_MSG(SUBJECT, PHONE, CALLBACK, STATUS, REQDATE, MSG, TYPE) VALUES
		--(@SUBJECT, @USERPHONE, @SEND_PHONE, '0', GETDATE(), @MSG, '0')


		UPDATE S4_COUPON SET isYN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

	END
END
GO
