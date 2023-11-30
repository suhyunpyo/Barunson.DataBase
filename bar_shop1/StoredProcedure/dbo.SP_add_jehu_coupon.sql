IF OBJECT_ID (N'dbo.SP_add_jehu_coupon', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_add_jehu_coupon
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[SP_add_jehu_coupon] 
-------------------------------------------------------------------------------
--  설  명 : 
--  작성자 : 
--  작성일 : 

--[SP_add_jehu_coupon] '6835','10'

-------------------------------------------------------------------------------
@company_seq varchar(20), 
@discount varchar(20)

AS  
SET NOCOUNT ON

BEGIN

	
	DECLARE	@coupon_code1 varchar(50)
	DECLARE	@coupon_code2 varchar(50)
	

	/*
	--쿠폰번호 세팅 
	set @coupon_code1 = 'BHR' + @discount + @company_seq + 'M'
	set @coupon_code2 = 'BHR' + @discount + @company_seq + 'U'

	--쿠폰 인써트
	insert into s4_coupon(coupon_code,company_seq,discount_type,discount_value, coupon_desc, isRecycle, isWeddingcoupon,isjehu,cardbrand) values(
	@coupon_code1,@company_seq,'R',@discount,'제휴사추가할인','1','','Y','M')

	insert into s4_coupon(coupon_code,company_seq,discount_type,discount_value, coupon_desc, isRecycle, isWeddingcoupon,isjehu,cardbrand) values(
	@coupon_code2,@company_seq,'R',@discount,'제휴사추가할인','1','','Y','U')
	*/
	
	--쿠폰번호 세팅 
	set @coupon_code1 = 'BHR' + @discount + @company_seq + 'N'
	
	--쿠폰 인써트
	insert into s4_coupon(coupon_code,company_seq,discount_type,discount_value, coupon_desc, isRecycle, isWeddingcoupon,isjehu,cardbrand) values(
	@coupon_code1,@company_seq,'R',@discount,'제휴사추가할인','1','','Y','N')


end
GO
