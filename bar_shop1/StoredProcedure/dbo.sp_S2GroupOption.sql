IF OBJECT_ID (N'dbo.sp_S2GroupOption', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2GroupOption
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_S2GroupOption 1,0
CREATE PROCEDURE [dbo].[sp_S2GroupOption]
@CardItemGroup_Seq int, @CardItem_Seq int
WITH EXEC AS CALLER
AS
IF @CardItem_Seq = 0 
		BEGIN
			SELECT 
				Card_Seq = a.Card_Seq,		
				Card_Code = a.Card_Code,
				Card_Name = a.Card_Name,
				DiffPrice = a.Card_Price,
				Card_Price = a.Card_Price,
				cardset_price = a.cardset_price,
				(select Card_Text_Premier from S2_CardDetail where card_seq = a.card_seq) Card_Text_Premier,
				card_image,
				isnull(Unit_Value, 0) Unit_Value,
				Unit
			FROM S2_Card a JOIN S2_CardItemGroup b ON a.Card_Seq = b.Card_Seq
			WHERE b.CardItemGroup_Seq = @CardItemGroup_Seq
			and b.CardItemGroup_Seq <> 0
			ORDER BY a.Card_Price
			--ORDER BY a.card_seq desc
		END		
	ELSE
		BEGIN
			DECLARE @Card_Price int
			SET @Card_Price = 0
			
			SELECT @Card_Price = Card_Price FROM S2_Card WHERE Card_Seq = @CardItem_Seq
			
			SELECT 
				Card_Seq = a.Card_Seq,		
				Card_Code = a.Card_Code,
				Card_Name = a.Card_Name,
				DiffPrice = a.Card_Price - @Card_Price,
				Card_Price = a.Card_Price,
				cardset_price = a.cardset_price,
				(select Card_Text_Premier from S2_CardDetail where card_seq = a.card_seq) Card_Text_Premier,
				card_image,
				isnull(Unit_Value, 0) Unit_Value,
				Unit
			FROM S2_Card a JOIN S2_CardItemGroup b ON a.Card_Seq = b.Card_Seq
			WHERE b.CardItemGroup_Seq = @CardItemGroup_Seq
      and b.CardItemGroup_Seq <> 0
			ORDER BY a.Card_Price - @Card_Price	
			--ORDER BY a.card_seq desc
		END
GO
