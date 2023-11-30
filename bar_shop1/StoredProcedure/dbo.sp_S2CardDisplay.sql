IF OBJECT_ID (N'dbo.sp_S2CardDisplay', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardDisplay
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE      Procedure [dbo].[sp_S2CardDisplay]
	@card_code 	varchar(10)
as
begin

select a.card_code as 제품코드,a.cardbrand as 브랜드,cardset_price as 셋트가격
,ISNULL(b.discount_rate,0) as 바른손카드할인율,ISNULL(c.discount_rate,0) as 프리미어할인율,ISNULL(d.discount_rate,0) as 비핸즈카드할인율,ISNULL(e.discount_rate,0) as 더카드할인율
,ISNULL(b.isDisplay,'0') as 바른손카드전시,ISNULL(c.isDisplay,'0') as 프리미어전시,ISNULL(d.isDisplay,'0') as 비핸즈카드전시,ISNULL(e.isDisplay,'0') as 더카드전시
from (

select  distinct card_code,cardset_price,CASE CardBrand WHEN 'B' THEN '바른손카드'      
      WHEN 'W' THEN '위시메이드'
      WHEN 'S' THEN '스토리오브러브'
      WHEN 'H' THEN '해피카드'
      WHEN 'P' THEN 'W페이퍼' 
      WHEN 'A' THEN '티아라카드' 
      END AS CardBrand from s2_card where card_div='A01'
      group by card_code,CardSet_Price,cardbrand
            ) a
            Left Join
            (
            select card_code,'바른손카드' as site_name,ISNULL(discount_rate,0) as discount_rate,ISNULL(isDisplay,'0') as isDisplay
            from S2_Card left outer join S2_CardSalesSite on S2_Card.Card_Seq = S2_CardSalesSite.card_seq ,S2_CardDiscount
			where S2_CardSalesSite.CardDiscount_Seq = S2_CardDiscount.CardDiscount_Seq
			and MinCount=400 and Card_Div='A01' and S2_CardSalesSite.company_seq=5001
            ) b
            on a.card_code = b.card_code
            Left Join
            (
             select card_code,'프리미어비핸즈' as site_name,ISNULL(discount_rate,0) as discount_rate,ISNULL(isDisplay,'0') as isDisplay
            from S2_Card left outer join S2_CardSalesSite on S2_Card.Card_Seq = S2_CardSalesSite.card_seq ,S2_CardDiscount
			where S2_CardSalesSite.CardDiscount_Seq = S2_CardDiscount.CardDiscount_Seq
			and MinCount=400 and Card_Div='A01' and S2_CardSalesSite.company_seq=5003
			) c
			on a.card_code = c.card_code
            Left Join
            (
             select card_code,'비핸즈카드' as site_name,ISNULL(discount_rate,0) as discount_rate,ISNULL(isDisplay,'0') as isDisplay
            from S2_Card left outer join S2_CardSalesSite on S2_Card.Card_Seq = S2_CardSalesSite.card_seq ,S2_CardDiscount
			where S2_CardSalesSite.CardDiscount_Seq = S2_CardDiscount.CardDiscount_Seq
			and MinCount=400 and Card_Div='A01' and S2_CardSalesSite.company_seq=5006
			) d
			on a.card_code = d.card_code
            Left Join
            (
             select card_code,'더카드' as site_name,ISNULL(discount_rate,0) as discount_rate,ISNULL(isDisplay,'0') as isDisplay
            from S2_Card left outer join S2_CardSalesSite on S2_Card.Card_Seq = S2_CardSalesSite.card_seq ,S2_CardDiscount
			where S2_CardSalesSite.CardDiscount_Seq = S2_CardDiscount.CardDiscount_Seq
			and MinCount=400 and Card_Div='A01' and S2_CardSalesSite.company_seq=5007
			) e
			on a.card_code = e.card_code		

where a.cardbrand is not null
order by a.card_code	


end						
GO
