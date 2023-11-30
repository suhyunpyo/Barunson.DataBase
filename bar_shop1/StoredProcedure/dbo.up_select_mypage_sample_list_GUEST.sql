IF OBJECT_ID (N'dbo.up_select_mypage_sample_list_GUEST', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mypage_sample_list_GUEST
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================      
-- Author:  조창연      
-- Create date: 2014-12-16      
-- Description: MyPage 샘플 리스트       
-- =============================================      
CREATE PROCEDURE [dbo].[up_select_mypage_sample_list_GUEST]      
       
 @company_seq  int,      
 @uid    nvarchar(16),
 @GUID  nvarchar(300)
       
AS      
BEGIN      
       
       
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
       
 SET NOCOUNT ON;      
    
 DECLARE @YearMonth  varchar(7)          
 DECLARE @startDate  smalldatetime          
 DECLARE @endDate  smalldatetime           
          
 SET @YearMonth = CONVERT(varchar(7), DATEADD(m, -1, GETDATE()), 126)          
 SET @startDate = CONVERT(smalldatetime, @YearMonth + '-01 00:00:00')          
 --SELECT @startDate          
 SET @endDate = DATEADD(MONTH, 1, CONVERT(smalldatetime, CONVERT(CHAR(6), @startDate, 112)+'01')) - 1          
 --SELECT @endDate          
      
    
 SELECT A.*    
    , ROW_NUMBER() OVER (ORDER BY A.cnt DESC) AS SAMPLE_RNK            
 INTO #CUSTOM_SAMPLE_ORDER_ITEM_CNT     
 FROM (    
     SELECT CSOI.Card_Seq, ISNULL(count(*),0) AS cnt            
    FROM CUSTOM_SAMPLE_ORDER_ITEM CSOI       
    LEFT JOIN CUSTOM_SAMPLE_ORDER CSO ON CSOI.SAMPLE_ORDER_SEQ = CSO.sample_order_seq    
    WHERE CSOI.Reg_Date BETWEEN @startDate AND @endDate                 
    AND   COMPANY_SEQ = 5007                           
    GROUP BY CSOI.Card_Seq        
    ) AS A    
    
 /*      
 SELECT COUNT(seq)       
 FROM S2_SampleBasket A      
 INNER JOIN S2_cardOption D ON A.card_Seq = D.card_seq       
 WHERE company_seq = @real_company_seq       
   AND uid = @uid      
   AND D.isSample = '1'       
 */      
      
 /*      
 DECLARE @company_seq int=5007      
 DECLARE @uid nvarchar(16)='palaoh'       
 */      
       
IF @UID <> '' 
BEGIN
 SELECT   A.seq         
   ,A.card_seq         
   ,C.card_code      
   ,C.card_name         
   ,C.cardset_price      
   --,C.Card_Image      
   ,C.card_price      
   ,SCK.cardkind_seq       
  , ISNULL(SC.SAMPLE_RNK,9999) AS SAMPLE_RNK  
 FROM S2_SampleBasket A       
 INNER JOIN S2_CardSalesSite B ON A.card_Seq = B.card_Seq      and A.company_seq = 5007   
 INNER JOIN S2_Card C ON A.card_seq = C.card_seq       
 INNER JOIN S2_cardOption D ON A.card_Seq = D.card_seq      
 INNER JOIN (      
     SELECT card_seq, MIN(CardKind_Seq) AS cardkind_seq      
     FROM S2_CardKind      
     GROUP BY card_seq      
    ) SCK ON A.card_seq = SCK.Card_Seq       
LEFT JOIN (    
    SELECT Card_Seq, SAMPLE_RNK  FROM #CUSTOM_SAMPLE_ORDER_ITEM_CNT    
) SC ON C.Card_Seq = SC.Card_Seq    
 WHERE A.uid = @uid          
   AND B.Company_Seq = @company_seq      
   AND B.isDisplay = 1       
   AND D.isSample = 1       
 ORDER BY A.seq DESC      
END
ELSE
BEGIN
 SELECT   A.seq         
   ,A.card_seq         
   ,C.card_code      
   ,C.card_name         
   ,C.cardset_price      
   --,C.Card_Image      
   ,C.card_price      
   ,SCK.cardkind_seq       
  , ISNULL(SC.SAMPLE_RNK,9999) AS SAMPLE_RNK  
 FROM S2_SampleBasket A       
 INNER JOIN S2_CardSalesSite B ON A.card_Seq = B.card_Seq       and A.company_seq = 5007  
 INNER JOIN S2_Card C ON A.card_seq = C.card_seq       
 INNER JOIN S2_cardOption D ON A.card_Seq = D.card_seq      
 INNER JOIN (      
     SELECT card_seq, MIN(CardKind_Seq) AS cardkind_seq      
     FROM S2_CardKind      
     GROUP BY card_seq      
    ) SCK ON A.card_seq = SCK.Card_Seq       
LEFT JOIN (    
    SELECT Card_Seq, SAMPLE_RNK  FROM #CUSTOM_SAMPLE_ORDER_ITEM_CNT    
) SC ON C.Card_Seq = SC.Card_Seq    
 WHERE A.uid = ''
   AND A.GUID = @GUID           
   AND B.Company_Seq = @company_seq      
   AND B.isDisplay = 1       
   AND D.isSample = 1       
 ORDER BY A.seq DESC      
END


         
 DROP TABLE #CUSTOM_SAMPLE_ORDER_ITEM_CNT       
        
END 
GO
