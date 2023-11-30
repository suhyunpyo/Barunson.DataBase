IF OBJECT_ID (N'invtmng.sp_BarunsonNRanking', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_BarunsonNRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






--exec sp_CardRanking 

CREATE         PROC [invtmng].[sp_BarunsonNRanking]
AS
	Declare 	@card_seq integer	
	Declare 	@card_code varchar(10)
	Declare 	@company varchar(10)
	Declare 	@card_img varchar(50)
	Declare 	@card_price integer
	Declare 	@disrate_type char(1)
	Declare	@cnt	integer
	Declare	@rank	integer
	Declare @Gubun char(1)


		set @rank = 0
		set @Gubun = '0'
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 20 b.card_img_ms, a.card_seq, b.card_code,b.company,b.card_price_customer,b.disrate_type, count(*) as cnt
			FROM
			custom_order a JOIN card b ON a.card_seq = b.card_seq 
			WHERE sales_gubun = 'W' and DATEDIFF(ww,src_send_date,getdate()) = 2   and display_yes_or_no='1' and  b.card_cate='I1' and b.is100='1' 
			group by a.card_seq,b.card_code,b.company,card_img_ms,b.card_price_customer,disrate_type
			order by cnt desc
		OPEN item_cursor

		FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRankingNew(sales_gubun,rank,card_seq,card_code,card_company,card_img_ms,card_price_customer,disrate_type,cnt,gubun) values('W',@rank,@card_seq,@card_code,@company,@card_img,@card_price,@disrate_type,@cnt,@Gubun)

			FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor

		set @rank = 0
		set @Gubun = '1'
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 20 b.card_img_ms, a.card_seq, b.card_code,b.company,b.card_price_customer,b.disrate_type, count(*) as cnt
			FROM
			custom_order a JOIN card b ON a.card_seq = b.card_seq 
			WHERE sales_gubun = 'W' and DATEDIFF(mm,src_send_date,getdate()) = 2   and display_yes_or_no='1' and  b.card_cate='I1' and  b.is100='1' 
			group by a.card_seq,b.card_code,b.company,card_img_ms,b.card_price_customer,disrate_type
			order by cnt desc
		OPEN item_cursor

		FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRankingNew(sales_gubun,rank,card_seq,card_code,card_company,card_img_ms,card_price_customer,disrate_type,cnt,gubun) values('W',@rank,@card_seq,@card_code,@company,@card_img,@card_price,@disrate_type,@cnt,@Gubun)

			FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor

		set @rank = 0
		set @Gubun = '2'
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 20 c.card_img_ms, b.card_seq, c.card_code,c.company,c.card_price_customer,c.disrate_type, count(*) as cnt
			FROM
	    custom_sample_order a JOIN custom_sample_order_item b ON a.sample_order_seq = b.sample_order_seq 
	    JOIN card c ON b.card_seq = c.card_seq 
	    WHERE a.sales_gubun = 'W' and DATEDIFF(mm,delivery_date,getdate()) = 2   and display_yes_or_no='1' and c.card_cate='I1' and c.is100='1' 
			group by b.card_seq,c.card_code,c.company,card_img_ms,card_price_customer,disrate_type
			order by cnt desc
		OPEN item_cursor

		FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRankingNew(sales_gubun,rank,card_seq,card_code,card_company,card_img_ms,card_price_customer,disrate_type,cnt,gubun) values('W',@rank,@card_seq,@card_code,@company,@card_img,@card_price,@disrate_type,@cnt,@Gubun)

			FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor

		set @rank = 0
		set @Gubun = '3'
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 20 card_img_ms, card_seq, card_code,company,card_price_customer,disrate_type,sales_ranking as cnt
			FROM
			card
			WHERE card_group = '0' and display_yes_or_no='1' and  card_cate='I1' and  is100='1' 
			order by sales_ranking
		OPEN item_cursor

		FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRankingNew(sales_gubun,rank,card_seq,card_code,card_company,card_img_ms,card_price_customer,disrate_type,cnt,gubun) values('W',@rank,@card_seq,@card_code,@company,@card_img,@card_price,@disrate_type,@cnt,@Gubun)

			FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor
		

		-- 이용후기 랭킹
		set @rank = 0
		set @Gubun = '5'
		DECLARE item_cursor CURSOR
		FOR 		
			SELECT TOP 20 b.card_img_ms, a.card_seq, b.card_code,b.company,b.card_price_customer,b.disrate_type, count(*) as cnt			
			FROM
			card_user_commnet a JOIN card b ON a.card_seq = b.card_seq 
			WHERE b.display_yes_or_no='1' and DATEDIFF(mm,regdate,getdate()) = 1 and A.sales_gubun='W' and  b.card_cate='I1' and b.is100='1' 
			group by a.card_seq,b.card_code,b.company,card_img_ms,card_price_customer,disrate_type
			order by cnt desc
		OPEN item_cursor

		FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			set @rank = @rank + 1
			insert into BestRankingNew(sales_gubun,rank,card_seq,card_code,card_company,card_img_ms,card_price_customer,disrate_type,cnt,gubun) values('W',@rank,@card_seq,@card_code,@company,@card_img,@card_price,@disrate_type,@cnt,@Gubun)

			FETCH NEXT FROM item_cursor INTO @card_img,@card_seq,@card_code,@company,@card_price,@disrate_type,@cnt

		END			-- end of while
		CLOSE item_cursor
		Deallocate item_cursor

	SET NOCOUNT OFF








GO
