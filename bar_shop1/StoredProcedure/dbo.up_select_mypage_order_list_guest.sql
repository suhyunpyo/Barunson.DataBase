IF OBJECT_ID (N'dbo.up_select_mypage_order_list_guest', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mypage_order_list_guest
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Create date: 2018-12-19 (더카드 비회원 추가)  
-- Description: 주문결제 리스트   
-- TEST : up_select_mypage_order_list 5007, 'mihee1103', 1, 100  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_mypage_order_list_guest]  
   
 @company_seq int,  
 @uname   nvarchar(20),   
 @uemail   nvarchar(50),   
 @page   int,   -- 페이지넘버  
 @pagesize  int    -- 페이지사이즈(페이지당 노출갯수)  
  
AS  
BEGIN  
   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;  
   
 --DECLARE @company_seq INT=5007  
 --DECLARE @uid VARCHAR(16)='palaoh';   
   
 WITH CTE_Order  
 AS  
 (  
  SELECT   G.order_date  
    ,O.*  
    ,G.order_total_price  
  FROM Custom_Order_Group G  
  INNER JOIN  
  (     
   SELECT  'S' AS order_case  
     ,'샘플' AS order_type_str  
     ,A.sample_order_seq AS order_seq       
     ,A.status_seq       
     ,'' AS status_seq_str  
     ,A.settle_price  
     ,A.settle_method  
     ,A.pg_tid  
     ,A.pg_mertid AS pg_shopid  
     ,ISNULL(A.pg_resultinfo, '') AS pg_resultinfo  
     ,ISNULL(A.pg_resultinfo2, '') AS pg_resultinfo2  
     ,A.settle_date  
     ,A.delivery_date  
     ,A.delivery_com  
     ,A.delivery_code_num AS delivery_code  
     ,A.member_id  
     ,A.company_seq  
     ,A.member_name  
     ,A.member_email     
     ,B.cnt AS unit_cnt  
     ,A.order_g_seq  
     ,'' AS strAddOrder       
   FROM Custom_Sample_Order AS A   
   LEFT OUTER JOIN (  
        SELECT sample_order_seq, COUNT(sample_order_seq) AS cnt  
        FROM CUSTOM_SAMPLE_ORDER_ITEM   
        GROUP BY sample_order_seq      
       ) B ON A.sample_order_seq = B.sample_order_seq  
   WHERE status_seq >= 1  
     AND company_seq = @company_seq  
     AND MEMBER_NAME = @uname  
     AND MEMBER_EMAIL = @uemail  
  
  ) O ON G.order_g_seq = O.order_g_seq AND G.order_email = O.member_email and g.order_name = O.member_name  
 )  
 ,  
 CTE_Order_Count  
 AS  
 (  
  SELECT COUNT(*) AS total_cnt   
  FROM CTE_Order  
 )  
   
   
  SELECT  ROW_NUMBER() OVER (ORDER BY order_date DESC) AS RowNum  
      , T.total_cnt   
         , O.*  
         , Sub_Rows.cnt AS sub_cnt  
         , dbo.get_order_amount(O.order_seq, O.order_case) AS strGoodsAmount  
         , ISNULL(DI.delivery_code_num, '') AS delivery_code_num,  
       (select PG_TID from Custom_order_Group where order_g_seq=O.order_g_seq) AS TID  
      , DI.delivery_com AS delivery_com  
  FROM CTE_Order O  
  INNER JOIN CTE_Order_Count T ON 1 = 1  
  INNER JOIN   
  (  
   SELECT order_g_seq, SUM(cnt) AS cnt  
   FROM  
   (  
  
    SELECT order_g_seq, COUNT(order_g_seq) AS cnt    
    FROM Custom_Sample_Order  
    WHERE 1 = 1  
      AND member_name = @uname  
      AND member_email = @uemail  
      AND company_seq = @company_seq  
      AND status_seq >= 1  
    GROUP BY order_g_seq  
    HAVING COUNT(order_g_seq) > 0  
   ) AA  
   GROUP BY order_g_seq  
  ) Sub_Rows ON O.order_g_seq = Sub_Rows.order_g_seq  
  LEFT OUTER JOIN Delivery_Info DI ON O.order_seq = DI.order_seq  
  
  
END  
  
  
GO
