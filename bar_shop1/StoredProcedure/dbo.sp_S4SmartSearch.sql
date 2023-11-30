IF OBJECT_ID (N'dbo.sp_S4SmartSearch', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S4SmartSearch
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[sp_S4SmartSearch]
@pIsList	varchar(1),	--pagesize인지 list인지 구분
@pListType  varchar(10), --합리적 가격 검색
@pOrderNum	int,		--주문수량
@pOrderBy	varchar(5),	--정렬순서
--@pGubun		varchar(2),	--정렬구분
@pCompany	varchar(4),		--컴패니코드
@pBrandB	varchar(1),		--브랜드 바른손
@pBrandW	varchar(1),		--브랜드 위시메이드
@pBrandH	varchar(1),		--브랜드 해피카드
@pBrandA	varchar(1),		--브랜드 티아라카드

@pPrice1	varchar(10),	--가격대 (200down)
@pPrice2	varchar(10),	--가격대 (200_400)
@pPrice3	varchar(10),	--가격대 (400_600)
@pPrice4	varchar(10),	--가격대 (600_800)
@pPrice5	varchar(10),	--가격대 (800_1000)
@pPrice6	varchar(10),	--가격대 (1000_1200)
@pPrice7	varchar(10),	--가격대 (1200up)

@pStyleColor varchar(100),--스타일 - 칼라,
@pStylePoint varchar(100),--스타일 - 포인트,
@pStyleTheme varchar(100),--스타일 - 테마,
@pStylePrint varchar(100),--스타일 - 프린트,
--@pItem		varchar(30),--디자인 
--@pColor		varchar(30),--디자인 
--@pPrint		varchar(30),--디자인

@pStatus1	varchar(4),	--카드 상태별 (new)
@pStatus2	varchar(4),	--카드 상태별 (best)
@pStatus3	varchar(4),	--카드 상태별 (sale)

@pFolding	varchar(50),	--카드 접이방식 (한번 접기)
--@pFolding2	varchar(3),	--카드 접이방식 (두번 접기)
--@pFolding3	varchar(3),	--카드 접이방식 (세번 이상 접기)
--@pFolding4	varchar(3),	--카드 접이방식 (접이 없음)

@pShape1	varchar(1),	--카드 접었을때 형태 (정사각형)
@pShape2	varchar(1),	--카드 접었을때 형태 (가로 직사각형)
@pShape3	varchar(1),	--카드 접었을때 형태 (세로 직사각형)

@pPageSize	int,		--한 페이지 사이즈							
@pPage		int,		--현제 페이지
@pImgSizeW	int,		--이미지 사이즈 W
@pImgSizeH	int,		--이미지 사이즈 H
@pSearchValue varchar(10)
AS
SET NOCOUNT ON
DECLARE 
	@SQL		varchar(5000),
	@TempStr	varchar(100),
	@Brand		varchar(100),
	@OrderBy	varchar(100),
	@Price		varchar(1000),
	@OrStr		varchar(3),
	@Status		varchar(300),
	@Folding	varchar(300),
	@Shape		varchar(300),
	@Quick		varchar(300),
	@CardKind   varchar(30)

IF @pCompany = ''
BEGIN
	SET @pCompany = '5007'
END

SET @CardKind = '1'
IF @pSearchValue != ''
BEGIN
	SET @CardKind = '1,2,3,4,5,6,7'
END

SET @Brand = ''
IF @pBrandB != '' or @pBrandW != '' or @pBrandH != '' or @pBrandA != ''
BEGIN
	SET @OrStr = ''
	SET @TempStr = ''
	IF @pBrandB = 'B'
	BEGIN
		SET @TempStr = @TempStr + @OrStr + ' b.cardbrand = ''B'' '
		SET	@OrStr = ' or '
	END
	IF @pBrandW = 'W'
	BEGIN
		SET @TempStr = @TempStr + @OrStr + ' b.cardbrand = ''W'' '
		SET	@OrStr = ' or '
	END
	IF @pBrandH = 'H'
	BEGIN
		SET @TempStr = @TempStr + @OrStr + ' b.cardbrand = ''H'' '
		SET	@OrStr = ' or '
	END
	IF @pBrandA = 'A'
	BEGIN
		SET @TempStr = @TempStr + @OrStr + ' b.cardbrand = ''A'' '
		SET	@OrStr = ' or '
	END
	SET @Brand = ' and (' + @TempStr + ') '
END

-- ### START : 가격별
SET @Price = ''
IF @pPrice1 != '' or @pPrice2 != '' or @pPrice3 != '' or @pPrice4 != '' or @pPrice5 != '' or @pPrice6 != '' or @pPrice7 != ''
BEGIN

	SET @OrStr = ''
	SET @TempStr = ' round((b.cardset_price*(100-f.discount_rate)/100),0) '
	
	IF @pPrice1 = '200down'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' < 200 ) '
		SET	@OrStr = ' or '
	END
	
	IF @pPrice2 = '200_400'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 200 and ' + @TempStr + ' < 400 ) '
		SET @OrStr = ' or '
	END
	
	IF @pPrice3 = '400_600'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 400 and ' + @TempStr + ' < 600 ) '
		SET @OrStr = ' or '
	END
	IF @pPrice4 = '600_800'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 600 and ' + @TempStr + ' < 800 ) '
		SET @OrStr = ' or '
	END
	IF @pPrice5 = '800_1000'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 800 and ' + @TempStr + ' < 1000 ) '
		SET @OrStr = ' or '
	END
	IF @pPrice6 = '1000up'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 1000 ) '
		SET @OrStr = ' or '
	END
	IF @pPrice7 = '1200up'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 1200 ) '
		SET @OrStr = ' or '
	END
	
	SET @Price = ' and ( ' + @Price + ' ) '
