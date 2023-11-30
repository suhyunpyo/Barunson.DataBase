IF OBJECT_ID (N'dbo.up_select_ranking_all_product_list', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_ranking_all_product_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  조창연  
-- Create date: 2014-11-05  
-- Description: THE CARD 상품 LIST (전체 또는 검색 용)  
-- exec up_select_ranking_all_product_list 5007,NULL,1,48,'REGDATE','DESC',400,NULL,200,600,1,2,3,'0','G1','G2','G3','S1','S2','S3','S4',372,373,374,375,376,377,457,460,458,462  
  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_ranking_all_product_list]  
   
     @company_seq int,    -- 회사고유코드   
     @brand   nvarchar(20),  -- 고유브랜드 (없을 경우 null 값 넘겨 받으면 됨)   
     @page   int,    -- 페이지 번호  
     @pagesize  int,    -- 페이지 사이즈 (페이지당 노출 갯수)   
     @orderby  nvarchar(20),  -- 정렬 컬럼  
     @Sequence  nvarchar(20),  -- 정렬 조건(ASC, DESC)  
     @order_num  int,    -- 주문 수량   
     @keyword  nvarchar(20),  -- 검색어 (카드번호 or 카드네임)   
     @price1   int,    -- 가격 (범위 시작)   
     @price2   int,    -- 가격 (범위 끝)  
     @shape1   int,    -- 모양1   
     @shape2   int,    -- 모양2  
     @shape3      int,    -- 모양3   
     @folding1  varchar(2),   -- folding1   
     @folding2  varchar(2),   -- folding2  
     @folding3  varchar(2),   -- folding3  
     @folding4  varchar(2),   -- folding4  
     @folding5  varchar(2),   -- folding5  
     @folding6  varchar(2),   -- folding6  
     @folding7  varchar(2),   -- folding7  
     @folding8  varchar(2),   -- folding8   
     @style1   int,    -- style1   
     @style2   int,    -- style2  
     @style3      int,    -- style3  
     @style4   int,    -- style4   
     @style5   int,    -- style5  
     @style6      int,    -- style6   
     @print1      int,    -- print1  
     @print2   int,    -- print2   
     @print3   int,    -- print3  
     @print4      int     -- print4  
     --@discRate  int     -- 할인율  
   
