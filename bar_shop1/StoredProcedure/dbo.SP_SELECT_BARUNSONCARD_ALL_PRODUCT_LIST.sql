IF OBJECT_ID (N'dbo.SP_SELECT_BARUNSONCARD_ALL_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BARUNSONCARD_ALL_PRODUCT_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**
 바른손 전체청첩장 리스트
 TEST :  EXEC SP_SELECT_BARUNSONCARD_ALL_PRODUCT_LIST 5001, '', '', '', '', '0', '210', '210', 1, 10, 'BEST', 300
**/
CREATE PROCEDURE [dbo].[SP_SELECT_BARUNSONCARD_ALL_PRODUCT_LIST]  
   
	@P_COMPANY_SEQ			INT				-- 회사고유코드 ( 5001 )   
 ,	@P_BRAND				NVARCHAR(20)	-- 고유브랜드	(없을 경우 NULL 값 넘겨 받으면 됨)   
 ,	@P_SEARCH_VALUE			NVARCHAR(20)    -- 검색 ( 카드 OR 카드이름 )
 ,	@P_SEARCH_DESIGN		NVARCHAR(20)    -- 검색 ( 디자인, 스타일 )
 ,	@P_SEARCH_FOLDING		NVARCHAR(20)    -- 검색 ( 접기방식 )
 ,	@P_SEARCH_PRICE			NVARCHAR(10)	-- 검색 ( 가격 1,2,3,4,5 )
 ,	@P_CARDIMAGEWIDTH		NVARCHAR(10)	-- 가로 사이즈   
 ,	@P_CARDIMAGEHEIGHT		NVARCHAR(10)	-- 세로 사이즈
 ,	@P_PAGE_NUMBER			INT				-- 페이지 번호  
 ,	@P_PAGE_SIZE			INT				-- 페이지 사이즈(페이지당 노출 갯수)   
 ,	@P_ORDERBY				NVARCHAR(20)	-- 정렬 컬럼  
 ,	@P_ORDER_NUM			INT				-- 주문 수량   

AS  
BEGIN  
	
	------------------------------------------------------------------------------------------------------------------------------------------------------------------

	DECLARE  @BEST_CARD_CNT			AS  INT	 = 0;		   
	DECLARE  @BEST_CARD_LIST		AS  NVARCHAR(4000) = '';

	--주문수량이 1000장초과일때
	IF @P_ORDER_NUM > 1000
		BEGIN
			SET @P_ORDER_NUM = 1000;
		END
	ELSE
		BEGIN
			SET @P_ORDER_NUM = @P_ORDER_NUM;
		END

	SET @P_ORDERBY = UPPER(@P_ORDERBY);

	------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--BEST 일경우 S4_RANKING_SORT 테이블에서 가져온다.
	--청첩장>전체상품에서 사용함. ==>사용안하고있는듯함. 다른페이지 확인필요
    IF	@P_ORDERBY = 'BEST'
		BEGIN
			SELECT  @BEST_CARD_CNT = ISNULL(COUNT(ST_SEQ), 0)
				,   @BEST_CARD_LIST = ISNULL(MAX(ST_CARD_CODE_ARRY), '')
			FROM    S4_RANKING_SORT WITH(NOLOCK)                            
			WHERE   1 = 1                                                   
			AND     ST_COMPANY_SEQ = 5001                                   
			AND     ST_CARD_CODE_ARRY <> ''                                 
			AND     ST_TABGUBUN = 'BRMO'                                    
			AND     ST_BRAND = 'ALL'                                        
			AND     (ST_SDATE<=GETDATE() AND ST_EDATE >=GETDATE())          
		END


	SELECT		COUNT(*)										AS TotalCount	-- TOT
			,	CEILING(CAST(COUNT(*) AS FLOAT) / @P_PAGE_SIZE)	AS TotalPage	-- TOTPAGE
	FROM (	SELECT	DISTINCT SCSS.CARD_SEQ
			FROM	S2_CARDSALESSITE	SCSS
					JOIN	S2_CARD				SC			ON SCSS.CARD_SEQ=SC.CARD_SEQ
					JOIN	S2_CARDDETAIL		SCD			ON SCSS.CARD_SEQ=SCD.CARD_SEQ
					JOIN	S2_CARDKIND			SCK			ON SCSS.CARD_SEQ=SCK.CARD_SEQ
					JOIN	S2_CARDKINDINFO		SCKI		ON SCK.CARDKIND_SEQ=SCKI.CARDKIND_SEQ
					JOIN	S2_CARDDISCOUNT		SCDC		ON SCSS.CARDDISCOUNT_SEQ = SCDC.CARDDISCOUNT_SEQ
					JOIN	S2_CARDDISCOUNT		SCDC_SORT	ON SCSS.CARDDISCOUNT_SEQ = SCDC_SORT.CARDDISCOUNT_SEQ
					JOIN	S2_CARDIMAGE		SCI			ON SCSS.CARD_SEQ=SCI.CARD_SEQ
					JOIN	S2_CARDOPTION		SCO			ON SCSS.CARD_SEQ=SCO.CARD_SEQ
					LEFT	JOIN	(
										SELECT	CARD_SEQ, COUNT(*) POST_CNT 
										FROM	S2_USERCOMMENT 
										WHERE	COMPANY_SEQ = 5001 
										GROUP BY CARD_SEQ
									)	COMMENT				ON SCSS.CARD_SEQ = COMMENT.CARD_SEQ
					JOIN	S2_CardStyle		SCS			ON SCS.Card_Seq = SCSS.Card_Seq
			WHERE	SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
			AND		SCSS.ISDISPLAY = '1'
			AND		SCDC.MINCOUNT = @P_ORDER_NUM
			AND		SCDC_SORT.MINCOUNT = 400
			AND		SCI.CARDIMAGE_WSIZE = @P_CARDIMAGEWIDTH
			AND		SCI.CARDIMAGE_HSIZE = @P_CARDIMAGEHEIGHT
			AND		SCI.CARDIMAGE_DIV = 'E'
			AND		SCI.COMPANY_SEQ = @P_COMPANY_SEQ
			AND		SCK.CARDKIND_SEQ IN (1,14)       -- 변수 처리 fn_SplitIn2Rows 감사장, 맞춤컬러인쇄, 기타등등
			AND		(
						ISNULL(@P_SEARCH_DESIGN,'') = '' OR SCS.CardStyle_Seq IN(SELECT ItemValue FROM fn_SplitIn2Rows(@P_SEARCH_DESIGN,'|'))
					)
			AND		(
						ISNULL(@P_SEARCH_FOLDING,'') = '' OR SCD.Card_Folding IN(SELECT ItemValue FROM fn_SplitIn2Rows(@P_SEARCH_FOLDING,'|'))
					)
			AND		(
						ISNULL(@P_ORDERBY,'') <> 'AfterPay' OR SCSS.isSSPre = '1'
					)

            -- 추가되는 파라미터에 대한 조건식 ex) 신상품

    		-- 이쪽 수정하고 싶다..	
			AND CASE WHEN @P_SEARCH_PRICE = '1' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 1 END < 300
			AND CASE WHEN @P_SEARCH_PRICE = '2' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 300 END BETWEEN 300 AND 399
			AND CASE WHEN @P_SEARCH_PRICE = '3' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 400 END BETWEEN 400 AND 499
			AND CASE WHEN @P_SEARCH_PRICE = '4' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 500 END BETWEEN 500 AND 599
			AND CASE WHEN @P_SEARCH_PRICE = '5' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 600 END >= 600

		) A



	;WITH PRODUCT_LIST_CTE AS  
	(  
		SELECT																																		--  구명칭
				DISTINCT	SCSS.COMPANY_SEQ																			AS CompanySeq				--	COMPANY_SEQ
				,	SCSS.CARD_SEQ																						AS CardSeq					--	CARD_SEQ
				,	SCSS.ISBEST																							AS IsBest					--	ISBEST
				,	SCSS.ISNEW																							AS IsNew					--	ISNEW
				,	SCSS.ISSALE																							AS IsSale					--	ISSALE
				,	SCSS.ISEXTRA																						AS IsExtra					--	ISEXTRA
				,	SCSS.ISSSPRE																						AS IsSamsungPreDiscount		--	ISSSPRE
				,	SC.CARD_CODE																						AS CardCode					--	CARD_CODE
				,	SC.CARDBRAND																						AS CardBrand				--	CARDBRAND
				,	SC.CARD_NAME																						AS CardName					--	CARD_NAME
				,	SC.CARDSET_PRICE																					AS CardPrice				--	CARDSET_PRICE
				,	SCD.CARD_CONTENT																					AS CardContent				--	CARD_CONTENT
				,	SCD.MINIMUM_COUNT																					AS MinimumCount				--	MINIMUM_COUNT
				,	SCDC.CARDDISCOUNT_SEQ																				AS CardDiscountSeq			--	CARDDISCOUNT_SEQ
				,	SCDC.DISCOUNT_RATE																					AS DiscountRate				--	DISCOUNT_RATE
				,	SCI.CARDIMAGE_FILENAME																				AS CardImageFileName		--	CARDIMAGE_FILENAME
				,	SCO.ISDIGITALCOLOR																					AS IsDigitalColor			--	ISDIGITALCOLOR
				,	SCO.DIGITALCOLOR																					AS DigitalColor				--	DIGITALCOLOR
				,	SCO.ISTECHNIC																						AS IsTechnic				--	ISTECHNIC
				,	SC.REGDATE																							AS RegDate					--	REGDATE
				,	SCSS.RANKING_W																						AS RankingWeek				--	RANKING_W
				,	SCSS.RANKING_M																						AS RankingMonth				--	RANKING_M
				,	ROUND( (SC.CARDSET_PRICE * (100 - SCDC.DISCOUNT_RATE) / 100), 0)									AS CardSalePrice			--	CARDSALE_PRICE 				    		 
				,	ROUND( (SC.CARDSET_PRICE * (100 - SCDC_SORT.DISCOUNT_RATE) / 100), 0)								AS CardSalePriceSort		--	CARDSALE_PRICE_ORDERBY
				,	ISNULL(COMMENT.POST_CNT, 0)																			AS CommentCount				--	POST_CNT
				,	ISNULL((SELECT COUNT(1) FROM S2_CARDKIND WHERE CARD_SEQ = SCSS.CARD_SEQ AND CARDKIND_SEQ = 14),0)	AS CustomCardYORN			--	CUSTOM_CARD_YN
				,	SCO.ISSAMPLE																						AS IsSample					--	ISSAMPLE
				,	ISNULL(SCO.ISFSC, '0')																				AS IsFsc					--	ISFSC
				,	ISNULL(BEST_CARD_TABLE.ROW_NUM, 9999)																AS CustomBestCardRanking	--	CUSTOM_BEST_CARD_RANKING	
				,	ISNULL(SCD.STICKER_GROUPSEQ, 0)																		AS StrickerGroupSeq			--	STICKER_GROUPSEQ
				--,	ISNULL(SCSS.ISDIGITALCARD, '0')																		AS IsDigitalCard			--	추가 ( 바른손 '맞춤컬러인쇄' 용도사용)
		FROM	S2_CARDSALESSITE	SCSS
				JOIN	S2_CARD				SC			ON SCSS.CARD_SEQ=SC.CARD_SEQ
				JOIN	S2_CARDDETAIL		SCD			ON SCSS.CARD_SEQ=SCD.CARD_SEQ
				JOIN	S2_CARDKIND			SCK			ON SCSS.CARD_SEQ=SCK.CARD_SEQ
				JOIN	S2_CARDKINDINFO		SCKI		ON SCK.CARDKIND_SEQ=SCKI.CARDKIND_SEQ
				JOIN	S2_CARDDISCOUNT		SCDC		ON SCSS.CARDDISCOUNT_SEQ = SCDC.CARDDISCOUNT_SEQ
				JOIN	S2_CARDDISCOUNT		SCDC_SORT	ON SCSS.CARDDISCOUNT_SEQ = SCDC_SORT.CARDDISCOUNT_SEQ
				JOIN	S2_CARDIMAGE		SCI			ON SCSS.CARD_SEQ=SCI.CARD_SEQ
				JOIN	S2_CARDOPTION		SCO			ON SCSS.CARD_SEQ=SCO.CARD_SEQ
				LEFT	JOIN	(
									SELECT	CARD_SEQ, COUNT(*) POST_CNT 
									FROM	S2_USERCOMMENT 
									WHERE	COMPANY_SEQ = @P_COMPANY_SEQ 
									GROUP BY CARD_SEQ
								)	COMMENT				ON SCSS.CARD_SEQ = COMMENT.CARD_SEQ
				LEFT	JOIN	(	
									SELECT	VALUE AS CARD_SEQ
									,	MAX(ROW_NUM) ROW_NUM
									FROM	DBO.[UFN_SPLITTABLEFORROWNUM](@BEST_CARD_LIST, ',')
									GROUP BY VALUE
								)	BEST_CARD_TABLE		ON BEST_CARD_TABLE.CARD_SEQ = SCSS.CARD_SEQ
				JOIN	S2_CardStyle		SCS			ON SCS.Card_Seq = SCSS.Card_Seq
		WHERE	SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
		AND		SCSS.ISDISPLAY = '1'
		AND		SCDC.MINCOUNT = @P_ORDER_NUM
		AND		SCDC_SORT.MINCOUNT = 400
		AND		SCI.CARDIMAGE_WSIZE = @P_CARDIMAGEWIDTH
		AND		SCI.CARDIMAGE_HSIZE = @P_CARDIMAGEHEIGHT
		AND		SCI.CARDIMAGE_DIV = 'E'
		AND		SCI.COMPANY_SEQ = @P_COMPANY_SEQ
		AND		SCK.CARDKIND_SEQ IN (1,14)     -- 변수 처리 fn_SplitIn2Rows 감사장, 맞춤컬러인쇄, 기타등등
		AND		(
					ISNULL(@P_SEARCH_DESIGN,'') = '' OR SCS.CardStyle_Seq IN(SELECT ItemValue FROM fn_SplitIn2Rows(@P_SEARCH_DESIGN,'|'))
				)
		AND		(
					ISNULL(@P_SEARCH_FOLDING,'') = '' OR SCD.Card_Folding IN(SELECT ItemValue FROM fn_SplitIn2Rows(@P_SEARCH_FOLDING,'|'))
				)
		AND		(
					ISNULL(@P_ORDERBY,'') <> 'AfterPay' OR SCSS.isSSPre = '1'
				)

        -- 추가되는 파라미터에 대한 조건식 ex) 신상품

		-- 이쪽 수정하고 싶다..
		AND CASE WHEN @P_SEARCH_PRICE = '1' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 1 END < 300
		AND CASE WHEN @P_SEARCH_PRICE = '2' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 300 END BETWEEN 300 AND 399
		AND CASE WHEN @P_SEARCH_PRICE = '3' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 400 END BETWEEN 400 AND 499
		AND CASE WHEN @P_SEARCH_PRICE = '4' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 500 END BETWEEN 500 AND 599
		AND CASE WHEN @P_SEARCH_PRICE = '5' THEN round((SC.cardset_price*(100-SCDC.discount_rate)/100),0) ELSE 600 END >= 600
	)  

	SELECT *  
	  
	FROM PRODUCT_LIST_CTE  
	
	ORDER BY 
		
		CASE WHEN @P_ORDERBY IN ( 'NEW' , 'AFTERPAY' ) THEN PRODUCT_LIST_CTE.Regdate ELSE 1 END DESC,
		CASE WHEN @P_ORDERBY = 'UC' THEN PRODUCT_LIST_CTE.CommentCount ELSE 1 END DESC,
		CASE WHEN @P_ORDERBY = 'BEST' THEN PRODUCT_LIST_CTE.CustomBestCardRanking ELSE 1 END ASC,
		CASE WHEN @P_ORDERBY = 'BEST' THEN PRODUCT_LIST_CTE.RankingMonth ELSE 1 END ASC,
		CASE WHEN @P_ORDERBY = 'HIGH' THEN PRODUCT_LIST_CTE.CardSalePriceSort ELSE 1 END DESC,
		CASE WHEN @P_ORDERBY = 'LOW' THEN PRODUCT_LIST_CTE.CardSalePriceSort ELSE 1 END ASC,
		CASE WHEN @P_ORDERBY = 'AFTERPAY' THEN PRODUCT_LIST_CTE.Regdate ELSE 1 END DESC
						 
	OFFSET (@P_PAGE_NUMBER - 1) * @P_PAGE_SIZE ROWS  
	FETCH NEXT @P_PAGE_SIZE ROWS ONLY  
  
END	
GO
