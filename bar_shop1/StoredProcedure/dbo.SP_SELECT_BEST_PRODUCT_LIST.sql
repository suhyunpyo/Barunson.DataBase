IF OBJECT_ID (N'dbo.SP_SELECT_BEST_PRODUCT_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BEST_PRODUCT_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		유우종
-- Create date: 2017-12-20
-- Description:	Best-Seller 리스트 페이지에서 쓰지 않는 컬럼은 제외.
--				필요한 컬럼은 기존 Stored Procedure 및 asp페이지 참조해서 추가.
--				ref.1) up_select_ranking1_web
--				ref.2) product/list_best.asp
-- =============================================
CREATE PROCEDURE [dbo].[SP_SELECT_BEST_PRODUCT_LIST]	
	@COMPANY_SEQ	INT				= 5001		-- 회사고유코드 (바른손: 5001)   
	,@TAB_GUBUN		NVARCHAR(50)	= 'BRWE'	-- 탭 구분 (주간판매: BRWE, 월간판매: BRMO, 스테디셀러: BRST, 이용후기: POST, 샘플신청: SAMP)
	,@BRAND			NVARCHAR(50)	= 'ALL'		-- 고유브랜드 
	,@ORDER_NUM		INT				= 300		-- 주문 수량
	,@IMAGE_WIDTH	VARCHAR(3)		= '210'		-- 이미지 가로 사이즈
	,@IMAGE_HEIGHT	VARCHAR(3)		= '210'		-- 이미지 세로 사이즈
	,@PAGE_NUMBER	INT				= 1			-- 페이지 번호
	,@PAGE_SIZE		INT				= 20		-- 페이지 크기 (페이지당 노출수)
