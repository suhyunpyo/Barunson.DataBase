IF OBJECT_ID (N'dbo.sp_S2CardRankInfo', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardRankInfo
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE Proc [dbo].[sp_S2CardRankInfo] 
	@Card_Seq int,
	@Site int
AS
	SELECT top 1 RankDiv =  Case 
								When Rank_DIv = 'A' Then '1'
								When Rank_DIv = 'E' Then '2'
								When Rank_DIv = 'C' Then '3'
								When Rank_DIv = 'D' Then '4'
								Else '0'					
							 End
	FROM S2_CardRank (NOLOCK) WHERE Card_Seq =@Card_Seq and Company_Seq = @Site and Rank_Div <> 'S'
GO
