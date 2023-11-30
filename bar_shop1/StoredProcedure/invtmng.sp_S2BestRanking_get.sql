IF OBJECT_ID (N'invtmng.sp_S2BestRanking_get', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_S2BestRanking_get
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE         PROC [invtmng].[sp_S2BestRanking_get]
	@company_seq as integer,
	@gubun as char(1),
	@order_num as int
AS
	Declare @gubun_data varchar(10)
	set @gubun_data=convert(varchar(10),getdate(),21)

	select A.rank,A.card_seq,A.RankChangeGubun,A.RankChangeNo,B.card_code,B.card_name,B.CardBrand as CardBrand,B.card_price,B.card_image
	,B.CardSet_Price,D.Discount_Rate,(B.CardSet_Price*(100-D.Discount_Rate)/100) as cardsale_price
	from BestRanking_New A inner join S2_Card B on A.card_seq = B.card_seq
	join S2_CardSalesSite C on A.card_seq=C.card_seq
	join S2_CardDiscount D ON D.CardDiscount_Seq = C.CardDiscount_Seq
	where A.company_seq=@company_seq and C.company_seq=@company_seq and A.gubun=@gubun and A.gubun_data=@gubun_data
	and D.minCount=@order_num and C.isDisplay='1'  order by A.rank
GO
