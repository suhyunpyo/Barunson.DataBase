IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_RANKING', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_RANKING
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

	EXEC SP_SELECT_CUSTOM_RANKING 5003, 'BRMO', 'ALL', '', 'RANKING'
	EXEC SP_SELECT_CUSTOM_RANKING 5000, 'SBBT', 'ALL', '', 'RANKING'

	EXEC SP_SELECT_CUSTOM_RANKING 5007, '125', 'ALL', '', 'RANKING'

	EXEC SP_SELECT_CUSTOM_RANKING 5001, '947', 'ALL', '', 'CUSTOM'
	EXEC SP_SELECT_CUSTOM_RANKING 5001, '947', 'ALL', '', 'RANKING'
*/
CREATE Procedure [dbo].[SP_SELECT_CUSTOM_RANKING]
		@P_COMPANY_SEQ		AS INT 
	,	@P_RANKING_TYPE		AS VARCHAR(20)
	,	@P_BRAND_TYPE		AS VARCHAR(20)
	,	@P_CARD_CODE		AS VARCHAR(50)
	,	@P_LIST_TYPE		AS VARCHAR(20) -- CUSTOM, RANKING, SEARCH

AS
BEGIN

-- @P_RANKING_TYPE이 'CUSTOM' 또는 'RECOM' 일 경우 @P_LIST_TYPE 을 'SEARCH' 로 변경
SET @P_LIST_TYPE = CASE WHEN @P_RANKING_TYPE IN ('CUSTOM', 'RECOM') AND @P_LIST_TYPE = 'RANKING' THEN 'SEARCH' ELSE @P_LIST_TYPE END