AS  
BEGIN  
   
 /*  
 DECLARE @company_seq int=5007    -- 회사고유코드   
 DECLARE @brand   nvarchar(20)=null  -- 고유브랜드 (없을 경우 null 값 넘겨 받으면 됨)   
 DECLARE @page   int=1     -- 페이지 번호  
 DECLARE @pagesize  int=240     -- 페이지 사이즈 (페이지당 노출 갯수)   
 DECLARE @orderby  nvarchar(20)='REGDATE' -- 정렬 컬럼  
 DECLARE @Sequence  nvarchar(20)='DESC'  -- 정렬 조건(ASC, DESC)  
 DECLARE @order_num  int=400     -- 주문 수량  
   
 DECLARE @keyword  nvarchar(20)=''   -- 검색어 (카드번호 or 카드네임)   
 DECLARE @price1   int=null    -- 가격 (범위 시작)   
 DECLARE @price2   int=null    -- 가격 (범위 끝)  
 */  
   
   
 DECLARE @YearMonth  varchar(7)  
 DECLARE @startDate  smalldatetime  
 DECLARE @endDate  smalldatetime   
  
 SET @YearMonth = CONVERT(varchar(7), DATEADD(m, -1, GETDATE()), 126)  
 SET @startDate = CONVERT(smalldatetime, @YearMonth + '-01 00:00:00')  
 --SELECT @startDate  
 SET @endDate = DATEADD(MONTH, 1, CONVERT(smalldatetime, CONVERT(CHAR(6), @startDate, 112)+'01')) - 1  
 --SELECT @endDate  
   
   
 DECLARE @temp varchar(20)  
 SET @temp = CONVERT(varchar(10), @endDate, 126) + ' 23:59:00'  
 --SELECT @temp  
   
 SET @endDate = CONVERT(smalldatetime, @temp)  
 --SELECT @endDate   
  
 DECLARE @strQuery NVARCHAR(MAX);  
 DECLARE @parmDefinition_itm NVARCHAR(1000)  
   
   
 /* -- 가격 비교 처리 --  
 할인가 = 원가 * 할인율   
 원가 = 할인가 / 할인율  
   
 cardset_price BETWEEN (@price1 / rate) AND (@price2 / rate)  
   
 IF @price1 IS NOT NULL AND @price2 IS NOT NULL BEGIN  
  SET @price1 = @price1 / @discRate  
  SET @price2 = @price1 / @discRate  
 END*/  
  
  
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;   
  
  
 SELECT Card_Seq, count(*) AS Cnt  
 INTO #CUSTOM_SAMPLE_ORDER_ITEM_CNT                            
 FROM CUSTOM_SAMPLE_ORDER_ITEM                        
 WHERE Reg_Date BETWEEN @startDate AND @endDate                    
 GROUP BY Card_Seq  
   
   
     
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
   
 INNER JOIN   
 (     
  SELECT DISTINCT card_seq  
  FROM S2_CardStyle   
  WHERE CardStyle_Seq IN (@style1, @style2, @style3, @style4, @style5, @style6)  
  --WHERE CardStyle_Seq IN (372, 373, 374, 375, 376, 377)  
 ) CS ON B.Card_Seq = CS.Card_Seq    
   
 INNER JOIN   
 (     
  SELECT DISTINCT card_seq  
  FROM S2_CardStyle   
  WHERE CardStyle_Seq IN (@print1, @print2, @print3, @print4)  
  --WHERE CardStyle_Seq IN (457, 458, 460, 600)  
 ) CS2 ON B.Card_Seq = CS2.Card_Seq   
     
 WHERE 1 = 1  
   AND A.CardBrand = ISNULL(@brand, A.CardBrand)  
   AND B.Company_Seq = @company_seq  
   AND B.IsDisplay = 1 -- 사용여부  
   AND D.MinCount = @order_num  
   AND E.CardImage_WSize = '210'   
   --AND E.CardImage_HSize = '210'   
   AND E.CardImage_Div = 'E'     
   AND E.Company_Seq = @company_seq  
   AND (J.CardKind_Seq in  (1,6) OR (ISNULL(@keyword, '') <> '' AND J.CardKind_Seq = 3)) -- (청첩장, 답례장) OR (검색어 있을때만 감사장 포함)   
   AND ( A.Card_Name LIKE ISNULL(@keyword, '') + '%' OR A.Card_Code LIKE ISNULL(@keyword, '') + '%' OR  Replace(Replace(A.Card_Name,' ',''),CHAR(10),'') LIKE ISNULL(@keyword, '') + '%' OR Replace(Replace(A.Card_Code,' ',''),CHAR(10),'') LIKE ISNULL(@keyword, '') + '%')
   AND ( A.Card_Price BETWEEN ISNULL(@price1, A.Card_Price) AND ISNULL(@price2, A.Card_Price) )  
   AND CD.Card_Shape IN (@shape1, @shape2, @shape3)  
   AND CD.Card_Folding IN (@folding1, @folding2, @folding3, @folding4, @folding5, @folding6, @folding7, @folding8)             
 -- Count Query 끝 --   
   
   
 -- List Paging Query 시작 --  
 --SELECT *   
 --FROM  
 --(  
 -- SELECT  ROW_NUMBER() OVER (ORDER BY (  
 --           CASE @Sequence WHEN 'ASC' THEN   
 --                   CASE @orderby WHEN 'REGDATE' THEN A.RegDate  
 --                        WHEN 'PRICE' THEN (A.CardSet_Price * @order_num) * ((100-Discount_Rate)/100)  
 --                        WHEN 'RECOM' THEN B.Ranking_M  
 --                   END  
 --           END   
 --           ) ASC,  
 --           (  
 --           CASE @Sequence WHEN 'DESC' THEN   
 --                   CASE @orderby WHEN 'REGDATE' THEN A.RegDate  
 --                        --WHEN 'PRICE' THEN A.CardSet_Price  
 --                        WHEN 'PRICE' THEN (A.CardSet_Price * @order_num) * ((100-Discount_Rate)/100)  
 --                        WHEN 'DISCOUNT_RATE' THEN D.Discount_Rate --할인율 높은 순  
 --                        WHEN 'SAMPLE' THEN SC.Cnt --샘플 신청 순  
 --                        WHEN 'COMMENT' THEN CM.Cnt --상품평 순  
 --                   END  
 --           END   
 --           ) DESC ) AS RowNum           
 --   , 1 AS ONE --S.RK_ST_SEQ  
 --   , 2 AS TWO  --S.RK_Card_Code  
 --   , 3 AS THREE--S.RK_Title  
 --   , A.Card_Name  
 --   , A.Card_Code  
 --   , A.CardBrand  
 --   , A.CardSet_Price  
 --   , A.card_seq  
 --   , A.RegDate      
 --   , CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate   
 --   , E.CardImage_FileName  
 --   , B.IsJumun  
 --   , B.IsNew  
 --   , B.IsBest  
 --   , B.IsExtra  
 --   , B.IsSale  
 --   , B.IsExtra2  
 --   , B.isRecommend  
 --   , B.isSSPre  
 --   , B.Company_Seq  
 --   , H.IsSample  
 --   , ISNULL(CM.cnt, 0) AS Comment_Cnt  
 --   , (ISNULL(CM.StarPoints, 0) / ISNULL(CM.cnt, 1)) AS StarPoints  
 --   , ISNULL(SC.Cnt, 0) AS Sample_Cnt  
 --   , H.IsEnvInsert  
 --   , B.Ranking_M  
 --   , ISNULL(H.isFSC, '0') AS isFSC  
 --   , ISNULL(H.isNewEvent, '0') AS isNewEvent  
 --   , ISNULL(H.isRepinart, '0') AS isRepinart  
 --   , ISNULL(H.isHappyPrice, '0') AS isHappyPrice  
 --   , ISNULL(H.isSpringYN, '0') AS isSpringYN  
 --   , ISNULL(H.isnewGubun, '0') AS isnewGubun  
 --   , ISNULL(B.isBgcolor,'') AS isBgcolor  
 -- FROM S2_Card AS A   
 -- LEFT OUTER JOIN (  
 --      SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt, SUM(ER_Review_Star) AS StarPoints   
 --      FROM S4_Event_Review  
 --      WHERE ER_Company_Seq = @company_seq  
 --      GROUP BY ER_Card_Seq  
 --     ) CM ON A.Card_Seq = CM.Card_Seq   
 -- INNER JOIN S2_CardSalesSite AS B ON A.Card_Seq = B.card_seq  
 -- INNER JOIN S2_CardDiscount AS D ON B.CardDiscount_Seq = D.CardDiscount_Seq  
 -- INNER JOIN S2_CardImage AS E ON A.Card_Seq = E.Card_Seq    
 -- INNER JOIN S2_CardOption AS H ON A.card_seq = H.card_seq  
 -- INNER JOIN S2_CardKind AS I ON B.card_seq = I.Card_Seq  
 -- INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq  
 -- LEFT OUTER JOIN (  
 --      SELECT Card_Seq, SUM(Cnt) AS Cnt   
 --      FROM CUSTOM_SAMPLE_ORDER_ITEM_COUNT    
 --      WHERE Reg_Date BETWEEN @startDate AND @endDate  
 --      GROUP BY Card_Seq   
 --     ) SC ON A.Card_Seq = SC.Card_Seq  
    
 -- INNER JOIN S2_CardDetail CD ON A.Card_Seq = CD.Card_Seq  
    
 -- INNER JOIN   
 -- (     
 --  SELECT DISTINCT card_seq  
 --  FROM S2_CardStyle   
 --  WHERE CardStyle_Seq IN (@style1, @style2, @style3, @style4, @style5, @style6)  
 --  --WHERE CardStyle_Seq IN (372, 373, 374, 375, 376, 377)  
 -- ) CS ON B.Card_Seq = CS.Card_Seq    
    
 -- INNER JOIN   
 -- (     
 --  SELECT DISTINCT card_seq  
 --  FROM S2_CardStyle   
 --  WHERE CardStyle_Seq IN (@print1, @print2, @print3, @print4)  
 --  --WHERE CardStyle_Seq IN (457, 458, 460, 600)  
 -- ) CS2 ON B.Card_Seq = CS2.Card_Seq    
    
 -- WHERE 1 = 1   
 --   AND A.CardBrand = ISNULL(@brand, A.CardBrand)  
 --   AND B.Company_Seq = @company_seq  
 --   AND B.IsDisplay = 1    
 --   AND D.MinCount = @order_num  
 --   AND E.Company_Seq = @company_seq    
 --   AND E.CardImage_WSize = '210'   
 --   --AND E.CardImage_HSize = '210'   
 --   AND E.CardImage_Div = 'E'      
 --   AND (J.CardKind_Seq in (1,6) OR (ISNULL(@keyword, '') <> '' AND J.CardKind_Seq = 3)) -- (청첩장, 답례장) OR (검색어 있을때만 감사장 포함)     
 --   -- ##### 상세 검색 조건 시작 ##### --  
 --   -- 1. 카드번호 or 카드명 검색  
 --   AND ( A.Card_Name LIKE '%' + ISNULL(@keyword, '') + '%' OR A.Card_Code LIKE '%' + ISNULL(@keyword, '') + '%' )  
 --   -- 2. 가격 검색      
 --   -- * AND ( A.CardSet_Price BETWEEN ISNULL(@price1, A.CardSet_Price) AND ISNULL(@price2, A.CardSet_Price) )  
 --   AND ROUND( (A.cardset_price * (100 - D.discount_rate)/100), 0) BETWEEN ISNULL(@price1, A.CardSet_Price) AND ISNULL(@price2, A.CardSet_Price)   
 --   -- 3. 카드 모양 검색  
 --   AND CD.Card_Shape IN (@shape1, @shape2, @shape3)  
 --   -- 4. 카드 형태 검색 (접기)  
 --   AND CD.Card_Folding IN (@folding1, @folding2, @folding3, @folding4, @folding5, @folding6, @folding7, @folding8)  
 --   -- 5. 카드 스타일 검색  
 --   --AND CSI.CardStyle_Seq IN (@style1, @style2, @style3, @style4, @style5, @style6)  
 --   -- 6. 카드 인쇄방식 검색  
 --   --AND CSI2.CardStyle_Seq IN (@print1, @print2, @print3, @print4)  
 --   -- ##### 상세 검색 조건 끝 ##### --  
      
 --) AS RESULT  
 --WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )  
 ---- List Paging Query 끝 --   
  
  
 set @parmDefinition_itm = N'@company_seq int , @brand varchar(20), @page INT , @pagesize INT , @orderby varchar(20) , @Sequence varchar(20) ,@order_num INT , @keyword varchar(20) , @price1 INT , @price2 int ,@shape1 int ,@shape2 int ,@shape3 int ,@folding1 varchar(2) ,@folding2 varchar(2) ,@folding3 varchar(2) ,@folding4 varchar(2) ,@folding5 varchar(2) ,@folding6 varchar(2) ,@folding7 varchar(2) ,@folding8 varchar(2) ,@style1 INT ,@style2 INT ,@style3 INT ,@style4 INT ,@style5 INT ,@style6 INT , @print1 INT , @print2 INT , @print3 INT , @print4 INT ,@startDate datetime , @endDate datetime'  
  
 SET @strQuery = N''   
  
 SET @strQuery = @strQuery + ' SELECT *                                           '+char(13) + char(10)   
 SET @strQuery = @strQuery + ' FROM                                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + ' (                                      '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  SELECT  ROW_NUMBER() OVER (ORDER BY (                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            CASE @Sequence WHEN ''ASC'' THEN                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '             CASE @orderby WHEN ''REGDATE'' THEN A.RegDate               '+char(13) + char(10)  
 SET @strQuery = @strQuery + '              WHEN ''PRICE'' THEN (A.CardSet_Price * @order_num) * ((100-Discount_Rate)/100)        '+char(13) + char(10)  
 SET @strQuery = @strQuery + '              WHEN ''RECOM'' THEN B.Ranking_M                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '             END                          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            END                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            ) ASC,                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            (                            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            CASE @Sequence WHEN ''DESC'' THEN                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '             CASE @orderby WHEN ''REGDATE'' THEN A.RegDate               '+char(13) + char(10)  
 SET @strQuery = @strQuery + '              WHEN ''PRICE'' THEN (A.CardSet_Price * @order_num) * ((100-Discount_Rate)/100)        '+char(13) + char(10)  
 SET @strQuery = @strQuery + '              WHEN ''DISCOUNT_RATE'' THEN D.Discount_Rate --할인율 높은 순            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '              WHEN ''SAMPLE'' THEN SC.Cnt --샘플 신청 순                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '              WHEN ''COMMENT'' THEN CM.Cnt --상품평 순                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '             END                          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            END                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '            ) DESC ) AS RowNum                         '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , 1 AS ONE --S.RK_ST_SEQ                             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , 2 AS TWO  --S.RK_Card_Code                            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , 3 AS THREE--S.RK_Title                              '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , A.Card_Name                                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , A.Card_Code                                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , A.CardBrand                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , A.CardSet_Price                                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , A.card_seq                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , A.RegDate                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , CONVERT(INTEGER, D.Discount_Rate) AS Discount_Rate                        '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , E.CardImage_FileName                              '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.IsJumun                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.IsNew                                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.IsBest                                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.IsExtra                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.IsSale                                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.IsExtra2                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.isRecommend                                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.isSSPre                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.Company_Seq                                '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , H.IsSample                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(CM.cnt, 0) AS Comment_Cnt                            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , (ISNULL(CM.StarPoints, 0) / ISNULL(CM.cnt, 1)) AS StarPoints                       '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(SC.Cnt, 0) AS Sample_Cnt                            '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , H.IsEnvInsert                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , B.Ranking_M                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(H.isFSC, ''0'') AS isFSC                             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(H.isNewEvent, ''0'') AS isNewEvent                          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(H.isRepinart, ''0'') AS isRepinart                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(H.isHappyPrice, ''0'') AS isHappyPrice                          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(H.isSpringYN, ''0'') AS isSpringYN                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(H.isnewGubun, ''0'') AS isnewGubun                          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    , ISNULL(B.isBgcolor,'''') AS isBgcolor                            '+char(13) + char(10)
 SET @strQuery = @strQuery + '	  , ISNULL((SELECT COUNT(1) FROM   S4_Ranking_Sort_Table WHERE  RK_CARD_CODE = A.CARD_SEQ AND RK_ST_SEQ = 679 ), 0) as SUPER_DAYS_COUPON '+char(13) + char(10) 
 SET @strQuery = @strQuery + '  FROM S2_Card AS A                                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  LEFT OUTER JOIN (                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '       SELECT ER_Card_Seq AS Card_Seq, COUNT(ER_Card_Seq) AS cnt, SUM(ER_Review_Star) AS StarPoints           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '       FROM S4_Event_Review                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '       WHERE ER_Company_Seq = @company_seq                       '+char(13) + char(10)  
 SET @strQuery = @strQuery + '       GROUP BY ER_Card_Seq                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '      ) CM ON A.Card_Seq = CM.Card_Seq                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardSalesSite AS B ON A.Card_Seq = B.card_seq                        '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardDiscount AS D ON B.CardDiscount_Seq = D.CardDiscount_Seq                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardImage AS E ON A.Card_Seq = E.Card_Seq                         '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardOption AS H ON A.card_seq = H.card_seq                        '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardKind AS I ON B.card_seq = I.Card_Seq                         '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq                      '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  LEFT OUTER JOIN (                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    SELECT Card_Seq , Cnt FROM #CUSTOM_SAMPLE_ORDER_ITEM_CNT              '+char(13) + char(10)        
 SET @strQuery = @strQuery + '      ) SC ON A.Card_Seq = SC.Card_Seq                          '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN S2_CardDetail CD ON A.Card_Seq = CD.Card_Seq                        '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN                                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  (                                     '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   SELECT DISTINCT card_seq                              '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   FROM S2_CardStyle                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   WHERE CardStyle_Seq IN (@style1, @style2, @style3, @style4, @style5, @style6)                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   --WHERE CardStyle_Seq IN (372, 373, 374, 375, 376, 377)                         '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  ) CS ON B.Card_Seq = CS.Card_Seq                              '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  INNER JOIN                                    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  (                                     '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   SELECT DISTINCT card_seq                              '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   FROM S2_CardStyle                                 '+char(13) + char(10)  
 SET @strQuery = @strQuery + '   WHERE CardStyle_Seq IN (@print1, @print2, @print3, @print4)                       '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  ) CS2 ON B.Card_Seq = CS2.Card_Seq                             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '  WHERE 1 = 1                                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND A.CardBrand = ISNULL(@brand, A.CardBrand)                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND B.Company_Seq = @company_seq                             '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND B.IsDisplay = 1                                   '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND D.MinCount = @order_num                               '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND E.Company_Seq = @company_seq                               '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND E.CardImage_WSize = ''210''                               '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND E.CardImage_Div = ''E''                                  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND (J.CardKind_Seq in (1,6) OR (ISNULL(@keyword, '''') <> '''' AND J.CardKind_Seq = 3)) -- (청첩장, 답례장) OR (검색어 있을때만 감사장 포함)    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- ##### 상세 검색 조건 시작 ##### --'+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- 1. 카드번호 or 카드명 검색'+char(13) + char(10)   
 SET @strQuery = @strQuery + '    AND ( A.Card_Name LIKE ''%'' + ISNULL(@keyword, '''') + ''%'' OR A.Card_Code LIKE ''%'' + ISNULL(@keyword, '''') + ''%'' OR Replace(Replace(A.Card_Code,'' '',''''),CHAR(10),'''') LIKE ''%'' + ISNULL(@keyword, '''') + ''%'' OR Replace(Replace(A.Card_Name,'' '',''''),CHAR(10),'''') LIKE ''%'' + ISNULL(@keyword, '''') + ''%'')  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- 2. 가격 검색    '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- * AND ( A.CardSet_Price BETWEEN ISNULL(@price1, A.CardSet_Price) AND ISNULL(@price2, A.CardSet_Price) ) '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND ROUND( (A.cardset_price * (100 - D.discount_rate)/100), 0) BETWEEN ISNULL(@price1, A.CardSet_Price) AND ISNULL(@price2, A.CardSet_Price)  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- 3. 카드 모양 검색'+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND CD.Card_Shape IN (@shape1, @shape2, @shape3)  '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- 4. 카드 형태 검색 (접기) '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    AND CD.Card_Folding IN (@folding1, @folding2, @folding3, @folding4, @folding5, @folding6, @folding7, @folding8) '+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- 5. 카드 스타일 검색'+char(13) + char(10)  
 SET @strQuery = @strQuery + '    --AND CSI.CardStyle_Seq IN (@style1, @style2, @style3, @style4, @style5, @style6)'+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- 6. 카드 인쇄방식 검색'+char(13) + char(10)  
 SET @strQuery = @strQuery + '    --AND CSI2.CardStyle_Seq IN (@print1, @print2, @print3, @print4)'+char(13) + char(10)  
 SET @strQuery = @strQuery + '    -- ##### 상세 검색 조건 끝 ##### --'+char(13) + char(10)  
 SET @strQuery = @strQuery + ' ) AS RESULT                           '+char(13) + char(10)  
 SET @strQuery = @strQuery + ' WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )     '+char(13) + char(10)  
  
 --PRINT CAST(@parmDefinition_itm  AS TEXT )  
 PRINT CAST(@strQuery AS TEXT)  
  
   
  
 exec sp_executesql @strQuery , @parmDefinition_itm ,@company_seq  , @brand , @page  , @pagesize  , @orderby  , @Sequence  , @order_num  , @keyword  , @price1  , @price2  , @shape1  , @shape2  , @shape3  , @folding1  , @folding2  , @folding3  , @folding4 
 ,@folding5  ,@folding6  ,@folding7  ,@folding8  ,@style1  ,@style2  ,@style3  ,@style4  ,@style5  ,@style6  , @print1  , @print2  , @print3  , @print4 ,@startDate ,@endDate  
  
 -- List Paging Query 끝 --   
  
 DROP TABLE #CUSTOM_SAMPLE_ORDER_ITEM_CNT  
      
END  
  
  
  
-- 스타일 --  
/*  
SELECT A.card_seq  
FROM S2_CardSalesSite A   
INNER JOIN (  
    SELECT   
      DISTINCT   
      card_seq  
    FROM S2_CardStyle   
    --WHERE CardStyle_Seq IN (@style1, @style2, @style3, @style4, @style5, @style6)  
    WHERE CardStyle_Seq IN (372, 373, 374, 375, 376, 377)  
   ) B ON A.Card_Seq = B.Card_Seq  
WHERE Company_Seq = 5007  
*/  
  
  
GO
