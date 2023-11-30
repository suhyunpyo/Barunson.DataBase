IF OBJECT_ID (N'dbo.sp_S2CardDisrate', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardDisrate
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec sp_S2CardDisrate 5001,30690,''
--exec sp_S2CardDisrate 5001,30690,550

--exec sp_S2CardDisrate 5002,30230,''
CREATE Proc [dbo].[sp_S2CardDisrate]
	@Company_Seq	int,
	@Card_Seq	    int,
	@Order_Count	int,
    @TypeCode       varchar(50) = ''
AS

BEGIN

IF @TypeCode = ''
    BEGIN
	    IF @Order_Count = ''
		    BEGIN
			    SELECT d.CardDiscount_Seq,d.MinCount,d.MaxCount,d.Discount_Rate, ISNULL(d.Discount_Price, 0) AS Discount_Price
			    FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq
						    JOIN S2_CardSalesSite c ON a.Card_Seq = c.Card_Seq
						    JOIN S2_CardDiscount d ON c.CardDiscount_Seq = d.CardDiscount_Seq
			    WHERE d.MinCount >= b.minimum_count and d.MinCount%50 = 0	--주문최소수량 및 주문단위 수량 Sort	
				      and c.Company_Seq = @Company_Seq and a.Card_Seq = @Card_Seq	
				      order by d.minCount
		    END			
	    ELSE
		    BEGIN
			    SELECT d.CardDiscount_Seq,d.MinCount,d.MaxCount,d.Discount_Rate, ISNULL(d.Discount_Price, 0) AS Discount_Price
			    FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq
						    JOIN S2_CardSalesSite c ON a.Card_Seq = c.Card_Seq
						    JOIN S2_CardDiscount d ON c.CardDiscount_Seq = d.CardDiscount_Seq
			    WHERE d.MinCount <= @Order_Count and d.MaxCount >= @Order_Count
				      and c.Company_Seq = @Company_Seq and a.Card_Seq = @Card_Seq	
				      order by d.minCount
		    END
    END
ELSE IF @TypeCode = 'SAMPLE_JOB_ORDER_PRINT'
    BEGIN        
        SELECT  d.CardDiscount_Seq
            ,   d.MinCount
            ,   d.MaxCount
            ,   d.Discount_Rate
            ,   ISNULL(d.Discount_Price, 0) AS Discount_Price
		FROM    S2_Card a 
        JOIN    S2_CardDetail b     ON a.Card_Seq = b.Card_Seq
		JOIN    S2_CardSalesSite c  ON a.Card_Seq = c.Card_Seq
		JOIN    S2_CardDiscount d   ON c.CardDiscount_Seq = d.CardDiscount_Seq
		WHERE   1 = 1
        AND     d.MinCount >= b.minimum_count 
        and     d.MinCount IN (100, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
		and     c.Company_Seq = @Company_Seq 
        and     a.Card_Seq = @Card_Seq	
		order by d.minCount
    END
END
GO
