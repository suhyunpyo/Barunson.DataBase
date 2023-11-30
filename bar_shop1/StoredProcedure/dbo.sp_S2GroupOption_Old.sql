IF OBJECT_ID (N'dbo.sp_S2GroupOption_Old', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2GroupOption_Old
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--exec sp_S2GroupOption 1080,'E'
CREATE PROC [dbo].[sp_S2GroupOption_Old]
	@Card_Seq as int,
	@Card_Div as char(1)
	
AS
	IF @Card_Div = '' 
		BEGIN
			--기본 
			SELECT 'B' as gubun ,a.Card_Seq, a.Card_Code, a.Card_Div, a.Card_Price, a.Card_image 
			FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Env_Seq 
															or a.Card_Seq = b.Inpaper_Seq
															or a.Card_Seq = b.Acc1_Seq
															or a.Card_Seq = b.Acc2_Seq
															or a.Card_Seq = MapCard_Seq
															or a.Card_Seq = GreetingCard_Seq
															or a.Card_Seq = Lining_Seq		
			WHERE b.Card_Seq = @Card_Seq		
			
			UNION 																					
			
			--그룹
			SELECT 'G' as gubun ,c.Card_Seq, c.Card_Code, c.Card_Div, c.Card_Price, c.Card_image 
			FROM S2_CardDetail a JOIN S2_CardItemGroup b ON  a.Env_GroupSeq = b.CardItemGroup_Seq
															or a.Inpaper_GroupSeq = b.CardItemGroup_Seq
															or a.Acc1_GroupSeq = b.CardItemGroup_Seq
															or a.Acc2_GroupSeq = b.CardItemGroup_Seq
															or a.MapCard_GroupSeq = b.CardItemGroup_Seq
															or a.GreetingCard_GroupSeq = b.CardItemGroup_Seq		
															or a.Lining_GroupSeq = b.CardItemGroup_Seq		
								 JOIN S2_Card c ON b.Card_Seq = c.Card_Seq											
			WHERE a.Card_Seq = @Card_Seq		 
			
			

		END
	ELSE
		--기본
		SELECT a.Card_Seq, a.Card_Code, a.Card_Div, a.Card_Price, a.Card_image 
		FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq 
		WHERE a.Card_Seq = (
							SELECT card_Seq = Case
												When @Card_Div = 'E' Then Env_Seq
												When @Card_Div = 'I' Then Inpaper_Seq
												When @Card_Div = 'A' Then Acc1_Seq
												When @Card_Div = 'E' Then Acc2_Seq
												When @Card_Div = 'E' Then MapCard_Seq
											  End 
							FROM S2_Card a JOIN S2_CardDetail b ON a.Card_Seq = b.Card_Seq 
							WHERE a.Card_Seq = @Card_Seq					
							)
GO
