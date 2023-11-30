IF OBJECT_ID (N'dbo.sp_S2CardSearch', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardSearch
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

--Exec Sp_S2CardSearch 'W'
CREATE Proc [dbo].[sp_S2CardSearch] 
	@CardBrand char(1)
AS
	DECLARE @CardSite as int
	SET @CardSite = ''
	
	IF @CardBrand = 'B'
		SET @CardSite = 5001	
	ELSE IF @CardBrand = 'W'
		SET @CardSite = 5002
	ELSE IF @CardBrand = 'S'
		SET @CardSite = 5003
	ELSE IF @CardBrand = 'H'
		SET @CardSite = 5004
	ELSE IF @CardBrand = 'P'
		SET @CardSite = 5005
			
	IF @CardBrand = 'T'
		BEGIN
			SELECT a.Card_Seq,a.Card_Code,CardBrand = Case
														When a.CardBrand = 'B' Then 'barunsoncard'
														When a.CardBrand = 'W' Then 'wishmade'
														When a.CardBrand = 'H' Then 'happycard'
														When a.CardBrand = 'S' Then 'story'
														When a.CardBrand = 'P' Then 'wpaper'
													  End
			,a.Card_Name, a.CardSet_Price, a.Card_Price, a.RegDate,e.CardImage_FileName,f.Card_Content ,f.Card_Text,b.IsBest,b.CardDiscount_Seq, f.Card_Folding, a.Card_WSize,a.Card_HSize,
			CardType =  Case
							When f.Inpaper_Seq = '0' and f.Inpaper_GroupSeq = '0'  Then '1'
							Else '2'
						End,
			Icon =  Case
						When b.IsNew = '1' and b.IsBest <> '1' and b.IsDisplay <> '2' Then 'new'
						When b.IsBest = '1' and  b.IsDisplay <> '2' Then 'best'
						When b.IsDisplay = '2' Then 'out'
					End, Rank, cuchun,cuchunRate,prodcuchun,zzim			   
			FROM S2_Card a(NOLOCK) JOIN S2_CardSalesSite b (NOLOCK) ON a.Card_Seq = b.Card_Seq
						   --JOIN S2_CardStyle c ON a.Card_Seq = c.Card_Seq
						   --JOIN S2_CardStyleItem d ON c.CardStyle_Seq = d.CardStyle_Seq  	 
						   JOIN S2_CardImage e ON a.Card_Seq = e.Card_Seq
						   JOIN S2_CardDetail f ON a.Card_Seq = f.Card_Seq
						   LEFT JOIN S2_CardRank g ON a.Card_Seq = g.Card_Seq 
						   LEFT JOIN S2_Report h ON a.Card_Code = h.Card_Code
			WHERE a.Card_Div = 'A01' and b.IsDisplay in (1,2) and b.IsJumun = 1 
				  and e.CardImage_WSize = '100' and e.CardImage_WSize = '100' and e.CardImage_FileName ='T5.png'
				  and g.company_seq = 5000 and g.Rank_Div = 'S'
			ORDER BY g.rank asc	  
		END		  
		
		
	ELSE
		BEGIN
			SELECT a.Card_Seq,a.Card_Code,CardBrand = Case
														When a.CardBrand = 'B' Then 'barunsoncard'
														When a.CardBrand = 'W' Then 'wishmade'
														When a.CardBrand = 'H' Then 'happycard'
														When a.CardBrand = 'S' Then 'story'
														When a.CardBrand = 'P' Then 'wpaper'
													  End
			,a.Card_Name, a.CardSet_Price, a.RegDate,e.CardImage_FileName,f.Card_Content,f.Card_Text,b.IsBest,b.CardDiscount_Seq, f.Card_Folding, a.Card_WSize,a.Card_HSize,
			CardType =  Case
							When f.Inpaper_Seq = '0' and f.Inpaper_GroupSeq = '0'  Then '1'
							Else '2'
						End,
			Icon =  Case
						When b.IsNew = '1' and b.IsBest <> '1' and b.IsDisplay <> '2' Then 'new'
						When b.IsBest = '1' and  b.IsDisplay <> '2' Then 'best'
						When b.IsDisplay = '2' Then 'out'
					End,Rank, cuchun,cuchunRate,prodcuchun,zzim			   			 
			FROM S2_Card a (NOLOCK) JOIN S2_CardSalesSite b (NOLOCK) ON a.Card_Seq = b.Card_Seq
						   --JOIN S2_CardStyle c ON a.Card_Seq = c.Card_Seq
						   --JOIN S2_CardStyleItem d ON c.CardStyle_Seq = d.CardStyle_Seq  	 
						   JOIN S2_CardImage e ON a.Card_Seq = e.Card_Seq
						   JOIN S2_CardDetail f ON a.Card_Seq = f.Card_Seq
						   LEFT JOIN S2_CardRank g ON a.Card_Seq = g.Card_Seq and b.company_seq = g.company_Seq
						   LEFT JOIN S2_Report h ON a.Card_Code = h.Card_Code
			WHERE a.CardBrand = @CardBrand and a.Card_Div = 'A01' 
				  and b.company_seq = @CardSite and b.IsDisplay in (1,2) and b.IsJumun = 1 
				  and e.CardImage_WSize = '100' and e.CardImage_WSize = '100' and e.CardImage_FileName ='T5.png'  and g.Rank_Div = 'S'
				  ORDER BY g.rank asc	  
		END
GO
