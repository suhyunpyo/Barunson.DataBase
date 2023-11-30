IF OBJECT_ID (N'dbo.up_select_top2_coupon_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_top2_coupon_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-05
-- Description:	쇼핑캐스트 - 쿠폰 리스트
-- TEST : up_select_top2_coupon_list 'palaoh'
-- =============================================
CREATE PROCEDURE [dbo].[up_select_top2_coupon_list]	
	
	@uid			nvarchar(16)	

AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	

	--DECLARE @uid varchar(16)='palaoh'

	SELECT TOP 2 CM.Subject
				,CONVERT(varchar(10), CM.ToDT, 102) AS ToDT
				,CM.Amt
				,CM.amtGb
				--,CS.CouponCD
				--,CS.CouponNum
				--,CM.ApplyType
	FROM tCouponSub CS
	INNER JOIN tCouponMst CM ON CS.CouponCD = CM.CouponCD 
	WHERE CS.userid = @uid 
	  AND CS.UseYN = 'N' 
	  AND CS.TakeYN = 'Y'
	  AND GETDATE() BETWEEN CM.FromDT AND CM.ToDT
	ORDER BY CM.ToDT DESC
	
  
END
GO
