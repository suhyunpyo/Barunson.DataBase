IF OBJECT_ID (N'dbo.sp_Season_Cancel_order', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_Season_Cancel_order
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- 시즌카드 자동 주문 취소...
CREATE PROCEDURE [dbo].[sp_Season_Cancel_order]
AS

declare @order_seq int
declare @card_seq int
declare @order_count int

-- 인쇄카드 주문취소 고객
BEGIN
	DECLARE tableCursor CURSOR FOR
		select order_seq
		from custom_order where sales_gubun='X' and order_type='4' and status_seq=9 and settle_status<>2
		and datediff(day,order_date,getdate())=15 and left(convert(varchar(10),order_date,21),10)>='2011-11-01' 

	OPEN tableCursor
	FETCH NEXT FROM tableCursor INTO @order_seq
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		BEGIN
			update custom_order set status_seq=3,src_cancel_date=getdate() where order_seq=@order_seq
		END

		FETCH NEXT FROM tableCursor INTO @order_seq
	END
	
	CLOSE tableCursor
	DEALLOCATE tableCursor

END

-- 완제품 주문취소 고객
BEGIN
	DECLARE tableCursor CURSOR FOR
		select order_seq
		from custom_etc_order where sales_gubun='X' and order_type='C' and status_seq=1 
		and datediff(day,order_date,getdate())=7 and left(convert(varchar(10),order_date,21),10)>='2011-11-01' 

	OPEN tableCursor
	FETCH NEXT FROM tableCursor INTO @order_seq
	WHILE @@FETCH_STATUS = 0
	BEGIN
		BEGIN
			DECLARE tableCursor2 CURSOR FOR
				select card_seq,order_count from custom_etc_order_item where order_seq=@order_seq
			OPEN tableCursor2
			FETCH NEXT FROM tableCursor2 INTO @card_seq,@order_count
			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN
					update card set ISHAVE_NUM=ISHAVE_NUM+@order_count where card_seq=@card_seq
				END
				FETCH NEXT FROM tableCursor2 INTO @card_seq,@order_count
			END

			CLOSE tableCursor2
			DEALLOCATE tableCursor2
		END
				
		BEGIN
			update custom_etc_order set status_seq=3,settle_cancel_date=getdate() where order_seq=@order_seq
		END

		FETCH NEXT FROM tableCursor INTO @order_seq
	END
	
	CLOSE tableCursor
	DEALLOCATE tableCursor

END
GO
