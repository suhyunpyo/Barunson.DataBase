IF OBJECT_ID (N'dbo.S2_getDiscountPrice', N'FN') IS NOT NULL OR 
	OBJECT_ID (N'dbo.S2_getDiscountPrice', N'FS') IS NOT NULL OR 
	OBJECT_ID (N'dbo.S2_getDiscountPrice', N'FT') IS NOT NULL OR 
	OBJECT_ID (N'dbo.S2_getDiscountPrice', N'IF') IS NOT NULL OR 
	OBJECT_ID (N'dbo.S2_getDiscountPrice', N'TF') IS NOT NULL 
BEGIN
    DROP FUNCTION dbo.S2_getDiscountPrice
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hee hwa>
-- Create date: <2010.01.25>
-- Description:	<제품의 할인 가격 리턴>
-- =============================================
CREATE FUNCTION [dbo].[S2_getDiscountPrice] 
(	
	@Card_Seq int,
	@Card_Num int
)
RETURNS int 
AS
	BEGIN
		DECLARE @DisPrice int
		
		SELECT @DisPrice = a.Cardset_Price * (100-c.Discount_Rate)/100
		FROM S2_Card a JOIN S2_CardSalesSite b ON a.Card_Seq = b.Card_Seq
		JOIN S2_CardDiscount c ON b.CardDiscount_Seq = c.CardDiscount_Seq 
		WHERE a.Card_Seq = @Card_Seq and MinCount = @Card_Num
	
	
		Return @DisPrice
	END
GO
