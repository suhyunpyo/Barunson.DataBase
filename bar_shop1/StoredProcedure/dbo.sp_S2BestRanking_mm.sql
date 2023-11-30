IF OBJECT_ID (N'dbo.sp_S2BestRanking_mm', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2BestRanking_mm
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--exec sp_BarunsonRanking_mm
CREATE         PROC [dbo].[sp_S2BestRanking_mm]
AS
	Declare 	@card_seq integer	
	Declare @company_seq integer
	Declare	@cnt	integer
	Declare	@rank	integer
	Declare @Gubun char(1)
	Declare @gubun_data varchar(10)

	--매월 첫일날 월간 집계 실행.


	set @gubun_data	= cast(datepart(year,dateadd(month,-1,getdate())) as varchar(4)) + cast(datepart(mm, dateadd(month,-1,getdate())) as varchar(2))

	--set @gubun_data	= '200911'

	--월간 주문 수량.
	set @rank = 0
	set @Gubun = '1'
	set @company_seq=5001
	while (@company_seq<=5005)
	begin

		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 30 card_seq, sum(order_count) as cnt
			FROM
			custom_order 
			WHERE  company_seq=@company_seq and DATEDIFF(mm,src_send_date,getdate()) = 1 and status_seq=15  and order_Type in ('1','6','7')
			group by card_seq
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
	
	--월간 샘플 주문
	set @rank = 0
	set @Gubun = '2'
	
	set @company_seq=5001
	while (@company_seq<=5005)
	begin
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 30 B.card_seq, count(B.card_seq) as cnt
			FROM
			custom_sample_order A inner join custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq
			WHERE  company_seq=@company_seq and DATEDIFF(mm,delivery_date,getdate()) = 1 and status_seq=12 
			group by card_seq
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
