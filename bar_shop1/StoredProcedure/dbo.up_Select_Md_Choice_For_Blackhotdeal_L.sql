IF OBJECT_ID (N'dbo.up_Select_Md_Choice_For_Blackhotdeal_L', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Md_Choice_For_Blackhotdeal_L
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		시스템지원팀, 장형일 과장
-- Create date: 2015-05-27
-- Description:	관리자, MD전시 > 위클리핫딜 상품 조회

-- exec dbo.up_Select_Md_Choice_For_Weeklyhotdeal_L 368, 5006
-- =============================================
create proc [dbo].[up_Select_Md_Choice_For_Blackhotdeal_L]

	@md_seq int
	, @company_seq int

as

set nocount on;

SELECT
	A.seq
	,A.card_seq
	, C.Company_Seq
	, B.Card_Code
	, B.Card_Name
	, B.CardBrand
	, CardImage_FileName = (select distinct top 1 CardImage_FileName from S2_CardImage where Company_Seq = C.Company_Seq and CardImage_WSize = '610' and CardImage_HSize = '477' and card_seq = A.card_seq)
	--, B.CardSet_Price
	, B.CardSet_Price * (1 - C2.Discount_Rate/100) as Card_Price
	, D.hotdeal_price
	, isNull(E.coupon_code, '') as Coupon_cd
	, convert(varchar(10), E.down_start_dt, 121) as down_start_dt
	, convert(varchar(10), E.down_end_dt, 121) as down_end_dt
	, case 
		when E.coupon_code is not null and E.view_coupon_downcnt is null then (select COUNT(uid) from S4_MyCoupon where coupon_code = E.coupon_code)
		when E.coupon_code is not null then E.view_coupon_downcnt
		else 0 
	  end as view_coupon_downcnt
	, case 
		when E.coupon_code is not null then (select COUNT(uid) from S4_MyCoupon where coupon_code = E.coupon_code)
		else 0 
	  end as real_coupon_downcnt
	, A.sorting_num
	, D.seq as hotdeal_seq
	, isnull(E.seq, 0) as coupon_seq
	, convert(varchar(10), F.end_date, 121) as use_end_dt
	, C.IsDisplay
	, C2.Discount_Rate
FROM S4_MD_Choice A WITH(NOLOCK) 
INNER JOIN S2_Card B WITH(NOLOCK) ON A.card_seq = B.Card_Seq
INNER JOIN S2_CardSalesSite C WITH(NOLOCK) ON A.card_seq = C.Card_Seq
INNER JOIN s2_carddiscount AS C2 with(nolock) on C.CardDiscount_Seq = C2.CardDiscount_Seq and C2.MinCount = 400
INNER JOIN S4_MD_Choice_weeklyhotdeal D WITH(NOLOCK) ON A.seq = D.choice_seq
LEFT OUTER JOIN S4_MD_Choice_UseCoupon E WITH(NOLOCK) ON A.seq = E.choice_seq
LEFT OUTER JOIN S4_COUPON F WITH(NOLOCK) ON E.coupon_code = F.coupon_code
WHERE A.md_seq= @md_seq and C.Company_Seq= @company_seq
-- GROUP BY A.seq, A.card_seq, C.Company_Seq, B.Card_Name, B.CardBrand, B.CardSet_Price, B.Card_Code, A.reg_date, D.hotdeal_price,E.coupon_code, E.view_coupon_downcnt, A.sorting_num
--	, D.seq, E.seq, E.down_start_dt, E.down_end_dt, C2.Discount_Rate, C.CardDiscount_Seq, F.end_date
ORDER BY A.sorting_num ASC
GO
