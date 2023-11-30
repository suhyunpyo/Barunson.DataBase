IF OBJECT_ID (N'dbo.up_tCouponSub_Delete_ForTheCard_StampSampleCoupon', N'P') IS NOT NULL DROP PROCEDURE dbo.up_tCouponSub_Delete_ForTheCard_StampSampleCoupon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		박동혁
-- Create date: 2016-01-27
-- Description:	스탬프 샘플후기 쿠폰 삭제
-- EXEC up_tCouponSub_Delete_ForTheCard_StampSampleCoupon 4, 's4guest', 0
-- =============================================
CREATE PROCEDURE [dbo].[up_tCouponSub_Delete_ForTheCard_StampSampleCoupon]
	@ER_Type				AS		INT,
	@ER_UserId				AS		VARCHAR(20),
	@Result					AS		INT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRAN
			
		DECLARE @EffectiveRows	INT = 0;

		DELETE FROM tCouponSub 
		WHERE UserID = @ER_UserId AND CouponCD IN 
		(
			SELECT A.CouponCD
			FROM tCouponSub AS A 
				LEFT OUTER JOIN custom_order AS B
					ON A.CouponNum = B.CouponSeq
					AND A.UserID = B.member_id
			WHERE A.UserID = @ER_UserId
				AND A.UseYN = 'N' 
				AND A.UseDT IS NULL 
				AND B.order_seq IS NULL
			AND A.CouponCD IN ('C0000101', 'C0000102', 'C0000103', 'C0000104', 'C0000105', 'C0000106', 'C0000107', 'C0000108', 'C0000109', 'C0000110', 'C0000125', 'C0000126', 'C0000127', 'C0000128', 'C0000129', 'C0000130', 'C0000131', 'C0000132', 'C0000133', 'C0000134')
		)

    	--SET @EffectiveRows = @@ROWCOUNT	
		SET @Result = '0'
		SET @Result = @@Error

		--IF (@EffectiveRows = 0 AND @Result <> 0) GOTO PROBLEM
		IF (@Result <> 0) GOTO PROBLEM
		COMMIT TRAN


		PROBLEM:
		--IF (@EffectiveRows = 0 AND @Result <> 0) BEGIN
		IF (@Result <> 0) BEGIN
			ROLLBACK TRAN
		END
			
		RETURN @Result

END
GO
