IF OBJECT_ID (N'dbo.up_Select_CardCategory_Rank_By_Style', N'P') IS NOT NULL DROP PROCEDURE dbo.up_Select_CardCategory_Rank_By_Style
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		박동혁
-- Create date: 2016-03-15
-- Description:	카드 카테고리별 랭크 반영 카드 조회
--
/*
	exec up_Select_CardCategory_Rank_By_Style 5006, 400, 1
*/
-- =============================================
CREATE PROCEDURE [dbo].[up_Select_CardCategory_Rank_By_Style]
(  
	  @Company_Seq		INT
	, @Order_Num		INT
	, @CardStyle_Num	INT
	, @WSize	varchar(3)
	, @HSize	varchar(3)
)	
AS
BEGIN 
	
	-- 해당 카테고리 상품 총수량
	SELECT
		COUNT(*) AS TotalCard_CNT
	FROM
	(
		SELECT 
			AA.*
		FROM
		(
			SELECT DISTINCT
				A.Card_Seq
				, A.Card_Code
				, A.Card_Name
				, K.Code_Value AS CardBrand_Name
				, A.CardSet_Price
				, A.RegDate
				, CONVERT(INT, F.Discount_Rate) AS Discount_Rate
				, G.CardImage_FileName
				, E.IsNew
				, E.Company_Seq
				, H.IsSample
				, ISNULL(H.isFSC, '0') AS IsFSC
				, D.RankNo
				, D.Cnt
			FROM S2_Card AS A
				INNER JOIN S2_CardStyle AS B
					ON A.Card_Seq = B.Card_Seq
				INNER JOIN S2_CardStyleItem AS C
					ON B.CardStyle_Seq = C.CardStyle_Seq
				INNER JOIN S4_BestTotalRanking_BHands AS D
					ON A.Card_Seq = D.Card_Seq
				INNER JOIN S2_CardSalesSite AS E
					ON A.Card_Seq = E.Card_Seq
				INNER JOIN S2_CardDiscount AS F
					ON E.CardDiscount_Seq = F.CardDiscount_Seq
				INNER JOIN S2_CardImage AS G
					ON A.Card_Seq = G.Card_Seq 
				INNER JOIN S2_CardOption AS H
					ON A.Card_Seq = H.Card_Seq
				INNER JOIN S2_CardKind AS I 
					ON A.card_seq = I.Card_Seq
				INNER JOIN S2_CardKindInfo AS J
					ON I.CardKind_Seq = J.CardKind_Seq
				INNER JOIN Manage_Code AS K
					ON A.CardBrand = K.Code
			WHERE 1 = 1
				AND C.CardStyle_Site = 'A'
				AND C.CardStyle_Category = 'H'
				AND C.CardStyle_Num = @CardStyle_Num
				AND D.Gubun = 'WEEK'
				AND D.Gubun_Date > DATEADD(d, -1, GETDATE())
				AND F.MinCount = @Order_Num 
				AND G.CardImage_WSize = @WSize
				AND G.CardImage_HSize = @HSize
				AND G.CardImage_Div = 'E' 
				AND E.IsDisplay = '1' 
				AND E.Company_Seq = @Company_Seq 
				AND J.CardKind_Seq = 1
				AND K.Code_Type = 'CardBrand'
				AND E.IsJehyu <> '1'
		) AS AA

		UNION ALL

		SELECT
			BB.*
		FROM
		(
			SELECT
				A.*
			FROM 
			(
				SELECT DISTINCT
					A.Card_Seq
					, A.Card_Code
					, A.Card_Name
					, K.Code_Value AS CardBrand_Name
					, A.CardSet_Price
					, A.RegDate
					, CONVERT(INT, F.Discount_Rate) AS Discount_Rate
					, G.CardImage_FileName
					, E.IsNew
					, E.Company_Seq
					, H.IsSample
					, ISNULL(H.isFSC, '0') AS IsFSC
					, 1 AS RankNo
					, 1 AS Cnt
				FROM S2_Card AS A
					INNER JOIN S2_CardStyle AS B
						ON A.Card_Seq = B.Card_Seq
					INNER JOIN S2_CardStyleItem AS C
						ON B.CardStyle_Seq = C.CardStyle_Seq
					INNER JOIN S2_CardSalesSite AS E
						ON A.Card_Seq = E.Card_Seq
					INNER JOIN S2_CardDiscount AS F
						ON E.CardDiscount_Seq = F.CardDiscount_Seq
					INNER JOIN S2_CardImage AS G
						ON A.Card_Seq = G.Card_Seq 
					INNER JOIN S2_CardOption AS H
						ON A.Card_Seq = H.Card_Seq
					INNER JOIN S2_CardKind AS I 
						ON A.card_seq = I.Card_Seq
					INNER JOIN S2_CardKindInfo AS J
						ON I.CardKind_Seq = J.CardKind_Seq
					INNER JOIN Manage_Code AS K
						ON A.CardBrand = K.Code
				WHERE 1 = 1
					AND C.CardStyle_Site = 'A'
					AND C.CardStyle_Category = 'H'
					AND C.CardStyle_Num = @CardStyle_Num
					AND F.MinCount = @Order_Num 
					AND G.CardImage_WSize = @WSize
					AND G.CardImage_HSize = @HSize 
					AND G.CardImage_Div = 'E' 
					AND E.IsDisplay = '1' 
					AND E.Company_Seq = @Company_Seq 
					AND J.CardKind_Seq = 1
					AND K.Code_Type = 'CardBrand'
					AND E.IsJehyu <> '1'
			) AS A
				LEFT OUTER JOIN
				(
					SELECT DISTINCT
						A.Card_Seq
						, A.Card_Code
						, A.Card_Name
						, K.Code_Value AS CardBrand_Name
						, A.CardSet_Price
						, A.RegDate
						, CONVERT(INT, F.Discount_Rate) AS Discount_Rate
						, G.CardImage_FileName
						, E.IsNew
						, E.Company_Seq
						, H.IsSample
						, ISNULL(H.isFSC, '0') AS IsFSC
						, 1 AS RankNo
						, 1 AS Cnt
					FROM S2_Card AS A
						INNER JOIN S2_CardStyle AS B
							ON A.Card_Seq = B.Card_Seq
						INNER JOIN S2_CardStyleItem AS C
							ON B.CardStyle_Seq = C.CardStyle_Seq
						INNER JOIN S4_BestTotalRanking_BHands AS D
							ON A.Card_Seq = D.Card_Seq
						INNER JOIN S2_CardSalesSite AS E
							ON A.Card_Seq = E.Card_Seq
						INNER JOIN S2_CardDiscount AS F
							ON E.CardDiscount_Seq = F.CardDiscount_Seq
						INNER JOIN S2_CardImage AS G
							ON A.Card_Seq = G.Card_Seq 
						INNER JOIN S2_CardOption AS H
							ON A.Card_Seq = H.Card_Seq
						INNER JOIN S2_CardKind AS I 
							ON A.card_seq = I.Card_Seq
						INNER JOIN S2_CardKindInfo AS J
							ON I.CardKind_Seq = J.CardKind_Seq
						INNER JOIN Manage_Code AS K
							ON A.CardBrand = K.Code
					WHERE 1 = 1
						AND C.CardStyle_Site = 'A'
						AND C.CardStyle_Category = 'H'
						AND C.CardStyle_Num = @CardStyle_Num
						AND D.Gubun = 'WEEK'
						AND D.Gubun_Date > DATEADD(d, -1, GETDATE())
						AND F.MinCount = @Order_Num 
						AND G.CardImage_WSize = @WSize 
						AND G.CardImage_HSize = @HSize 
						AND G.CardImage_Div = 'E' 
						AND E.IsDisplay = '1' 
						AND E.Company_Seq = @Company_Seq 
						AND J.CardKind_Seq = 1
						AND K.Code_Type = 'CardBrand'
						AND E.IsJehyu <> '1'	
				) AS B
					ON A.Card_Seq = B.Card_Seq
			WHERE B.Card_Seq IS NULL
		) AS BB
	) AS AAA

	-- 해당 카테고리 상품 리스트
	SELECT
		  AAA.Card_Name
		, AAA.Card_Code
		, AAA.CardBrand_Name
		, AAA.CardSet_Price
		, AAA.Card_Seq
		, AAA.RegDate
		, AAA.Discount_Rate
		, AAA.CardImage_FileName
		, AAA.IsNew
		, AAA.Company_Seq
		, AAA.IsSample
		, AAA.IsFSC
	FROM
	(
		SELECT 
			AA.*
		FROM
		(
			SELECT DISTINCT
				A.Card_Seq
				, A.Card_Code
				, A.Card_Name
				, K.Code_Value AS CardBrand_Name
				, A.CardSet_Price
				, A.RegDate
				, CONVERT(INT, F.Discount_Rate) AS Discount_Rate
				, G.CardImage_FileName
				, E.IsNew
				, E.Company_Seq
				, H.IsSample
				, ISNULL(H.isFSC, '0') AS IsFSC
				, D.RankNo
				, D.Cnt
			FROM S2_Card AS A
				INNER JOIN S2_CardStyle AS B
					ON A.Card_Seq = B.Card_Seq
				INNER JOIN S2_CardStyleItem AS C
					ON B.CardStyle_Seq = C.CardStyle_Seq
				INNER JOIN S4_BestTotalRanking_BHands AS D
					ON A.Card_Seq = D.Card_Seq
				INNER JOIN S2_CardSalesSite AS E
					ON A.Card_Seq = E.Card_Seq
				INNER JOIN S2_CardDiscount AS F
					ON E.CardDiscount_Seq = F.CardDiscount_Seq
				INNER JOIN S2_CardImage AS G
					ON A.Card_Seq = G.Card_Seq 
				INNER JOIN S2_CardOption AS H
					ON A.Card_Seq = H.Card_Seq
				INNER JOIN S2_CardKind AS I 
					ON A.card_seq = I.Card_Seq
				INNER JOIN S2_CardKindInfo AS J
					ON I.CardKind_Seq = J.CardKind_Seq
				INNER JOIN Manage_Code AS K
					ON A.CardBrand = K.Code
			WHERE 1 = 1
				AND C.CardStyle_Site = 'A'
				AND C.CardStyle_Category = 'H'
				AND C.CardStyle_Num = @CardStyle_Num
				AND D.Gubun = 'WEEK'
				AND D.Gubun_Date > DATEADD(d, -1, GETDATE())
				AND F.MinCount = @Order_Num 
				AND G.CardImage_WSize = @WSize 
				AND G.CardImage_HSize = @HSize 
				AND G.CardImage_Div = 'E' 
				AND E.IsDisplay = '1' 
				AND E.Company_Seq = @Company_Seq 
				AND J.CardKind_Seq = 1
				AND K.Code_Type = 'CardBrand'
				AND E.IsJehyu <> '1'	
		) AS AA

		UNION ALL

		SELECT
			BB.*
		FROM
		(
			SELECT
				A.*
			FROM 
			(
				SELECT DISTINCT
					A.Card_Seq
					, A.Card_Code
					, A.Card_Name
					, K.Code_Value AS CardBrand_Name
					, A.CardSet_Price
					, A.RegDate
					, CONVERT(INT, F.Discount_Rate) AS Discount_Rate
					, G.CardImage_FileName
					, E.IsNew
					, E.Company_Seq
					, H.IsSample
					, ISNULL(H.isFSC, '0') AS IsFSC
					, 1 AS RankNo
					, 1 AS Cnt
				FROM S2_Card AS A
					INNER JOIN S2_CardStyle AS B
						ON A.Card_Seq = B.Card_Seq
					INNER JOIN S2_CardStyleItem AS C
						ON B.CardStyle_Seq = C.CardStyle_Seq
					INNER JOIN S2_CardSalesSite AS E
						ON A.Card_Seq = E.Card_Seq
					INNER JOIN S2_CardDiscount AS F
						ON E.CardDiscount_Seq = F.CardDiscount_Seq
					INNER JOIN S2_CardImage AS G
						ON A.Card_Seq = G.Card_Seq 
					INNER JOIN S2_CardOption AS H
						ON A.Card_Seq = H.Card_Seq
					INNER JOIN S2_CardKind AS I 
						ON A.card_seq = I.Card_Seq
					INNER JOIN S2_CardKindInfo AS J
						ON I.CardKind_Seq = J.CardKind_Seq
					INNER JOIN Manage_Code AS K
						ON A.CardBrand = K.Code
				WHERE 1 = 1
					AND C.CardStyle_Site = 'A'
					AND C.CardStyle_Category = 'H'
					AND C.CardStyle_Num = @CardStyle_Num
					AND F.MinCount = @Order_Num 
					AND G.CardImage_WSize = @WSize 
					AND G.CardImage_HSize = @HSize
					AND G.CardImage_Div = 'E' 
					AND E.IsDisplay = '1' 
					AND E.Company_Seq = @Company_Seq 
					AND J.CardKind_Seq = 1
					AND K.Code_Type = 'CardBrand'
					AND E.IsJehyu <> '1' 
			) AS A
				LEFT OUTER JOIN
				(
					SELECT DISTINCT
						A.Card_Seq
						, A.Card_Code
						, A.Card_Name
						, K.Code_Value AS CardBrand_Name
						, A.CardSet_Price
						, A.RegDate
						, CONVERT(INT, F.Discount_Rate) AS Discount_Rate
						, G.CardImage_FileName
						, E.IsNew
						, E.Company_Seq
						, H.IsSample
						, ISNULL(H.isFSC, '0') AS IsFSC
						, 1 AS RankNo
						, 1 AS Cnt
					FROM S2_Card AS A
						INNER JOIN S2_CardStyle AS B
							ON A.Card_Seq = B.Card_Seq
						INNER JOIN S2_CardStyleItem AS C
							ON B.CardStyle_Seq = C.CardStyle_Seq
						INNER JOIN S4_BestTotalRanking_BHands AS D
							ON A.Card_Seq = D.Card_Seq
						INNER JOIN S2_CardSalesSite AS E
							ON A.Card_Seq = E.Card_Seq
						INNER JOIN S2_CardDiscount AS F
							ON E.CardDiscount_Seq = F.CardDiscount_Seq
						INNER JOIN S2_CardImage AS G
							ON A.Card_Seq = G.Card_Seq 
						INNER JOIN S2_CardOption AS H
							ON A.Card_Seq = H.Card_Seq
						INNER JOIN S2_CardKind AS I 
							ON A.card_seq = I.Card_Seq
						INNER JOIN S2_CardKindInfo AS J
							ON I.CardKind_Seq = J.CardKind_Seq
						INNER JOIN Manage_Code AS K
							ON A.CardBrand = K.Code
					WHERE 1 = 1
						AND C.CardStyle_Site = 'A'
						AND C.CardStyle_Category = 'H'
						AND C.CardStyle_Num = @CardStyle_Num
						AND D.Gubun = 'WEEK'
						AND D.Gubun_Date > DATEADD(d, -1, GETDATE())
						AND F.MinCount = @Order_Num 
						AND G.CardImage_WSize = @WSize 
						AND G.CardImage_HSize = @HSize 
						AND G.CardImage_Div = 'E' 
						AND E.IsDisplay = '1' 
						AND E.Company_Seq = @Company_Seq 
						AND J.CardKind_Seq = 1
						AND K.Code_Type = 'CardBrand'
						AND E.IsJehyu <> '1'
				) AS B
					ON A.Card_Seq = B.Card_Seq
			WHERE B.Card_Seq IS NULL
		) AS BB
	) AS AAA
	ORDER BY
		CASE WHEN AAA.Cnt > 1 THEN AAA.Cnt END DESC
		, CASE WHEN AAA.Cnt = 1 THEN AAA.RegDate END DESC


END

GO
