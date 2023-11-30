IF OBJECT_ID (N'dbo.up_select_product_list_stylecolor_search_boton', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_stylecolor_search_boton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
/*
	작성정보   : 김덕중
	관련페이지 : product > product_list.asp
	내용	   : 보통데이즈 상품검색
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_product_list_stylecolor_search_boton]
	-- Add the parameters for the stored procedure here
 @company_seq AS int,
 @ordernum AS int,
 @page AS	int,
 @pagesize AS int,
 @cardkind AS	nvarchar(20),
 @Sequence AS nvarchar(20),
 @orderby AS nvarchar(20),
 @brand	nvarchar(20),
 @CardStyle_Site	nvarchar(10),	--(A:비핸즈, B:바른손, P:프리미어페이퍼, T:더카드)
 @CardStyle_Category	nvarchar(10),			--(X:color, B:Object,etc..)
 @CardStyle_Num	int,
 @search_text	nvarchar(100)	--검색어
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @sql	nvarchar(2000)
	DECLARE @sql2	nvarchar(4000)
	DECLARE @sqlorderby	nvarchar(1000)
	DECLARE @sqlwhere	nvarchar(1000)
	DECLARE @sqlstyle	nvarchar(1000)
    
	if @brand <> ''
		begin
			set @sqlwhere = ' CardBrand='''+@brand+''' and '
		end
	else
		begin
			set @sqlwhere = ''
		end	
	
	if @search_text <> ''
		begin
			set @sqlwhere = @sqlwhere + ' (card_code like ''%'+@search_text+'%'' or card_name like ''%'+@search_text+'%'' ) and '
		end

	if @CardStyle_Category <> '' 	-- 칼라, 스타일등의 값을 보여줄려면
		begin
			set @sqlstyle = ' join (select card_seq from '
			set @sqlstyle = @sqlstyle + ' s2_cardstyleitem AS A '
			set @sqlstyle = @sqlstyle + ' left outer join s2_cardstyle AS B '
			set @sqlstyle = @sqlstyle + ' on '
			set @sqlstyle = @sqlstyle + ' A.CardStyle_Seq = B.CardStyle_Seq '
			set @sqlstyle = @sqlstyle + ' where A.CardStyle_Site='''+@CardStyle_Site+''' and CardStyle_Category='''+@CardStyle_Category+''' ) AS J on B.card_seq = J.card_seq '
		end
	if @CardStyle_Category <> '' and @CardStyle_Num <> ''	-- 칼라, 스타일등의 값을 보여줄려면
		begin
			set @sqlstyle = ' join (select card_seq from '
			set @sqlstyle = @sqlstyle + ' s2_cardstyleitem AS A '
			set @sqlstyle = @sqlstyle + ' left outer join s2_cardstyle AS B '
			set @sqlstyle = @sqlstyle + ' on '
			set @sqlstyle = @sqlstyle + ' A.CardStyle_Seq = B.CardStyle_Seq '
			set @sqlstyle = @sqlstyle + ' where A.CardStyle_Site='''+@CardStyle_Site+''' and CardStyle_Category='''+@CardStyle_Category+''' and CardStyle_Num='+convert(varchar,@CardStyle_Num)+') AS J on B.card_seq = J.card_seq '
		end	
	else
		begin
			set @sqlstyle = ''
		end

	set @sqlorderby = ''
	if @orderby = 'REGDATE'
		begin
			set @sqlorderby = @sqlorderby + ' order by RegDate '
		end
	else if @orderby = 'SORT'
		begin
			set @sqlorderby = @sqlorderby + ' order by RegDate '
		end
	else if @orderby = 'DC'
		begin
			set @sqlorderby = @sqlorderby + ' order by discount_rate '
		end
	else if @orderby = 'PRICE'
		begin
			set @sqlorderby = @sqlorderby + ' order by cardset_price '
		end
	else if @orderby = 'COMMENT'	--상품평갯수
		begin
			set @sqlorderby = @sqlorderby + ' order by  (select count(seq) from S2_UserComment where company_seq='+convert(varchar(10),@company_seq)+' and card_seq=B.card_seq) '
		end	

	if @Sequence = 'DESC'
		begin
			set @sqlorderby = @sqlorderby + ' DESC'
		end
	else 
		begin
			set @sqlorderby = @sqlorderby + ' ASC'
		end
	
	set @sql = 'select COUNT(A.card_seq) AS tcount from s2_cardsalessite AS A with(nolock) '
	set @sql = @sql + '	 join S2_Card AS B	with(nolock) on A.card_seq = B.Card_Seq '
	set @sql = @sql + '	join s2_carddiscount AS D with(nolock) on A.CardDiscount_Seq = D.CardDiscount_Seq '
	set @sql = @sql + '	join s2_cardoption AS H on B.card_seq=H.card_seq '
	set @sql = @sql + @sqlstyle
	set @sql = @sql + '	join '
	set @sql = @sql + '(select Card_Seq from S2_CardKind AS A with(nolock) '
	set @sql = @sql + ' join S2_CardKindInfo AS B on A.CardKind_Seq = B.CardKind_Seq '
	set @sql = @sql + ' where '
	set @sql = @sql + ' B.CardKind_Seq in ('+@cardkind+') '
	set @sql = @sql + ' group by card_seq ) AS Z '
	set @sql = @sql + ' on A.card_seq = Z.Card_Seq '
	set @sql = @sql + ' where '
	set @sql = @sql + @sqlwhere
	set @sql = @sql + ' A.Company_Seq='+convert(varchar(10),@company_seq)+' and D.MinCount='+convert(varchar(10), @ordernum)+'  and '
	set @sql = @sql + '	A.IsDisplay=''1''  '

	exec (@sql)

	set @sql2 =  'select top '+CONVERT(VARCHAR(50),@pagesize)+'  B.card_name, B.card_code, B.cardbrand, B.cardset_price, B.card_seq, B.RegDate, '
	set @sql2 = @sql2 + '	convert(integer, d.discount_rate) AS discount_rate , A.CardDiscount_Seq, A.company_seq, isSample, isNew, isBest, isSSPre,  '
	set @sql2 = @sql2 + '	(select count(seq) from S2_UserComment where company_seq='+convert(varchar(10),@company_seq)+' and card_seq=B.card_seq) AS Comment_cnt '
	set @sql2 = @sql2 + '	 from s2_cardsalessite AS A with(nolock)  '
	set @sql2 = @sql2 + '	 join S2_Card AS B	with(nolock) on A.card_seq = B.Card_Seq  '
	set @sql2 = @sql2 + '	join s2_carddiscount AS D with(nolock) on A.CardDiscount_Seq = D.CardDiscount_Seq '
	set @sql2 = @sql2 + '	join s2_cardoption AS H on B.card_seq=H.card_seq  '
	set @sql2 = @sql2 + @sqlstyle
	set @sql2 = @sql2 + '	join '
	set @sql2 = @sql2 + '(select Card_Seq from S2_CardKind AS A with(nolock)  '
	set @sql2 = @sql2 + 'join S2_CardKindInfo AS B on A.CardKind_Seq = B.CardKind_Seq  '
	set @sql2 = @sql2 + 'where  '
	set @sql2 = @sql2 + 'B.CardKind_Seq in ('+@cardkind+') '
	set @sql2 = @sql2 + 'group by card_seq ) AS Z '
	set @sql2 = @sql2 + 'on A.card_seq = Z.Card_Seq  '
	set @sql2 = @sql2 + 'where '
	set @sql2 = @sql2 + @sqlwhere
	set @sql2 = @sql2 + ' A.Company_Seq='+convert(varchar(10),@company_seq)+' and D.MinCount='+convert(varchar(10), @ordernum)+' '
	set @sql2 = @sql2 + ' and '
	set @sql2 = @sql2 + '	A.IsDisplay=''1'' '
	set @sql2 = @sql2 + ' and B.card_seq not in (select top '+ CONVERT(VARCHAR(50), @PageSize * (@Page - 1)) +' B.card_seq '
	set @sql2 = @sql2 + '	 from s2_cardsalessite AS A with(nolock) '
	set @sql2 = @sql2 + '	 join S2_Card AS B	with(nolock) on A.card_seq = B.Card_Seq '
	set @sql2 = @sql2 + '	join s2_carddiscount AS D with(nolock) on A.CardDiscount_Seq = D.CardDiscount_Seq '
	set @sql2 = @sql2 + '	join s2_cardoption AS H on B.card_seq=H.card_seq '
	set @sql2 = @sql2 + @sqlstyle
	set @sql2 = @sql2 + '	join '
	set @sql2 = @sql2 + '(select Card_Seq from S2_CardKind AS A with(nolock) '
	set @sql2 = @sql2 + 'join S2_CardKindInfo AS B on A.CardKind_Seq = B.CardKind_Seq '
	set @sql2 = @sql2 + 'where '
	set @sql2 = @sql2 + 'B.CardKind_Seq in ('+@cardkind+') '
	set @sql2 = @sql2 + 'group by card_seq ) AS Z '
	set @sql2 = @sql2 + 'on A.card_seq = Z.Card_Seq '
	set @sql2 = @sql2 + 'where '
	set @sql2 = @sql2 + @sqlwhere
	set @sql2 = @sql2 + ' A.Company_Seq='+convert(varchar(10),@company_seq)+' and D.MinCount='+convert(varchar(10), @ordernum)+' '
	set @sql2 = @sql2 + '  and A.IsDisplay=''1''  '
	set @sql2 = @sql2 + @sqlorderby	
	set @sql2 = @sql2 + ' )'
	set @sql2 = @sql2 + @sqlorderby		

	exec (@sql2)		 
		 
END
GO
