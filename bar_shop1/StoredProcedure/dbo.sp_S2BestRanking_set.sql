IF OBJECT_ID (N'dbo.sp_S2BestRanking_set', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2BestRanking_set
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create          PROC [dbo].[sp_S2BestRanking_set]
@company_seq integer
AS
	Declare 	@card_seq integer	
	Declare	@rank	integer

--주간 주문 수량.(30위 안의 데이타는 BestRanking_new 테이블에 저장, S2_salessite.ranking_w 업데이트)
	set @rank = 0
	DECLARE item_cursor CURSOR
	FOR 		
		SELECT card_seq
		FROM
		custom_order 
		WHERE  company_seq=@company_seq and DATEDIFF(dd,src_send_date,getdate())>0 and DATEDIFF(dd,src_send_date,getdate())<=30 and status_seq=15
		group by card_seq
		order by count(order_count) desc
	OPEN item_cursor

	FETCH NEXT FROM item_cursor INTO @card_seq

	WHILE @@FETCH_STATUS = 0
	BEGIN
		set @rank = @rank + 1
		update s2_cardsalessite set ranking_m=@rank where card_seq=@card_seq

		FETCH NEXT FROM item_cursor INTO @card_seq

	END			-- end of while
	CLOSE item_cursor
	Deallocate item_cursor
GO
