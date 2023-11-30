IF OBJECT_ID (N'dbo.SP_BEST_SAMPLE_WEEK_THECARD_TOP4', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BEST_SAMPLE_WEEK_THECARD_TOP4
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[SP_BEST_SAMPLE_WEEK_THECARD_TOP4]  
 @ST_SEQ    nvarchar(10),  
 @UID   nvarchar(100)
AS  
BEGIN  
  
      
  
    --DECLARE @TIME AS VARCHAR(10)  
    --SET @TIME = ' 14:30:00'  
  
 --커서를 이용하여 해당되는 고객정보를 얻는다.  
 DECLARE cur_AutoInsert_For_TheCard CURSOR FAST_FORWARD  
 FOR   
  SELECT *   
    FROM  
    (  
   SELECT  TOP 4 ROW_NUMBER() OVER (ORDER BY /*(  
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
             A.RK_IDX ASC) AS RowNum      
     , B.Card_Seq AS CARD_SEQ  
  
   FROM S4_Ranking_Sort_Table AS A  WITH(NOLOCK)  
   LEFT OUTER JOIN S2_Card AS B ON A.RK_Card_Code = B.Card_Seq  
   LEFT OUTER JOIN (  
        SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt, SUM(ER_Review_Star) AS StarPoints   
        FROM S4_Event_Review  WITH(NOLOCK)  
        WHERE ER_Company_Seq = 5007  
        GROUP BY ER_Card_Seq  
       ) CM ON B.Card_Seq = CM.Card_Seq   
   INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq  
   INNER JOIN S2_CardDiscount AS D ON C.CardDiscount_Seq = D.CardDiscount_Seq  
   INNER JOIN S2_CardImage AS E ON A.RK_Card_Code = E.Card_Seq   
   INNER JOIN S2_CardOption AS H ON B.Card_Seq = H.Card_Seq  
   INNER JOIN S2_CardKind AS I ON C.Card_Seq = I.Card_Seq  
   INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq   
   WHERE 1 = 1  
     AND A.RK_ST_SEQ = @ST_SEQ -- 카테고리 코드 조건  
     AND B.CardBrand = ISNULL(null, B.CardBrand) -- 브랜드 조건  
     AND C.Company_Seq = 5007  
     AND C.IsDisplay = 1    
     AND D.MinCount = 300   
     AND E.CardImage_WSize = '210'   
     AND E.CardImage_HSize = '210'   
     AND E.cardimage_div = 'E'      
     AND E.Company_Seq = 5007   
     AND J.CardKind_Seq = 1      
  ) AS RESULT  
  WHERE --RESULT.CARD_SEQ NOT IN ('35634','35713','35578','35542','35760')    -- 추천샘플5종제외  
  RESULT.CARD_SEQ NOT IN ('35542', '35586', '35634', '35723', '35805')    -- 추천샘플5종제외(2016.11.14 김지선요청)  
  AND  RowNum BETWEEN ( ( (1 - 1) * 30 ) + 1 ) AND ( 1 * 30 )   
  
 OPEN cur_AutoInsert_For_TheCard  
  
 DECLARE @PRIORITY VARCHAR(100)  
 DECLARE @CARD_SEQ VARCHAR(100)  
 DECLARE @CARD_EXIST INT  
  
 FETCH NEXT FROM cur_AutoInsert_For_TheCard INTO @PRIORITY, @CARD_SEQ  
  
 WHILE @@FETCH_STATUS = 0  
  
 BEGIN  
    
  --샘플장바구니 체크  
  SELECT @CARD_EXIST = COUNT(*) FROM  S2_SampleBasket   
  WHERE card_seq = @CARD_SEQ  
  AND uid = @UID  
  AND sales_gubun = 'ST'  
  
  IF @CARD_EXIST = 0  
  BEGIN  
  
   INSERT INTO S2_SampleBasket(sales_gubun, company_seq, uid, card_seq, reg_date, MD_recommend)           
   VALUES ( 'ST', '5007', @UID, @CARD_SEQ, GETDATE(), 'N')  
  END  
  
  FETCH NEXT FROM cur_AutoInsert_For_TheCard INTO @PRIORITY, @CARD_SEQ  
 END  
  
 CLOSE cur_AutoInsert_For_TheCard  
 DEALLOCATE cur_AutoInsert_For_TheCard  
END  
  
  
  
GO
