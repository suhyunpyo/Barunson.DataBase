IF OBJECT_ID (N'dbo.OrderCountAVG', N'P') IS NOT NULL DROP PROCEDURE dbo.OrderCountAVG
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[OrderCountAVG]
	AS
	DECLARE WeddingCard CURSOR KEYSET
	FOR  SELECT  order_seq, up_order_seq, order_count FROM CUSTOM_ORDER WHERE order_type=1 AND  status_seq=15	 
								ORDER BY order_seq ASC
	
		--DROP TABLE #WeddingAVG
		CREATE TABLE #WeddingAVG (
			Order_seq		int,
			--Order_Date		smalldatetime,	
			Order_Count		int,	
			--Order_Price		money,
			--Discount_Rate		varchar(10),
			--Order_Total_Price	money
			
		)
	
	DECLARE @order_seq  	int
	DECLARE @up_order_seq 	int
	DECLARE @order_count	int
	
	OPEN WeddingCard
	
	FETCH NEXT FROM WeddingCard INTO @order_seq, @up_order_seq, @order_count
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
	
			IF @up_order_seq  is  null
				INSERT #WeddingAVG (Order_seq, Order_Count) VALUES (@order_seq, @order_count)
			ELSE
				UPDATE #WeddingAVG Set Order_Count = Order_Count + @order_Count  WHERE order_seq = @up_order_seq		
		END
		FETCH NEXT FROM WeddingCard INTO @order_seq, @up_order_seq, @order_count
	END
	
	
	SELECT AVG(Order_count) FROM #WeddingAVG
	
	CLOSE WeddingCard
	DEALLOCATE WeddingCard
	
GO
