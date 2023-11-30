IF OBJECT_ID (N'dbo.SP_PP_MAIN_RANKING_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_PP_MAIN_RANKING_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================================
-- Author:		엄예지
-- Create date: 2016.10.12  
-- Description:	프리미어페이퍼 메인화면 정렬방식에 따른 리스트 가져오기
-- 메인사진은 334*536만 뿌려준다
-- 제휴는 PR0001카드 보여주지 않는다.

--2017.06.14 프페리뉴얼 작업으로 인한 쿼리수정
-- gb : I-인기상품, N : 신상품 , P : Premium Quality , R : 롤링배너 , S : 이벤트배너
-- =======================================================================================
CREATE PROCEDURE [dbo].[SP_PP_MAIN_RANKING_LIST] 

	@company_seq	AS int,
	@tabgubun		AS nvarchar(20),				--PRMA:메인화면
	@brand			AS nvarchar(20),				--I : 인기상품 , N : 신상품 , H : 고가상품 , L : 저가상품 , all : 베스트셀러(/product/product_list_best.asp)
	@ordernum		AS int,
	@image_wsize	AS nvarchar(10),
	@image_hsize	AS nvarchar(10),
	@uid			AS nvarchar(16),
	@jehu_ing		AS nvarchar(1),	--제휴구분 'Y'이면 제휴

	--2017.01.16추가
	@PRD_GB			AS nvarchar(1) = '',	--해당상품 구분 M:상품 , G,E:이벤트 ==모바일때문에 추가함
	@V_PAGE			AS int = 0,
	@V_PAGESIZE		AS int = 0

AS
BEGIN
	SET NOCOUNT ON;


	declare @re_mincount int; --주문수량이 1000장 넘으면 1000으로 셋팅하기위한 변수
	DECLARE @ST INT	
	--DECLARE @JEHU_GB nvarchar(50)	
	DECLARE @strQuery NVARCHAR(MAX);
	DECLARE @parmDefinition_itm	NVARCHAR(500)	 

	if @ordernum > 1000
		set @re_mincount = 1000;
	else
		set @re_mincount = @ordernum;

	
	

	IF @brand = 'I' OR @brand = 'N' --I : 인기상품 , N : 신상품
		BEGIN
	
			select @st=ST_SEQ from S4_Ranking_Sort with(nolock)  where ST_company_seq=@company_seq and ST_tabgubun=@tabgubun and ST_brand=@brand;


			set @parmDefinition_itm = N'@IN_company_seq int ,@IN_ordernum int ,@IN_image_wsize varchar(3), @IN_image_hsize varchar(3) , @IN_uid varchar(16)  , @IN_re_mincount int  , @IN_PRD_GB varchar(1) , @IN_V_PAGE int , @IN_V_PAGESIZE int , @IN_st INT'

			SET @strQuery = N'' 

			SET @strQuery = @strQuery + 'SELECT /*인기,신상품*/ num , cnt , gb , RE_RM_NO,card_seq ,isbest	,isnew	,isextra	,card_code	,card_name	,cardset_price	,discount_rate	,cardimage_filename	,issample	,card_sale_price'+char(13) + char(10)
			SET @strQuery = @strQuery + ' 	,card_text_premier	,regdate	,isFSC ,card_price,wishcard	, sampleCnt															     '+char(13) + char(10)
			SET @strQuery = @strQuery + ' 	,title , link_url_img, link_url,  link_target, view_div, jehu_view_div, md_content ,aa , 1 CardKind_Seq ,p_cnt												     '+char(13) + char(10)
			SET @strQuery = @strQuery + ' FROM (																									     '+char(13) + char(10)
			SET @strQuery = @strQuery + '	SELECT  ROW_NUMBER()OVER(ORDER BY gb) NUM,count(*)over() cnt,*																		     '+char(13) + char(10)
			SET @strQuery = @strQuery + '	FROM (																									     '+char(13) + char(10)
			SET @strQuery = @strQuery + '		 select gb 																							     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			   ,rm RE_RM_NO																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			   ,card_seq ,isbest	,isnew	,isextra	,card_code	,card_name	,cardset_price	,discount_rate	,cardimage_filename	,issample	,card_sale_price		     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			   ,card_text_premier	,regdate	,isFSC ,card_price,Wishcard, sampleCnt															     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			   ,'''' title , '''' link_url_img, ''''link_url,  '''' link_target, '''' view_div, '''' jehu_view_div, '''' md_content ,'''' aa , 1 CardKind_Seq					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			   ,cnt p_cnt																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + '		 from (																								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '				select  CASE WHEN A.RK_ST_SEQ = 133 THEN ''N'' ELSE ''I'' END gb ,														     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					row_number()over(PARTITION BY RK_ST_SEQ order by A.RK_IDX) rm,count(*)over() cnt,											     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					card_seq,isbest, isnew, isextra,  card_code, Card_Name as card_name, cardset_price,card_content,	discount_rate, cardimage_filename,	issample,		     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					cardsale_price card_sale_price, card_text_premier, regdate,isFSC,  													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					replace( convert( VARCHAR, convert(money , (Round(cardset_price * ((100 - D.Discount_Rate) / 100) , 0)) * @IN_ordernum), 1 ), ''.00'', '''' )  card_price , Wishcard, sampleCnt	     '+char(13) + char(10)
			SET @strQuery = @strQuery + '				from S4_Ranking_Sort_Table AS A left outer join (select distinct B.Card_Seq, C.company_seq,											     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										isbest, isnew, isextra, isextra2, isjumun,											     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										cardbrand, card_code, card_name, regdate,											     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										cardset_price, card_content, c.carddiscount_seq, cardimage_filename,								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										issample, isdigitalcolor, discount_rate, mincount, 										     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										round((B.cardset_price*(100-j.discount_rate)/100),0) as cardsale_price,								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										F.card_text_premier, ISNULL(h.isFSC, ''0'') AS isFSC,c.isdisplay								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										,row_number()over(partition by b.card_seq order by G.CARDIMAGE_FILENAME ) s_rm							     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										,ISNULL((SELECT top 1  ''Y'' FROM S2_Wishcard WHERE CARD_SEQ = B.CARD_SEQ AND UID=@IN_uid and uid <> '''') , ''N'') Wishcard'+char(13) + char(10)
            SET @strQuery = @strQuery + '										,ISNULL((SELECT top 1  ''Y'' FROM s2_samplebasket WHERE COMPANY_SEQ = 5003 AND CARD_SEQ = B.CARD_SEQ AND UID=@IN_uid and uid <> '''') , ''N'') sampleCnt'+char(13) + char(10)
			SET @strQuery = @strQuery + '								 from S2_Card AS B with(nolock) 														     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										join s2_cardsalessite AS C with(nolock)  on B.Card_Seq= c.card_seq								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										join s2_cardimage AS G with(nolock)  on B.Card_Seq = g.Card_Seq									     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										join s2_carddetail AS F with(nolock)  on B.Card_Seq =  F.Card_Seq								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										join s2_cardoption AS h with(nolock)  on B.Card_Seq =  h.Card_Seq								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '										join s2_carddiscount j with(nolock)  on C.carddiscount_seq=j.carddiscount_seq							     '+char(13) + char(10)
			SET @strQuery = @strQuery + '								 where cardimage_wsize = @IN_image_wsize													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '									and cardimage_hsize = @IN_image_hsize													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '									and cardimage_div =''E'' 														     '+char(13) + char(10)
			SET @strQuery = @strQuery + '									and g.Company_Seq = @IN_company_seq													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '									and c.Company_Seq = @IN_company_seq													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '									and j.mincount = @IN_re_mincount													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '								) AS D on A.RK_Card_Code = D.Card_Seq														     '+char(13) + char(10)

			IF @tabgubun = 'PRMA'
				BEGIN
					SET @strQuery = @strQuery + '				 where A.RK_ST_SEQ IN (133 , 134)																		     '+char(13) + char(10)
				END
			ELSE
				BEGIN
					SET @strQuery = @strQuery + '				 where A.RK_ST_SEQ = @IN_st  '+char(13) + char(10)
				END

			SET @strQuery = @strQuery + '				 AND S_RM = 1																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '				 and isdisplay = ''1''																				     '+char(13) + char(10)

			IF @jehu_ing = 'Y' 
			BEGIN
				SET @strQuery = @strQuery + ' 		and card_code <> ''PR0001''' +char(13) + char(10)
			END

			SET @strQuery = @strQuery + '			) A																							     '+char(13) + char(10)
			
			IF @tabgubun = 'PRMA'
			BEGIN
				SET @strQuery = @strQuery + '		 WHERE RM <= 10																							     '+char(13) + char(10)
			END

			SET @strQuery = @strQuery + '		 UNION ALL																							     '+char(13) + char(10)
			SET @strQuery = @strQuery + '		 select  /*이벤트 리스트*/ gb																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			,rm RE_RM_NO																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			,card_seq ,'''' isbest ,'''' isnew	, '''' isextra ,'''' card_code	,'''' card_name,0 cardset_price,0 discount_rate	,'''' cardimage_filename	,'''' issample ,0 card_sale_price    '+char(13) + char(10)
			SET @strQuery = @strQuery + '			,'''' card_text_premier,reg_date regdate,'''' isFSC ,'''' card_price,''N'' Wishcard,''N'' sampleCnt													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			,title , link_url_img,link_url,  link_target, view_div, jehu_view_div, md_content ,'''' aa, 1 CardKind_Seq										     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			,0 p_cnt																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + '		 from (																								     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			SELECT /*Premium Quality 최대10개*/ ''P'' gb, row_number()over(order by sorting_num  ) rm , 												     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					seq card_seq, sorting_num, card_text title, imgfile_path link_url_img ,link_url,  link_target, view_div, jehu_view_div, reg_date ,md_content 				     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			FROM S4_MD_Choice 																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			WHERE md_seq = 420																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			and VIEW_DIV = ''Y''																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			UNION ALL																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			SELECT /*롤링배너 최대10개*/''R'' gb, row_number()over(order by sorting_num  ) rm , 													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					seq card_seq, sorting_num, card_text title, imgfile_path link_url_img ,link_url,  link_target, view_div, jehu_view_div, reg_date ,md_content 				     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			FROM S4_MD_Choice																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			WHERE MD_SEQ = 576																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			and VIEW_DIV = ''Y''																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			UNION ALL																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			SELECT /*이벤트배너 최대4개*/''S'' gb, row_number()over(order by sorting_num  ) rm , 													     '+char(13) + char(10)
			SET @strQuery = @strQuery + '					seq card_seq, sorting_num, card_text title, imgfile_path link_url_img ,link_url,  link_target, view_div, jehu_view_div, reg_date ,md_content 				     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			FROM S4_MD_Choice																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			WHERE MD_SEQ = 577																					     '+char(13) + char(10)
			SET @strQuery = @strQuery + '			and VIEW_DIV = ''Y''																					     '+char(13) + char(10)

			IF @jehu_ing = 'Y' 
			BEGIN
				SET @strQuery = @strQuery + ' AND jehu_view_div = ''Y''' +char(13) + char(10) 
			END


			SET @strQuery = @strQuery + '		      ) a 																							     '+char(13) + char(10)
			SET @strQuery = @strQuery + '		 where rm <= 10 																						     '+char(13) + char(10)
			SET @strQuery = @strQuery + ' 	) A'+char(13) + char(10)

			IF @PRD_GB <> '' 
				IF @PRD_GB = 'M'
					BEGIN
						SET @strQuery = @strQuery + ' 	WHERE GB IN (''N'',''I'')' +char(13) + char(10)
					END
				ELSE
					BEGIN
						SET @strQuery = @strQuery + ' 	WHERE GB = @IN_PRD_GB' +char(13) + char(10)
					END


			SET @strQuery = @strQuery + ' ) A'+char(13) + char(10)

			IF @V_PAGE > 0 --페이징
			BEGIN
				SET @strQuery = @strQuery + 'WHERE num > ( @IN_V_PAGE -1 ) * @IN_V_PAGESIZE  and num <=  ( @IN_V_PAGE  * @IN_V_PAGESIZE )'
			END 


			PRINT CAST(@strQuery AS TEXT)
			exec sp_executesql @strQuery  ,@parmDefinition_itm, @company_seq ,@ordernum ,@image_wsize , @image_hsize , @uid , @re_mincount , @PRD_GB , @V_PAGE , @V_PAGESIZE ,@st
	

			

		END


	else IF  @brand = 'all' --all : 베스트셀러
		BEGIN
	
			select @st=ST_SEQ from S4_Ranking_Sort with(nolock)  where ST_company_seq=@company_seq and ST_tabgubun=@tabgubun and ST_brand=@brand;

			set @parmDefinition_itm = N'@IN_company_seq int ,@IN_ordernum int ,@IN_image_wsize varchar(3), @IN_image_hsize varchar(3) , @IN_uid varchar(16)  , @IN_re_mincount int , @IN_st INT , @IN_V_PAGE int , @IN_V_PAGESIZE int'

			SET @strQuery = N''


			SET @strQuery = @strQuery + 'select rm , cnt ,card_seq,isbest, isnew, isextra,  card_code,card_name , cardset_price,isnull(card_content,'''') AS card_content '+char(13) + char(10)
			SET @strQuery = @strQuery + '		,	discount_rate, cardimage_filename,	issample,  '+char(13) + char(10)
			SET @strQuery = @strQuery + '	   card_sale_price, isnull(card_text_premier,'' '') AS card_text_premier , regdate,isfsc,card_price , wishcard, sampleCnt	,gb		 '+char(13) + char(10)
			SET @strQuery = @strQuery + 'from ( '+char(13) + char(10)
			SET @strQuery = @strQuery + 'SELECT  '+char(13) + char(10)
			SET @strQuery = @strQuery + '	row_number()over(order by a.rk_idx) rm,count(*)over() cnt,'+char(13) + char(10)
			SET @strQuery = @strQuery + '	card_seq,isbest, isnew, isextra,  card_code, CARD_NAME as card_name, cardset_price,card_content,	discount_rate, cardimage_filename,	issample, '+char(13) + char(10)
			SET @strQuery = @strQuery + '	cardsale_price card_sale_price, card_text_premier, regdate,isfsc,  '+char(13) + char(10)
			SET @strQuery = @strQuery + '	replace( convert( varchar, convert(money , (round(cardset_price * ((100 - d.discount_rate) / 100) , 0)) * @IN_ordernum), 1 ), ''.00'', '''' )  card_price , '+char(13) + char(10)
			--SET @strQuery = @strQuery + '	wishcard, sampleCnt,''M'' gb'+char(13) + char(10)
			SET @strQuery = @strQuery + '	ISNULL((SELECT TOP 1  ''Y'' FROM S2_WISHCARD WHERE CARD_SEQ = A.RK_CARD_CODE AND UID=@IN_uid  and uid <> '''') , ''N'') WISHCARD,'+char(13) + char(10)	
            SET @strQuery = @strQuery + '	ISNULL((SELECT top 1  ''Y'' FROM s2_samplebasket WHERE CARD_SEQ = A.RK_CARD_CODE AND COMPANY_SEQ = 5003 AND UID=@IN_uid and uid <> '''') , ''N'') sampleCnt ,'+char(13) + char(10)	
			SET @strQuery = @strQuery + '''M'' gb'+char(13) + char(10)
			SET @strQuery = @strQuery + 'FROM S4_RANKING_SORT_TABLE AS A LEFT OUTER JOIN (SELECT DISTINCT B.CARD_SEQ, C.COMPANY_SEQ,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								ISBEST, ISNEW, ISEXTRA, ISEXTRA2, ISJUMUN,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								CARDBRAND, CARD_CODE, CARD_NAME, REGDATE,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								CARDSET_PRICE, CARD_CONTENT, C.CARDDISCOUNT_SEQ, CARDIMAGE_FILENAME,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								ISSAMPLE, ISDIGITALCOLOR, DISCOUNT_RATE, MINCOUNT, '+char(13) + char(10)
			SET @strQuery = @strQuery + '								ROUND((B.CARDSET_PRICE*(100-J.DISCOUNT_RATE)/100),0) AS CARDSALE_PRICE,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								F.CARD_TEXT_PREMIER, ISNULL(H.ISFSC, ''0'') AS ISFSC,C.ISDISPLAY	'+char(13) + char(10)
			SET @strQuery = @strQuery + '								,ROW_NUMBER()OVER(PARTITION BY B.CARD_SEQ ORDER BY G.CARDIMAGE_FILENAME ) S_RM	'+char(13) + char(10)
--			SET @strQuery = @strQuery + '								,ISNULL((SELECT TOP 1  ''Y'' FROM S2_WISHCARD WHERE CARD_SEQ = B.CARD_SEQ AND UID=@IN_uid  and uid <> '''') , ''N'') WISHCARD'+char(13) + char(10)	
--            SET @strQuery = @strQuery + '								,ISNULL((SELECT top 1  ''Y'' FROM s2_samplebasket WHERE COMPANY_SEQ = 5003 AND CARD_SEQ = B.CARD_SEQ AND COMPANY_SEQ = 5003 AND UID=@IN_uid and uid <> '''') , ''N'') sampleCnt'+char(13) + char(10)	
			SET @strQuery = @strQuery + '							FROM S2_CARD AS B WITH(NOLOCK) '+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDSALESSITE AS C WITH(NOLOCK)  ON B.CARD_SEQ= C.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDIMAGE AS G WITH(NOLOCK)  ON B.CARD_SEQ = G.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDDETAIL AS F WITH(NOLOCK)  ON B.CARD_SEQ =  F.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDOPTION AS H WITH(NOLOCK)  ON B.CARD_SEQ =  H.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDDISCOUNT J WITH(NOLOCK)  ON C.CARDDISCOUNT_SEQ=J.CARDDISCOUNT_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '							WHERE CARDIMAGE_WSIZE = @IN_image_wsize'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND CARDIMAGE_HSIZE = @IN_image_hsize'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND CARDIMAGE_DIV =''E'' '+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND G.COMPANY_SEQ = @IN_company_seq'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND C.COMPANY_SEQ = @IN_company_seq'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND J.MINCOUNT = @IN_re_mincount'+char(13) + char(10)
			--SET @strQuery = @strQuery + '							AND C.ISNEW = ''1'''+char(13) + char(10)   -- NEW 체크 값만 나오도록 처리
			SET @strQuery = @strQuery + '						) AS D ON A.RK_CARD_CODE = D.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + 'WHERE A.RK_ST_SEQ=@IN_st'+char(13) + char(10)
			SET @strQuery = @strQuery + 'AND S_RM = 1'+char(13) + char(10)
			SET @strQuery = @strQuery + 'AND ISDISPLAY = ''1'''+char(13) + char(10)
			

			IF @jehu_ing = 'Y' 
			BEGIN
				SET @strQuery = @strQuery + ' 		and card_code <> ''PR0001''' +char(13) + char(10)
			END

			SET @strQuery = @strQuery + ' 	) A'+char(13) + char(10)

			--SET @strQuery = @strQuery + ' order by regdate desc'+char(13) + char(10)
			IF @V_PAGE > 0 --페이징, 등록일 순으로 나오도록 처리
			BEGIN
				SET @strQuery = @strQuery + 'WHERE rm > ( @IN_V_PAGE -1 ) * @IN_V_PAGESIZE  and rm <=  ( @IN_V_PAGE  * @IN_V_PAGESIZE ) order by regdate desc'
			END 


			PRINT @strQuery;
			exec sp_executesql @strQuery  ,@parmDefinition_itm, @company_seq ,@ordernum ,@image_wsize , @image_hsize , @uid , @re_mincount ,@st ,@V_PAGE , @V_PAGESIZE

		END

	else IF  @brand = 'all_m' --all : 베스트셀러
		BEGIN
			
			IF @brand = 'all_m'
			BEGIN
				SET @brand = 'all'
			END

			select @st=ST_SEQ from S4_Ranking_Sort with(nolock)  where ST_company_seq=@company_seq and ST_tabgubun=@tabgubun and ST_brand=@brand;

			set @parmDefinition_itm = N'@IN_company_seq int ,@IN_ordernum int ,@IN_image_wsize varchar(3), @IN_image_hsize varchar(3) , @IN_uid varchar(16)  , @IN_re_mincount int , @IN_st INT , @IN_V_PAGE int , @IN_V_PAGESIZE int'

			SET @strQuery = N''


			SET @strQuery = @strQuery + 'select rm , cnt ,card_seq,isbest, isnew, isextra,  card_code,card_name , cardset_price,isnull(card_content,'''') AS card_content '+char(13) + char(10)
			SET @strQuery = @strQuery + '		,	discount_rate, cardimage_filename,	issample,  '+char(13) + char(10)
			SET @strQuery = @strQuery + '	   card_sale_price, isnull(card_text_premier,'' '') AS card_text_premier , regdate,isfsc,card_price , wishcard, sampleCnt	,gb		 '+char(13) + char(10)
			SET @strQuery = @strQuery + 'from ( '+char(13) + char(10)
			SET @strQuery = @strQuery + 'SELECT  '+char(13) + char(10)
			SET @strQuery = @strQuery + '	row_number()over(order by a.rk_idx) rm,count(*)over() cnt,'+char(13) + char(10)
			SET @strQuery = @strQuery + '	card_seq,isbest, isnew, isextra,  card_code, CARD_NAME as card_name, cardset_price,card_content,	discount_rate, cardimage_filename,	issample, '+char(13) + char(10)
			SET @strQuery = @strQuery + '	cardsale_price card_sale_price, card_text_premier, regdate,isfsc,  '+char(13) + char(10)
			SET @strQuery = @strQuery + '	replace( convert( varchar, convert(money , (round(cardset_price * ((100 - d.discount_rate) / 100) , 0)) * @IN_ordernum), 1 ), ''.00'', '''' )  card_price , '+char(13) + char(10)
			SET @strQuery = @strQuery + '	ISNULL((SELECT TOP 1  ''Y'' FROM S2_WISHCARD WHERE CARD_SEQ = A.RK_CARD_CODE AND UID=@IN_uid  and uid <> '''') , ''N'') WISHCARD,'+char(13) + char(10)	
            SET @strQuery = @strQuery + '	ISNULL((SELECT top 1  ''Y'' FROM s2_samplebasket WHERE CARD_SEQ = A.RK_CARD_CODE AND COMPANY_SEQ = 5003 AND UID=@IN_uid and uid <> '''') , ''N'') sampleCnt,'+char(13) + char(10)	
			SET @strQuery = @strQuery + '	''M'' gb'+char(13) + char(10)
			SET @strQuery = @strQuery + 'FROM S4_RANKING_SORT_TABLE AS A LEFT OUTER JOIN (SELECT DISTINCT B.CARD_SEQ, C.COMPANY_SEQ,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								ISBEST, ISNEW, ISEXTRA, ISEXTRA2, ISJUMUN,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								CARDBRAND, CARD_CODE, CARD_NAME, REGDATE,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								CARDSET_PRICE, CARD_CONTENT, C.CARDDISCOUNT_SEQ, CARDIMAGE_FILENAME,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								ISSAMPLE, ISDIGITALCOLOR, DISCOUNT_RATE, MINCOUNT, '+char(13) + char(10)
			SET @strQuery = @strQuery + '								ROUND((B.CARDSET_PRICE*(100-J.DISCOUNT_RATE)/100),0) AS CARDSALE_PRICE,'+char(13) + char(10)
			SET @strQuery = @strQuery + '								F.CARD_TEXT_PREMIER, ISNULL(H.ISFSC, ''0'') AS ISFSC,C.ISDISPLAY	'+char(13) + char(10)
			SET @strQuery = @strQuery + '								,ROW_NUMBER()OVER(PARTITION BY B.CARD_SEQ ORDER BY G.CARDIMAGE_FILENAME ) S_RM	'+char(13) + char(10)
--			SET @strQuery = @strQuery + '								,ISNULL((SELECT TOP 1  ''Y'' FROM S2_WISHCARD WHERE CARD_SEQ = B.CARD_SEQ AND UID=@IN_uid  and uid <> '''') , ''N'') WISHCARD'+char(13) + char(10)	
--            SET @strQuery = @strQuery + '								,ISNULL((SELECT top 1  ''Y'' FROM s2_samplebasket WHERE COMPANY_SEQ = 5003 AND CARD_SEQ = B.CARD_SEQ AND COMPANY_SEQ = 5003 AND UID=@IN_uid and uid <> '''') , ''N'') sampleCnt'+char(13) + char(10)	
			SET @strQuery = @strQuery + '							FROM S2_CARD AS B WITH(NOLOCK) '+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDSALESSITE AS C WITH(NOLOCK)  ON B.CARD_SEQ= C.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDIMAGE AS G WITH(NOLOCK)  ON B.CARD_SEQ = G.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDDETAIL AS F WITH(NOLOCK)  ON B.CARD_SEQ =  F.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDOPTION AS H WITH(NOLOCK)  ON B.CARD_SEQ =  H.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '								JOIN S2_CARDDISCOUNT J WITH(NOLOCK)  ON C.CARDDISCOUNT_SEQ=J.CARDDISCOUNT_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + '							WHERE CARDIMAGE_WSIZE = @IN_image_wsize'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND CARDIMAGE_HSIZE = @IN_image_hsize'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND CARDIMAGE_DIV =''E'' '+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND G.COMPANY_SEQ = @IN_company_seq'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND C.COMPANY_SEQ = @IN_company_seq'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND J.MINCOUNT = @IN_re_mincount'+char(13) + char(10)
			SET @strQuery = @strQuery + '							AND C.ISNEW = ''1'''+char(13) + char(10)   -- NEW 체크 값만 나오도록 처리
			SET @strQuery = @strQuery + '						) AS D ON A.RK_CARD_CODE = D.CARD_SEQ'+char(13) + char(10)
			SET @strQuery = @strQuery + 'WHERE A.RK_ST_SEQ=@IN_st'+char(13) + char(10)
			SET @strQuery = @strQuery + 'AND S_RM = 1'+char(13) + char(10)
			SET @strQuery = @strQuery + 'AND ISDISPLAY = ''1'''+char(13) + char(10)
			

			IF @jehu_ing = 'Y' 
			BEGIN
				SET @strQuery = @strQuery + ' 		and card_code <> ''PR0001''' +char(13) + char(10)
			END

			SET @strQuery = @strQuery + ' 	) A'+char(13) + char(10)

			--SET @strQuery = @strQuery + ' order by regdate desc'+char(13) + char(10)
			IF @V_PAGE > 0 --페이징, 등록일 순으로 나오도록 처리
			BEGIN
				SET @strQuery = @strQuery + 'WHERE rm > ( @IN_V_PAGE -1 ) * @IN_V_PAGESIZE  and rm <=  ( @IN_V_PAGE  * @IN_V_PAGESIZE ) order by regdate desc'
			END 


			PRINT @strQuery;
			exec sp_executesql @strQuery  ,@parmDefinition_itm, @company_seq ,@ordernum ,@image_wsize , @image_hsize , @uid , @re_mincount ,@st ,@V_PAGE , @V_PAGESIZE

		END

	ELSE	--H : 고가상품 , L : 저가상품
		BEGIN
			
			

			set @parmDefinition_itm = N'@IN_company_seq int ,@IN_ordernum int ,@IN_image_wsize varchar(3), @IN_image_hsize varchar(3) , @IN_uid varchar(16)  , @IN_re_mincount int '

			SET @strQuery = N'' 

			SET @strQuery = @strQuery + ' SELECT num , cnt , gb , RE_RM_NO,card_seq ,isbest	,isnew	,isextra	,card_code	,card_name	,cardset_price	,discount_rate	,cardimage_filename	,issample	,card_sale_price' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 	,card_text_premier	,regdate	,isFSC ,card_price,wishcard, sampleCnt' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 	,title , link_url_img, link_url,  link_target, view_div, jehu_view_div, md_content ,aa ' +char(13) + char(10)
			SET @strQuery = @strQuery + ' FROM (' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 		SELECT  ROW_NUMBER()OVER(ORDER BY gb desc, RE_RM_NO) NUM,count(*)over() cnt,*' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 		FROM (' +char(13) + char(10)


			SET @strQuery = @strQuery + ' select ''M'' gb ,' +char(13) + char(10)
			SET @strQuery = @strQuery + '		case when rm > 3 THEN  ' +char(13) + char(10)
			SET @strQuery = @strQuery + '			 CASE WHEN (rm % 3) in (1,2) then (rm + (rm / 3))' +char(13) + char(10)
			SET @strQuery = @strQuery + '				  WHEN (rm % 3) = 0 then rm + ((rm / 4)) end' +char(13) + char(10)
			SET @strQuery = @strQuery + '			ELSE rm END RE_RM_NO' +char(13) + char(10)
			SET @strQuery = @strQuery + '       ,card_seq ,isbest	,isnew	,isextra	,card_code	,card_name	,cardset_price	,discount_rate	,cardimage_filename	,issample	,card_sale_price' +char(13) + char(10)
			SET @strQuery = @strQuery + '	   ,card_text_premier	,regdate	,isFSC ,card_price, Wishcard,sampleCnt' +char(13) + char(10)
			SET @strQuery = @strQuery + '	   ,'''' title , '''' link_url_img, ''''link_url,  '''' link_target, '''' view_div, '''' jehu_view_div, '''' reg_date ,'''' md_content ,'''' aa' +char(13) + char(10)
			SET @strQuery = @strQuery + '	   --,card_content	' +char(13) + char(10)
			SET @strQuery = @strQuery + ' from (' +char(13) + char(10)
			
			IF @brand = 'L'
				BEGIN
				SET @strQuery = @strQuery + ' SELECT row_number()over( order by cardset_price) rm ' +char(13) + char(10)
				END
			ELSE
				BEGIN
				SET @strQuery = @strQuery + ' SELECT row_number()over( order by cardset_price DESC) rm ' +char(13) + char(10)
				END 

			SET @strQuery = @strQuery + '				--,count(*)over() cnt' +char(13) + char(10)
			SET @strQuery = @strQuery + '				,Card_Seq ,isbest	,isnew	,isextra	,card_code	,card_name	,cardset_price	,card_content	,discount_rate	,cardimage_filename	,issample ,card_sale_price ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				,card_text_premier	,regdate	,isFSC  ,Wishcard, sampleCnt ,replace( convert( VARCHAR, convert(money , (Round(cardset_price * ((100 - discount_rate) / 100) , 0)) * @IN_ordernum), 1 ), ''.00'', '''' )  card_price' +char(13


) + char(10)
			SET @strQuery = @strQuery + '		from (' +char(13) + char(10)
			SET @strQuery = @strQuery + '				Select distinct b.Card_Seq, a.isbest, a.isnew,	a.isextra, 	b.card_code,	b.card_name, b.cardset_price, c.card_content,	f.discount_rate, ' +char(13) + char(10)
			SET @strQuery = @strQuery + '						g.cardimage_filename, 	h.issample, round((b.cardset_price*(100-f.discount_rate)/100),0) as card_sale_price, c.card_text_premier, ' +char(13) + char(10)
			SET @strQuery = @strQuery + '						b.regdate,	ISNULL(h.isFSC, ''0'') AS isFSC,	row_number()over(partition by b.card_seq order by G.CARDIMAGE_FILENAME ) s_rm,' +char(13) + char(10)
			SET @strQuery = @strQuery + '						ISNULL((SELECT top 1  ''Y'' FROM S2_Wishcard WHERE CARD_SEQ = B.CARD_SEQ AND UID=@IN_uid ) , ''N'') Wishcard,' +char(13) + char(10)
            SET @strQuery = @strQuery + '						ISNULL((SELECT top 1  ''Y'' FROM s2_samplebasket WHERE CARD_SEQ = B.CARD_SEQ AND COMPANY_SEQ = 5003 AND UID=@IN_uid and uid <> '''') , ''N'') sampleCnt' +char(13) + char(10)
			SET @strQuery = @strQuery + '				From s4_MD_choice z join s2_cardsalessite a on a.card_seq = z.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_card b on a.card_seq=b.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_carddetail c on a.card_seq=c.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_cardkind d on a.card_seq=d.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_cardkindinfo e on d.cardkind_seq=e.cardkind_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_carddiscount f on a.carddiscount_seq=f.carddiscount_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_cardimage g on a.card_seq=g.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_cardoption h on a.card_seq=h.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_cardstyle i on a.card_seq=i.card_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '									join s2_cardstyleitem j on i.cardstyle_seq=j.cardstyle_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				Where a.company_seq = @IN_company_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				and a.isdisplay = ''1'' ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				and f.mincount = @IN_re_mincount ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				and g.cardimage_wsize = @IN_image_wsize' +char(13) + char(10)
			SET @strQuery = @strQuery + '				and g.cardimage_hsize = @IN_image_hsize ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				and g.company_seq = @IN_company_seq ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				and z.view_div = ''Y'' '

			IF @jehu_ing = 'Y' 
			BEGIN
				SET @strQuery = @strQuery + ' 		and card_code <> ''PR0001''' +char(13) + char(10)
			END


			SET @strQuery = @strQuery + '			) A' +char(13) + char(10)
			SET @strQuery = @strQuery + '		WHERE S_RM = 1' +char(13) + char(10)
			SET @strQuery = @strQuery + '	)A' +char(13) + char(10)
			SET @strQuery = @strQuery + ''
			SET @strQuery = @strQuery + ' UNION ALL ' +char(13) + char(10)
			SET @strQuery = @strQuery + ''
			SET @strQuery = @strQuery + ' select   case when sorting_num = 1 then ''G''ELSE ''E'' END gb  ' +char(13) + char(10)
			SET @strQuery = @strQuery + '		--,case when rm > 1 then (rm * 4)+4 else (rm * 4) end RE_RM_NO'+char(13) + char(10)
			SET @strQuery = @strQuery + '		,(rm * 4) RE_RM_NO' +char(13) + char(10)
			SET @strQuery = @strQuery + '		,card_seq ,'''' isbest ,'''' isnew	, '''' isextra ,'''' card_code	,'''' card_name,0 cardset_price,0 discount_rate	,'''' cardimage_filename	,'''' issample ,0 card_sale_price' +char(13) + char(10)
			SET @strQuery = @strQuery + '		,'''' card_text_premier,'''' regdate	,'''' isFSC ,'''' card_price ,''N'' Wishcard, ''N'' sampleCnt' +char(13) + char(10)
			SET @strQuery = @strQuery + '		,title , link_url_img,link_url,  link_target, view_div, jehu_view_div, reg_date ,md_content ,'''' aa' +char(13) + char(10)
			SET @strQuery = @strQuery + '	   --,'''' card_content' +char(13) + char(10)
			SET @strQuery = @strQuery + ' from (' +char(13) + char(10)
			SET @strQuery = @strQuery + '		SELECT row_number()over(order by sorting_num  ) rm , ' +char(13) + char(10)
			SET @strQuery = @strQuery + '				seq card_seq, sorting_num, card_text title, imgfile_path link_url_img,link_url,  link_target, view_div, jehu_view_div, reg_date ,md_content ' +char(13) + char(10)
			SET @strQuery = @strQuery + '		FROM S4_MD_Choice ' +char(13) + char(10)
			SET @strQuery = @strQuery + '		WHERE md_seq = 420' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 		and VIEW_DIV = ''Y''' +char(13) + char(10)

			IF @jehu_ing = 'Y' 
			BEGIN
				SET @strQuery = @strQuery + ' AND jehu_view_div = ''Y''' +char(13) + char(10)
			END

			SET @strQuery = @strQuery + ' 	) a ' +char(13) + char(10)
			SET @strQuery = @strQuery + ' where rm <= 8' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 			) A' +char(13) + char(10)
			SET @strQuery = @strQuery + ' 	) A' +char(13) + char(10)



			PRINT @strQuery;
			exec sp_executesql @strQuery  ,@parmDefinition_itm, @company_seq ,@ordernum ,@image_wsize , @image_hsize , @uid , @re_mincount 


		END 


END
GO
