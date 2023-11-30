IF OBJECT_ID (N'dbo.up_select_product_list_N', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_N
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
CREATE Procedure [dbo].[up_select_product_list_N]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@brand AS nvarchar(20),		-- 고유브랜드(없을경우 '1'값 넘겨받으면 됨 (1의 경우 isDisplay=1)
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	@orderby nvarchar(20),		-- 정렬컬럼
	@Sequence	nvarchar(20),	-- 정렬조건(ASC, DESC)
	@ordernum	int,			-- 주문수량
	@imagesize  int				-- 이미지 크기			
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @data_arry nvarchar(4000)
	declare @data_arry_title nvarchar(4000)
	declare @st_code	nvarchar(10)
	
	set @st_code = 'new'

    
-- ############# @data_arry값 불러오는게 가장 중요..#################
select @data_arry=ST_Card_Code_Arry, @data_arry_title=ST_Title from S4_Ranking_Sort where ST_company_seq=@company_seq  and ST_Code=@st_code

-- ############# @data_arry에서 가져오는값 페이징 처리..#################
select COUNT(itemSEQ) from  dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',') AS A
	join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	where C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1
	and
	
	(
			CASE @brand
			WHEN '1' THEN	IsDisplay
			ELSE B.CardBrand
			END
		) = @brand
	

select  top (@pagesize) ItemSEQ, itemvalue, itemvalue2, card_name, card_code, cardbrand, cardset_price, B.card_seq, B.RegDate, --8
	brand_all, convert(integer, discount_rate) AS discount_rate , cardimage_filename, j.CardKind_Seq, IsNew, IsBest, isSSPre, IsSample
	, C.CardDiscount_Seq
	 from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',') AS A
	join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	where C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1
	and
	
	(
			CASE @brand
			WHEN '1' THEN	IsDisplay
			ELSE B.CardBrand
			END
		) = @brand
		
		-- ============ not in start =============
		and A.ItemSEQ not in 
		(select top (@pagesize * (@page - 1)) A.ItemSEQ from dbo.fn_SplitIn4Rows(@data_arry,@data_arry_title,',') AS A
		join S2_Card AS B	with(nolock) on A.itemvalue = B.Card_Seq 
	join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
	join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
	join s2_cardimage AS E	with(nolock) on A.itemvalue=E.Card_Seq 
	join s2_cardoption AS H on B.card_seq=H.card_seq
	join s2_cardkind AS I on C.card_seq = I.Card_Seq
	join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
	where C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
	C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1 and 
		
		(
			CASE @brand
			WHEN '1' THEN	C.IsDisplay
			ELSE B.CardBrand
			END
		) = @brand
		
		--정렬기준
		order by 
		(
		CASE @Sequence
		 WHEN 'ASC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemSEQ
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 ASC,
		 (
		CASE @Sequence
		 WHEN 'DESC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemSEQ
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
				WHEN 'SORT' THEN ItemSEQ
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 ASC,
		 (
		CASE @Sequence
		 WHEN 'DESC' THEN 
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN ItemSEQ
				WHEN 'PRICE' THEN CardSet_Price END
		 END	)
		 DESC
END
GO
