IF OBJECT_ID (N'dbo.sp_S2CardStyle_List', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardStyle_List
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE Proc [dbo].[sp_S2CardStyle_List] 
	@company_seq	int,
	@cardstyle_seq	int,
	@order_num	int,
	@cardimage_wsize	varchar(3),
	@cardimage_hsize	varchar(3)
AS
	Select top 5 a.card_seq,a.isbest,a.isnew,a.isextra,b.card_code,b.card_name,b.cardset_price,c.card_content,d.cardkind_seq,f.discount_rate,g.cardimage_filename,h.issample
	From s2_cardsalessite a join s2_card b on a.card_seq=b.card_seq
	join s2_carddetail c on a.card_seq=c.card_seq
	join s2_cardkind d on a.card_seq=d.card_seq
	join s2_cardkindinfo e on d.cardkind_seq=e.cardkind_seq
	join s2_carddiscount f on a.carddiscount_seq = f.carddiscount_seq
	join s2_cardimage g on a.card_seq=g.card_seq
	join s2_cardoption h on a.card_seq=h.card_seq
	join s2_cardstyle i on a.card_seq=i.card_seq
	join s2_cardstyleitem j on i.cardstyle_seq=j.cardstyle_seq
	Where a.company_seq=@company_seq and a.isdisplay='1' and f.mincount=@order_num and e.cardkind_seq=1
	and g.cardimage_wsize=@cardimage_wsize and g.cardimage_hsize=@cardimage_hsize
	and j.cardstyle_seq=@cardstyle_seq and j.cardstyle_category='F'
	Order By a.ranking Asc
GO
