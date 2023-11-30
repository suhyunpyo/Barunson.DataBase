IF OBJECT_ID (N'dbo.up_insert_coupon', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_coupon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		daniel,kim
-- Create date: 2015.03.03
-- Description: 쿠폰발급
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_coupon]
	@company_seq		int,
	@uid				varchar(20),
	@couponCD			varchar(10)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@couponNum VARCHAR(30)
	
	SET @couponNum = ''

	-- 회원당 동일 쿠폰이 중복으로 발급되어도 되는 경우
	IF (@couponCD <> 'C0000062' AND @couponCD <> 'C0000112' AND @couponCD <> 'C0000199'  AND @couponCD <> 'C0000113' AND @couponCD <> 'C0000117' AND @couponCD <> 'C0000118' AND @couponCD <> 'C0000119' AND @couponCD <> 'C0000141' AND @couponCD <> 'C0000147' AND @couponCD <> 'C0000148' AND @couponCD <> 'C0000155' AND @couponCD <> 'C0000154' AND @couponCD <> 'C0000150' AND @couponCD <> 'C0000156' AND @couponCD <> 'C0000157' AND @couponCD <> 'C0000159' AND @couponCD <> 'C0000160' AND @couponCD <> 'C0000149' AND @couponCD <> 'C0000162' AND @couponCD <> 'C0000164' AND @couponCD <> 'C0000169' AND @couponCD <> 'C0000170' AND @couponCD <> 'C0000171' AND @couponCD <> 'C0000173' AND @couponCD <> 'C0000179' AND @couponCD <> 'C0000174' AND @couponCD <> 'C0000175' AND @couponCD <> 'C0000176' AND @couponCD <> 'C0000184' AND @couponCD <> 'C0000183' AND @couponCD <> 'C0000194' AND @couponCD <> 'C0000186' AND @couponCD <> 'C0000187' AND @couponCD <> 'C0000188' AND @couponCD <> 'C0000189'  AND @couponCD <> 'C0000197'  AND @couponCD <> 'C0000202'  AND @couponCD <> 'C0000198' AND @couponCD <> 'C0000205' AND @couponCD <> 'C0000207' AND @couponCD <> 'C0000209' AND @couponCD <> 'C0000210' AND @couponCD <> 'C0000212' AND @couponCD <> 'C0000215' AND @couponCD <> 'C0000216' AND @couponCD <> 'C0000217'  AND @couponCD <> 'C0000218'  AND @couponCD <> 'C0000219'  AND @couponCD <> 'C0000220' AND @couponCD <> 'C0000224' AND @couponCD <> 'C0000228'  )
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
	END
	-- 회원당 동일 쿠폰이 중복으로 발급되면 안되는 경우
	ELSE IF NOT EXISTS 
	( 
		SELECT *
		FROM tCouponSub
		WHERE UserID = @uid
			AND CouponCD = @couponCD
	)
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
	END	
END

GO
