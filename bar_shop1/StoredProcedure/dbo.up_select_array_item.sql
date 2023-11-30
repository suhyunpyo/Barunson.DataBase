IF OBJECT_ID (N'dbo.up_select_array_item', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_array_item
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : product > product_list.asp
	내용	   : 상품리스트(신규) 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_array_item]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@orderby nvarchar(20),		-- 정렬컬럼
	@Sequence	nvarchar(20),	-- 정렬조건(ASC, DESC)
	@ordernum	int,			-- 주문수량
	@data_arry nvarchar(4000)
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

select  count(itemvalue) 
	 from dbo.fn_SplitIn2Rows(@data_arry,',') AS A
	join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	where C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1



select  top (@pagesize)  card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate, --8
	 convert(integer, discount_rate) AS discount_rate , cardimage_filename, j.CardKind_Seq, IsNew, IsBest, isSSPre, IsSample
	, C.CardDiscount_Seq
	 from dbo.fn_SplitIn2Rows(@data_arry,',') AS A
	join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	where C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1
	
		
		-- ============ not in start =============
		and A.ItemValue not in 
		(select top (@pagesize * (@page - 1)) A.ItemValue from dbo.fn_SplitIn2Rows(@data_arry,',') AS A
		join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	where C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1 
		
		--정렬기준
		order by 
		(
		CASE @Sequence
		 WHEN 'ASC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemValue
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 ASC,
		 (
		CASE @Sequence
		 WHEN 'DESC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemValue
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 DESC
		) 
		-- ============= not in end ===============
		
		order by 
		(
		CASE @Sequence
		 WHEN 'ASC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemValue
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 ASC,
		 (
		CASE @Sequence
		 WHEN 'DESC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemValue
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 DESC
END

GO
