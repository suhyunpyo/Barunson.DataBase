IF OBJECT_ID (N'invtmng.sp_S2BestRanking_ww', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_S2BestRanking_ww
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      PROC [invtmng].[sp_S2BestRanking_ww]
AS
	Declare @company_seq integer
	Declare 	@card_seq integer	
	Declare	@cnt	integer
	Declare	@rank	integer
	Declare @Gubun char(1)
	Declare @gubun_data varchar(10)



	--매주 일요일에 집계 실행.
	set @gubun_data	= cast(datepart(year,getdate()) as varchar(4)) + cast(datepart(week,getdate()) as varchar(2))


	--주간 주문 수량.
	set @rank = 0
	set @Gubun = '0'
	set @company_seq=5001
	while (@company_seq<=5005)
	begin
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 30 card_seq, sum(order_count) as cnt
			FROM
			custom_order
			WHERE company_seq = @company_seq and DATEDIFF(week,src_send_date,getdate()) = 1 and status_seq=15 and order_Type in ('1','6','7')
			group by sales_gubun,card_seq
			order by cnt desc
		OPEN item_cursor
	
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRanking_New(company_seq,rank,card_seq,cnt,gubun,gubun_data) values(@company_seq,@rank,@card_seq,@cnt,@Gubun,@gubun_data)
	
			FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor
		set @company_seq = @company_seq + 1
	end




GO
