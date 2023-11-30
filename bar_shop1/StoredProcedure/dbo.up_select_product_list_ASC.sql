IF OBJECT_ID (N'dbo.up_select_product_list_ASC', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_ASC
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : product > product_list.asp
	내용	   : 상품리스트 가져오기
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_product_list_ASC]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,		-- 회사고유코드
	@brand AS nvarchar(20),		-- 고유브랜드(없을경우 '1'값 넘겨받으면 됨 (1의 경우 isDisplay=1)
	@md_seq int,				-- MD전시 일련번호
	@page	int,				-- 페이지넘버
	@pagesize int,				-- 페이지사이즈(페이지당 노출갯수)
	--@code	nvarchar(20),		-- 고유코드(신상품:NEW 스타일별:STYLE)
	@orderby nvarchar(20),		-- 정렬컬럼
	@Sequence	nvarchar(20),	-- 정렬조건(ASC, DESC)
	@ordernum	int,			-- 주문수량
	@imagesize  int				-- 이미지 크기			
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- total count
	select COUNT(md_seq) AS TOT from S4_MD_Choice AS A with(nolock) left outer join S2_Card AS B with(nolock) on A.card_seq = B.Card_Seq 
		join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
		where A.md_seq=@md_seq and  C.Company_Seq=@company_seq and C.IsDisplay='1'
		and
		(
			CASE @brand
			WHEN '1' THEN	IsDisplay
			ELSE B.CardBrand
			END
		) = @brand
		
	-- goods list
	select top (@pagesize) A.card_seq, B.card_code, B.card_name, C.isNew, B.cardset_price, B.card_price,
		convert(integer, discount_rate) AS discount_rate , cardimage_filename
		from S4_MD_Choice AS A
		left outer join S2_Card AS B	with(nolock) on A.card_seq = B.Card_Seq 
		join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
		join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
		join s2_cardimage AS E	with(nolock) on A.card_seq=E.Card_Seq 
		join s2_cardoption AS H on B.card_seq=H.card_seq
		join s2_cardkind AS I on C.card_seq = I.Card_Seq
		join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
		
		where A.md_seq=@md_seq and  C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize=@imagesize  and E.CardImage_HSize=@imagesize and E.cardimage_div='E' and
		C.IsDisplay='1' and E.Company_Seq=@company_seq and J.CardKind_Seq=1 and
		(
			CASE @brand
			WHEN '1' THEN	IsDisplay
			ELSE B.CardBrand
			END
		) = @brand
		
		-- ============ not in start =============
		and A.card_seq not in 
		(select top (@pagesize * (@page - 1)) C.card_seq from S4_MD_Choice
		AS C join S2_Card AS D with(nolock) on C.card_seq= D.Card_Seq 
		where C.md_seq=@md_seq and
		
		(
			CASE @brand
			WHEN '1' THEN	IsDisplay
			ELSE D.CardBrand
			END
		) = @brand
		
		--정렬기준
		order by 
		(
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN sorting_num
				WHEN 'PRICE' THEN CardSet_Price END
			)
		 ASC
		 
		) 
		-- ============= not in end ===============
		
		order by 
		(
			CASE @orderby 
				WHEN 'REGDATE' THEN RegDate
				WHEN 'SORT' THEN sorting_num
				WHEN 'PRICE' THEN CardSet_Price END
			)
		 ASC
END
GO