END
-- ### END : 가격별

SET @Quick = ''
IF @pListType = 'quick'
BEGIN
	SET @Quick = ' and h.isquick = ''1'' '
END

-- ### START : 합리적 가격별
IF @pListType = 'compare01' or @pListType = 'compare02' or @pListType = 'compare03' or @pListType = 'compare04'
BEGIN
	SET @Price = ''
	SET @OrStr = ''
	SET @TempStr = ' round((b.cardset_price*(100-f.discount_rate)/100),0) '
	
	IF @pListType = 'compare01'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 200 and ' + @TempStr + ' < 301 ) '
		SET	@OrStr = ' or '
	END
	
	IF @pListType = 'compare02'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 301 and ' + @TempStr + ' < 401 ) '
		SET @OrStr = ' or '
	END
	
	IF @pListType = 'compare03'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 401 and ' + @TempStr + ' < 601 ) '
		SET @OrStr = ' or '
	END
	IF @pListType = 'compare04'
	BEGIN
		SET @Price = @Price + @OrStr + ' ( ' + @TempStr + ' >= 601 and ' + @TempStr + ' < 1501 ) '
		SET @OrStr = ' or '
	END
	
	SET @Price = ' and ( ' + @Price + ' ) '
END
-- ### END : 합리적 가격별

-- ### START : 스타일별
--IF @pStyle = ''
--BEGIN
--	SET @pStyle = '93,94,201,202,203,204,205,206,207,208,209,231,232,233,234,235,236,237,238,239,240,241,242'
--END
--SET @Style = ''
--IF @pStyle != '' or @pItem != '' or @pColor != '' or @pPrint != ''
--IF @pStyle != ''
--BEGIN
--	IF @pStyle != ''
--	BEGIN
--		SET @Style = @Style + @OrStr + ' and i.cardstyle_seq in (' + @pStyle + ')'
--	END
--	--IF @pItem != ''
--	--BEGIN
--	--	SET @Style = @Style + @OrStr + ' i.cardstyle_seq in (' + @pItem + ')'
--	--	SET @OrStr = ' or'
--	--END
--	--IF @pColor != ''
--	--BEGIN
--	--	SET @Style = @Style + @OrStr + ' i.cardstyle_seq in (' + @pColor + ')'
--	--	SET @OrStr = ' or'
--	--END
--	--IF @pPrint != ''
--	--BEGIN
--	--	SET @Style = @Style + @OrStr + ' i.cardstyle_seq in (' + @pPrint + ')'
--	--	SET @OrStr = ' or'
--	--END

--	SET @Style = ' and (' + @Style + ')'
--END
-- ### END : 스타일별

-- ### START : 카드 상태별
SET @Status = ''
--IF @pStatus1 = '' and @pStatus2 = '' and @pStatus3 = ''
--BEGIN
--	SET @Status = ' and ( a.isnew=''1'' or a.isbest=''1'' or a.issale=''1'' )' 
--END
--ELSE
IF @pStatus1 != '' or @pStatus2 != '' or @pStatus3 != ''
BEGIN
	SET @OrStr = ''
	IF @pStatus1 = 'new'
	BEGIN
		SET @Status = @Status + @OrStr + ' a.isnew=''1'''
		SET @OrStr = ' or'
	END
	IF @pStatus2 = 'best'
	BEGIN
		SET @Status = @Status + @OrStr + ' a.isbest=''1'''
		SET @OrStr = ' or'
	END
	IF @pStatus3 = 'sale'
	BEGIN
		SET @Status = @Status + @OrStr + ' a.issale=''1'''
		SET @OrStr = ' or'
	END
	
	SET @Status = ' and (' + @Status + ')'
END
-- ### END : 카드 상태별

