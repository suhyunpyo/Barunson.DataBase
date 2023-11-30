IF OBJECT_ID (N'dbo.up_select_product_list_stylecolor_search_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_product_list_stylecolor_search_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/*
	작성정보   : 조창연
	관련페이지 : product > product_list.asp
	내용	   : 상품리스트 가져오기
				 기존 up_select_product_list_stylecolor_search를 대신하여 THE CARD 전용으로 새로 만듬	 
	
	수정정보   : 
*/
-- =============================================
CREATE Procedure [dbo].[up_select_product_list_stylecolor_search_new]
	-- Add the parameters for the stored procedure here
	 @company_seq			INT,
	 @ordernum				INT,
	 @page 					INT,
	 @pagesize				INT,
	 @cardkind 				NVARCHAR(20),
	 @Sequence				NVARCHAR(20),
	 @orderby				NVARCHAR(20),
	 @brand					NVARCHAR(20),
	 --@CardStyle_Site	nvarchar(10),	--(A:비핸즈, B:바른손, P:프리미어페이퍼, T:더카드)
	 @CardStyle_Category	NVARCHAR(10),			--(X:color, B:Object,etc..)
	 @CardStyle_Num			INT,
	 @search_text			NVARCHAR(100)	--검색어
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	DECLARE @sql		NVARCHAR(2000)
	DECLARE @sql2		NVARCHAR(4000)
	DECLARE @sqlorderby	NVARCHAR(1000)
	DECLARE @sqlwhere	NVARCHAR(1000)
	DECLARE @sqlstyle	NVARCHAR(1000)
    
	IF @brand <> ''
		BEGIN
			SET @sqlwhere = ' CardBrand = ''' + @brand + ''' AND '
		END
	ELSE
		BEGIN
			SET @sqlwhere = ''
		END	
	
	IF @search_text <> ''
		BEGIN
			SET @sqlwhere = @sqlwhere + ' (card_code LIKE ''%' + @search_text + '%'' OR card_name LIKE ''%' + @search_text + '%'' ) AND '
		END

	IF @CardStyle_Category <> '' 	-- 칼라, 스타일등의 값을 보여줄려면
		BEGIN
			SET @sqlstyle = ' INNER JOIN (SELECT card_seq FROM '
			SET @sqlstyle = @sqlstyle + ' S2_cardstyleitem AS A '
			SET @sqlstyle = @sqlstyle + ' LEFT OUTER JOIN S2_cardstyle AS B '
			SET @sqlstyle = @sqlstyle + ' ON '
			SET @sqlstyle = @sqlstyle + ' A.CardStyle_Seq = B.CardStyle_Seq '
			SET @sqlstyle = @sqlstyle + ' WHERE A.CardStyle_Site = ''T'' AND CardStyle_Category = ''' + @CardStyle_Category + ''' ) AS J ON B.card_seq = J.card_seq '
		END
	
	IF @CardStyle_Category <> '' AND @CardStyle_Num <> ''	-- 칼라, 스타일등의 값을 보여줄려면
		BEGIN
			SET @sqlstyle = ' INNER JOIN (SELECT card_seq FROM '
			SET @sqlstyle = @sqlstyle + ' S2_cardstyleitem AS A '
			SET @sqlstyle = @sqlstyle + ' LEFT OUTER JOIN S2_cardstyle AS B '
			SET @sqlstyle = @sqlstyle + ' ON '
			SET @sqlstyle = @sqlstyle + ' A.CardStyle_Seq = B.CardStyle_Seq '
			SET @sqlstyle = @sqlstyle + ' WHERE A.CardStyle_Site = ''T'' AND CardStyle_Category = ''' + @CardStyle_Category + ''' AND CardStyle_Num = ' + convert(varchar, @CardStyle_Num) + ') AS J ON B.card_seq = J.card_seq '
		END	
	ELSE
		BEGIN
			SET @sqlstyle = ''
		END

	SET @sqlorderby = ''
	IF @orderby = 'REGDATE'
		BEGIN
			SET @sqlorderby = @sqlorderby + ' ORDER BY RegDate '
		END
	ELSE IF @orderby = 'SORT'
		BEGIN
			SET @sqlorderby = @sqlorderby + ' ORDER BY RegDate '
		END
	ELSE IF @orderby = 'PRICE'
		BEGIN
			SET @sqlorderby = @sqlorderby + ' ORDER BY (CardSet_Price * discount_rate) '
		END
	ELSE IF @orderby = 'COMMENT'	--상품평갯수
		BEGIN
			SET @sqlorderby = @sqlorderby + ' ORDER BY (SELECT COUNT(seq) FROM S2_UserComment WHERE company_seq = ' + convert(varchar(10), @company_seq) + ' AND card_seq = B.card_seq) '
		END	

	IF @Sequence = 'DESC'
		BEGIN
			SET @sqlorderby = @sqlorderby + ' DESC'
		END
	ELSE 
		BEGIN
			SET @sqlorderby = @sqlorderby + ' ASC'
		END
	
	
	SET @sql = ''
	SET @sql = @sql + 'SELECT COUNT(A.card_seq) AS tcount '
	SET @sql = @sql + 'FROM S2_cardsalessite AS A '
	SET @sql = @sql + 'INNER JOIN S2_Card AS B ON A.card_seq = B.Card_Seq '
	SET @sql = @sql + 'INNER JOIN S2_carddiscount AS D ON A.CardDiscount_Seq = D.CardDiscount_Seq '
	SET @sql = @sql + 'INNER JOIN S2_cardimage AS E ON A.card_seq = E.Card_Seq '
	SET @sql = @sql + 'INNER JOIN S2_cardoption AS H ON B.card_seq = H.card_seq '
	SET @sql = @sql + @sqlstyle
	SET @sql = @sql + 'INNER JOIN (SELECT Card_Seq '
	SET @sql = @sql + '            FROM S2_CardKind AS A '
	SET @sql = @sql + '            INNER JOIN S2_CardKindInfo AS B ON A.CardKind_Seq = B.CardKind_Seq '
	SET @sql = @sql + '            WHERE B.CardKind_Seq IN (' + @cardkind + ') '
	SET @sql = @sql + '            GROUP BY card_seq ) AS Z ON A.card_seq = Z.Card_Seq '
	SET @sql = @sql + 'WHERE '
	SET @sql = @sql + @sqlwhere
	SET @sql = @sql + '      A.Company_Seq = ' + convert(varchar(10), @company_seq) 
	SET @sql = @sql + '  AND D.MinCount = ' + convert(varchar(10), @ordernum)
	SET @sql = @sql + '  AND E.CardImage_WSize = ''210'' '
	SET @sql = @sql + '  AND E.CardImage_HSize = ''210'' '
	SET @sql = @sql + '  AND E.cardimage_div = ''E'' '
	SET @sql = @sql + '  AND A.IsDisplay = ''1'' '
	SET @sql = @sql + '  AND E.Company_Seq = ' + convert(varchar(10), @company_seq)

	EXEC (@sql)
	
	
	SET @sql2 = ''
	SET @sql2 = @sql2 + 'SELECT * '
	SET @sql2 = @sql2 + 'FROM '
	SET @sql2 = @sql2 + '( '
	SET @sql2 = @sql2 + 'SELECT  ROW_NUMBER() OVER (' + @sqlorderby +') AS RowNum '
	SET @sql2 = @sql2 + '		,B.card_name '
	SET @sql2 = @sql2 + '		,B.card_code '
	SET @sql2 = @sql2 + '		,B.cardbrand '
	SET @sql2 = @sql2 + '		,B.cardset_price '
	SET @sql2 = @sql2 + '		,B.card_seq '
	SET @sql2 = @sql2 + '		,B.RegDate '
	SET @sql2 = @sql2 + '		,CONVERT(integer, D.discount_rate) AS discount_rate '
	SET @sql2 = @sql2 + '		,E.cardimage_filename '
	SET @sql2 = @sql2 + '		,A.CardDiscount_Seq '
	SET @sql2 = @sql2 + '		,A.company_seq '
	SET @sql2 = @sql2 + '		,H.isSample '
	SET @sql2 = @sql2 + '		,H.isNew '
	SET @sql2 = @sql2 + '		,H.isBest '
	SET @sql2 = @sql2 + '		,H.isSSPre '
	SET @sql2 = @sql2 + '       ,ISNULL(CM.cnt, 0) AS Comment_Cnt '
	--SET @sql2 = @sql2 + '		,(SELECT COUNT(seq) FROM S2_UserComment WHERE company_seq='+convert(varchar(10),@company_seq)+' AND card_seq = B.card_seq) AS Comment_cnt '
	SET @sql2 = @sql2 + '		  FROM S2_cardsalessite AS A '
	SET @sql2 = @sql2 + '		  INNER JOIN S2_Card AS B ON A.card_seq = B.Card_Seq '
	SET @sql2 = @sql2 + '		  INNER JOIN S2_carddiscount AS D ON A.CardDiscount_Seq = D.CardDiscount_Seq '
	SET @sql2 = @sql2 + '		  INNER JOIN S2_cardimage AS E ON A.card_seq = E.Card_Seq '
	SET @sql2 = @sql2 + '		  INNER JOIN S2_cardoption AS H ON B.card_seq = H.card_seq '
	SET @sql2 = @sql2 + '		  LEFT OUTER JOIN ( '
	SET @sql2 = @sql2 + '						   SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt '
	SET @sql2 = @sql2 + '						   FROM S4_Event_Review '
	SET @sql2 = @sql2 + '						   WHERE ER_Company_Seq = @company_seq '
	SET @sql2 = @sql2 + '						   GROUP BY ER_Card_Seq '
	SET @sql2 = @sql2 + '					      ) CM ON B.Card_Seq = CM.Card_Seq '
	SET @sql2 = @sql2 + @sqlstyle
	SET @sql2 = @sql2 + '		  INNER JOIN (SELECT Card_Seq '
	SET @sql2 = @sql2 + '					  FROM S2_CardKind AS A '
	SET @sql2 = @sql2 + '					  INNER JOIN S2_CardKindInfo AS B ON A.CardKind_Seq = B.CardKind_Seq '
	SET @sql2 = @sql2 + '					  WHERE B.CardKind_Seq IN (' + @cardkind + ') '
	SET @sql2 = @sql2 + '					  GROUP BY card_seq) AS Z ON A.card_seq = Z.Card_Seq '
	SET @sql2 = @sql2 + 'WHERE '
	SET @sql2 = @sql2 + @sqlwhere
	SET @sql2 = @sql2 + '      A.Company_Seq = ' + convert(varchar(10), @company_seq)
	SET @sql2 = @sql2 + '  AND D.MinCount = ' + convert(varchar(10), @ordernum)
	SET @sql2 = @sql2 + '  AND E.CardImage_WSize = ''210'' '
	SET @sql2 = @sql2 + '  AND E.CardImage_HSize = ''210'' '
	SET @sql2 = @sql2 + '  AND E.cardimage_div = ''E'' '
	SET @sql2 = @sql2 + '  AND A.IsDisplay = ''1'' '
	SET @sql2 = @sql2 + '  AND E.Company_Seq = ' + convert(varchar(10), @company_seq)
	SET @sql2 = @sql2 + ') AS RESULT '
	SET @sql2 = @sql2 + 'WHERE RowNum BETWEEN ( ( (' + convert(varchar(10), @page) + ' - 1) * ' + convert(varchar(10), @pagesize) + ' ) + 1 ) AND ( ' + convert(varchar(10), @page) + ' * ' + convert(varchar(10), @pagesize) + ' ) '
	
	EXEC (@sql2)		 
		 
END
GO
