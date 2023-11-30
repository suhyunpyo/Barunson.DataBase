IF OBJECT_ID (N'invtmng.sp_TUcardRanking', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_TUcardRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE        PROC [invtmng].[sp_TUcardRanking]
AS
	Declare @rank integer
	Declare 	@card_code varchar(50)
	Declare 	@cnt integer
	set @rank = 1

  -- 주간구매	
	DECLARE item_cursor CURSOR
	FOR 		
	    SELECT top 20 card_code, count(order_count) as cnt
	    FROM custom_order A inner join card B on A.card_seq = B.card_Seq
	    WHERE sales_gubun  = 'U' and DATEDIFF(ww,order_date,getdate()) = 1 and status_seq=15 and order_Type in ('1','6','7') and display_yes_or_no='1' 
	    GROUP BY card_code
	    ORDER BY cnt DESC
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @card_code,@cnt
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO  BestRanking(sales_gubun,rank,card_code,cnt,gubun) values(
		'U',@rank,@card_code,@cnt,'1')

		FETCH NEXT FROM item_cursor INTO @card_code,@cnt
		set @rank = @rank + 1

	END			-- end of while
	CLOSE item_cursor
	DEALLOCATE item_cursor

	
     -- 월간구매	
	set @rank = 1
	DECLARE item_cursor CURSOR
	FOR 		
	    SELECT TOP 50 card_code, count(order_seq) as cnt
	    FROM custom_order A inner join card B on A.card_seq = B.card_Seq
	    WHERE sales_gubun  = 'U' and DATEDIFF(mm,order_date,getdate()) = 1 and status_seq=15 and order_Type in ('1','6','7') and display_yes_or_no='1' 
	    GROUP BY card_code
	    ORDER BY cnt DESC
	OPEN item_cursor
	
	FETCH NEXT FROM item_cursor INTO @card_code,@cnt
		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO  BestRanking(sales_gubun,rank,card_code,cnt,gubun) values(
		'U',@rank,@card_code,@cnt,'2')

		FETCH NEXT FROM item_cursor INTO @card_code,@cnt
		set @rank = @rank + 1

	END			-- end of while

	CLOSE item_cursor
	DEALLOCATE item_cursor
	    







GO
