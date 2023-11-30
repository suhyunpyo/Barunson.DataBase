IF OBJECT_ID (N'dbo.sp_CardRanking', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CardRanking
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec sp_CardRanking 

CREATE  PROC [dbo].[sp_CardRanking]
AS

    SET NOCOUNT ON
	
	
    SELECT IDENTITY(int, 1,1)  as Rank , b.card_img_ms, a.card_seq, b.card_code, count(*) as cnt
    INTO #CardRank
    FROM
    custom_order a JOIN card b ON a.card_seq = b.card_seq 
    WHERE a.sales_gubun = 'W' and DATEDIFF(mm,a.src_send_date,getdate()) = 1   and b.display_yes_or_no='1'  and  b.is100='1' 
    GROUP BY a.card_seq, b.card_code, b.card_img_ms,b.regist_Date
    ORDER BY cnt DESC,b.regist_Date DESC


	UPDATE card
	SET BestRangking = b.Rank
	FROM Card a JOIN #CardRank b ON a.card_seq = b.card_seq
	
	SET NOCOUNT OFF


GO
