IF OBJECT_ID (N'dbo.up_select_Disigner_product_list_main', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_Disigner_product_list_main
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================    
-- Create date : 2015-05-21   
-- Edit date : 2016-07-21  
-- Description :   
-- 1) 최초 작성 :  
--   카테고리 별로 제품 목록 Display   
-- 2) 변경 내역 :  
--   베스트 청첩장(Category = 8) 또는 FSC인증 청첩장(Category = 10000)의 경우 관리자 페이지의 등록된 순서를 무시하고  
--   실제 판매량에 의거한 순서에 따라 출력하게끔 변경함.  
--   더카드 메인 best of best 관리자에서 관리  
--  
-- up_select_Disigner_product_list_main 5007,  300    
-- =============================================    
  
CREATE PROCEDURE [dbo].[up_select_Disigner_product_list_main]  
   
 @company_seq int,    -- 회사고유코드   
 @order_num  int,    -- 주문 수량  
 @category  int     -- 디자이너 추천 : 719 
   
AS  
BEGIN  
    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;    
   
 SELECT   
   COUNT(A.RK_Card_Code) AS CNT     
 FROM S4_Ranking_Sort_Table a   
  LEFT JOIN S4_Ranking_Sort r ON a.rk_st_seq=r.st_code   
  LEFT JOIN S2_Card b ON a.rk_card_code=b.card_seq   
  LEFT outer join S2_CardSalesSite AS c with(nolock) on A.rk_card_code=c.card_seq and c.company_seq=@company_seq   
  INNER JOIN S2_CardDiscount AS D WITH(NOLOCK)  
   ON C.CardDiscount_Seq = D.CardDiscount_Seq  
  INNER JOIN S2_CardImage AS E WITH(NOLOCK)  
   ON b.Card_Seq = e.Card_Seq   
  INNER JOIN S2_CardOption AS H WITH(NOLOCK)  
   ON B.Card_Seq = H.Card_Seq  
  LEFT OUTER JOIN   
  (  
   SELECT   
    ER_Card_Seq AS Card_Seq  
    , COUNT(ER_Card_Seq) AS CNT  
    , SUM(ER_Review_Star) AS StarPoints   
   FROM S4_Event_Review WITH(NOLOCK)  
   WHERE ER_Company_Seq  = @company_seq  
   GROUP BY ER_Card_Seq  
  ) AS CM  
  ON B.Card_Seq = CM.Card_Seq   
 WHERE r.st_company_seq=@company_seq AND a.rk_st_seq=@category   
  AND D.MinCount = @order_num  
  AND C.IsDisplay = 1  
  AND E.CardImage_WSize = '210'    
  AND E.cardimage_div = 'E'      
  AND E.Company_Seq = @company_seq  
  
  
 SELECT top 9  
   A.RK_Card_Code AS RK_Card_Code  
  , A.RK_Title AS RK_Title  
  , B.Card_Name  
  , B.Card_Code  
  , B.CardBrand  
  , B.CardSet_Price  
  , B.Card_Seq  
  , B.RegDate      
  , CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate  
  , E.CardImage_FileName  
  , C.IsJumun  
  , C.IsNew  
  , C.IsBest  
  , C.IsExtra  
  , C.IsSale  
  , C.IsExtra2  
  , C.isRecommend  
  , C.isSSPre  
  , C.Company_Seq  
  , H.IsSample  
  , ISNULL(CM.CNT, 0) AS Comment_CNT  
  , (ISNULL(CM.StarPoints, 0) / ISNULL(CM.cnt, 1)) AS StarPoints  
  , H.IsEnvInsert  
  --, (B.CardSet_Price * (100 - D.Discount_Rate) * 0.01) AS Discount_Card_Price
  , REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(round((B.CardSet_Price * ((100 - D.Discount_Rate) * 0.01)) , 0) * 1)),1), '.00', '') Discount_Card_Price    
  --, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(B.CardSet_Price * 300 * (100 - D.Discount_Rate) * 0.01)),1), '.00', '') Discount_Card_Price  
  --, REPLACE(CONVERT(VARCHAR,CONVERT(MONEY,(round((B.CardSet_Price * ((100 - D.Discount_Rate) * 0.01)) , 0) * 300)),1), '.00', '') Discount_Card_Price  
  , ISNULL(H.isFSC, '0') AS isFSC  
  , ISNULL(H.isNewEvent, '0') AS isNewEvent  
  , ISNULL(H.isRepinart, '0') AS isRepinart  
  , ISNULL(H.isHappyPrice, '0') AS isHappyPrice  
  , ISNULL(H.isSpringYN, '0') AS isSpringYN  
  , ISNULL(H.isnewGubun, '0') AS isnewGubun  
 FROM S4_Ranking_Sort_Table a   
  LEFT JOIN S4_Ranking_Sort r ON a.rk_st_seq=r.st_code   
  LEFT JOIN S2_Card b ON a.rk_card_code=b.card_seq   
  LEFT outer join S2_CardSalesSite AS c with(nolock) on A.rk_card_code=c.card_seq and c.company_seq=@company_seq   
  INNER JOIN S2_CardDiscount AS D WITH(NOLOCK)  
   ON C.CardDiscount_Seq = D.CardDiscount_Seq  
  INNER JOIN S2_CardImage AS E WITH(NOLOCK)  
   ON b.Card_Seq = e.Card_Seq   
  INNER JOIN S2_CardOption AS H WITH(NOLOCK)  
   ON B.Card_Seq = H.Card_Seq  
  LEFT OUTER JOIN   
  (  
   SELECT   
    ER_Card_Seq AS Card_Seq  
    , COUNT(ER_Card_Seq) AS CNT  
    , SUM(ER_Review_Star) AS StarPoints   
   FROM S4_Event_Review WITH(NOLOCK)  
   WHERE ER_Company_Seq  = @company_seq  
   GROUP BY ER_Card_Seq  
  ) AS CM  
  ON B.Card_Seq = CM.Card_Seq   
 WHERE r.st_company_seq= @company_seq AND a.rk_st_seq=@category   
  AND D.MinCount = @order_num  
  AND C.IsDisplay = 1  
  AND E.CardImage_WSize = '210'   
  AND E.cardimage_div = 'E'      
  AND E.Company_Seq = @company_seq  
  order by rk_idx asc  
  
      
END  
GO