-- ### START : 카드 접이 방식
SET @Folding = ''
IF @pFolding != '' -- or @pFolding2 != '' or @pFolding3 != '' or @pFolding4 != ''
BEGIN
	SET @Folding = 'c.card_folding in (''' + Replace(@pFolding, ',', ''',''') + ''')'
	--SET @OrStr = ''

	--IF @pFolding1 = 'GS1'
	--BEGIN
	--	SET @Folding = @Folding + @OrStr + ' c.card_folding=''G1'' or c.card_folding=''S1'''
	--	SET @OrStr = ' or'
	--END
	--IF @pFolding2 = 'GS2'
	--BEGIN
	--	SET @Folding = @Folding + @OrStr + ' c.card_folding=''G2'' or c.card_folding=''S2'''
	--	SET @OrStr = ' or'
	--END
	--IF @pFolding3 = 'GS3'
	--BEGIN
	--	SET @Folding = @Folding + @OrStr + ' c.card_folding=''G3'' or c.card_folding=''S3'' or c.card_folding=''G4'' or c.card_folding=''S4'''
	--	SET @OrStr = ' or'
	--END
	--IF @pFolding4 = '0'
	--BEGIN
	--	SET @Folding = @Folding + @OrStr + ' c.card_folding=''0'''
	--	SET @OrStr = ' or'
	--END

	SET @Folding = ' and (' + @Folding + ')'
END
-- ### END : 카드 접이 방식

-- ### START : 카드 접었을때 형태
SET @Shape = ''
IF @pShape1 != '' or @pShape2 != '' or @pShape3 != ''
BEGIN
	SET @OrStr = ''
	
	IF @pShape1 = '1'
	BEGIN
		SET @Shape = @Shape + @OrStr + ' b.card_Wsize= b.card_HSize'
		SET @OrStr = ' or'
	END
	IF @pShape2 = '2'
	BEGIN
		SET @Shape = @Shape + @OrStr + ' b.card_Wsize > b.card_HSize'
		SET @OrStr = ' or'
	END
	IF @pShape3 = '3'
	BEGIN
		SET @Shape = @Shape + @OrStr + ' b.card_Wsize < b.card_HSize'
		SET @OrStr = ' or'
	END

	SET @Shape = ' and (' + @Shape + ')'
END
-- ### END : 카드 접었을때 형태

-- ### START : 정렬 순서
SET @OrderBy = ''

IF @pOrderBy = 'week'			--주간판매순
	SET @OrderBy = ' Order By Ranking_w asc'
ELSE IF @pOrderBy = 'month' 	--월간판매순
	SET @OrderBy = ' Order By Ranking_m asc'
ELSE IF @pOrderBy = 'new' 		--신상품순
	SET @OrderBy = ' Order By RegDate Desc'
ELSE IF @pOrderBy = 'dis' 		--신상품순
	SET @OrderBy = ' Order By discount_rate Desc'
ELSE IF @pOrderBy = 'low' 		--저가순
	SET @OrderBy = ' Order By cardset_price Asc'
ELSE IF @pOrderBy = 'high' 		--고가순
	SET @OrderBy = ' Order By cardset_price Desc'
-- ### END : 정렬 순서

