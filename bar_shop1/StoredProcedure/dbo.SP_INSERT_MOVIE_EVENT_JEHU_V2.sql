IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT_JEHU_V2', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT_JEHU_V2
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
-- EXEC SP_INSERT_MOVIE_EVENT_JEHU_V2 's4guest'
-- =============================================

CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT_JEHU_V2]
	@UID							AS VARCHAR(50)
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
	DECLARE		@END_DATE						AS	VARCHAR(50)	= ''
	DECLARE		@MSG							AS	VARCHAR(150) = ''
	DECLARE		@SUBJECT						AS	VARCHAR(50) = ''
	DECLARE		@USERPHONE						AS	VARCHAR(50) = ''
	DECLARE		@COMPANY_NM						AS	VARCHAR(50) = ''
	DECLARE		@SEND_PHONE						AS	VARCHAR(15) = ''
	DECLARE		@COUPON_TYPE_CODE				AS	VARCHAR(6) = ''

	DECLARE		@FLOW AS INT = 0; 

	SET @SEND_PHONE = '1644-7413';	--바른손몰
	SET @COUPON_TYPE_CODE = '114008'; -- 쿠폰타입코드


	-- 이미 발급된 쿠폰이 있는 지 확인
	IF EXISTS (  
		SELECT		*
		FROM		S4_COUPON			SC
		INNER JOIN	S4_MYCOUPON			SMC	ON SC.COUPON_CODE = SMC.COUPON_CODE
		WHERE		SMC.UID = @UID
		AND		SC.COUPON_TYPE_CODE = @COUPON_TYPE_CODE 
		)  
		BEGIN                     
			SET @FLOW = 0  
		END  
	ELSE  
		BEGIN                     
			SET @FLOW = 1
		END 

	-- 발급이력이 없다면 영상쿠폰 발급
	IF @FLOW = 1
	BEGIN
			
		-- 발급안된 쿠폰번호 검색 후, 쿠폰발급
		SELECT	TOP(1) @COUPON_CODE =  COUPON_CODE
		FROM	S4_COUPON
		WHERE	COUPON_TYPE_CODE = @COUPON_TYPE_CODE
		AND	isYN = 'Y'
		AND	end_date >= getdate() 
		AND reg_date >= '2021-12-01'


		SET		@END_DATE		=	CONVERT(DATETIME, CONvERT(varchar(10), getdate()+180)) ;

		INSERT INTO S4_MYCOUPON (UID, COUPON_CODE, COMPANY_SEQ, ISMYYN, END_DATE) VALUES (@UID, @COUPON_CODE, '5006', 'Y', @END_DATE)
		
		UPDATE S4_COUPON SET isYN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

	END
END
GO
