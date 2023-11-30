IF OBJECT_ID (N'dbo.sp_stat_CardSumBrand', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_stat_CardSumBrand
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/*
	'사이트,브랜드 판매수량/금액
*/

CREATE   Procedure [dbo].[sp_stat_CardSumBrand]
	@sales_gubun char(1),	
	@sdate 	char(8),		-- 검색 시작일
	@edate  char(8)		-- 검색 종료일
as
begin

	if @sales_gubun = ''
		begin
			select  b.company ,IsNull(sum(order_count),0) as sum_count, IsNull(sum(settle_price),0) as sum_price  from 
			  (
			  select order_seq,card_seq,order_count,settle_price from custom_order 
			  where Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('W','T','U','A','B')
			  ) a Right Join (select distinct company,card_seq from card) b
			  on a.card_seq = b.card_seq
			 group by b.company			

		end
	else	
		begin			
			select  b.company ,IsNull(sum(order_count),0) as sum_count, IsNull(sum(settle_price),0) as sum_price  from 
			  (
			  select order_seq,card_seq,order_count,settle_price from custom_order 
			  where Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun =@sales_gubun
			  ) a Right Join (select distinct company,card_seq from card) b
			  on a.card_seq = b.card_seq
			 group by b.company			

		end

end



GO
