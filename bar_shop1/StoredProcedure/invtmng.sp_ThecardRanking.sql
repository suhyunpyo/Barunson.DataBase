IF OBJECT_ID (N'invtmng.sp_ThecardRanking', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_ThecardRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE     PROC [invtmng].[sp_ThecardRanking]
AS
	Declare @rank integer
	Declare 	@card_seq integer	
	Declare 	@cnt integer
	set @rank = 1

  -- 주간구매	
	DECLARE item_cursor CURSOR
	FOR 		
	    SELECT top 20 a.card_seq, count(order_count) as cnt
	    FROM custom_order a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE sales_gubun = 'T' and DATEDIFF(ww,src_send_date,getdate()) = 1 and status_seq=15 and order_Type in ('1','6','7') and  display_yes_or_no='1' 
	    GROUP BY a.card_seq
	    ORDER BY cnt DESC
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO  BestRanking(sales_gubun,rank,card_seq,cnt,gubun) values(
		'T',@rank,@card_seq,@cnt,'1')

		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
		set @rank = @rank + 1

	END			-- end of while
	CLOSE item_cursor
	DEALLOCATE item_cursor

	
     -- 월간구매	
	set @rank = 1
	DECLARE item_cursor CURSOR
	FOR 		
	    SELECT TOP 40  a.card_seq, count(order_seq) as cnt
	    FROM custom_order a JOIN card b ON a.card_seq = b.card_seq 
	    WHERE sales_gubun = 'T' and DATEDIFF(mm,src_send_date,getdate()) = 1 and status_seq=15 and order_Type in ('1','6','7') and  display_yes_or_no='1' 
	    GROUP BY a.card_seq
	    ORDER BY cnt DESC
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO  BestRanking(sales_gubun,rank,card_seq,cnt,gubun) values(
		'T',@rank,@card_seq,@cnt,'2')

		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
		set @rank = @rank + 1

	END			-- end of while

	CLOSE item_cursor
	DEALLOCATE item_cursor
	    




GO
