IF OBJECT_ID (N'dbo.SP_INSERT_MOVIE_EVENT_ST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_INSERT_MOVIE_EVENT_ST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		<Author,,Name>
-- Create date: 2018.01.31
-- Description:	더카드 식전영상쿠폰발급 : 필모션용
-- 발급조건   : 1. 청첩장 원주문고객(감사장, 부가상품 제외)
--				2. 구매수량 100매이상
--				3. 회원ID당 1회발급
--				4. 청첩장 초안고객 컨펌 완료 후 발급가능
--	COUPON_MST_SEQ = 112			
-- =======================================================
CREATE PROCEDURE [dbo].[SP_INSERT_MOVIE_EVENT_ST]
	@COUPON_MST_SEQ 					AS INT,
	@UID								AS VARCHAR(50)	,
	@COMPANY_SEQ						AS INT	=	5007,
	@SALES_GUBUN						AS VARCHAR(2) = 'ST'	--기본세팅 : 더카드
AS
BEGIN
	
	DECLARE		@COUPON_CODE					AS	VARCHAR(50) = ''
	DECLARE		@END_DATE						AS	VARCHAR(50)	= ''
	DECLARE		@MMS_MSG						AS	VARCHAR(150) = ''
	DECLARE		@SUBJECT						AS	VARCHAR(50) = ''
	DECLARE		@USERPHONE						AS	VARCHAR(50) = ''
	DECLARE		@COMPANY_NM						AS	VARCHAR(50) = ''
	DECLARE		@SEND_PHONE						AS	VARCHAR(15) = ''

	DECLARE		@CNT							AS	INT = 0
	DECLARE		@STATUS_SEQ						AS	INT
	DECLARE		@MSG							AS	VARCHAR(150) = ''
	DECLARE     @RESULT_CODE					AS VARCHAR(4)	= ''
	DECLARE     @RESULT_MESSAGE					AS VARCHAR(500)	= ''

	--조건검색
	SELECT @CNT			= COUNT(*)  
		 , @STATUS_SEQ	= MAX(STATUS_SEQ) 
	FROM CUSTOM_ORDER
	WHERE MEMBER_ID = @UID
	AND SALES_GUBUN = @SALES_GUBUN
	AND COMPANY_SEQ = @COMPANY_SEQ
	AND UP_ORDER_SEQ IS NULL
	AND ORDER_COUNT >= 100
	--AND STATUS_SEQ >= 9
	AND SETTLE_STATUS IN (1,2)
	AND ORDER_TYPE IN (1,6,7)

	IF @CNT = 0	--청첩장 구매여부
		BEGIN
			SET		@MSG		= '청첩장 구매 후 이용 가능합니다.';
		END 
	ELSE
		BEGIN
			IF @STATUS_SEQ < 9
				BEGIN
					SET		@MSG		= '청첩장 시안을 확정해주신 후 쿠폰 발급이 가능합니다^^';
				END 

			ELSE
				BEGIN
					-- 이미 발급된 쿠폰이 있는 지 확인
					IF	NOT EXISTS(
						SELECT		*
						FROM		COUPON_DETAIL			CD
						INNER JOIN	COUPON_ISSUE			CI	ON CD.COUPON_DETAIL_SEQ= CI.COUPON_DETAIL_SEQ
						WHERE		1 = 1
						AND			CI.UID = @UID
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

							IF @COUPON_CODE <> ''
								BEGIN
									
									EXEC	SP_EXEC_COUPON_ISSUE_FOR_ONE @COMPANY_SEQ, @SALES_GUBUN, @UID, @COUPON_CODE

									--SELECT	@USERPHONE = HPHONE
									--FROM	VW_USER_INFO
									--WHERE	UID = @UID AND SITE_DIV = @SALES_GUBUN

									--SET		@COMPANY_NM = '더카드';
									--SET		@MMS_MSG	= '식전영상쿠폰이 발급되었습니다.' + CHAR(10)
									--					+ '▷ 쿠폰번호' + CHAR(10)+ '▷ ' + @COUPON_CODE + CHAR(10) + ' 마이페이지 > 쿠폰보관함에서' + CHAR(10)+ ' 확인가능';
									--SET		@SUBJECT	= '[' + @COMPANY_NM + '] 쿠폰이 발급되었습니다.'
									--SET		@SEND_PHONE = '1644-7998';


									--INSERT INTO invtmng.MMS_MSG(SUBJECT, PHONE, CALLBACK, STATUS, REQDATE, MSG, TYPE) VALUES
									--(@SUBJECT, @USERPHONE, @SEND_PHONE, '0', GETDATE(), @MMS_MSG, '0')

									UPDATE COUPON_DETAIL SET DOWNLOAD_ACTIVE_YN = 'N' WHERE COUPON_CODE = @COUPON_CODE 

									SET		@MSG		= '쿠폰이 발급되었습니다. 마이페이지에서 확인해주세요.';
							
								END 
							

						END

					ELSE
						BEGIN
							SET		@MSG		= '이미 쿠폰을 발급받으셨습니다. 쿠폰함을 확인해주세요.';
						END
				END
			
		END

	--RETURN
	SELECT	@MSG	AS	MSG

END
GO
