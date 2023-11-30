IF OBJECT_ID (N'dbo.apMetaTagCloudList', N'P') IS NOT NULL DROP PROCEDURE dbo.apMetaTagCloudList
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec apMetaTagCloudList

CREATE PROC [dbo].[apMetaTagCloudList]

AS

    SET NOCOUNT ON


    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank ,   a.card_seq, b.card_code, count(*) as cnt
    INTO #PastRank
    FROM
    custom_order a JOIN card b ON a.card_seq = b.card_seq 
    WHERE sales_gubun = 'W' and DATEDIFF(ww,src_send_date,getdate()) = 2  
    GROUP BY a.card_seq, b.card_code
    ORDER BY cnt DESC


    SELECT TOP 10  IDENTITY(int, 1,1)  as Rank ,   a.card_seq, b.card_code, count(*) as cnt
    INTO #Rank
    FROM
    custom_order a JOIN card b ON a.card_seq = b.card_seq 
    WHERE sales_gubun = 'W' and DATEDIFF(ww,src_send_date,getdate()) = 1  
    GROUP BY a.card_seq, b.card_code, a.status_seq
    ORDER BY cnt DESC

	
   SELECT a.rank,a.card_seq,a.card_code,a.cnt
						, tt =  Case
					             		When b.rank is null Then 'new'
							Else
								Case	    	
							              	When  a.rank = b.rank Then '-'
									

									When a.rank > b.rank Then   'd' + CAST((a.rank-b.rank) as char(2)) --a.rank - b.rank   --순위 내려갔을 경우
									When a.rank < b.rank Then   'u' + CAST((b.rank-a.rank) as char(2)) --a.rank - b.rank   --순위 올라갔을 경우
									Else ''	 	
	   			
								End	
						       End
   FROM #Rank a LEFT JOIN #PastRank b ON a.card_seq = b.card_seq ORDER BY a.cnt DESC 	

--     SELECT * FROM #PastRank    ORDER BY    cnt  DESC
--     SELECT * FROM #Rank    ORDER BY    cnt  DESC	
 

    SET NOCOUNT OFF

GO