IF @P_LIST_TYPE = 'CUSTOM' 
	BEGIN

		SELECT	SC.CARD_SEQ		AS CardSeq
			,	SC.CARD_CODE	AS CardCode
			,	SC.CARD_NAME	AS CardName
			,	SC.CARD_PRICE	AS CardPrice
			,	SC.CARDBRAND	AS CardBrand
			,	CASE 
						WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
						WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5007 THEN 'http://file.barunsoncard.com/thecard/'			+ SC.CARD_CODE + '/210.jpg'
						ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
				END AS ImageUrl
			,	C.ROW_NUM		AS SortingNum
			,	RS.StartDate
			,	RS.EndDate

		FROM	DBO.ufn_SplitTableForRowNum
				(
					(
						SELECT	TOP 1 ST_CARD_CODE_ARRY 
						FROM	S4_RANKING_SORT
						WHERE	1 = 1
						AND		ST_COMPANY_SEQ = @P_COMPANY_SEQ 
						
						-- 더카드 아닌 경우 검색 조건
						AND		CASE WHEN @P_COMPANY_SEQ != 5007 THEN ST_TABGUBUN ELSE '' END = CASE WHEN @P_COMPANY_SEQ != 5007 THEN @P_RANKING_TYPE ELSE '' END
						AND		CASE WHEN @P_COMPANY_SEQ != 5007 THEN ST_BRAND ELSE '' END = CASE WHEN @P_COMPANY_SEQ != 5007 THEN @P_BRAND_TYPE ELSE '' END

						-- 더카드인 경우 검색 조건
						AND		CASE WHEN @P_COMPANY_SEQ = 5007 THEN ST_CODE ELSE '' END = CASE WHEN @P_COMPANY_SEQ = 5007  THEN @P_RANKING_TYPE ELSE '' END
					)
					, ','
				) C
		JOIN	S2_CARD SC ON C.VALUE = SC.CARD_SEQ	
		,		(
					SELECT	TOP 1 ST_SDATE AS StartDate, ST_EDATE AS EndDate, ST_COMPANY_SEQ AS CompanySeq
					FROM	S4_RANKING_SORT
					WHERE	1 = 1
					AND		ST_COMPANY_SEQ = @P_COMPANY_SEQ 
					
					-- 더카드 아닌 경우 검색 조건
					AND		CASE WHEN @P_COMPANY_SEQ != 5007 THEN ST_TABGUBUN ELSE '' END = CASE WHEN @P_COMPANY_SEQ != 5007 THEN @P_RANKING_TYPE ELSE '' END
					AND		CASE WHEN @P_COMPANY_SEQ != 5007 THEN ST_BRAND ELSE '' END = CASE WHEN @P_COMPANY_SEQ != 5007 THEN @P_BRAND_TYPE ELSE '' END

					-- 더카드인 경우 검색 조건
					AND		CASE WHEN @P_COMPANY_SEQ = 5007 THEN ST_CODE ELSE '' END = CASE WHEN @P_COMPANY_SEQ = 5007  THEN @P_RANKING_TYPE ELSE '' END
				) RS



	END

ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ = 5007
  IF @P_RANKING_TYPE = 10010 OR @P_RANKING_TYPE = 10020 OR @P_RANKING_TYPE = 10021 OR @P_RANKING_TYPE = 10022 OR @P_RANKING_TYPE = 10023 OR @P_RANKING_TYPE = 10024 OR @P_RANKING_TYPE = 10025 OR @P_RANKING_TYPE = 673 OR @P_RANKING_TYPE = 679
  BEGIN    
	DECLARE @THECARD_RANK_BRAND AS VARCHAR(3)
	DECLARE @THECARD_RANK_DIV_TYPE AS VARCHAR(3)
	DECLARE @THECARD_RANK_KIND_SEQ AS int
	
	-- 바른손 : B, 비핸즈 : N, 프리 : S, 더카 : C, 디디 : D
	SET @THECARD_RANK_BRAND = CASE   
		WHEN @P_RANKING_TYPE = '10020' THEN 'C'   
		WHEN @P_RANKING_TYPE = '10021' THEN 'B'  
		WHEN @P_RANKING_TYPE = '10022' THEN 'N'  
		WHEN @P_RANKING_TYPE = '10023' THEN 'S'  
		WHEN @P_RANKING_TYPE = '10024' THEN 'D'  
		WHEN @P_RANKING_TYPE = '10025' THEN 'S' 
		ELSE 'ALL'
	END

	SELECT SC.CARD_SEQ  AS CardSeq  
		, SC.CARD_CODE AS CardCode  
		, SC.CARD_NAME AS CardName  
		, SC.CARD_PRICE AS CardPrice  
		, SC.CARDBRAND AS CardBrand  
		, 'http://file.barunsoncard.com/thecard/'   + SC.CARD_CODE + '/210.jpg' AS ImageUrl  
		, ISNULL(CAST(SCSS.RANKING_W AS INT), 9999) AS SortingNum  
		, '' AS StartDate  
		, '' AS EndDate  
  
	FROM S2_CARD SC  
	JOIN (
		SELECT * FROM S2_CARDSALESSITE
		WHERE COMPANY_SEQ = 5007
		AND Company_Seq = 5007
		AND IsDisplay = 1
		AND card_seq IN (SELECT card_seq FROM S2_CardKind WHERE CardKind_Seq = 1)
	) SCSS ON (SC.CARD_SEQ = SCSS.CARD_SEQ )
	WHERE 1 = 1  
	AND sc.DISPLAY_YORN = 'Y'
	AND card_div = 'A01' 
	AND (CASE WHEN @THECARD_RANK_BRAND = 'ALL' THEN @THECARD_RANK_BRAND ELSE CardBrand END) = @THECARD_RANK_BRAND  
	ORDER BY REGDATE DESC
  End
 ELSE IF  @P_RANKING_TYPE = '10011' 
   BEGIN    
    SELECT SC.CARD_SEQ  AS CardSeq  
     , SC.CARD_CODE AS CardCode  
     , SC.CARD_NAME AS CardName  
     , SC.CARD_PRICE AS CardPrice  
     , SC.CARDBRAND AS CardBrand  
     , 'http://file.barunsoncard.com/thecard/'   + SC.CARD_CODE + '/210.jpg' AS ImageUrl  
     , ISNULL(CAST(SCSS.RANKING_M AS INT), 9999) AS SortingNum  
     , '' AS StartDate  
     , '' AS EndDate  
  
    FROM S2_CARD SC  
    JOIN (
		SELECT * FROM S2_CARDSALESSITE
		WHERE COMPANY_SEQ = 5007
		AND Company_Seq = 5007
		AND IsDisplay = 1
		AND card_seq IN (SELECT card_seq FROM S2_CardKind WHERE CardKind_Seq = 1)
	) SCSS ON (SC.CARD_SEQ = SCSS.CARD_SEQ )
    WHERE 1 = 1  
	AND sc.DISPLAY_YORN = 'Y'
	AND card_div = 'A01' 
	ORDER BY RANKING_M ASC
  End	

  
 ELSE IF  @P_RANKING_TYPE = '10030' -- 부가부가
	BEGIN

		SET @P_BRAND_TYPE = CASE   
			WHEN @P_BRAND_TYPE = 'ALL' THEN 'C,E'
			ELSE @P_BRAND_TYPE   
		END  

		SELECT  
			SC.CARD_SEQ  AS CardSeq  
			, SC.CARD_CODE AS CardCode  
			, SC.CARD_NAME AS CardName  
			, SC.CARD_PRICE AS CardPrice  
			, SC.CARDBRAND AS CardBrand  
			, 'http://file.barunsoncard.com/thecard/'   + SC.CARD_CODE + '/210.jpg' AS ImageUrl  
			, ISNULL(CAST(SCSS.RANKING_M AS INT), 9999) AS SortingNum  
			, '' AS StartDate  
			, '' AS EndDate  
		FROM S2_CARD SC, S2_CARDSALESSITE SCSS
		WHERE SC.CARD_SEQ = SCSS.CARD_SEQ 
		AND SCSS.COMPANY_SEQ = 5007
		AND IsDisplay = 1
		AND sc.DISPLAY_YORN = 'Y'
		AND (CASE   
				WHEN Card_Div = 'A01' THEN 'C'
				ELSE 'E' 
			END) IN (SELECT VALUE FROM DBO.FN_SPLIT(@P_BRAND_TYPE, ','))  
		ORDER BY REGDATE DESC
	End	
 ELSE 
	 BEGIN  
		
			DECLARE @SUB_TYPE AS VARCHAR(100)  
	  
	  SET @SUB_TYPE = CASE   
			 WHEN @P_RANKING_TYPE = '125' THEN 'WEEK'   
			 WHEN @P_RANKING_TYPE = '130' THEN 'MONT'  
			 WHEN @P_RANKING_TYPE = '131' THEN 'SAMP'  
			 ELSE 'WEEK'   
		   END  
	  
	  SELECT SC.CARD_SEQ  AS CardSeq  
	   , SC.CARD_CODE AS CardCode  
	   , SC.CARD_NAME AS CardName  
	   , SC.CARD_PRICE AS CardPrice  
	   , SC.CARDBRAND AS CardBrand  
	   , CASE   
		  WHEN @P_COMPANY_SEQ = 5007 THEN 'http://file.barunsoncard.com/thecard/' + SC.CARD_CODE + '/210.jpg'  
		  ELSE       'http://file.barunsoncard.com/barunsoncard/' + SC.CARD_CODE + '/210.jpg'  
		END AS ImageUrl  
	   , CAST(SCSS.RANKING_W AS INT) AS SortingNum  
	   , '' AS StartDate  
	   , '' AS EndDate  
	  
	  FROM S4_BestTotalRanking_TheCard AS A WITH(NOLOCK)  
	   INNER JOIN S2_Card AS SC WITH(NOLOCK)  
		ON A.Card_Seq = SC.Card_Seq  
	   INNER JOIN S2_CardSalesSite AS SCSS WITH(NOLOCK)  
		ON SC.Card_Seq = SCSS.Card_Seq  
	   INNER JOIN S2_CardDiscount AS D WITH(NOLOCK)  
		ON SCSS.CardDiscount_Seq = D.CardDiscount_Seq  
	   INNER JOIN S2_CardImage AS E WITH(NOLOCK)  
		ON A.Card_Seq = E.Card_Seq   
	   INNER JOIN S2_CardOption AS H WITH(NOLOCK)  
		ON SC.Card_Seq = H.Card_Seq  
	   INNER JOIN S2_CardKind AS I WITH(NOLOCK)  
		ON SCSS.Card_Seq = I.Card_Seq  
	   INNER JOIN S2_CardKindInfo AS J WITH(NOLOCK)  
		ON I.CardKind_Seq = J.CardKind_Seq   
	  WHERE 1 = 1  
	   AND A.Gubun_date = CONVERT(VARCHAR(10), GETDATE(), 120)  
	   AND A.Gubun = @SUB_TYPE  
	   AND SC.CardBrand = ISNULL(NULL, SC.CardBrand) -- 브랜드 조건  
	   AND SCSS.Company_Seq = @P_COMPANY_SEQ  
	   AND SCSS.IsDisplay = 1    
	   AND D.MinCount = 400  
	   AND E.CardImage_WSize = '210'   
	   AND E.CardImage_HSize = '210'   
	   AND E.cardimage_div = 'E'      
	   AND E.Company_Seq = @P_COMPANY_SEQ   
	   AND J.CardKind_Seq = 1     
	 END  
	 
 ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ = 5006 AND  ISNUMERIC(@P_RANKING_TYPE) = 1
	BEGIN
			SELECT	SC.CARD_SEQ		AS CardSeq
				,	SC.CARD_CODE	AS CardCode
				,	SC.CARD_NAME	AS CardName
				,	SC.CARD_PRICE	AS CardPrice
				,	SC.CARDBRAND	AS CardBrand
				,	'http://file.barunsoncard.com/bhandscard/' + SC.CARD_CODE + '/210.jpg' AS ImageUrl
				,	'' AS StartDate
				,	'' AS EndDate
				, scss.IsNew

			FROM	S2_CARD SC
			JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
				
			WHERE	1 = 1
			AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
			AND		SCSS.ISDISPLAY='1'
			AND     card_div = 'A01' 
