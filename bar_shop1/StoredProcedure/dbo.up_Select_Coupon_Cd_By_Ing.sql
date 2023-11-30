IF OBJECT_ID (N'dbo.up_Select_Coupon_Cd_By_Ing', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Coupon_Cd_By_Ing
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-05-27
-- Description:	관리자, 공통. 진행중인 쿠폰 리스트 조회

-- exec dbo.up_Select_Coupon_Cd_By_Ing 114002, 5006
-- =============================================
CREATE proc [dbo].[up_Select_Coupon_Cd_By_Ing]

	@coupon_type_code varchar(6)
	, @company_seq int

as

set nocount on;


select coupon_code, coupon_desc
from S4_COUPON
where isYN = 'Y' 
	and coupon_type_code = @coupon_type_code and company_seq = @company_seq
	and reg_date <= getdate() And end_date >= getdate()













GO
