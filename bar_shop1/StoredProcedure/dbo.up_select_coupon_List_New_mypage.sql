IF OBJECT_ID (N'dbo.up_select_coupon_List_New_mypage', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_coupon_List_New_mypage
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-06-30
-- Description:	쿠폰 리스트 
-- EXEC up_select_coupon_List_New 5007, 's5guest', 1, 'N'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_coupon_List_New_mypage]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(30),
	@status	AS char(1), --사용가능 쿠폰:1, 지난쿠폰 : 2
	@useYN  AS char(1)
	
AS
BEGIN
	SET NOCOUNT ON;
			
			IF @status = '1'
				BEGIN
					SELECT COUNT(A.CouponCD) 
					FROM tCouponSub AS A WITH(NOLOCK) 
						LEFT OUTER JOIN tCouponMst AS B WITH(NOLOCK) ON A.CouponCD = B.CouponCD
					WHERE A.UserID = @uid 
						--AND CONVERT(VARCHAR(10), ToDT, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121) AND CONVERT(VARCHAR(10), FromDT, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) 
						--AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121) AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN A.TakeDT ELSE B.FromDT END, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) 
						AND ( 
								( CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121) AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN A.TakeDT ELSE B.FromDT END, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) )
								or (A.COUPONCD = 'C0000162')
							) 						
						AND A.UseYN = @useYN
						--AND B.MultiUseYN = 'N'

					SELECT 
							A.CouponCD
						  , CouponNum
						  , UserID
						  , UserEmail
						  , TakeYN
						  , TakeDT
						  , A.UseYN
						  , UseDT
						  , userDelYN
						  , sendMailYN
						  , A.InsertDT
						  , TimeCD
						  , Cd
						  , Subject
						  , Amt
						  , amtGb
						  --, FromDT
						  , CASE WHEN B.IssueYN = 'Y' THEN A.TakeDT ELSE B.FromDT END AS FromDT
						  --, ToDT
						  , CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END AS ToDT
						  , ValidAmt
						  , UseTarget
						  , DeliveryYN
						  , CoverageComment
					FROM tCouponSub AS A WITH(NOLOCK) 
						LEFT OUTER JOIN tCouponMst AS B WITH(NOLOCK) 
							ON A.CouponCD = B.CouponCD
					WHERE A.UserID = @uid 
						--AND CONVERT(VARCHAR(10), ToDT, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121) AND CONVERT(VARCHAR(10), FromDT, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) 
						--AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121) AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN A.TakeDT ELSE B.FromDT END, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) 
						AND ( 
								( CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) >= CONVERT(VARCHAR(10), GETDATE(), 121) AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN A.TakeDT ELSE B.FromDT END, 121) <= CONVERT(VARCHAR(10), GETDATE(), 121) )
								or (A.COUPONCD = 'C0000162')
							) 
						AND A.UseYN = @useYN
						--AND B.MultiUseYN = 'N'
				
				END
			ELSE 
				BEGIN
					SELECT COUNT(A.CouponCD) 
					FROM tCouponSub AS A WITH(NOLOCK) 
						LEFT OUTER JOIN tCouponMst AS B WITH(NOLOCK) 
							ON A.CouponCD = B.CouponCD
					WHERE A.UserID = @uid 
						--AND CONVERT(VARCHAR(10), ToDT, 121) < CONVERT(VARCHAR(10), GETDATE(), 121) 
						--AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) < CONVERT(VARCHAR(10), GETDATE(), 121) 
						AND ( 
								( CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) < CONVERT(VARCHAR(10), GETDATE(), 121)  ) 
								or (A.COUPONCD = 'C0000162')
							) 
						AND A.UseYN=@useYN
						--AND B.MultiUseYN = 'N'

					SELECT 
							A.CouponCD
						  , CouponNum
						  , UserID
						  , UserEmail
						  , TakeYN
						  , TakeDT
						  , A.UseYN
						  , UseDT
						  , userDelYN
						  , sendMailYN
						  , A.InsertDT
						  , TimeCD
						  , Cd
						  , Subject
						  , Amt
						  , amtGb
						  --, FromDT
						  , CASE WHEN B.IssueYN = 'Y' THEN A.TakeDT ELSE B.FromDT END AS FromDT
						  --, ToDT
						  , CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END AS ToDT
						  , ValidAmt
						  , UseTarget
						  , DeliveryYN
						  , CoverageComment
					FROM tCouponSub AS A WITH(NOLOCK) 
						LEFT OUTER JOIN tCouponMst AS B WITH(NOLOCK) 
							ON A.CouponCD = B.CouponCD
					WHERE  A.UserID = @uid 
						--AND CONVERT(VARCHAR(10), ToDT, 121) < CONVERT(VARCHAR(10), GETDATE(), 121) 
						--AND CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) < CONVERT(VARCHAR(10), GETDATE(), 121) 
						AND ( 
								( CONVERT(VARCHAR(10), CASE WHEN B.IssueYN = 'Y' THEN DATEADD(dd, B.IssueDayCnt, A.TakeDT) ELSE B.ToDT END, 121) < CONVERT(VARCHAR(10), GETDATE(), 121)  ) 
								or (A.COUPONCD = 'C0000162')
							) 
						AND A.UseYN = @useYN
						--AND B.MultiUseYN = 'N'
				
				END
				
END
GO