--			and		SCSS.IsNew = 1

			ORDER BY SC.RegDate DESC

	END
ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ = 5001 AND @P_RANKING_TYPE in ('956','957','958','959','960')
	BEGIN

		DECLARE @TYPE_GUBUN AS VARCHAR(100)
		
		SET @TYPE_GUBUN = 	CASE 
								WHEN @P_RANKING_TYPE = '956' THEN 'BRWE'
								WHEN @P_RANKING_TYPE = '957' THEN 'BRMO'
								WHEN @P_RANKING_TYPE = '958' THEN 'BRST'
								WHEN @P_RANKING_TYPE = '959' THEN 'POST'
								WHEN @P_RANKING_TYPE = '960' THEN 'SAMP'
								ELSE 'BRWE'
							END

		SELECT * 
		FROM 
				(
				SELECT 
						SC.CARD_SEQ		AS CardSeq
					,	SC.CARD_CODE	AS CardCode
					,	SC.CARD_NAME	AS CardName
					,	SC.CARD_PRICE	AS CardPrice
					,	SC.CARDBRAND	AS CardBrand
					,	CASE 
								WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
								WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
								ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						END AS ImageUrl
					,	ISNULL(CAST(z.rankno as INT),0) AS SortingNum
					,	'' AS StartDate
					,	'' AS EndDate
				
				FROM
					S2_Card SC
					Join S2_CardSalesSite SCSS on SC.card_seq = scss.card_seq
					join ( select * 
							from S4_BestTotalRanking_Barunson
							WHERE gubun = (case when @TYPE_GUBUN = 'BRWE' THEN 'BRWE' 
										when @TYPE_GUBUN = 'BRMO' THEN 'BRMO' 
										when @TYPE_GUBUN = 'BRST' THEN 'BRST' 
										when @TYPE_GUBUN = 'POST' THEN 'POST'
										when @TYPE_GUBUN = 'SAMP' THEN 'SAMP'
									end )
								and SubGubun = (case when @TYPE_GUBUN = 'BRWE' then 'AL'
										when @TYPE_GUBUN = 'BRMO' then 'AL'
										when @TYPE_GUBUN = 'BRST' then 'AL'
										when @TYPE_GUBUN = 'POST' then 'PO'
										when @TYPE_GUBUN = 'SAMP' THEN 'SA'
									end )
								and Gubun_date = (
												SELECT 
													max(gubun_date) gubun_date 
												from 
													S4_BestTotalRanking_Barunson 
												where gubun = (case when @TYPE_GUBUN = 'BRWE' THEN 'BRWE' 
															when @TYPE_GUBUN = 'BRMO' THEN 'BRMO' 
															when @TYPE_GUBUN = 'BRST' THEN 'BRST' 
															when @TYPE_GUBUN = 'POST' THEN 'POST'
															when @TYPE_GUBUN = 'SAMP' THEN 'SAMP'
														end )
													and SubGubun = (case when @TYPE_GUBUN = 'BRWE' then 'AL'
															when @TYPE_GUBUN = 'BRMO' then 'AL'
															when @TYPE_GUBUN = 'BRST' then 'AL'
															when @TYPE_GUBUN = 'POST' then 'PO'
															when @TYPE_GUBUN = 'SAMP' THEN 'SA'
														end )
													) 
						) z on z.card_seq = SC.card_seq
				WHERE
					scss.IsDisplay = '1'
					and sc.DISPLAY_YORN = 'Y'
					and scss.Company_Seq = @P_COMPANY_SEQ
					and SC.card_div = 'A01' 
			)A
		ORDER BY A.sortingNum ASC							
	END
ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ <> 5003 AND (@P_COMPANY_SEQ <> 5000 OR ((@P_COMPANY_SEQ = 5000 AND @P_RANKING_TYPE NOT IN ('SBBT', 'SABT', 'STBT', 'SSBT')))) AND @P_RANKING_TYPE <> '947'
	BEGIN 

		DECLARE @SUB_GUBUN AS VARCHAR(100)
		DECLARE @BRAND AS VARCHAR(100)

		SET @SUB_GUBUN =	CASE	
									WHEN @P_BRAND_TYPE = 'ALL' THEN 'AL' 
									WHEN @P_BRAND_TYPE = 'B' THEN 'BB'
									WHEN @P_BRAND_TYPE = 'W' THEN 'BW'
									WHEN @P_BRAND_TYPE = 'H' THEN 'BH'
									WHEN @P_BRAND_TYPE = 'S' THEN 'BS'
									ELSE 'AL' 
							END
		SET @SUB_GUBUN = CASE WHEN @P_RANKING_TYPE = 'POST' THEN 'PO' ELSE @SUB_GUBUN END
		SET @SUB_GUBUN = CASE WHEN @P_RANKING_TYPE = 'PRIC' THEN 'P1,P2,P3,P4' ELSE @SUB_GUBUN END

		SET @BRAND = CASE WHEN @P_BRAND_TYPE = 'ALL' THEN 'B,W,H,S,M,U,N,I' ELSE @P_BRAND_TYPE END

		SELECT	SC.CARD_SEQ		AS CardSeq
			,	SC.CARD_CODE	AS CardCode
			,	SC.CARD_NAME	AS CardName
			,	SC.CARD_PRICE	AS CardPrice
			,	SC.CARDBRAND	AS CardBrand
			,	CASE 
						WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
						WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
						ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
				END AS ImageUrl
			,	CAST(C.RANKNO AS INT) AS SortingNum
			,	'' AS StartDate
			,	'' AS EndDate

		FROM	(
					
					SELECT	GUBUN_DATE, GUBUN, SUBGUBUN, RANKNO, CARD_SEQ, CNT, 5001 AS COMPANY_SEQ
					FROM	S4_BESTTOTALRANKING_BARUNSON
					WHERE	1 = 1
					AND		GUBUN = @P_RANKING_TYPE
					AND		SUBGUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@SUB_GUBUN, ','))
					AND		GUBUN_DATE = (SELECT MAX(GUBUN_DATE) FROM S4_BESTTOTALRANKING_BARUNSON WHERE GUBUN = @P_RANKING_TYPE AND SUBGUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@SUB_GUBUN, ',')))

					UNION ALL

					SELECT	GUBUN_DATE, GUBUN, SUBGUBUN, RANKNO, CARD_SEQ, CNT, 5006 AS COMPANY_SEQ
					FROM	S4_BESTTOTALRANKING_BHANDS
					WHERE	1 = 1
					AND		GUBUN = @P_RANKING_TYPE
					AND		SUBGUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@SUB_GUBUN, ','))
					AND		GUBUN_DATE = (SELECT MAX(GUBUN_DATE) FROM S4_BESTTOTALRANKING_BHANDS WHERE GUBUN = @P_RANKING_TYPE AND SUBGUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@SUB_GUBUN, ',')))

					UNION ALL

					SELECT	GUBUN_DATE, GUBUN, SUBGUBUN, RANKNO, CARD_SEQ, CNT, 5000 AS COMPANY_SEQ
					FROM	S4_BESTTOTALRANKING_BSMALL
					WHERE	1 = 1
					AND		GUBUN = @P_RANKING_TYPE
					AND		SUBGUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@SUB_GUBUN, ','))
					AND		GUBUN_DATE = (SELECT MAX(GUBUN_DATE) FROM S4_BESTTOTALRANKING_BSMALL WHERE GUBUN = @P_RANKING_TYPE AND SUBGUBUN IN (SELECT VALUE FROM DBO.FN_SPLIT(@SUB_GUBUN, ',')))

				) C
		JOIN	S2_CARD SC ON C.CARD_SEQ = SC.CARD_SEQ AND C.COMPANY_SEQ = @P_COMPANY_SEQ
		JOIN	S2_CARDSALESSITE SCSS ON C.CARD_SEQ = SCSS.CARD_SEQ AND C.COMPANY_SEQ = SCSS.COMPANY_SEQ

		WHERE	1 = 1
		AND		SC.CARDBRAND IN (SELECT VALUE FROM DBO.FN_SPLIT(@BRAND, ','))
		AND		SCSS.ISDISPLAY = 1

		ORDER BY 
					CASE WHEN @P_RANKING_TYPE = 'PRIC' THEN C.SUBGUBUN ELSE '1' END ASC
				,	C.RANKNO ASC
				,	C.CNT DESC

	END
	

ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ = 5003
	BEGIN
		
		IF @P_RANKING_TYPE = 'WCAL' OR @P_RANKING_TYPE = 'PRMA'
			BEGIN

				SELECT	SC.CARD_SEQ		AS CardSeq
					,	SC.CARD_CODE	AS CardCode
					,	SC.CARD_NAME	AS CardName
					,	SC.CARD_PRICE	AS CardPrice
					,	SC.CARDBRAND	AS CardBrand
					,	CASE 
								WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
								WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
								ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						END AS ImageUrl
					,	ISNULL(CAST(SCSB.RANKING_W AS INT), 9999) AS SortingNum
					,	ISNULL(CAST(SCSB.RANKING_M AS INT), 9999) AS SortingNumM
					,	'' AS StartDate
					,	'' AS EndDate

				FROM	S2_CARD SC
				JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
				JOIN	S2_CARDSALESBEST SCSB ON SC.CARD_SEQ = SCSB.CARD_SEQ
				LEFT JOIN (
					SELECT card_seq, count(1) as order_num, sum(order_count) as order_count  FROM custom_order 
					WHERE company_seq = 5003
					AND trouble_type = 0
					AND status_seq = 15
					AND src_send_date <= CONVERT (date, SYSDATETIME()) 
					AND src_send_date >= CONVERT(date, DATEADD(MONTH,-1, SYSDATETIME()))	
					GROUP BY card_seq
				) AS ORD ON ORD.card_seq = SC.Card_Seq

				WHERE	1 = 1
				AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSB.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSS.ISDISPLAY='1'
				and     SC.CARD_SEQ IN (SELECT CARD_SEQ FROM S2_CARDKIND WHERE CARDKIND_SEQ IN (1, 7))				

				ORDER BY 
					CASE @P_BRAND_TYPE WHEN 'I' THEN ORD.order_num ELSE 1 END DESC, 
					CASE @P_BRAND_TYPE WHEN 'N' THEN SC.RegDate ELSE 1 END DESC,
					ORD.order_count DESC


			END

		ELSE IF @P_RANKING_TYPE = 'PRN1' OR @P_RANKING_TYPE = 'PRN2' OR @P_RANKING_TYPE = 'PRN3' OR @P_RANKING_TYPE = 'PRN4'
			BEGIN

				SELECT	SC.CARD_SEQ		AS CardSeq
					,	SC.CARD_CODE	AS CardCode
					,	SC.CARD_NAME	AS CardName
					,	SC.CARD_PRICE	AS CardPrice
					,	SC.CARDBRAND	AS CardBrand
					,	'http://file.barunsoncard.com/story/' + SC.CARD_CODE + '/180.jpg' AS ImageUrl
					,	'' AS StartDate
					,	'' AS EndDate
					, scss.IsNew

				FROM	S2_CARD SC
				JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
				
				WHERE	1 = 1
				AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSS.ISDISPLAY='1'
				and		SCSS.IsNew = 1

				ORDER BY SC.RegDate DESC

			END

		ELSE IF  @P_RANKING_TYPE = 'PNEW' OR @P_RANKING_TYPE = 'PBST' OR @P_RANKING_TYPE = 'PBSP'
			BEGIN

				SELECT	SC.CARD_SEQ		AS CardSeq
					,	SC.CARD_CODE	AS CardCode
					,	SC.CARD_NAME	AS CardName
					,	SC.CARD_PRICE	AS CardPrice
					,	SC.CARDBRAND	AS CardBrand
					,	CASE 
								WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
								WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
								WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
								ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						END AS ImageUrl
					,	ISNULL(CAST(SCSS.RANKING_W AS INT), 9999) AS SortingNum
					,	'' AS StartDate
					,	'' AS EndDate

				FROM	S2_CARD SC
				JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
				JOIN	S2_CARDSALESBEST SCSB ON SC.CARD_SEQ = SCSB.CARD_SEQ
				LEFT JOIN (
					SELECT card_seq, count(1) as order_num, sum(order_count) as order_count  FROM custom_order 
					WHERE company_seq = 5003
					AND trouble_type = 0
					AND status_seq = 15
					AND src_send_date <= CONVERT (date, SYSDATETIME()) 
					AND src_send_date >= CONVERT(date, DATEADD(MONTH,-1, SYSDATETIME()))	
					GROUP BY card_seq
				) AS ORD ON ORD.card_seq = SC.Card_Seq

				WHERE	1 = 1
				AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSB.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSS.ISDISPLAY='1'

				AND		(
							(
								@P_RANKING_TYPE = 'PBST'
								AND	SC.CARD_SEQ IN (SELECT CARD_SEQ FROM S2_CARDKIND WHERE CARDKIND_SEQ IN (1, 7))
							)
							OR
							(
									@P_RANKING_TYPE = 'PBSP'
								AND	SC.CARD_SEQ IN (SELECT CARD_SEQ FROM S2_CARDKIND WHERE CARDKIND_SEQ IN (1, 7))

							)
							OR
							(
								@P_RANKING_TYPE = 'PNEW'
								AND	SCSS.ISNEW = 1
							)
						)

				ORDER BY 
					CASE 
						WHEN @P_RANKING_TYPE = 'PNEW' THEN SC.RegDate 
						ELSE ORD.order_num
					END DESC,
					 ORD.order_count DESC

			END
			
		ELSE 
			BEGIN
				SELECT	SC.CARD_SEQ		AS CardSeq
					,	SC.CARD_CODE	AS CardCode
					,	SC.CARD_NAME	AS CardName
					,	SC.CARD_PRICE	AS CardPrice
					,	SC.CARDBRAND	AS CardBrand
					,	'http://file.barunsoncard.com/story/' + SC.CARD_CODE + '/180.jpg' AS ImageUrl
					,	'' AS StartDate
					,	'' AS EndDate
					, scss.IsNew

				FROM	S2_CARD SC
				JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
				
				WHERE	1 = 1
				AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
				AND		SCSS.ISDISPLAY='1'
				ORDER BY SC.RegDate DESC
			END

	END

ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ = 5000 AND @P_RANKING_TYPE IN ('SBBT', 'SABT', 'STBT', 'SSBT')
	BEGIN

		SELECT	TOP 30
				SC.CARD_SEQ		AS CardSeq
			,	SC.CARD_CODE	AS CardCode
			,	SC.CARD_NAME	AS CardName
			,	SC.CARD_PRICE	AS CardPrice
			,	SC.CARDBRAND	AS CardBrand
			,	CASE 
						WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
						WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
						ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
				END AS ImageUrl
			,	CAST(SCSS.RANKING_W AS INT) AS SortingNum
			,	'' AS StartDate
			,	'' AS EndDate

		FROM	S2_CARD SC
		JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
		JOIN	S2_CARDSALESBEST SCSB ON SC.CARD_SEQ = SCSB.CARD_SEQ
		JOIN	(
					SELECT	CARD_SEQ, COUNT(*) AS CNT
					FROM	CUSTOM_ORDER 
					WHERE	ORDER_DATE >= GETDATE() - 50 
					AND		ORDER_TYPE IN (1,6,7) 
					AND		STATUS_SEQ > 0 
					AND		STATUS_SEQ NOT IN (3, 5)
					GROUP BY CARD_SEQ
				) CO ON SC.CARD_SEQ = CO.CARD_SEQ

		WHERE	1 = 1
		AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
		AND		SCSB.COMPANY_SEQ = @P_COMPANY_SEQ
		AND		SCSS.ISDISPLAY='1'
		AND		(
						(@P_RANKING_TYPE = 'SBBT' AND SC.CARDBRAND = 'B') 
					OR	(@P_RANKING_TYPE = 'SABT' AND SC.CARDBRAND = 'N') 
					OR  (@P_RANKING_TYPE = 'STBT' AND SC.CARDBRAND = 'C') 
					OR  (@P_RANKING_TYPE = 'SSBT' AND SC.CARDBRAND = 'S') 
				)

		ORDER BY CO.CNT DESC

	END


