IF OBJECT_ID (N'dbo.SP_SELECT_PRODUCT_LIST_THECARD_ACC_CHR', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_PRODUCT_LIST_THECARD_ACC_CHR
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
-- =============================================          
-- Author :  nsm        
-- Editor :  
-- Create date : 
-- Edit date : 
-- Description :         
-- 1) 최초 작성 :        
--   모바일 더카드 s4_md_choice 추천구성상품 모바일] (596)  [NEW19] 예식순서지만
-- 2) 변경 내역 :        
-- exec  [SP_SELECT_PRODUCT_LIST_THECARD_ACC_CHR] '5007' ,'747','1','10','RK_IDX','ASC' -- 예식순서지

-- =============================================          

CREATE PROCEDURE [dbo].[SP_SELECT_PRODUCT_LIST_THECARD_ACC_CHR]        
         
 @company_seq int,    -- 회사고유코드         
 @category  int,    -- 카테고리 코드         
 @page   int,    -- 페이지 번호        
 @pagesize  int,    -- 페이지 사이즈 (페이지당 노출 갯수)         
 @orderby  nvarchar(20),  -- 정렬 컬럼        
 @Sequence  nvarchar(20),  -- 정렬 조건(ASC, DESC)        
  @uid       varchar(100)    
         
AS        
BEGIN        
          
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
         
 SET NOCOUNT ON;          
 
 declare @ordernum int;
 set @ordernum = 300;

        
  -- Count Query 시작 --    
  
 select COUNT(MC.SEQ) AS CNT   
  from S4_MD_Choice as mc 
 inner join S2_Card AS A on A.card_Seq = mc.CARD_SEQ
 INNER JOIN S2_CardSalesSite B ON A.Card_Seq = B.card_seq      
 INNER JOIN S2_CardKind AS I ON B.card_seq = I.Card_Seq               
 INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq                  
 INNER JOIN S2_CardImage AS E ON B.Card_Seq = E.Card_Seq         
 INNER JOIN S2_CardDiscount AS D ON B.CardDiscount_Seq = D.CardDiscount_Seq      
 INNER JOIN S2_CardOption AS H ON A.card_seq = H.card_seq      
 INNER JOIN S2_CardDetail CD ON A.Card_Seq = CD.Card_Seq   

WHERE 1 = 1         
  and MC.MD_SEQ = @category
   AND B.Company_Seq = @company_seq      
   AND B.IsDisplay = 1 -- 사용여부      
   AND D.MinCount = @ordernum
   AND E.CardImage_WSize = '210'       
   AND E.CardImage_Div = 'E'         
   AND E.Company_Seq = @company_seq     
   AND J.CardKind_Seq = 17 -- 답례장    


  -- Count Query 끝 --         
          
  -- List Paging Query 시작 --        
  SELECT *         
  FROM        
  (        
   SELECT  ROW_NUMBER() OVER (ORDER BY     
             MC.Sorting_num ASC) AS RowNum            
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
 
    , CASE LEN(ISNULL(@UID ,''))     
        WHEN 0 THEN 0     
        ELSE ISNULL((select count(1) from S2_SampleBasket where uid = @UID and company_seq = @COMPANY_sEQ and card_seq = B.card_Seq),0)     
     END AS isBasket    

	
   from S4_MD_Choice as mc 
 inner join S2_Card AS A on A.card_Seq = mc.CARD_SEQ
 INNER JOIN S2_CardSalesSite B ON A.Card_Seq = B.card_seq      
 INNER JOIN S2_CardKind AS I ON B.card_seq = I.Card_Seq               
 INNER JOIN S2_CardKindInfo AS J ON I.CardKind_Seq = J.CardKind_Seq                  
 INNER JOIN S2_CardImage AS E ON B.Card_Seq = E.Card_Seq         
 INNER JOIN S2_CardDiscount AS D ON B.CardDiscount_Seq = D.CardDiscount_Seq      
 INNER JOIN S2_CardOption AS H ON A.card_seq = H.card_seq      
 INNER JOIN S2_CardDetail CD ON A.Card_Seq = CD.Card_Seq   
  
WHERE 1 = 1         
  and MC.MD_SEQ = @category
   AND B.Company_Seq = @company_seq      
   AND B.IsDisplay = 1 -- 사용여부      
   AND D.MinCount = @ordernum
   AND E.CardImage_WSize = '210'       
   AND E.CardImage_Div = 'E'         
   AND E.Company_Seq = @company_seq     
   AND J.CardKind_Seq = 17 -- 답례장   


  ) AS RESULT        
  WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )         
        
          
  -- List Paging Query 끝 --        
          
END 

 
GO
