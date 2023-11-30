IF OBJECT_ID (N'dbo.up_select_mypage_zzim_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mypage_zzim_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2014-12-14
-- Description:	MyPage 찜 리스트
-- TEST : up_select_mypage_zzim_list 'palaoh', 5007
-- =============================================
CREATE PROCEDURE [dbo].[up_select_mypage_zzim_list]	

	@uid VARCHAR(16),	
	@company_seq INT 

AS
BEGIN
	
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	
	
	SELECT  WC.seq
		   ,WC.uid
		   ,WC.card_seq
		   ,SC.Card_Code
		   ,SC.Card_Name
		   ,SC.CardSet_Price		   
		   ,SCK.cardkind_seq
		   ,D.Discount_Rate
	FROM S2_WishCard WC
	INNER JOIN S2_Card SC ON WC.card_seq = SC.Card_Seq
	INNER JOIN (
					SELECT card_seq, MIN(CardKind_Seq) AS cardkind_seq
					FROM S2_CardKind
					GROUP BY card_seq
				) SCK ON WC.card_seq = SCK.Card_Seq
	INNER JOIN S2_CardSalesSite C ON WC.Card_Seq = C.Card_Seq
	INNER JOIN S2_CardDiscount D ON C.CardDiscount_Seq = D.CardDiscount_Seq
	WHERE 1 = 1
	  AND WC.uid = @uid	  
	  AND D.MinCount <= 300 
	  AND D.MaxCount >= 300
	  AND C.Company_Seq = @Company_Seq
	ORDER BY WC.seq DESC  

END
GO
