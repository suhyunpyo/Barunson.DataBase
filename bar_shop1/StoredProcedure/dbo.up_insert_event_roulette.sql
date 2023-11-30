IF OBJECT_ID (N'dbo.up_insert_event_roulette', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_event_roulette
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015.01.30
-- Description: 룰렛이벤트 참여
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_event_roulette]
	@company_seq		int,
	@rot_idx			int,
	@uid				varchar(20),
	@order_seq			int,
	@result_code		int = 0 OUTPUT,	
	@result_item		int = 0 OUTPUT,	
	@result_idx			int = 0 OUTPUT	
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE	@rots_Idx INT
	DECLARE	@roti_Idx INT
	DECLARE	@st INT	
	DECLARE	@ord INT	
	DECLARE	@roti_type CHAR(1)
	DECLARE	@roti_couponCD VARCHAR(10)
	DECLARE	@couponNum VARCHAR(25)
		
	SET @result_code = 99
	SET @result_item = 0
	SET @result_idx = 0

	SET	@roti_couponCD =''
	SET @couponNum = ''

	SELECT 
		TOP 1 @rots_Idx = B.rots_Idx, @roti_Idx= B.rots_roti_Idx, @st = B.rots_ST, @ord = B.rots_ord
		, @roti_type = C.roti_type, @roti_couponCD = C.roti_couponCD
	FROM 
		Roulette_Main AS A 
		INNER JOIN Roulette_ST AS B ON A.rot_idx=B.rot_idx
		INNER JOIN Roulette_Item AS C ON B.rots_roti_Idx=C.roti_Idx
	WHERE 
		A.rot_idx = @rot_idx AND A.rot_company_seq=@company_seq
		AND GETDATE() BETWEEN A.rot_sDate AND A.rot_Edate
		AND B.rots_status = 0 AND C.roti_status = 0
		AND B.rots_CNT > 0 
		AND B.rots_ST >= A.rot_ST 
		AND ((B.rots_ST = A.rot_ST AND (CASE WHEN B.rots_ord < A.ing_ST THEN B.rots_ord + A.ing_ST ELSE B.rots_ord END) >= A.ing_ST)
		OR B.rots_ST > A.rot_ST)
	ORDER BY B.rots_ST ASC, (CASE WHEN B.rots_ord <= A.ing_ST AND B.rots_ST=A.rot_ST THEN B.rots_ord + A.ing_ST ELSE B.rots_ord END) ASC, rots_idx DESC

	
	IF LEN(@rots_Idx) > 0 
	BEGIN
		BEGIN TRAN		
		
		BEGIN TRY
			-- 아이템이 쿠폰인 경우 쿠폰번호 조회
			IF @roti_type = 'C'
			BEGIN
				SELECT @couponNum = (IsNull(Max(Convert(Int, Right(CouponNum, 7))), 0) + 1)  FROM tCouponSub WHERE CouponCD = @roti_couponCD
				
				SET @couponNum = @roti_couponCD + RIGHT(CONVERT(varchar(30), GETDATE(), 112), 6) + Convert(varchar(4), @company_seq) + RIGHT('0000000' + @couponNum, 7)

				--쿠폰정보 등록
				INSERT INTO tCouponSub ( CouponCD, CouponNum, UserID, UserEmail, TakeYN, TakeDT ) 
					SELECT @roti_couponCD, @couponNum, uid, umail, 'Y', GETDATE() FROM S2_UserInfo_TheCard WHERE uid=@uid
			END
		
			-- 남은 수량 UPDATE
			UPDATE Roulette_ST SET rots_CNT = rots_CNT -1  WHERE rots_Idx = @rots_Idx
			
			-- 이벤트 참여 정보 INSERT
			INSERT Roulette_Member(rotm_UID, rotm_rot_idx, rotm_ST, rotm_rots_Idx, rotm_coupon_code, rotm_order_seq)
			VALUES(@uid, @rot_idx, @st, @rots_Idx, @couponNum, @order_seq)
			
			set @result_idx = SCOPE_IDENTITY()
			
			--쿠폰인 경우는 쿠폰 발송완료 상태로 변경
			IF @roti_type = 'C'
			BEGIN
				UPDATE Roulette_Member SET rotm_status=1 WHERE rotm_Idx=@result_idx
			END
			
			-- 이벤트 현재 정보 UPDATE
			UPDATE Roulette_Main SET rot_ST=@st, ing_ST=@ord WHERE rot_idx=@rot_idx

			COMMIT TRAN
				
			SET @result_code = 0
			SET @result_item = @ord
			SET @result_idx = @result_idx
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			SET @result_code = 1
			SET @result_item = 0
			SET @result_idx = 0
		END CATCH;

	END

	return @result_code
	return @result_item
	return @result_idx
END
GO
