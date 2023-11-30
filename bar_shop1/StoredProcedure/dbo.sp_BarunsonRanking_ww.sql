IF OBJECT_ID (N'dbo.sp_BarunsonRanking_ww', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BarunsonRanking_ww
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_CardRanking 

CREATE    PROC [dbo].[sp_BarunsonRanking_ww]
AS
	Declare @sales_gubun char(1)
	Declare 	@card_seq integer	
	Declare	@cnt	integer
	Declare	@rank	integer
	Declare @Gubun char(1)
	Declare @gubun_data varchar(10)



	--매주 일요일에 집계 실행.
	if len(datepart(week,getdate())) = 1
		set @gubun_data	= cast(datepart(year,getdate()) as varchar(4)) + '0' + cast(datepart(week,getdate()) as varchar(1))
	else
		set @gubun_data	= cast(datepart(year,getdate()) as varchar(4)) + cast(datepart(week,getdate()) as varchar(2))


	--주간 주문 수량.
	set @rank = 0
	set @Gubun = '0'
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT TOP 30 sales_gubun,card_seq, sum(order_count) as cnt
		FROM
		custom_order
		WHERE sales_gubun = 'W' and DATEDIFF(week,src_send_date,getdate()) = 1 and status_seq=15
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
