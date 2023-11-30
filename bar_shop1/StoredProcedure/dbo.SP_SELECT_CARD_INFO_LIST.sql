IF OBJECT_ID (N'dbo.SP_SELECT_CARD_INFO_LIST', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CARD_INFO_LIST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC [SP_SELECT_CARD_INFO_LIST]

CREATE PROCEDURE [dbo].[SP_SELECT_CARD_INFO_LIST]
	AS
BEGIN



SELECT	A.Card_Code	
	,	A.Card_Name
	,	A.CardSet_Price
	,	A.Card_Price

	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.Env_Seq WHERE CD.Card_Seq = A.Card_Seq)         , '') AS Env
	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.Inpaper_Seq WHERE CD.Card_Seq = A.Card_Seq)     , '') AS Inpaper
	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.Acc1_Seq WHERE CD.Card_Seq = A.Card_Seq)        , '') AS Acc1
	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.Acc2_Seq WHERE CD.Card_Seq = A.Card_Seq)        , '') AS Acc2
	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.MapCard_Seq WHERE CD.Card_Seq = A.Card_Seq)     , '') AS MapCard
	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.GreetingCard_Seq WHERE CD.Card_Seq = A.Card_Seq), '') AS GreetingCard
	,	ISNULL((SELECT C.Card_Code FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.Lining_Seq WHERE CD.Card_Seq = A.Card_Seq)      , '') AS Lining
	
	,	CASE	WHEN UPPER(A.CardBrand) = 'A' THEN '티아라카드'
				WHEN UPPER(a.CardBrand) = 'B' THEN '바른손카드'
				WHEN UPPER(a.CardBrand) = 'G' THEN '가랑카드'
				WHEN UPPER(a.CardBrand) = 'H' THEN '해피카드'
				WHEN UPPER(a.CardBrand) = 'P' THEN 'W페이퍼'
				WHEN UPPER(a.CardBrand) = 'S' THEN '스토리오브러브'
				WHEN UPPER(a.CardBrand) = 'T' THEN '티로즈'
				WHEN UPPER(a.CardBrand) = 'W' THEN '위시메이드'
				WHEN UPPER(a.CardBrand) = 'Y' THEN '예카드'
				ELSE '기타' END AS CardBrand
	
	,	CASE	WHEN S2CD.Card_Folding  = 'S1' THEN '세로1번 접기'
				WHEN S2CD.Card_Folding  = 'S2' THEN '세로2번 접기'
				WHEN S2CD.Card_Folding  = 'G1' THEN '가로1번 접기'
				WHEN S2CD.Card_Folding  = 'G2' THEN '가로2번 접기'
				WHEN S2CD.Card_Folding  = 'S3' THEN '세로3번 접기'
				WHEN S2CD.Card_Folding  = 'G3' THEN '가로3번 접기'
				WHEN S2CD.Card_Folding  = 'S4' THEN '세로4번 접기'
				WHEN S2CD.Card_Folding  = 'G4' THEN '가로4번 접기'
				WHEN S2CD.Card_Folding  = 'ETC' THEN '기타'
				WHEN S2CD.Card_Folding  = 'E0' THEN '엽서형'
				WHEN S2CD.Card_Folding  = '0' THEN '기타'
				ELSE '접선없음' END AS Card_Folding
				
	,	CASE	WHEN S2CD.card_shape = '2' THEN '직사각형(가로)'
				WHEN S2CD.card_shape = '3' THEN '직사각형(세로)'
				ELSE '정사각형' END AS card_shape
	
	
	,	ISNULL((SELECT CD.Card_Material FROM S2_CardDetail CD JOIN S2_Card C ON C.Card_Seq = CD.Card_Seq WHERE CD.Card_Seq = A.Card_Seq), '')   AS Material
	,	A.Card_WSize
	,	A.Card_HSize	
	
FROM	S2_CARD A 
LEFT JOIN	S2_CardDetail S2CD ON A.Card_Seq = S2CD.Card_Seq
WHERE	A.Card_Div = 'A01'
AND     A.CARD_SEQ IN (SELECT CARD_SEQ FROM S2_CARDSALESSITE WHERE COMPANY_SEQ = 5001 AND ISDISPLAY = 1)



END
GO