IF @pIsList = 'L'
Begin	
	SET @SQL = ' select * from (
				 Select ROW_NUMBER()OVER(' + @OrderBy + ') AS ROWNUM, * from ( select distinct
						a.card_seq,
						a.company_seq,
						a.isbest,
						a.isnew,
						a.issale,
						a.isextra,
						a.isjumun,
						b.cardbrand,
						b.card_code,
						b.card_name,
						a.Ranking_w,
						a.Ranking_m,
						a.Ranking,
						b.regdate,
						b.cardset_price,
						c.card_content,
						a.carddiscount_seq,
						f.discount_rate,
						g.cardimage_filename,
						h.issample,'
						+ --'j.site_name,' +
					'	round((b.cardset_price*(100-f.discount_rate)/100),0) as cardsale_price 
				   From s2_cardsalessite a join s2_card b on a.card_seq=b.card_seq 
										  join s2_carddetail c on a.card_seq=c.card_seq 
										  join s2_cardkind d on a.card_seq=d.card_seq 
										  join s2_cardkindinfo e on d.cardkind_seq=e.cardkind_seq 
										  join s2_carddiscount f on a.carddiscount_seq=f.carddiscount_seq 
										  join s2_cardimage g on a.card_seq=g.card_seq 
										  join s2_cardoption h on a.card_seq=h.card_seq '
	IF @pStyleColor != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStyleColor + ') group by card_seq ) i on a.card_seq = i.card_seq '
	END 
	IF @pStylePoint != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStylePoint + ') group by card_seq ) j on a.card_seq = j.card_seq '
	END 
	IF @pStyleTheme != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStyleTheme + ') group by card_seq ) k on a.card_seq = k.card_seq '
	END 
	IF @pStylePrint != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStylePrint + ') group by card_seq ) l on a.card_seq = l.card_seq '
	END 
					
	SET @SQL = @SQL + ' where a.isdisplay=''1'' 
				   and g.cardimage_wsize=''' + CONVERT(VARCHAR(10), @pImgSizeW) + ''' 
				   and g.cardimage_hsize=''' + CONVERT(VARCHAR(10), @pImgSizeH) + ''' 
				   and e.cardkind_seq in (' + @CardKind + ') 
				   and f.mincount=' + CONVERT(VARCHAR(10), @pOrderNum) + ' 
				   and a.company_seq = ' + @pCompany + '
				   and g.company_seq = ' + @pCompany + '
				   and b.card_code like ''%' + @pSearchValue + '%'''
	IF @pSearchValue = ''
	BEGIN	
		SET @SQL = @SQL + 'and a.card_seq not in ( select a.card_seq 
			                                 from ( select b.Card_Seq, Max(b.CardKind_Seq) CardKind_Seq 
                                                      from S2_CardSalesSite a join S2_CardKind b on a.card_seq = b.Card_Seq
                                                     where a.Company_Seq = ' + @pCompany + '
                                                     group by b.card_seq ) a 
                                            where a.CardKind_Seq = 11 ) '
    END
    SET @SQL = @SQL + @Quick + '
				   ' + @Brand + '
				   ' + @Price + '		
				   ' + @Status + '		
				   ' + @Folding + '	
				   ' + @Shape + ' ) a ) a where a.ROWNUM between ' + CONVERT(VARCHAR(10),(@pPage-1)*@pPageSize+1) + '  and ' + CONVERT(VARCHAR(10), @pPageSize * @pPage)
	EXEC (@SQL)
	SET NOCOUNT OFF
END

ELSE
BEGIN
	SET @SQL = 'Select count(*) as tot, ceiling(cast(count(*) as float)/ ' + CONVERT(VARCHAR(10), @pPageSize) + ' ) as totpage 
				  From ( select distinct a.card_seq 
				           from s2_cardsalessite a 
				                join s2_card b on a.card_seq=b.card_seq 
								join s2_carddetail c on a.card_seq=c.card_seq 
								join s2_cardkind d on a.card_seq=d.card_seq 
								join s2_cardkindinfo e on d.cardkind_seq=e.cardkind_seq 
								join s2_carddiscount f on a.carddiscount_seq=f.carddiscount_seq 
								join s2_cardimage g on a.card_seq=g.card_seq 
								join s2_cardoption h on a.card_seq=h.card_seq '
	IF @pStyleColor != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStyleColor + ') group by card_seq ) i on a.card_seq = i.card_seq '
	END 
	IF @pStylePoint != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStylePoint + ') group by card_seq ) j on a.card_seq = j.card_seq '
	END 
	IF @pStyleTheme != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStyleTheme + ') group by card_seq ) k on a.card_seq = k.card_seq '
	END 
	IF @pStylePrint != ''
	BEGIN
		SET @SQL = @SQL + ' join ( select card_seq from s2_cardstyle where cardstyle_seq in (' + @pStylePrint + ') group by card_seq ) l on a.card_seq = l.card_seq '
	END 
					
	SET @SQL = @SQL + 
			' where a.isdisplay=''1'' 
			   and g.cardimage_wsize=''' + CONVERT(VARCHAR(10), @pImgSizeW) + ''' 
			   and g.cardimage_hsize=''' + CONVERT(VARCHAR(10), @pImgSizeH) + ''' 
			   and e.cardkind_seq in (' + @CardKind + ') 
			   and f.mincount=' + CONVERT(VARCHAR(10), @pOrderNum) + '
			   and a.company_seq = ' + @pCompany + '
			   and g.company_seq = ' + @pCompany + '
			   and b.card_code like ''%' + @pSearchValue + '%''
			   and a.card_seq not in ( select a.card_seq 
			                             from ( select b.Card_Seq, Max(b.CardKind_Seq) CardKind_Seq 
                                                  from S2_CardSalesSite a join S2_CardKind b on a.card_seq = b.Card_Seq
                                                 where a.Company_Seq = ' + @pCompany + '
                                                 group by b.card_seq ) a 
                                        where a.CardKind_Seq = 11 )
			   ' + @Quick + '
			   ' + @Brand + '
			   ' + @Price + '		
			   ' + @Status + '		
			   ' + @Folding + '	
			   ' + @Shape + ') a'
	
	EXEC (@SQL)
END


--print  @SQL
	
GO
