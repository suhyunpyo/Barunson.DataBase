IF OBJECT_ID (N'dbo.sp_TiaraBestRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_TiaraBestRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE       PROC [dbo].[sp_TiaraBestRanking]
AS
	Declare 	@card_seq integer	
	Declare @company_seq integer
	Declare	@cnt	integer
	Declare	@rank	integer



--주간 주문 수량.(30위 안의 데이타는 BestRanking_new 테이블에 저장, S2_salessite.ranking_w 업데이트)
	set @company_seq=1437
	set @rank = 0
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT card_seq, sum(order_count) as cnt
		FROM
		custom_order
		WHERE company_seq = @company_seq and DATEDIFF(dd,src_send_date,getdate())>0 and DATEDIFF(dd,src_send_date,getdate())<=7 and status_seq=15
		group by card_seq
		order by cnt desc
	OPEN item_cursor

	FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		update card set BestRangking=@rank where card_seq=@card_seq

		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor


--월간 주문 수량.(30위 안의 데이타는 BestRanking_new 테이블에 저장, S2_salessite.ranking_m 업데이트)

	set @rank = 0
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT card_seq, sum(order_count) as cnt
		FROM
		custom_order 
		WHERE  company_seq=@company_seq and DATEDIFF(dd,src_send_date,getdate())>0 and DATEDIFF(dd,src_send_date,getdate())<=30 and status_seq=15 
		group by card_seq
		order by cnt desc

	OPEN item_cursor

	FETCH NEXT FROM item_cursor INTO @card_seq,@cnt

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		update card set sales_ranking=@rank where card_seq=@card_seq
	
		FETCH NEXT FROM item_cursor INTO @card_seq,@cnt
	
	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor

	

GO