ELSE IF @P_LIST_TYPE = 'RANKING' AND @P_COMPANY_SEQ = 5001 AND @P_RANKING_TYPE ='947'
	BEGIN
		SELECT * FROM 
		(
		SELECT	
				SC.CARD_SEQ		AS CardSeq
			,	SC.CARD_CODE	AS CardCode
			,	SC.CARD_NAME	AS CardName
			,	SC.CARD_PRICE	AS CardPrice
			,	SC.CARDBRAND	AS CardBrand
			,	CASE 
						WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
						WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
						ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
				END AS ImageUrl
			,	ISNULL(CAST(SCSS.RANKING_M AS INT),0) AS SortingNum
			,	'' AS StartDate
			,	'' AS EndDate
		FROM	S2_CARD SC
		JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ
		WHERE	1 = 1
		AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
		AND		SC.DISPLAY_YORN ='Y'
		AND		SCSS.ISDISPLAY='1'
		and		SC.card_div = 'A01' 
		) A 
		ORDER BY A.SortingNum ASC

	END


ELSE IF	@P_LIST_TYPE = 'SEARCH' 
	BEGIN
	
		DECLARE @SEARCH_DIV AS VARCHAR(5)

		SET @SEARCH_DIV = CASE   
			WHEN @P_RANKING_TYPE = '10030' THEN 'C,E'
			ELSE 'C'   
		END  

		SELECT	SC.CARD_SEQ		AS CardSeq
			,	SC.CARD_CODE	AS CardCode
			,	SC.CARD_NAME	AS CardName
			,	SC.CARD_PRICE	AS CardPrice
			,	SC.CARDBRAND	AS CardBrand
			,	CASE 
						WHEN @P_COMPANY_SEQ = 5000 THEN 'http://file.barunsoncard.com/barunsonmall/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5001 THEN 'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5003 THEN 'http://file.barunsoncard.com/story/'			+ SC.CARD_CODE + '/180.jpg'
						WHEN @P_COMPANY_SEQ = 5006 THEN 'http://file.barunsoncard.com/bhandscard/'		+ SC.CARD_CODE + '/210.jpg'
						WHEN @P_COMPANY_SEQ = 5007 THEN 'http://file.barunsoncard.com/thecard/'			+ SC.CARD_CODE + '/210.jpg'
						ELSE							'http://file.barunsoncard.com/barunsoncard/'	+ SC.CARD_CODE + '/210.jpg'
				END AS ImageUrl
			,	ISNULL(CAST(SCSS.RANKING_W AS INT), 999) AS SortingNum
			,	'' AS StartDate
			,	'' AS EndDate

		FROM	S2_CARD SC
		JOIN	S2_CARDSALESSITE SCSS ON SC.CARD_SEQ = SCSS.CARD_SEQ

		WHERE	1 = 1
		AND		SCSS.COMPANY_SEQ = @P_COMPANY_SEQ
		AND		SCSS.ISDISPLAY = 1
		AND		(SC.CARD_CODE LIKE '%' + @P_CARD_CODE + '%' OR SC.CARD_NAME LIKE '%' + @P_CARD_CODE + '%')
		AND (CASE   
				WHEN SC.CARD_DIV = 'A01' THEN 'C'
				ELSE 'E' 
			END) IN (SELECT VALUE FROM DBO.FN_SPLIT(@SEARCH_DIV, ','))  

		
		-- 맞춤인쇄카드 (@P_RANKING_TYPE = 'CUSTOM')
		AND		(
						(@P_RANKING_TYPE = 'CUSTOM' AND SC.CARD_SEQ IN (SELECT CARD_SEQ FROM S2_CARDKIND WHERE CARDKIND_SEQ = 14))
					OR	(@P_RANKING_TYPE <> 'CUSTOM')
				)

		-- 신상품 (@P_RANKING_TYPE = 'RECOM')
		AND		(CASE WHEN @P_RANKING_TYPE = 'RECOM' THEN SCSS.ISNEW ELSE 1 END) = 1
		
		ORDER BY SCSS.RANKING_W ASC

	END

END
GO
