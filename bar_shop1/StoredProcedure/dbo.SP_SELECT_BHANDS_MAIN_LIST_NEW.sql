IF OBJECT_ID (N'dbo.SP_SELECT_BHANDS_MAIN_LIST_NEW', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_BHANDS_MAIN_LIST_NEW
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

비핸즈 메인 리뉴얼 
EXEC SP_SELECT_BHANDS_MAIN_LIST_NEW 418, 8, 350 
2018.11.14 수량추가

*/
CREATE PROCEDURE [dbo].[SP_SELECT_BHANDS_MAIN_LIST_NEW]
    @MD_SEQ AS INT
,   @SELET_CNT AS INT
,   @ORDER_NUM AS INT
	AS
BEGIN
/*
	
	SELECT COUNT(*) AS cnt
	FROM S4_MD_Choice A JOIN S2_Card B ON A.card_seq = B.Card_Seq  
		JOIN S2_CardSalesSite C ON A.card_seq = C.Card_Seq 
		JOIN S2_CardDiscount D ON C.CardDiscount_Seq = D.CardDiscount_Seq  
	WHERE A.md_seq = @MD_SEQ  
		and C.Company_Seq=5006  
		and D.MinCount=300  
		and C.IsDisplay = 1 
	GROUP BY A.card_seq, C.Company_Seq, B.Card_Name, B.CardSet_Price, D.Discount_Rate, B.Card_Code, A.sorting_num, A.seq
*/

	SELECT TOP (@SELET_CNT) A.card_seq
		, C.Company_Seq
		, B.Card_Name
		, B.CardSet_Price
		, CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate
		, B.Card_Code
		, A.sorting_num
		, A.seq 
		--, Round((b.cardset_price*(100-D.discount_rate)/100),0) * 300 AS cardsale_price
		, replace( convert( VARCHAR, convert(MONEY , B.CardSet_Price * @ORDER_NUM),1), '.00', '' )  cardset_total_price 
		, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(round((B.CardSet_Price * ((100 - D.Discount_Rate) * 0.01)) , 0) * @ORDER_NUM)),1), '.00', '') cardsale_price
		,(select IsSample from s2_cardoption where card_seq = a.card_seq) isSample
	FROM S4_MD_Choice A JOIN S2_Card B ON A.card_seq = B.Card_Seq  
		JOIN S2_CardSalesSite C ON A.card_seq = C.Card_Seq 
		JOIN S2_CardDiscount D ON C.CardDiscount_Seq = D.CardDiscount_Seq  
	WHERE A.md_seq = @MD_SEQ  
		and C.Company_Seq=5006  
		and D.MinCount=@ORDER_NUM  
		and C.IsDisplay = 1 
	GROUP BY A.card_seq, C.Company_Seq, B.Card_Name, B.CardSet_Price, D.Discount_Rate, B.Card_Code, A.sorting_num, A.seq
	ORDER BY A.sorting_num ASC 

END
GO
