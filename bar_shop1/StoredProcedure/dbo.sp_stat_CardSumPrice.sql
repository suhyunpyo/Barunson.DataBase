IF OBJECT_ID (N'dbo.sp_stat_CardSumPrice', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_stat_CardSumPrice
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO




/*
	'사이트,브랜드 판매수량/금액
*/

create   Procedure [dbo].[sp_stat_CardSumPrice]
	@sales_gubun char(1),	
	@sdate 	char(8),		-- 검색 시작일
	@edate  char(8)		-- 검색 종료일
as
begin

	if @sales_gubun = ''
		begin
			select  b.card_price,IsNull(sum(order_count),0) as sum_count, IsNull(sum(settle_price),0) as sum_price  from 
			  (
			  select order_seq,card_seq,order_count,settle_price from custom_order 
			  where Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('W','T','U','A','B')
			  ) a Right Join (select distinct card_seq,card_price = Case
		When CARD_PRICE_CUSTOMER >=100 and  CARD_PRICE_CUSTOMER <200 Then 100
		 When CARD_PRICE_CUSTOMER >=200 and  CARD_PRICE_CUSTOMER <300 Then 200
		When CARD_PRICE_CUSTOMER >=300 and  CARD_PRICE_CUSTOMER <400 Then 300
		When CARD_PRICE_CUSTOMER >=400 and  CARD_PRICE_CUSTOMER <500 Then 400
		When CARD_PRICE_CUSTOMER >=500 and  CARD_PRICE_CUSTOMER <600 Then 500
		When CARD_PRICE_CUSTOMER >=600 and  CARD_PRICE_CUSTOMER <700 Then 600
		When CARD_PRICE_CUSTOMER >=700 and  CARD_PRICE_CUSTOMER <800 Then 700
		 When CARD_PRICE_CUSTOMER >=800 and  CARD_PRICE_CUSTOMER <900 Then 800
		When CARD_PRICE_CUSTOMER >=900 and  CARD_PRICE_CUSTOMER <1000 Then 900
		When CARD_PRICE_CUSTOMER >=1000 and  CARD_PRICE_CUSTOMER <1100 Then 1000
		When CARD_PRICE_CUSTOMER >=1100 and  CARD_PRICE_CUSTOMER <1200 Then 1100
		When CARD_PRICE_CUSTOMER >=1200 and  CARD_PRICE_CUSTOMER <1300 Then 1200	
		 When CARD_PRICE_CUSTOMER >=1300 and  CARD_PRICE_CUSTOMER <1400 Then 1300
		When CARD_PRICE_CUSTOMER >=1400 and  CARD_PRICE_CUSTOMER <1500 Then 1400
		When CARD_PRICE_CUSTOMER >=1500 and  CARD_PRICE_CUSTOMER <1600 Then 1500
		When CARD_PRICE_CUSTOMER >=1600 and  CARD_PRICE_CUSTOMER <1700 Then 1600
		When CARD_PRICE_CUSTOMER >=1700 and  CARD_PRICE_CUSTOMER <1800 Then 1700	
		When CARD_PRICE_CUSTOMER >=1800 and  CARD_PRICE_CUSTOMER <1900 Then 1800
		When CARD_PRICE_CUSTOMER >=1900 and  CARD_PRICE_CUSTOMER <2000 Then 1900
		When CARD_PRICE_CUSTOMER >=2000 Then 2000
		end  from card where card_cate='I1' and card_price_customer>0) b
			  on a.card_seq = b.card_seq
			 group by b.card_price	
			 order by b.card_price	


		end
	else	
		begin			
			select  b.card_price,IsNull(sum(order_count),0) as sum_count, IsNull(sum(settle_price),0) as sum_price  from 
			  (
			  select order_seq,card_seq,order_count,settle_price from custom_order 
			  where Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun =@sales_gubun
			  ) a Right Join (select distinct company,card_seq,card_price = Case
		When CARD_PRICE_CUSTOMER >=100 and  CARD_PRICE_CUSTOMER <200 Then 100
		 When CARD_PRICE_CUSTOMER >=200 and  CARD_PRICE_CUSTOMER <300 Then 200
		When CARD_PRICE_CUSTOMER >=300 and  CARD_PRICE_CUSTOMER <400 Then 300
		When CARD_PRICE_CUSTOMER >=400 and  CARD_PRICE_CUSTOMER <500 Then 400
		When CARD_PRICE_CUSTOMER >=500 and  CARD_PRICE_CUSTOMER <600 Then 500
		When CARD_PRICE_CUSTOMER >=600 and  CARD_PRICE_CUSTOMER <700 Then 600
		When CARD_PRICE_CUSTOMER >=700 and  CARD_PRICE_CUSTOMER <800 Then 700
		 When CARD_PRICE_CUSTOMER >=800 and  CARD_PRICE_CUSTOMER <900 Then 800
		When CARD_PRICE_CUSTOMER >=900 and  CARD_PRICE_CUSTOMER <1000 Then 900
		When CARD_PRICE_CUSTOMER >=1000 and  CARD_PRICE_CUSTOMER <1100 Then 1000
		When CARD_PRICE_CUSTOMER >=1100 and  CARD_PRICE_CUSTOMER <1200 Then 1100
		When CARD_PRICE_CUSTOMER >=1200 and  CARD_PRICE_CUSTOMER <1300 Then 1200	
		 When CARD_PRICE_CUSTOMER >=1300 and  CARD_PRICE_CUSTOMER <1400 Then 1300
		When CARD_PRICE_CUSTOMER >=1400 and  CARD_PRICE_CUSTOMER <1500 Then 1400
		When CARD_PRICE_CUSTOMER >=1500 and  CARD_PRICE_CUSTOMER <1600 Then 1500
		When CARD_PRICE_CUSTOMER >=1600 and  CARD_PRICE_CUSTOMER <1700 Then 1600
		When CARD_PRICE_CUSTOMER >=1700 and  CARD_PRICE_CUSTOMER <1800 Then 1700	
		When CARD_PRICE_CUSTOMER >=1800 and  CARD_PRICE_CUSTOMER <1900 Then 1800
		When CARD_PRICE_CUSTOMER >=1900 and  CARD_PRICE_CUSTOMER <2000 Then 1900
		When CARD_PRICE_CUSTOMER >=2000 Then 2000
		end from card where card_cate='I1' and card_price_customer>0) b
			  on a.card_seq = b.card_seq
			 group by b.card_price		
			 order by b.card_price	

		end

end



GO
