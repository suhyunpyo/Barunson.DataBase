IF OBJECT_ID (N'dbo.sp_BarunsonRanking_mm', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BarunsonRanking_mm
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec sp_BarunsonRanking_mm
CREATE      PROC [dbo].[sp_BarunsonRanking_mm]
AS
	Declare 	@sales_gubun char(1)
	Declare 	@card_seq integer	
	Declare	@cnt	integer
	Declare	@rank	integer
	Declare @Gubun char(1)
	Declare @gubun_data varchar(10)

	--매월 첫일날 월간 집계 실행.


	if len(datepart(mm,dateadd(day,-3,getdate()))) = 1
		set @gubun_data	= cast(datepart(year,dateadd(day,-3,getdate())) as varchar(4)) + '0' + cast(datepart(mm,dateadd(day,-3,getdate())) as varchar(1))
	else
		set @gubun_data	= cast(datepart(year,dateadd(day,-3,getdate())) as varchar(4)) + cast(datepart(mm,dateadd(day,-3,getdate())) as varchar(2))

	--set @gubun_data	= '200911'

	--월간 주문 수량.
	set @rank = 0
	set @Gubun = '1'
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT TOP 30 sales_gubun,card_seq, sum(order_count) as cnt
		FROM
		custom_order 
		WHERE  sales_gubun='W' and DATEDIFF(mm,src_send_date,getdate()) = 1 and status_seq=15 
		group by sales_gubun,card_seq
		order by cnt desc
	OPEN item_cursor

	FETCH NEXT FROM item_cursor INTO @sales_gubun,@card_seq,@cnt

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		insert into BestRanking_New(sales_gubun,rank,card_seq,cnt,gubun,gubun_data) values(@sales_gubun,@rank,@card_seq,@cnt,@Gubun,@gubun_data)

		FETCH NEXT FROM item_cursor INTO @sales_gubun,@card_seq,@cnt

	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor
	
	--월간 샘플 주문
	set @rank = 0
	set @Gubun = '2'
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT TOP 30 A.sales_gubun,B.card_seq, count(B.card_seq) as cnt
		FROM
		custom_sample_order A inner join custom_sample_order_item B on A.sample_order_seq = B.sample_order_seq
		WHERE  sales_gubun='W' and DATEDIFF(mm,delivery_date,getdate()) = 1 and status_seq=12 
		group by sales_gubun,card_seq
		order by cnt desc
	OPEN item_cursor


	FETCH NEXT FROM item_cursor INTO @sales_gubun,@card_seq,@cnt

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		insert into BestRanking_New(sales_gubun,rank,card_seq,cnt,gubun,gubun_data) values(@sales_gubun,@rank,@card_seq,@cnt,@Gubun,@gubun_data)

		FETCH NEXT FROM item_cursor INTO @sales_gubun,@card_seq,@cnt

	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

	-- 이용후기 랭킹
	set @rank = 0
	set @Gubun = '3'
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT TOP 30 sales_gubun,card_seq,count(card_seq) as cnt
		FROM
		card_user_commnet 
		WHERE sales_gubun='W' and DATEDIFF(mm,regdate,getdate()) = 1 
		group by sales_gubun,card_seq
		order by cnt desc
	OPEN item_cursor

	FETCH NEXT FROM item_cursor INTO @sales_gubun,@card_seq,@cnt

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		insert into BestRanking_New(sales_gubun,rank,card_seq,cnt,gubun,gubun_data) values(@sales_gubun,@rank,@card_seq,@cnt,@Gubun,@gubun_data)

		FETCH NEXT FROM item_cursor INTO @sales_gubun,@card_seq,@cnt

	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor




GO
