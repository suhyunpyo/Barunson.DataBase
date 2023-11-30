IF OBJECT_ID (N'dbo.SP_SELECT_PRODUCT_LIST_THECARD_ACC', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_PRODUCT_LIST_THECARD_ACC
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
--   모바일 더카드 s4_md_choice 추천구성상품 모바일] (596)  [NEW19] 
-- 2) 변경 내역 :        
-- exec  SP_SELECT_PRODUCT_LIST_THECARD_ACC '5007' ,'736','1','10','RK_IDX','ASC' -- 식권
-- exec  SP_SELECT_PRODUCT_LIST_THECARD_ACC '5007' ,'737','1','10','RK_IDX','ASC' -- 방명록
-- exec  SP_SELECT_PRODUCT_LIST_THECARD_ACC '5007' ,'744','1','10','RK_IDX','ASC' -- 스티커
-- exec  SP_SELECT_PRODUCT_LIST_THECARD_ACC '5007' ,'745','1','10','RK_IDX','ASC' -- 디자인봉투
-- exec  SP_SELECT_PRODUCT_LIST_THECARD_ACC '5007' ,'746','1','10','RK_IDX','ASC' -- 돈봉투
-- exec  SP_SELECT_PRODUCT_LIST_THECARD_ACC '5007' ,'747','1','10','RK_IDX','ASC' -- 예식순서지

-- =============================================          
CREATE PROCEDURE [dbo].[SP_SELECT_PRODUCT_LIST_THECARD_ACC]        
         
 @company_seq int,    -- 회사고유코드         
 @category  int,    -- 카테고리 코드         
 @page   int,    -- 페이지 번호        
 @pagesize  int,    -- 페이지 사이즈 (페이지당 노출 갯수)         
 @orderby  nvarchar(20),  -- 정렬 컬럼        
 @Sequence  nvarchar(20)  -- 정렬 조건(ASC, DESC)        

         
AS        
BEGIN        
          
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
         
 SET NOCOUNT ON;          
 
        
  -- Count Query 시작 --    
  
 select COUNT(A.MD_SEQ) AS CNT   
  from S4_MD_Choice as A with(nolock) 
  INNER JOIN S2_Card AS B with(nolock)  ON A.card_seq = B.Card_Seq               
  INNER JOIN S2_CardSalesSite AS C with(nolock)  ON B.Card_Seq = C.Card_Seq  
  left join S2_CardDetail as Cd WITH(NOLOCK) ON B.Card_Seq= Cd.card_seq  
  WHERE 1 = 1        
    and A.MD_SEQ = @category 
	AND B.Card_Group='I' 	    
    AND C.isJumun='1'
    AND C.Company_Seq = @company_seq  

  -- Count Query 끝 --         
          
  -- List Paging Query 시작 --        
  SELECT *         
  FROM        
  (        
   SELECT  ROW_NUMBER() OVER (ORDER BY     
             A.Sorting_num ASC) AS RowNum            
     , @category AS RK_ST_SEQ        
     , A.CARD_SEQ AS RK_Card_Code        
     , B.Card_Name AS RK_Title        
     , B.Card_Name        
     , B.Card_Code        
     , (select code_value from manage_code where code_type='cardbrand' and code = B.CardBrand) as CardBrand      
     , B.card_price        
     , B.Card_Seq        
     , B.RegDate        
     , CASE WHEN Cd.acc1_seq > 0 THEN (SELECT card_code FROM S2_Card WHERE Card_Seq=Cd.acc1_seq) ELSE '' END AS acc1_code     
     , CASE WHEN Cd.acc2_seq > 0 THEN (SELECT card_code FROM S2_Card WHERE Card_Seq=Cd.acc2_seq) ELSE '' END AS acc2_code    
   FROM S4_MD_Choice AS A        
  INNER JOIN S2_Card AS B ON A.CARD_SEQ = B.Card_Seq               
  INNER JOIN S2_CardSalesSite AS C ON B.Card_Seq = C.Card_Seq  
  left join S2_CardDetail as Cd WITH(NOLOCK) ON B.Card_Seq= Cd.card_seq
   WHERE 1 = 1            
    AND A.MD_SEQ = @category
	AND B.Card_Group='I'     	
    AND C.isJumun='1'
    AND C.Company_Seq = @company_seq


  ) AS RESULT        
  WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )         
        
          
  -- List Paging Query 끝 --        
          
END 

 
GO
