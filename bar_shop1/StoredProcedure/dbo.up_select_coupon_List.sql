IF OBJECT_ID (N'dbo.up_select_coupon_List', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_coupon_List
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김덕중
-- Create date: 2014-06-30
-- Description:	쿠폰 리스트 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_coupon_List]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(30),
	@page	AS int,
	@pagesize AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
			begin
				select COUNT(A.coupon_code) from s4_coupon AS A with(nolock) 
				inner join s4_myCoupon AS B with(nolock) on A.coupon_code = B.coupon_code
				and A.company_seq = B.company_seq
				where  A.company_seq = @company_seq and isYN='Y' and B.isMyYN='Y'
				and (B.end_date is null or Convert(varchar(8), B.end_date, 112) >= convert(varchar(8), getdate(), 112) )
				and B.uid = @uid
		
				select  top (@pagesize) A.coupon_code, A.coupon_desc, A.reg_date,discount_type,discount_value,coupon_desc,isJehu,isWeddingCoupon,item_type,ISNULL(limit_price,0) as limit_price,B.end_date,ISNULL(cardbrand,'') as cardbrand 
				from s4_coupon AS A with(nolock) 
				inner join s4_myCoupon AS B with(nolock) on A.coupon_code = B.coupon_code
				and A.company_seq = B.company_seq
				where  A.company_seq = @company_seq and isYN='Y' and B.isMyYN='Y'
				and (B.end_date is null or Convert(varchar(8), B.end_date, 112) >= convert(varchar(8), getdate(), 112) )
				and B.uid = @uid
				
			end
END

GO
