IF OBJECT_ID (N'dbo.up_select_sample_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_sample_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김덕중
-- Create date: 2014-04-15
-- Description:	샘플리스트 
-- =============================================
CREATE PROCEDURE [dbo].[up_select_sample_list]
	-- Add the parameters for the stored procedure here
	@company_seq AS int,
	@uid	AS nvarchar(16),
	@real_company_seq	AS int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
			select COUNT(seq) from s2_SampleBasket AS A with(nolock) 
			join S2_cardOption D on a.card_Seq = D.card_seq 
			where COMPANY_seq=@real_company_seq and uid=@uid
			and D.isSample='1' 
		
			Select a.seq, a.company_seq, a.card_seq, b.isDisplay, b.appSample, 
			c.card_code, c.card_name, c.cardbrand, c.cardset_price, c.Card_Image 
			From s2_SampleBasket a 
			join s2_cardsalessite b on A.card_Seq = B.card_Seq
			and b.Company_Seq=@company_seq 
			join s2_card c on a.card_seq=c.card_seq 
			join S2_cardOption D on a.card_Seq = D.card_seq 
			Where a.uid=@uid and a.company_seq = @real_company_seq and D.isSample='1' 
END
GO
