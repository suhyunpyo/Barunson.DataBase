IF OBJECT_ID (N'dbo.SP_BHANDS_ALL_BEST_MD', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BHANDS_ALL_BEST_MD
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================================================================================================
-- Create date: 2018.11.14 정혜련
-- Description:	베스트 랭킹 변경 (MD 변경)
-- 'BH7051', 'BH5003', 'BH7056', 'BH7041'
-- 36168  35104 36208 36124
-- =============================================================================================================================
CREATE PROCEDURE [dbo].[SP_BHANDS_ALL_BEST_MD] 
AS
BEGIN

	Update s2_cardsalessite set ranking_w = ranking_w + 10 , ranking_m= ranking_m + 10 where company_seq = 5006 and ranking_m < 5;

	Update s2_cardsalessite set ranking_w = 1, ranking_m= 1 where company_seq = 5006 and card_Seq =  36168 ;
	Update s2_cardsalessite set ranking_w = 2, ranking_m= 2 where company_seq = 5006 and card_Seq =  35104 ;
	Update s2_cardsalessite set ranking_w = 3, ranking_m= 3 where company_seq = 5006 and card_Seq =  36208 ;
	Update s2_cardsalessite set ranking_w = 4, ranking_m= 4 where company_seq = 5006 and card_Seq =  36124 ;
	
END

GO
