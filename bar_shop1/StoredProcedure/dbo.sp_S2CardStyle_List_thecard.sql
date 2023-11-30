IF OBJECT_ID (N'dbo.sp_S2CardStyle_List_thecard', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_S2CardStyle_List_thecard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
  /*  
-- =============================================    
-- Author:  nsm    
-- Create date: 2019-07-30  
-- Description: Style code & name 목록    
-- 더카드 청첩장 사용되는 스타일만 가져옴  
exec sp_S2CardStyle_List_thecard  


334 모던
302 전통
303 신랑신부
306 플라워
336 로맨틱
340 큐트
337 럭셔리
338 심플
341 ETC
이것만 노출 원함

-- =============================================    
*/  
  
  
CREATE procedure [dbo].[sp_S2CardStyle_List_thecard]  
as   
begin  
   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
       
 SET NOCOUNT ON;       
  -- Count Query 시작 --                   

    SELECT  count(*) as totCnt  
    FROM  [DBO].[S2_CARDSTYLEITEM] AS [EXTENT1]   
    WHERE (([EXTENT1].[CARDSTYLE_SITE] = 'T') OR (([EXTENT1].[CARDSTYLE_SITE] IS NULL) AND ('T' IS NULL)))    
 AND ([EXTENT1].[CARDSTYLE_CATEGORY] IS NOT NULL)   
 AND ([EXTENT1].[CARDSTYLE_CATEGORY] IN (N'W', N'A', N'B', N'D', N'E', N'G')) 
 AND ([EXTENT1].[CARDSTYLE_CATEGORY] NOT IN ('B', 'D', 'E', 'G', 'H')) 
  AND [EXTENT1].CARDSTYLE_SEQ NOT IN (301,304,305,307,333, 335,339)
 


 
  
  
  -- List Paging Query 시작 --      
 SELECT   
    [Extent1].[CardStyle_Seq] AS [CardStyle_Seq],   
    [Extent1].[CardStyle] AS [CardStyle],   
    [Extent1].[CardStyle_Site] AS [CardStyle_Site],   
    [Extent1].[CardStyle_Category] AS [CardStyle_Category]

   FROM  [DBO].[S2_CARDSTYLEITEM] AS [EXTENT1]   
    WHERE (([EXTENT1].[CARDSTYLE_SITE] = 'T') OR (([EXTENT1].[CARDSTYLE_SITE] IS NULL) AND ('T' IS NULL)))    
 AND ([EXTENT1].[CARDSTYLE_CATEGORY] IS NOT NULL)   
 AND ([EXTENT1].[CARDSTYLE_CATEGORY] IN (N'W', N'A', N'B', N'D', N'E', N'G')) 
 AND ([EXTENT1].[CARDSTYLE_CATEGORY] NOT IN ('B', 'D', 'E', 'G', 'H')) 
  AND [EXTENT1].CARDSTYLE_SEQ NOT IN (301,304,305,307,333,335,339)
ORDER BY CardStyle_Seq


end 
GO
