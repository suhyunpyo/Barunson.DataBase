IF OBJECT_ID (N'dbo.up_select_thanks_product_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thanks_product_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  조창연  
-- Create date: 2014-11-06  
-- Description: THE CARD 답례장 LIST  
-- up_select_thanks_product_list 5007, 1, 24, 400  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_thanks_product_list]  
   
 @company_seq int,    -- 회사고유코드  
 @page   int,    -- 페이지 번호  
 @pagesize  int,    -- 페이지 사이즈 (페이지당 노출 갯수)  
 @order_num  int     -- 주문 수량  
   
AS  
BEGIN  
   
 /*  
 DECLARE @company_seq int=5007    -- 회사고유코드    
 DECLARE @page   int=1     -- 페이지 번호  
 DECLARE @pagesize  int=24     -- 페이지 사이즈 (페이지당 노출 갯수)   
 DECLARE @order_num  int=400     -- 주문 수량  
 */  
  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;   
   
   
     
 -- Count Query 시작 --               
 SELECT COUNT(*) AS cnt  
 FROM S2_Card AS A      
 INNER JOIN S2_CardSalesSite B ON A.Card_Seq = B.card_seq  
 INNER JOIN S2_CardKind AS I ON B.card_seq = I.Card_Seq           
 INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq              
 INNER JOIN S2_CardImage AS E ON B.Card_Seq = E.Card_Seq     
 INNER JOIN S2_CardDiscount AS D ON B.CardDiscount_Seq = D.CardDiscount_Seq  
 INNER JOIN S2_CardOption AS H ON A.card_seq = H.card_seq  
 INNER JOIN S2_CardDetail CD ON A.Card_Seq = CD.Card_Seq  
 WHERE 1 = 1     
   AND B.Company_Seq = @company_seq  
   AND B.IsDisplay = 1 -- 사용여부  
   AND D.MinCount = @order_num  
   AND E.CardImage_WSize = '210'   
   --AND E.CardImage_HSize = '210'   
   AND E.CardImage_Div = 'E'    
   AND B.CARD_SEQ not in (select card_seq from S4_MD_Choice where md_seq in (811,812,813)) 
   AND E.Company_Seq = @company_seq  
   AND J.CardKind_Seq = 3 -- 답례장               
 -- Count Query 끝 --   
   
   
 -- List Paging Query 시작 --  
 SELECT *   
 FROM  
 (  
  SELECT  ROW_NUMBER() OVER (ORDER BY RegDate DESC ) AS RowNum  
    ,A.Card_Name  
    ,A.Card_Code  
    ,A.CardBrand  
    ,A.CardSet_Price  
    ,A.card_seq  
    ,A.RegDate      
    ,CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate   
    ,E.CardImage_FileName  
    ,B.IsJumun  
    ,B.IsNew  
    ,B.IsBest  
    ,B.IsExtra  
    ,B.IsSale  
    ,B.IsExtra2  
    ,B.isRecommend  
    ,B.isSSPre  
    ,B.Company_Seq  
    ,H.IsSample   
    ,ISNULL(B.isBgcolor,'') AS isBgcolor       
    ,ISNULL(CD.Minimum_Count,'100') AS min_count
  FROM S2_Card AS A   
  LEFT OUTER JOIN (  
       SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt, SUM(ER_Review_Star) AS StarPoints   
       FROM S4_Event_Review  
       WHERE ER_Company_Seq = @company_seq  
       GROUP BY ER_Card_Seq  
      ) CM ON A.Card_Seq = CM.Card_Seq   
  INNER JOIN S2_CardSalesSite AS B ON A.Card_Seq = B.card_seq  
  INNER JOIN S2_CardDiscount AS D ON B.CardDiscount_Seq = D.CardDiscount_Seq  
  INNER JOIN S2_CardImage AS E ON A.Card_Seq = E.Card_Seq    
  INNER JOIN S2_CardOption AS H ON A.card_seq = H.card_seq  
  INNER JOIN S2_CardKind AS I ON B.card_seq = I.Card_Seq  
  INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq  
  INNER JOIN S2_CardDetail CD ON A.Card_Seq = CD.Card_Seq  
  WHERE 1 = 1       
    AND B.Company_Seq = @company_seq  
    AND B.IsDisplay = 1    
    AND D.MinCount = @order_num  
    AND E.Company_Seq = @company_seq    
    AND E.CardImage_WSize = '210'   
    --AND E.CardImage_HSize = '210'   
    AND E.CardImage_Div = 'E'      
    AND J.CardKind_Seq = 3 --답례장/결혼답례카드
	and B.CARD_SEQ NOT IN (select card_seq from S4_MD_Choice where md_seq in (811,812,813) )  
 ) AS RESULT  
 WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )  
 -- List Paging Query 끝 --   
      
END
GO
