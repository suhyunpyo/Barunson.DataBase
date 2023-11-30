IF OBJECT_ID (N'dbo.sp_BrandRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BrandRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec sp_BrandRanking
CREATE Proc [dbo].[sp_BrandRanking]
AS

SET NOCOUNT ON

BEGIN
	SELECT a.rank,a.card_seq,a.RankChangeGubun,a.RankChangeNo,a.card_code,a.card_name,a.CardBrand,a.card_price,a.card_image,a.CardSet_Price,a.company_seq,a.Discount_Rate,a.cardsale_price
	INTO #BrRanking
	FROM (	
		SELECT Top 10 A.rank,A.card_seq,A.RankChangeGubun,A.RankChangeNo,B.card_code,B.card_name,B.CardBrand as CardBrand,B.card_price,B.card_image,B.CardSet_Price,C.company_seq,D.Discount_Rate,(B.CardSet_Price*(100-D.Discount_Rate)/100) as cardsale_price
		FROM BestRanking_New A inner join S2_Card B on A.card_seq = B.card_seq 
		JOIN S2_CardSalesSite C on A.card_seq=C.card_seq 
		JOIN S2_CardDiscount D ON D.CardDiscount_Seq = C.CardDiscount_Seq 
		WHERE A.company_seq = 5001 and C.company_seq = 5001
		and A.gubun='1' and A.gubun_data='2010-08-01'and D.minCount=400 and C.isDisplay='1' 

		UNION
		
		SELECT Top 10 A.rank,A.card_seq,A.RankChangeGubun,A.RankChangeNo,B.card_code,B.card_name,B.CardBrand as CardBrand,B.card_price,B.card_image,B.CardSet_Price,C.company_seq,D.Discount_Rate,(B.CardSet_Price*(100-D.Discount_Rate)/100) as cardsale_price 
		FROM BestRanking_New A inner join S2_Card B on A.card_seq = B.card_seq 
		JOIN S2_CardSalesSite C on A.card_seq=C.card_seq 
		JOIN S2_CardDiscount D ON D.CardDiscount_Seq = C.CardDiscount_Seq 
		WHERE A.company_seq = 5002 and C.company_seq = 5002
		and A.gubun='1' and A.gubun_data='2010-08-01'and D.minCount=400 and C.isDisplay='1' 
		
		UNION
		
		SELECT Top 10 A.rank,A.card_seq,A.RankChangeGubun,A.RankChangeNo,B.card_code,B.card_name,B.CardBrand as CardBrand,B.card_price,B.card_image,B.CardSet_Price,C.company_seq,D.Discount_Rate,(B.CardSet_Price*(100-D.Discount_Rate)/100) as cardsale_price 
		FROM BestRanking_New A inner join S2_Card B on A.card_seq = B.card_seq 
		JOIN S2_CardSalesSite C on A.card_seq=C.card_seq 
		JOIN S2_CardDiscount D ON D.CardDiscount_Seq = C.CardDiscount_Seq 
		WHERE A.company_seq = 5003 and C.company_seq = 5003
		and A.gubun='1' and A.gubun_data='2010-08-01'and D.minCount=400 and C.isDisplay='1' 
		
		UNION
		
		SELECT Top 10 A.rank,A.card_seq,A.RankChangeGubun,A.RankChangeNo,B.card_code,B.card_name,B.CardBrand as CardBrand,B.card_price,B.card_image,B.CardSet_Price,C.company_seq,D.Discount_Rate,(B.CardSet_Price*(100-D.Discount_Rate)/100) as cardsale_price 
		FROM BestRanking_New A inner join S2_Card B on A.card_seq = B.card_seq 
		JOIN S2_CardSalesSite C on A.card_seq=C.card_seq 
		JOIN S2_CardDiscount D ON D.CardDiscount_Seq = C.CardDiscount_Seq 
		WHERE A.company_seq = 5004 and C.company_seq = 5004
		and A.gubun='1' and A.gubun_data='2010-08-01'and D.minCount=400 and C.isDisplay='1' 
		
		UNION
		
		SELECT Top 10 A.rank,A.card_seq,A.RankChangeGubun,A.RankChangeNo,B.card_code,B.card_name,B.CardBrand as CardBrand,B.card_price,B.card_image,B.CardSet_Price,C.company_seq,D.Discount_Rate,(B.CardSet_Price*(100-D.Discount_Rate)/100) as cardsale_price 
		FROM BestRanking_New A inner join S2_Card B on A.card_seq = B.card_seq 
		JOIN S2_CardSalesSite C on A.card_seq=C.card_seq 
		JOIN S2_CardDiscount D ON D.CardDiscount_Seq = C.CardDiscount_Seq 
		WHERE A.company_seq = 5005 and C.company_seq = 5005
		and A.gubun='1' and A.gubun_data='2010-08-01'and D.minCount=400 and C.isDisplay='1' 
		)  a 


SELECT a.rank,a.card_seq,a.RankChangeGubun,a.RankChangeNo,a.card_code,a.card_name,a.CardBrand,a.card_price,a.card_image,a.CardSet_Price,a.company_seq,a.Discount_Rate,
	   a.cardsale_price,IsNull(b.cnt,0) as chooCnt,IsNull(c.cnt,0) as zzimCnt,
	   d.isbest,d.isnew,d.isextra,e.card_content,f.issample,g.cardimage_filename 
FROM #BrRanking a LEFT JOIN (
							SELECT  a.card_seq,count(*) as cnt
							FROM #BrRanking a JOIN S2_RecommendCard b ON a.Card_seq = b.Card_seq  
							GROUP BY a.card_seq
							) b ON a.Card_seq = b.Card_seq 
				  LEFT JOIN ( 
							SELECT  a.card_seq,count(*) as cnt
							FROM #BrRanking a JOIN S2_WishCard b ON a.Card_seq = b.Card_seq  
							GROUP BY a.card_seq	
							) c ON a.card_seq = c.card_seq
	JOIN s2_cardsalessite d on a.card_seq = d.card_seq
	JOIN s2_cardDetail e on a.card_seq = e.card_seq
	JOIN s2_cardOption f on a.card_seq = f.card_seq
	JOIN s2_CardImage g on a.card_seq = g.card_seq
WHERE g.cardimage_wsize='160' and g.cardimage_hsize='160'				  											
END	
	
GO
