IF OBJECT_ID (N'dbo.S2_CardViewSMART', N'V') IS NOT NULL DROP View dbo.S2_CardViewSMART
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  VIEW [dbo].[S2_CardViewSMART]
AS
SELECT  Card_Seq,Card_Code, Card_Group as company_seq, DISPLAY_YES_OR_NO as isDisplay,JUMUN_YES_OR_NO as isJumun,card_price_customer
FROM      Card  where card_cate='I1'
UNION
SELECT   a.Card_Seq,Card_Code,b.Company_Seq, IsDisplay ,isJumun, a.CardSet_price
FROM      S2_Card a JOIN S2_CardSalesSite b ON a.Card_Seq = b.Card_Seq where A.card_div in ('A01','C03')


GO
