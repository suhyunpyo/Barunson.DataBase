IF OBJECT_ID (N'dbo.up_insert_coupon_custom', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_coupon_custom
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 2016.11.14
-- Description: 더카드 모바일 이벤트 쿠폰발급 (@result_code: 0(정상(쿠폰발급)), 1 (기발급), 2(정상(문자발송)), 3(오류)
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_coupon_custom]
	@company_seq		INT,
	@uid				VARCHAR(20) = '',
	@couponCD			VARCHAR(10),
	@cellPhoneNum		VARCHAR(15) = '',
	@title				VARCHAR(120) = '',
	@msg				VARCHAR(4000) = '',
	@result_code		INT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@couponNum VARCHAR(30)
	
	SET @couponNum = ''
	
	IF @uid <> ''
	BEGIN
		IF NOT EXISTS (SELECT * FROM tCouponSub WHERE UserID = @uid AND CouponCD = @couponCD)
		BEGIN
			SELECT @couponNum = (IsNull(Max(Convert(Int, Right(CouponNum, 7))), 0) + 1)  FROM tCouponSub WHERE CouponCD = @couponCD
				
			SET @couponNum = @couponCD + RIGHT(CONVERT(varchar(30), GETDATE(), 112), 6) + Convert(varchar(4), @company_seq) + RIGHT('0000000' + @couponNum, 7)

			--쿠폰정보 등록
			INSERT INTO tCouponSub ( CouponCD, CouponNum, UserID, UserEmail, TakeYN, TakeDT ) 
			SELECT 
				@couponCD
				, @couponNum
				, uid
				, umail
				, 'Y'
				, GETDATE() 
			FROM S2_UserInfo_TheCard 
			WHERE uid = @uid

			--정상(발급)
			SET @result_code = 0
		END
		ELSE
		BEGIN
			--기발급
			SET @result_code = 1

		END	
	END
	ELSE IF @cellPhoneNum <> ''
	BEGIN				
		--SET @msg = '더카드★시크릿 만원 할인쿠폰 C0000183 ' + char(13) + char(10) + '더카드>마이페이지>쿠폰함 등록 후 사용'

		EXEC SP_EXEC_SMS_OR_MMS_SEND '1644-7998', @cellPhoneNum, @title, @msg, 'ST', '쿠폰발급', @couponCD, '', 0, ''

		--정상(문자발송)
		SET @result_code = 2
	END
	ELSE
	BEGIN
		--오류(@uid 도 @cellPhoneNum 도 없는 요청...)
		SET @result_code = 3

	END

END
GO
