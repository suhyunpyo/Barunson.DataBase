IF OBJECT_ID (N'dbo.sp_S2CardBest_List', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardBest_List
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE Proc [dbo].[sp_S2CardBest_List] 
	@company_seq	int,
	@cardbest_div	char(1),
	@order_num	int,
	@cardimage_wsize	varchar(3),
	@cardimage_hsize	varchar(3)
AS
	Select top 10 a.card_seq,a.isbest,a.isnew,a.isextra,b.card_code,b.card_name,b.cardset_price,i.card_content,c.cardkind_seq,e.discount_rate
	,f.cardimage_filename,g.issample,h.rank,h.rank_updown,rank_change
	From s2_cardsalessite a join s2_card b on a.card_seq=b.card_seq
	join s2_cardkind c on a.card_seq=c.card_seq
	join s2_cardkindinfo d on c.cardkind_seq=d.cardkind_seq
	join s2_carddiscount e on a.carddiscount_seq=e.carddiscount_seq
	join s2_cardimage f on a.card_seq=f.card_seq
	join s2_cardoption g on a.card_seq=g.card_seq
	join s2_cardrank h on a.card_seq=h.card_seq
	join s2_carddetail i on a.card_seq=i.card_seq
	Where a.company_seq=@company_seq and a.isdisplay='1' and d.cardkind_seq=1 and e.mincount=@order_num
	and f.cardimage_wsize=@cardimage_wsize and f.cardimage_hsize=@cardimage_hsize
	and h.company_seq=@company_seq and h.rank_div=@cardbest_div Order By h.rank Asc
GO
