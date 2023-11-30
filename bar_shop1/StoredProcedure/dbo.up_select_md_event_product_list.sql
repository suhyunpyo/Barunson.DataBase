IF OBJECT_ID (N'dbo.up_select_md_event_product_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_md_event_product_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- =============================================           
-- 2019.05.20 더카드 이벤트 md 카드 (랭킹 아닌)  
-- [up_select_ranking_category_product_list_search] 5007, null, 26, 1, 40, '', 'ASC', 100, ''     
-- 변경 : [up_select_md_product_list_event] 729, 5007, 100
-- 2021.11.17 limited_deal_event  
-- =============================================          
CREATE PROCEDURE [dbo].[up_select_md_event_product_list]        
 @MD_SEQ int,    -- 회사고유코드          
 @company_seq int,    -- 회사고유코드              
 @order_num int  -- 수량        
AS        
BEGIN        
          
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
         
 SET NOCOUNT ON;          
            
 BEGIN        
          
  -- Count Query 시작 --         
  SELECT COUNT(A.CARD_SEQ) AS CNT         
  FROM s4_MD_choice A        
  INNER JOIN S2_Card AS B ON A.card_seq = B.Card_Seq               
  INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq                  
  INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq        
  INNER JOIN S2_CardImage AS E ON A.CARD_SEQ = E.Card_Seq         
  INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq                 
  INNER JOIN S2_cardkind AS I ON C.Card_Seq = I.Card_Seq  
  INNER JOIN S2_cardkindinfo AS J ON I.CardKind_Seq = J.CardKind_Seq        
  WHERE 1 = 1        
    AND A.md_seq = @md_seq   
    AND C.Company_Seq = @company_seq        
    AND C.IsDisplay = 1 -- 사용여부          
    AND D.MinCount = @order_num         
    AND E.CardImage_WSize = '210'              
    AND E.cardimage_div = 'E'            
    AND E.Company_Seq = @company_seq         
    AND I.CardKind_Seq in (1,6,7) 

  -- Count Query 끝 --         
          
  -- List Paging Query 시작 --        
  SELECT *         
  FROM        
 (        
   SELECT B.Card_Name        
     , B.Card_Code        
     , B.CardBrand        
     , B.CardSet_Price        
     , B.Card_Seq        
     , B.RegDate            
     , CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate         
     , E.CardImage_FileName           
     , C.IsNew        
     , C.IsBest                
     , C.Company_Seq        
     , H.IsSample                   
     , (B.CardSet_Price * 400 * (100 - D.Discount_Rate) * 0.01) AS Discount_Card_Price             
     , ISNULL(C.isBgcolor,'') AS isBgcolor           
     , ISNULL(CD.Minimum_Count,'100') AS min_count
	 , SORTING_NUM 
	 , isnull(a.card_text, '0') card_text       
   FROM s4_MD_choice AS A        
   INNER JOIN S2_Card AS B ON A.card_seq = B.Card_Seq                
   INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq        
   INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq        
   INNER JOIN S2_CardImage AS E ON A.card_Seq = E.Card_Seq         
   INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq        
   INNER JOIN S2_CardKind AS I ON C.Card_Seq = I.Card_Seq 
   INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq         
   INNER JOIN S2_CardDetail CD ON B.Card_Seq = CD.Card_Seq               
   WHERE 1 = 1           
     AND A.md_seq = @md_seq   
     AND C.Company_Seq = @company_seq        
     AND C.IsDisplay = 1          
     AND D.MinCount = @order_num         
     AND E.CardImage_WSize = '210'              
     AND E.cardimage_div = 'E'            
     AND E.Company_Seq = @company_seq    
	 AND I.CardKind_Seq in (1,6,7) 

  ) AS RESULT order by sorting_num asc       
     
                
  -- List Paging Query 끝 --        
          
 END        
            
END 
GO