AS
BEGIN	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	CREATE TABLE #RankTable (RankNo INT, Card_Seq INT)
	DECLARE @CARD_SEQ_LIST AS VARCHAR(4000)

	SELECT @CARD_SEQ_LIST = ST_Card_Code_Arry
	FROM S4_Ranking_Sort
	WHERE ST_company_seq = @COMPANY_SEQ  
		AND ST_tabgubun = @TAB_GUBUN 
		AND ST_brand = @BRAND
		AND ISNULL(ST_Card_Code_Arry, '') <> ''
		AND ST_SDate <= GETDATE() 
		AND ST_Edate >= GETDATE() 
	
	IF ISNULL(@CARD_SEQ_LIST, '') = ''
	BEGIN		
		DECLARE @SUB_GUBUN AS CHAR(2) = 'AL'

		IF @TAB_GUBUN = 'POST'
		BEGIN
			SET @SUB_GUBUN = 'PO'
		END
		ELSE IF @TAB_GUBUN = 'SAMP'
		BEGIN
			SET @SUB_GUBUN = ''
		END	

		-- S4_BestTotalRanking_Barunson 기준으로 Rank 조회
		INSERT INTO #RankTable (RankNo, Card_Seq)
		SELECT RankNo, Card_Seq
		FROM S4_BestTotalRanking_Barunson
		WHERE Gubun = @TAB_GUBUN 
			AND (@SUB_GUBUN = '' OR SubGubun = @SUB_GUBUN)
			AND Gubun_date = (SELECT MAX(Gubun_date) FROM S4_BestTotalRanking_Barunson WHERE Gubun = @TAB_GUBUN AND (@SUB_GUBUN = '' OR SubGubun = @SUB_GUBUN))
	END
	ELSE
	BEGIN
		-- S4_Ranking_Sort 기준으로 Rank 조회
		INSERT INTO #RankTable (RankNo, Card_Seq)
		SELECT row_num AS RankNo, value AS Card_Seq
		FROM ufn_SplitTableForRowNum(@CARD_SEQ_LIST, ',')	
	END

	SELECT COUNT(*)										AS TotalCount,
		CEILING(CAST(COUNT(*) AS FLOAT) / @PAGE_SIZE)	AS TotalPage
	FROM S2_Card				AS SC
		JOIN #RankTable			AS SR	ON SR.Card_Seq = SC.Card_Seq
		JOIN S2_CardSalesSite	AS SCS	ON SCS.card_seq = SC.Card_Seq
		JOIN S2_CardImage		AS SCI	ON SCI.Card_Seq = SC.Card_Seq
		JOIN S2_CardDetail		AS SCD	ON SCD.Card_Seq = SC.Card_Seq
		JOIN S2_CardOption		AS SCO	ON SCO.Card_Seq = SC.Card_Seq
		JOIN S2_CardDiscount	AS SCDC ON SCDC.CardDiscount_Seq = SCS.CardDiscount_Seq
	WHERE SCI.CardImage_WSize = @IMAGE_WIDTH
		AND SCI.CardImage_HSize = @IMAGE_HEIGHT
		AND SCI.CardImage_Div = 'E'
		AND SCI.Company_Seq = @COMPANY_SEQ
		AND SCS.Company_Seq = @COMPANY_SEQ
		AND SCDC.MinCount = @ORDER_NUM
		AND SCS.IsDisplay = '1';	
	
	WITH LIST_CTE AS
	(
		SELECT SR.RankNo,
			SC.Card_Seq														AS CardSeq,
			SC.Card_Name													AS CardName,			
			SC.Card_Code													AS CardCode,			
			SC.CardSet_Price												AS CardPrice,
			SC.CardBrand													AS CardBrand,
			SCO.IsSample													AS IsSample,	
			SCS.IsBest														AS IsBest,
			SCS.IsNew														AS IsNew,			
			SCS.isSSPre														AS IsSamsungPreDiscount,
			SCS.Company_Seq													AS CompanySeq,
			SCS.CardDiscount_Seq											AS CardDiscountSeq,
			SCD.Card_Content												AS CardContent,
			SCI.CardImage_FileName											AS CardImageFileName,			
			SCDC.Discount_Rate												AS DiscountRate,			
			ISNULL(SCO.isFSC, '0')											AS IsFsc,
			ROUND((SC.CardSet_Price * (100 - SCDC.Discount_Rate) / 100), 0) AS CardSalePrice,
			SC.RegDate														AS RegDate
			--SCS.IsExtra													AS IsExtra,				
			--SCS.IsExtra2													AS IsExtra2,
			--SCS.IsJumun													AS IsJumun,
			--SCO.isDigitalColor											AS isDigitalColor,
			--SCO.DigitalColor												AS DigitalColor,
			--SCDC.MinCount													AS MinimumCount,
		FROM S2_Card			 	AS SC
			JOIN #RankTable			AS SR	ON SR.Card_Seq = SC.Card_Seq
			JOIN S2_CardSalesSite	AS SCS	ON SCS.card_seq = SC.Card_Seq
			JOIN S2_CardImage		AS SCI	ON SCI.Card_Seq = SC.Card_Seq
			JOIN S2_CardDetail		AS SCD	ON SCD.Card_Seq = SC.Card_Seq
			JOIN S2_CardOption		AS SCO	ON SCO.Card_Seq = SC.Card_Seq
			JOIN S2_CardDiscount	AS SCDC ON SCDC.CardDiscount_Seq = SCS.CardDiscount_Seq
		WHERE SCI.CardImage_WSize = @IMAGE_WIDTH
			AND SCI.CardImage_HSize = @IMAGE_HEIGHT
			AND SCI.CardImage_Div = 'E'
			AND SCI.Company_Seq = @COMPANY_SEQ
			AND SCS.Company_Seq = @COMPANY_SEQ
			AND SCDC.MinCount = @ORDER_NUM
			AND SCS.IsDisplay = '1'	
	)

	SELECT *  	  
	FROM LIST_CTE  
	ORDER BY RankNo ASC 
	OFFSET (@PAGE_NUMBER - 1) * @PAGE_SIZE ROWS  
	FETCH NEXT @PAGE_SIZE ROWS ONLY 
	
END
GO
