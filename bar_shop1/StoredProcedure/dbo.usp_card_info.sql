IF OBJECT_ID (N'dbo.usp_card_info', N'P') IS NOT NULL DROP PROCEDURE dbo.usp_card_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /*
 usp_card_info 'BH9416;BH9447;BH9445'
 */
CREATE PROCEDURE [dbo].[usp_card_info]    
@MD_TITLE AS VARCHAR(100) = ''
AS    
BEGIN    

SELECT CARD_SEQ, CARD_CODE, CARD_NAME, CARD_PRICE FROM (
	SELECT ROW_NUMBER() OVER(PARTITION BY a.CARD_SEQ ORDER BY E.NO) AS RN,
	ROW_NUMBER() OVER(ORDER BY E.NO) AS NO,
	a.CARD_SEQ, CARD_CODE, CARD_NAME,
	FORMAT(CAST(ROUND(CardSet_Price*((100-Discount_Rate) * 0.01),0)*MinCount as INT), N'#,0') + '원' CARD_PRICE
	FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq
	JOIN S2_CardSalesSite c ON a.Card_Seq = c.Card_Seq
	JOIN S2_CardDiscount d ON c.CardDiscount_Seq = d.CardDiscount_Seq
	JOIN (SELECT NO, VALUE FROM FN_SPLIT2(@MD_TITLE,';')) e ON a.Card_Code = e.VALUE
	and MinCount = 300
) T WHERE RN = 1

END 
GO
