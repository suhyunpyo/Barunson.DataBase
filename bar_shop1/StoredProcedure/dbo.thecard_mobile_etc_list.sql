IF OBJECT_ID (N'dbo.thecard_mobile_etc_list', N'P') IS NOT NULL DROP PROCEDURE dbo.thecard_mobile_etc_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================    
-- Author :  김현기  
-- Create date : 2014-11-12    
-- Edit date : 2015-05-21  
-- Description :   
-- 1) 최초 작성 :  
-- 모바일 청첩장 부가상품 리스트  
--  
-- EXEC thecard_mobile_etc_list 5007, 'B01', 1, 20  
-- =============================================    
CREATE PROCEDURE [dbo].[thecard_mobile_etc_list]  
 @company_seq int,    -- 회사고유코드   
 @card_div  varchar(20),    -- 카테고리 코드   
 @page   int,    -- 페이지 번호  
 @pagesize  int     -- 페이지 사이즈 (페이지당 노출 갯수)   
AS  
BEGIN  
    
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;    
  
 DECLARE @card_div_list varchar(100)  
 set @card_div_list = CASE @card_div WHEN 'C06' THEN 'C01,C02,C06,C09,C10,C11' ELSE @card_div + ',' END  
   
 -- 베스트 청첩장  
 IF (@card_div = 'B01')  
 BEGIN  
    
     SELECT AA.CARD_SEQ,  
                AA.CARD_CODE,                                                                                                  
                AA.CARD_NAME,                                                                                                  
                AA.CARD_WSIZE,                                                                                                  
                AA.CARD_HSIZE,                                                                                                  
                AA.CARD_PRICE,                                                                                                  
                AA.CARDIMAGE_FILENAME,                                                                                                  
                AA.CARD_DIV,                                                                                                  
                AA.CATE_SORT,  
                0 AS ACC1_CODE,                                                                                                 
                0 AS ACC2_CODE                                                                                                
     FROM                                                                                        
     (                                                                                           
         SELECT  A.CARD_SEQ, B.CARD_CODE, B.CARD_NAME, B.CARD_WSIZE, B.CARD_HSIZE,               
                 B.CARD_PRICE, D.CARDIMAGE_FILENAME, B.CARD_DIV,                              
                 ROW_NUMBER()OVER(PARTITION BY B.CARD_SEQ ORDER BY D.CARDIMAGE_FILENAME ) S_RM,  
                 CASE                                                                            
                     WHEN LEFT(B.CARD_CODE,2) = '18' THEN 1                                      
                     WHEN LEFT(B.CARD_CODE,2) = '16' THEN 0                                      
                     WHEN LEFT(B.CARD_CODE,2) = '14' THEN 2                                      
                     ELSE 0                                                                      
                 END CATE_SORT,                                                                  
                 CASE                     
                    WHEN B.CARD_DIV = 'C18' THEN '개'                                            
                    ELSE '장'                   
                 END CATE_STR,
                 B.RegDate                
         FROM    S2_CARDSALESSITE A                                                              
                 JOIN S2_CARD B ON A.CARD_SEQ=B.CARD_SEQ                                         
                 JOIN S2_CARDIMAGE D ON A.CARD_SEQ=D.CARD_SEQ AND D.COMPANY_SEQ=5001             
         WHERE A.COMPANY_SEQ = @company_seq                                                 
         AND A.ISDISPLAY='1'                                                                     
         AND LEFT(D.CARDIMAGE_FILENAME,2) = 'B1'                                                 
         AND B.CARD_DIV = @card_div                                      
     ) AA                                      
     WHERE AA.S_RM = 1                                                                           
     ORDER BY  AA.CATE_SORT ASC , AA.CARD_SEQ DESC                      
  
 END  
 -- FSC인증 청첩장  
 ELSE   
 BEGIN  
     -- total count  
     --SELECT COUNT(A.Card_Seq) AS TOT   
     --FROM   
     -- S2_Card AS A WITH(NOLOCK)   
     -- INNER JOIN S2_CardSalesSite AS B WITH(NOLOCK) ON A.Card_Seq=B.Card_Seq    
     --WHERE   
     -- A.card_div IN (SELECT value FROM FN_SPLIT(@card_div_list, ','))   
     -- --A.card_div=@card_div  
     -- AND A.card_seq not in ('33958', '34420', '34431', '34432', '34836', '34880') -- 사용안하는 제품은 노출금지..daniel,kim  
     -- AND A.Card_Group='I'   
     -- AND B.isJumun='1'   
     -- AND B.Company_Seq=@company_seq;  
    
     -- goods list  
     SELECT    
            RESULT.CARD_SEQ,  
            RESULT.CARD_CODE,  
            RESULT.CARD_NAME,  
            0 AS CARD_WSIZE,  
            0 AS CARD_HSIZE,  
            RESULT.CARD_PRICE,                                                                                                  
            '' AS CARDIMAGE_FILENAME,                                                                                                  
            RESULT.CARD_DIV,                                                                                                  
            0 AS CATE_SORT,  
            RESULT.acc1_code AS ACC1_CODE,                                                                                                 
            RESULT.acc2_code AS ACC2_CODE                                                                                                
  
     FROM  
     (  
      SELECT  ROW_NUMBER() OVER (ORDER BY (  
               A.REGDATE  
                   ) DESC,  
                (  
               A.REGDATE  
                   ) ASC   
                                                    ) AS RowNum,       
       A.card_seq, A.card_code, A.card_name, A.cardset_price, A.card_price, A.cardFactory_Price, A.card_image, A.Card_Div,  
       CASE WHEN C.acc1_seq > 0 THEN (SELECT card_code FROM S2_Card WHERE Card_Seq=C.acc1_seq) ELSE '' END AS acc1_code,   
       CASE WHEN C.acc2_seq > 0 THEN (SELECT card_code FROM S2_Card WHERE Card_Seq=C.acc2_seq) ELSE '' END AS acc2_code  
      FROM   
       S2_Card AS A   
       inner join s2_cardsalessite AS B WITH(NOLOCK) ON A.Card_Seq= B.card_seq  
       left join S2_CardDetail as C WITH(NOLOCK) ON A.Card_Seq= C.card_seq  
      WHERE   
       A.card_div IN (SELECT value FROM FN_SPLIT(@card_div_list, ','))    
       --A.card_div=@card_div   
       AND A.card_seq not in ('33958', '34420', '34431', '34432', '34836', '34880') -- 사용안하는 제품은 노출금지..daniel,kim  
       AND A.Card_Group='I'   
       AND B.isJumun='1'   
       AND B.Company_Seq=@company_seq  
     ) AS RESULT  
     WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )   
 END  
END  
  
GO
