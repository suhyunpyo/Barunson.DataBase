IF OBJECT_ID (N'dbo.up_select_zzim_list_N', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_zzim_list_N
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-24
-- Description:	찜리스트 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_zzim_list_N]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(16),
	@real_company_seq	AS int,
	@ordernum	AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
			select COUNT(seq) from S2_WishCard AS A with(nolock) 
			--join S2_cardOption D on a.card_Seq = D.card_seq 
			where COMPANY_seq=@real_company_seq and uid=@uid
			--and D.isSample='1' 
		
			select a.seq, card_name, a.card_seq, c.IsDisplay, c.AppSample, b.Card_Code, cardbrand, cardset_price, B.RegDate, --8
			convert(integer, discount_rate) AS discount_rate , cardimage_filename, j.CardKind_Seq, IsNew, IsBest, isSSPre, IsSample
			, C.CardDiscount_Seq
			 from S2_WishCard AS A
			join S2_Card AS B	with(nolock) on A.card_seq = B.Card_Seq 
			join s2_cardsalessite AS C with(nolock) on B.Card_Seq= C.card_seq
			join s2_carddiscount AS D with(nolock) on C.CardDiscount_Seq = D.CardDiscount_Seq
			join s2_cardimage AS E	with(nolock) on A.card_seq=E.Card_Seq 
			join s2_cardoption AS H on B.card_seq=H.card_seq
			join s2_cardkind AS I on C.card_seq = I.Card_Seq
			join s2_cardkindinfo AS j on I.CardKind_Seq = j.CardKind_Seq
			where a.COMPANY_seq=@real_company_seq and uid=@uid and  C.Company_Seq=@company_seq and D.MinCount=@ordernum and E.CardImage_WSize='210' and E.CardImage_HSize='210' and E.cardimage_div='E' and
			C.IsDisplay='1' and E.Company_Seq=@company_seq and j.CardKind_Seq=1

	
END

GO
