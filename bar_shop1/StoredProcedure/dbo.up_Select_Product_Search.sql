USE [bar_shop1]
GO

IF OBJECT_ID (N'dbo.up_Select_Product_Search', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_Product_Search
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김광호
-- Create date: 2023-08-16
-- Description:	상품 목록 조회

-- exec up_Select_Product_Search 5003, 0, '', @listType='best', @orderBy='best', @imgSize='336', @imgSizeH='538'
-- exec up_Select_Product_Search 5001, 947, '', '', 'best'
-- =============================================
CREATE PROCEDURE [dbo].[up_Select_Product_Search]
	@CCOMSEQ		int,				-- 회사고유코드
	@mdseq			int,				-- MD전시 일련번호, null 일수 있음
	@searchText		varchar(100) = '',	-- 검색어
	@listType		varchar(10) = '',	--
	@orderBy		varchar(20) = 'best',		-- 정렬컬럼
	@orderNum		int = 200,			-- 주문수량
	@currentPage	int = 1,			-- 페이지넘버
	@pageSize		int = 30,			-- 페이지사이즈(페이지당 노출갯수)
	@imgSize		varchar(3) = '210',	-- 이미지 크기		
	@imgSizeH		varchar(3) = null,	-- 이미지 크기
	@uid			varchar(50) = null,
	@guid			varchar(50) = null,
	@jehuViewDiv	char(1) = null,		-- 제휴사 부 여부, 몰만사용
	@REALCCOMSEQ	int = null			-- 몰 제휴사 코드
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; 

	Declare @pageNum int, @nowdt smalldatetime, @totalCount int, @rk_st_seq int;
	Set @pageNum = @currentPage - 1;
	set @nowdt = GETDATE();
	Set @totalCount = 0;
	if @imgSizeH is null
	Begin
		Set @imgSizeH = @imgSize
	End
	if @REALCCOMSEQ is null
	Begin
		Set @REALCCOMSEQ = @CCOMSEQ
	End

	-- listType 분기..s2_cardkind 조건
	Declare @CardKindSeqs as table (Seq int);
	-- Custom cart 설정
	Declare @bestSelectCards as table (CardSeq int, CUSTOM_BEST_CARD_RANKING int);

	
	If @CCOMSEQ = 5001  -- 바른손 사이트
	  Begin
		If @listType in ('thanks','thank') -- 감사장
		  Begin
			Insert @CardKindSeqs values (3), (4), (5);
		  End
		Else If @listType = 'invitation' -- 초대장
		  Begin
			Insert @CardKindSeqs values (2), (6), (7); 
		  End
		Else If @listType = 'quick' -- 특급배송, 모든 카드, and h.isquick = 1 조건 추가 해야 함.
		  Begin
			Insert @CardKindSeqs values (1), (2); 
		  End
		-- 모든카드, new는 S2_CardSalesSite 의 a.isNew = 1 조건 추가 해야 함.
		Else If @listType in ('new', 'NEW_EVENT', 'isLaserCard', 'BRWE', 'BRMO', 'BRST','POST','SAMP') 
		  Begin
			Insert into @CardKindSeqs select CardKind_Seq from s2_cardkindinfo; 

			if @listType = 'new' 
			  Begin
				Insert @bestSelectCards
				Select distinct [value], row_num
				from ufn_SplitTableForRowNum(
					(SELECT  top 1 ST_CARD_CODE_ARRY
						From	S4_Ranking_Sort
						where	ST_company_seq = @CCOMSEQ
						and		ST_CODE = @listType
						Order by ST_Edate desc)
					, ','
				);
			  End
			Set @rk_st_seq = 956; 
			-- 배스트 상품 페이지
			If @listType = 'BRWE' Begin Set @rk_st_seq = 956 End
			If @listType = 'BRMO' Begin Set @rk_st_seq = 957 End
			If @listType = 'BRST' Begin Set @rk_st_seq = 958 End
			If @listType = 'POST' Begin Set @rk_st_seq = 959 End
			If @listType = 'SAMP' Begin Set @rk_st_seq = 960 End
			If @listType in ('BRWE', 'BRMO','BRST','POST','SAMP')
			  Begin
				Insert @bestSelectCards
				Select RK_Card_Code, RK_Idx
				from S4_Ranking_Sort_Table
				Where rk_st_seq = @rk_st_seq
			  End
		  End
		Else
		  Begin
			--초대장 기준으로 필터 및 정렬
			Insert @CardKindSeqs values (1), (14);
			if @mdseq > 0	 --mdseq 값이 있을 경우
			  Begin
				Insert @bestSelectCards
				Select distinct [value], row_num
				from ufn_SplitTableForRowNum(
					(SELECT  top 1 ST_CARD_CODE_ARRY
						From	S4_Ranking_Sort
						where	ST_company_seq = @CCOMSEQ
						and	ST_MD_SEQ = @mdseq
						and	ST_SDate <= @nowdt 
						and	ST_Edate >= @nowdt
						and	ST_brand = 'all'
						and	ST_Card_Code_Arry <> ''
						Order by ST_Edate desc)
					, ','
				);
			  End
			Else 
			  Begin
				Insert @bestSelectCards
				Select RK_Card_Code, RK_Idx
				from S4_Ranking_Sort_Table
				Where rk_st_seq = 947  --기본값 초대장 전체
			  End
		  End
	  End
	Else If @CCOMSEQ = 5000  -- 바른손몰 사이트
	  Begin
		If @listType in ('thanks','thank') -- 감사장
		  Begin
			Insert @CardKindSeqs values (3), (4), (5);
		  End
		Else If @listType = 'invitation' -- 초대장
		  Begin
			Insert @CardKindSeqs values (2), (6), (7); 
		  End
		Else If @listType = 'quick' -- 특급배송, 모든 카드, and h.isquick = 1 조건 추가 해야 함.
		  Begin
			Insert @CardKindSeqs values (1), (2); 
		  End
		Else If @listType in ('best','new')  --베스트, 신상품 페이지
		  Begin
			Insert @bestSelectCards
			Select CARD_SEQ, SORTING_NUM
			from S4_MD_Choice
			Where MD_SEQ = @mdseq
			Insert @CardKindSeqs values (1), (14);
		  End
		Else 
		  Begin
			Insert @CardKindSeqs values (1), (14);
		  End
	  End
	Else If @CCOMSEQ = 5003  -- 프리미엄페이퍼 사이트, 
	  Begin
		-- listtype에 따라 다른 조건이나. 동일한 Listtype이라도 정렬에따라 다른방식을 취하고 있음. 표시 조건 정리 필요함.
		If @listType in ('thanks','thank') -- 감사장
		  Begin
			Insert @CardKindSeqs values (3), (4);
		  End
		Else If @listType = 'invite' -- 초대장
		  Begin
			Insert @CardKindSeqs values (2), (6), (7); 
		  End
		Else 
		  Begin
			Insert @CardKindSeqs values (1);

			if @listType = 'new' or @listType = 'pnew'
			  Begin
				Set @rk_st_seq = 109; 
				If @mdseq > 0 
				  Begin
					Set @rk_st_seq = @mdseq
				  End
				Insert @bestSelectCards
				Select RK_Card_Code, RK_Idx
				from S4_Ranking_Sort_Table
				Where rk_st_seq = @rk_st_seq  
			  End
			Else if @listType = 'best' -- 관리페이지 md 설정, 베스트(288)
				  Begin
					Insert @bestSelectCards
					Select distinct [value], row_num
					from ufn_SplitTableForRowNum(
						(SELECT  top 1 ST_CARD_CODE_ARRY
							From	S4_Ranking_Sort
							where	ST_company_seq = @CCOMSEQ
							and		ST_tabgubun = 'PBST'
							Order by ST_Edate desc)
						, ','
					);
				  End
			Else if @listType = 'mbest' -- 관리페이지 md 설정, 청첩장(303)
				  Begin
					Insert @bestSelectCards
					Select distinct [value], row_num
					from ufn_SplitTableForRowNum(
						(SELECT  top 1 ST_CARD_CODE_ARRY
							From	S4_Ranking_Sort
							where	ST_company_seq = @CCOMSEQ
							and		ST_tabgubun = 'WCAL'
							and		ST_brand = 'N'
							Order by ST_Edate desc)
						, ','
					);
				  End

			Else if @listType = 'all' --전체 카드표시: 베스트,신규는 mdseq가 있고, 고가,저가는 없음.
			  Begin
				if @mdseq > 0
				  Begin
					Insert @bestSelectCards
					Select RK_Card_Code, RK_Idx
					from S4_Ranking_Sort_Table
					Where rk_st_seq = @mdseq 
				  End
			  End
			Else
			  Begin
				if @mdseq > 0
				  Begin
					Insert	@bestSelectCards
					Select	CARD_SEQ, SORTING_NUM
					from	S4_MD_Choice
					Where	MD_SEQ = @mdseq
					And		VIEW_DIV = 'Y'
				  End
			  End
		  End
	  End
	Else -- 그외는 모두 초대장 기준으로 필터 및 정렬
	  Begin
		Insert @CardKindSeqs values (1), (14);
	  End

	-- 표시할 카드 ID 임시 저장 테이블
	Declare @SelectedCards as table (CardSeq int, CUSTOM_BEST_CARD_RANKING int);
	If (Select Count(*) From @bestSelectCards) > 0
	  Begin
		insert @SelectedCards
		Select a.card_seq, isnull(temptb.CUSTOM_BEST_CARD_RANKING, 999) as [CUSTOM_BEST_CARD_RANKING]
		From @bestSelectCards as temptb
			inner join S2_CardSalesSite as a on temptb.CardSeq = a.card_seq 
			inner join s2_card b on a.card_seq=b.card_seq
			inner join s2_cardoption h on a.card_seq=h.card_seq
		Where	a.Company_Seq = @CCOMSEQ 
		And		a.IsDisplay = '1'
		And		(
					(@searchText <> '' And (b.card_code like '%' + @searchText + '%' or b.card_name like '%' + @searchText + '%')) Or
					(@searchText = '' And a.card_seq in (select distinct card_seq from s2_cardkind d  where d.cardkind_seq in (select Seq from @CardKindSeqs))) 
				)
		And		(h.isFSC = '1' or @listType <> 'fsc')
		And		(h.IsQuick = '1' or @listType <> 'quick')
		And		(a.isNew = '1' or @listType <> 'new')
		And		(@jehuViewDiv is null or a.IsJehyu <> '1')
	  End
	Else
	  Begin
		insert @SelectedCards
		Select a.card_seq, IsNull(a.Ranking_m, 999) as [CUSTOM_BEST_CARD_RANKING]
		From S2_CardSalesSite as a 
			inner join s2_card b on a.card_seq=b.card_seq
			inner join s2_cardoption h on a.card_seq=h.card_seq
		Where	a.Company_Seq = @CCOMSEQ 
		And		a.IsDisplay = '1'
		And		(
					(@searchText <> '' And (b.card_code like '%' + @searchText + '%' or b.card_name like '%' + @searchText + '%')) Or
					(@searchText = '' And a.card_seq in (select distinct card_seq from s2_cardkind d  where d.cardkind_seq in (select Seq from @CardKindSeqs))) 
				)
		And		(h.isFSC = '1' or @listType <> 'fsc')
		And		(h.IsQuick = '1' or @listType <> 'quick')
		And		(a.isNew = '1' or @listType <> 'new')
		And		(@jehuViewDiv is null or a.IsJehyu <> '1')
	  End

	-- 총 상품 수
	Select @totalCount = Count(*) From @SelectedCards;
	
	-- UID or GUID 변수가 있으면 Sample 장바구니 담겨있는지 확인
	Declare @IsBasket as Table (CardSeq int, Has int)
	If @uid is not null And @uid <> ''
	Begin
		Insert	@IsBasket
		Select	distinct sb.card_seq, 1
		From	S2_SampleBasket as sb
		Where	sb.[uid] = @uid
		And		sb.company_seq = @REALCCOMSEQ
	End
	Else If @guid is not null And @guid <> ''
	Begin
		Insert	@IsBasket
		Select	distinct sb.card_seq, 1
		From	S2_SampleBasket as sb
		Where	sb.[uid] = ''
		And		sb.[GUID] = @guid
		And		sb.company_seq = @REALCCOMSEQ
	End
	-- UID 가 있으면 wishcard 확인
	Declare @IsWishCard as Table (CardSeq int, Has int)
	IF @uid is not null and  @uid <> ''
	  Begin
		Insert	@IsWishCard
		Select	distinct ws.card_seq, 1
		From	S2_WishCard as ws
		Where	ws.[uid] = @uid
		And		ws.company_seq = @REALCCOMSEQ
	  End


	-- 상품 목록, 페이징 됨
	Select  a.company_seq, a.card_seq, a.isbest, a.isnew,a.issale, a.isextra, a.isSSPre, a.IsInProduct
			, ISNULL(a.isBgcolor, '') AS isBgcolor, a.ranking_w, a.ranking_m, a.SampRankNo
			, b.card_code, b.cardbrand, b.card_name, b.cardset_price, b.regdate
			, c.card_content, c.minimum_count, isnull(c.Sticker_GroupSeq, 0) as Sticker_GroupSeq
			, f.carddiscount_seq, f.discount_rate, f.mincount as ordernum
			, ROUND((b.cardset_price*(100-f.discount_rate)/100),0) as cardsale_price
			, cardimage_filename = (select top 1 cardimage_filename from s2_cardimage g 
									Where g.Card_Seq = a.card_seq and g.Company_Seq = a.Company_Seq 
									and	g.cardimage_wsize =	@imgSize and g.CardImage_HSize = @imgSizeH and g.CardImage_Div = 'E'
									order by cardimage_filename)
			, h.IsUsrImg1, h.isdigitalcolor, h.digitalcolor, h.istechnic, h.issample, ISNULL(h.isFSC, '0') AS isFSC, h.isCardOptionColor
			, ISNULL(post.post_cnt, 0) as post_cnt
			, ISNULL(CARD_LIKE.LIKE_CNT, 0) AS LIKE_CNT
			, ISNULL(temptb.CUSTOM_BEST_CARD_RANKING, 999) as [CUSTOM_BEST_CARD_RANKING]
			, 1 as siteDisplay, 0 as evt_sale_card
			, r.rk_idx
			, ISNULL(basket.Has, 0) as isBasket						
			, ISNULL(wish.Has, 0) as isWish
			, isnull(c.Card_Text_Premier, '') as card_text_premier
			, @totalCount as TotalCount		
			, ISNULL(a.IsThanks, 0) isThanks
	From @SelectedCards as temptb 
		inner join S2_CardSalesSite as a on temptb.CardSeq = a.card_seq
		inner join s2_card b on a.card_seq=b.card_seq
		inner join s2_carddetail c on a.card_seq=c.card_seq
		inner join s2_carddiscount f on a.carddiscount_seq = f.carddiscount_seq
		inner join s2_cardoption h on a.card_seq=h.card_seq
		left join S4_Ranking_Sort_Table r on r.rk_Card_code = a.card_seq and r.rk_st_seq = 947 
		left join (
					Select	CardSeq, (sum(OrderReviewCount) + Case When @CCOMSEQ = 5001 Then sum(SampleReviewCount) Else Sum(RealSampleReviewCount) End) as post_cnt
					From	Custom_Order_Review_Count
					Where	CompaySeq = @CCOMSEQ
					Group By CardSeq
				  ) as post on a.card_seq = post.CardSeq  
		left join (
					select card_seq, COUNT(*) LIKE_CNT from S2_CARD_LIKE as cl where cl.company_seq = @CCOMSEQ  group by card_seq
				  ) as CARD_LIKE on a.card_seq = CARD_LIKE.card_seq  
		left join @IsBasket as basket on basket.CardSeq = a.card_seq
		left join @IsWishCard as wish on wish.CardSeq = a.card_seq
	Where a.Company_Seq = @CCOMSEQ 
	and	f.mincount = @ordernum

	order by 
		case @orderby 
			When 'best'	Then temptb.CUSTOM_BEST_CARD_RANKING
			When 'low'	Then round((b.cardset_price*(100-f.discount_rate)/100),0) 
			When 'md'	Then r.rk_idx 
			When 'rank'	Then a.Ranking_m 
		end
		,
		case @orderby 
			When 'new'	Then b.regdate 
			When 'regdate' Then b.regdate 
			When 'uc'	Then post_cnt 
			When 'high'	Then round((b.cardset_price*(100-f.discount_rate)/100),0) 
		end desc
		, b.regdate desc
	OFFSET (@pageNum*@pageSize) ROWS
	FETCH NEXT @pageSize ROWS ONLY;
END
