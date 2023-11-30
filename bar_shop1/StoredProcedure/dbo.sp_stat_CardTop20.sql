IF OBJECT_ID (N'dbo.sp_stat_CardTop20', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_stat_CardTop20
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO



/*
	'사이트별 상위판매제품 Top20 판매수량 & 금액 
*/

CREATE   Procedure [dbo].[sp_stat_CardTop20]
	@sales_gubun char(1),	
	@sdate 	char(8),		-- 검색 시작일
	@edate  char(8)		-- 검색 종료일
as
begin

	declare @totPrice bigint		-- 전체 매출액

	if @sales_gubun = ''
		begin
			set @totPrice = (select cast(sum(settle_price) as bigint) from custom_order where status_seq=15 and  Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun in ('W','T','U','A','B'))
			
			select top 20 c.card_code,  sum(a.order_count) as sum_count, sum(a.settle_price) as sum_price,(cast(sum(a.settle_price) as float)/@totPrice )*100 as 'B점유율'  from 
				custom_order a join card c 
				on a.card_seq = c.card_seq
				where status_seq=15 and Convert(char(8),a.src_send_date,112) between @sdate and @edate and sales_gubun in ('W','T','U','A','B')
				group by a.sales_gubun,c.card_code
				order by sum_count desc 
		
		end
	else	
		begin	
		
			set @totPrice = (select cast(sum(settle_price) as bigint) from custom_order where status_seq=15 and  Convert(char(8),src_send_date,112) between @sdate and @edate and sales_gubun =@sales_gubun)
			
			select top 20 c.card_code,  sum(a.order_count) as sum_count, sum(a.settle_price) as sum_price,(cast(sum(a.settle_price) as float)/@totPrice )*100 as 'B점유율'  from 
				custom_order a join card c 
				on a.card_seq = c.card_seq
				where status_seq=15 and Convert(char(8),a.src_send_date,112) between @sdate and @edate and sales_gubun=@sales_gubun
				group by a.sales_gubun,c.card_code
				order by sum_count desc 
		end

end


GO
