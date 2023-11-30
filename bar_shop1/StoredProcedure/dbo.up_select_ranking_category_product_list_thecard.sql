IF OBJECT_ID (N'dbo.up_select_ranking_category_product_list_thecard', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking_category_product_list_thecard
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- =============================================      
-- Author :  조창연    
-- Editor :  박동혁    
-- Create date : 2014-11-12      
-- Edit date : 2015-05-21    
-- Description :     
-- 1) 최초 작성 :    
--   카테고리 별로 제품 목록 Display     
-- 2) 변경 내역 :    
--   베스트 청첩장(Category = 8) 또는 FSC인증 청첩장(Category = 10000)의 경우 관리자 페이지의 등록된 순서를 무시하고    
--   실제 판매량에 의거한 순서에 따라 출력하게끔 변경함.    
--    
-- up_select_ranking_category_product_list 5007, null, 26, 1, 40, '', 'ASC', 100, ''     
-- =============================================      
CREATE PROCEDURE [dbo].[up_select_ranking_category_product_list_thecard]    
     
 @company_seq int,    -- 회사고유코드     
 @brand   nvarchar(20),  -- 고유브랜드 (없을 경우 NULL 값 넘겨 받으면 됨)    
 @category  int,    -- 카테고리 코드     
 @page   int,    -- 페이지 번호    
 @pagesize  int,    -- 페이지 사이즈 (페이지당 노출 갯수)     
 @orderby  nvarchar(20),  -- 정렬 컬럼    
 @Sequence  nvarchar(20),  -- 정렬 조건(ASC, DESC)    
 @order_num  int,     -- 주문 수량    
 @uid       varchar(100)  
     
AS    
BEGIN    
      
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
     
 SET NOCOUNT ON;      
     
      
  DECLARE @CARD_SEQ_ARRAY AS VARCHAR(4000)    
  SET @CARD_SEQ_ARRAY = ISNULL((SELECT ST_Card_Code_Arry FROM S4_RANKING_SORT WHERE ST_CODE = CAST(@category AS VARCHAR(10))), '')    
  SET @CARD_SEQ_ARRAY = REPLACE(@CARD_SEQ_ARRAY, ' ', '')    
    
  -- Count Query 시작 --     
  SELECT COUNT(A.VALUE) AS CNT     
  FROM ufn_SplitTableForRowNum(@CARD_SEQ_ARRAY, ',') AS A    
  INNER JOIN S2_Card AS B ON A.VALUE = B.Card_Seq           
  INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq              
  INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq    
  INNER JOIN S2_CardImage AS E ON A.VALUE = E.Card_Seq     
  INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq             
  INNER JOIN S2_cardkind AS I ON C.Card_Seq = I.Card_Seq    
  INNER JOIN S2_cardkindinfo AS J ON I.CardKind_Seq = J.CardKind_Seq    
  WHERE 1 = 1    
--    AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건    
    AND B.CardBrand = ISNULL(@brand, B.CardBrand) -- 브랜드 조건    
    AND C.Company_Seq = @company_seq    
    AND C.IsDisplay = 1 -- 사용여부      
    AND D.MinCount = @order_num     
    AND E.CardImage_WSize = '210'     
    AND E.CardImage_HSize = '210'     
    AND E.cardimage_div = 'E'        
    AND E.Company_Seq = @company_seq     
    AND J.CardKind_Seq = 1 -- 청첩장                
  -- Count Query 끝 --     
      
  -- List Paging Query 시작 --    
  SELECT *     
  FROM    
  (    
   SELECT  ROW_NUMBER() OVER (ORDER BY /*(    
             CASE @Sequence WHEN 'ASC' THEN     
                     CASE @orderby WHEN 'REGDATE' THEN B.RegDate    
                          WHEN 'PRICE' THEN B.CardSet_Price     
                     END    
             END     
             ) ASC,    
             (    
             CASE @Sequence WHEN 'DESC' THEN     
                     CASE @orderby WHEN 'REGDATE' THEN B.RegDate    
                          WHEN 'PRICE' THEN B.CardSet_Price    
                          WHEN 'DISCOUNT_RATE' THEN D.Discount_Rate --할인율 높은 순                             
                          WHEN 'COMMENT' THEN CM.Cnt --상품평 순    
                     END    
             END     
             ) DESC ) AS RowNum*/    
             A.ROW_NUM ASC) AS RowNum        
     , @category AS RK_ST_SEQ    
     , A.VALUE AS RK_Card_Code    
     , B.Card_Name AS RK_Title    
     , B.Card_Name    
     , B.Card_Code    
     , (select code_value from manage_code where code_type='cardbrand' and code = B.CardBrand) as CardBrand  
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
     , ISNULL(CM.cnt, 0) AS Comment_Cnt    
     , (ISNULL(CM.StarPoints, 0) / ISNULL(CM.cnt, 1)) AS StarPoints    
     , H.IsEnvInsert    
     --,RK_Idx    
     , NULL AS Gubun    
     , (B.CardSet_Price * 400 * (100 - D.Discount_Rate) * 0.01) AS Discount_Card_Price    
     , NULL AS Sales_CNT    
     , ISNULL(H.isFSC, '0') AS isFSC    
     , ISNULL(H.isNewEvent, '0') AS isNewEvent    
     , ISNULL(H.isRepinart, '0') AS isRepinart    
     , ISNULL(H.isHappyPrice, '0') AS isHappyPrice    
     , ISNULL(H.isSpringYN, '0') AS isSpringYN    
     , ISNULL(H.isnewGubun, '0') AS isnewGubun    
     , ISNULL(C.isBgcolor,'') AS isBgcolor    
    , CASE LEN(ISNULL(@UID ,''))   
        WHEN 0 THEN 0   
        ELSE ISNULL((select count(1) from S2_SampleBasket where uid = @UID and company_seq = @COMPANY_sEQ and card_seq = B.card_Seq),0)   
     END AS isBasket  
   FROM ufn_SplitTableForRowNum(@CARD_SEQ_ARRAY, ',') AS A    
   LEFT OUTER JOIN S2_Card AS B ON A.VALUE = B.Card_Seq    
   LEFT OUTER JOIN (    
        SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt, SUM(ER_Review_Star) AS StarPoints     
        FROM S4_Event_Review  WITH(NOLOCK)    
        WHERE ER_Company_Seq = @company_seq    
        GROUP BY ER_Card_Seq    
       ) CM ON B.Card_Seq = CM.Card_Seq     
   INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq    
   INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq    
   INNER JOIN S2_CardImage AS E ON A.VALUE = E.Card_Seq     
   INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq    
   INNER JOIN S2_CardKind AS I ON C.Card_Seq = I.Card_Seq    
   INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq     
   WHERE 1 = 1    
     --AND A.RK_ST_SEQ = @category -- 카테고리 코드 조건    
     AND B.CardBrand = ISNULL(@brand, B.CardBrand) -- 브랜드 조건    
     AND C.Company_Seq = @company_seq    
     AND C.IsDisplay = 1      
     AND D.MinCount = @order_num     
     AND E.CardImage_WSize = '210'     
     AND E.CardImage_HSize = '210'     
     AND E.cardimage_div = 'E'        
     AND E.Company_Seq = @company_seq     
     AND J.CardKind_Seq = 1        
  ) AS RESULT    
  WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )     
    
      
  -- List Paging Query 끝 --    
      
END    
GO
