IF OBJECT_ID (N'dbo.up_Select_Md_Choice_For_Weeklyhotdeal_U_temp', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Md_Choice_For_Weeklyhotdeal_U_temp
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-05-27
-- Description:	관리자, MD전시 > 위클리핫딜 상품 수정

-- exec dbo.up_Select_Md_Choice_For_Weeklyhotdeal_U 7317, 3, 900, 0, 0
-- exec dbo.up_Select_Md_Choice_For_Weeklyhotdeal_U 7316, 2, 1, 0, 0
-- =============================================
CREATE proc [dbo].[up_Select_Md_Choice_For_Weeklyhotdeal_U_temp]

	@choice_seq				int
	, @hotdeal_seq			int
	, @hotdeal_price		int
	, @coupon_seq			int
	, @coupon_code			varchar(50)
	, @view_coupon_downcnt	int
	, @down_start_dt		varchar(10)
	, @down_end_dt			varchar(10)
	, @use_end_dt			varchar(10)

as

set nocount on;


declare @real_coupon_seq int, @card_seq int, @sorting_num int

select @real_coupon_seq = SEQ
from S4_COUPON with(nolock)
where coupon_code = @coupon_code

select @card_seq = card_seq, @sorting_num = sorting_num
from S4_MD_Choice with(nolock)
where seq = @choice_seq

update S4_MD_Choice_weeklyhotdeal
set hotdeal_price = @hotdeal_price
where seq = @hotdeal_seq


if @coupon_seq > 0 and @coupon_code <> '00000000'
	begin

		declare @pre_coupon_seq int
	
		select @pre_coupon_seq = SEQ
		from S4_COUPON with(nolock)
		where coupon_code = (select coupon_code from S4_MD_Choice_UseCoupon where seq = @coupon_seq)

		delete
		from S4_COUPON_ADDON_CARD_SEQ
		where COUPON_SEQ = @pre_coupon_seq and CARD_SEQ = @card_seq

		update S4_MD_Choice_UseCoupon
		set coupon_code = @coupon_code, view_coupon_downcnt = @view_coupon_downcnt, down_start_dt = @down_start_dt, down_end_dt = @down_end_dt
		where seq = @coupon_seq

		update S4_COUPON
		set end_date = @use_end_dt
		where seq = @real_coupon_seq

		insert into S4_COUPON_ADDON_CARD_SEQ
		values
		(
			@real_coupon_seq, @card_seq, @sorting_num, getdate()
		)

	end
else if @coupon_seq > 0 and @coupon_code = '00000000'
	begin
		
		delete
		from S4_MD_Choice_UseCoupon
		where seq = @coupon_seq

		delete
		from S4_COUPON_ADDON_CARD_SEQ
		where COUPON_SEQ = @real_coupon_seq and CARD_SEQ = @card_seq

	end
else if @coupon_seq = 0 and @coupon_code <> '00000000'
	begin

		insert into S4_MD_Choice_UseCoupon
		values
		(
			@choice_seq, @coupon_code, @view_coupon_downcnt, @down_start_dt, @down_end_dt
		)

		update S4_COUPON
		set end_date = @use_end_dt
		where seq = @real_coupon_seq

		insert into S4_COUPON_ADDON_CARD_SEQ
		values
		(
			@real_coupon_seq, @card_seq, @sorting_num, getdate()
		)

	end













GO
