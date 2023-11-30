IF OBJECT_ID (N'dbo.up_select_mypage_order_list_v2', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_mypage_order_list_v2
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
-- =============================================      
-- Author:  조창연      
-- Create date: 2014-12-17      
-- Description: 주문결제 리스트       
-- TEST : up_select_mypage_order_list 5007, 'mihee1103', 1, 100
-- Modify History: 2020-12-17 (박혜림) - 최근주문 내역 20건까지만 조회되도록 수정
-- =============================================      
CREATE PROCEDURE [dbo].[up_select_mypage_order_list_v2]      
       
 @company_seq int,      
 @uid   nvarchar(16),       
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
     AND member_id = @uid      
         
   UNION ALL      
         
   SELECT  'E' AS order_case      
     ,dbo.get_code_value('item_type', order_type) AS order_type_str      
     ,order_seq           
     ,status_seq           
     ,'' AS status_seq_str      
     ,settle_price      
     ,settle_method      
     ,pg_tid      
     ,pg_shopid      
     ,ISNULL(pg_resultinfo, '') AS pg_resultinfo      
     ,ISNULL(pg_resultinfo2, '') AS pg_resultinfo2      
     ,settle_date      
     ,delivery_date      
     ,delivery_com      
     ,delivery_code      
     ,member_id      
     ,company_seq      
     ,order_name  AS MEMBER_NAME      
     ,order_email AS member_email      
     ,0 AS unit_cnt      
     ,order_g_seq      
     ,'' AS strAddOrder           
   FROM Custom_Etc_Order      
   WHERE status_seq >= 1      
     AND company_seq = @company_seq      
     AND member_id = @uid         
         
   UNION ALL      
        
   SELECT  order_type AS order_case      
     ,dbo.get_code_value('worder_type', order_type) AS order_type_str      
     ,A.order_seq           
     ,status_seq           
     ,'' AS status_seq_str      
     ,last_total_price AS settle_price      
     ,settle_method      
     ,pg_tid      
     ,pg_shopid      
     ,ISNULL(pg_resultinfo, '') AS pg_resultinfo      
     ,ISNULL(pg_resultinfo2, '') AS pg_resultinfo2      
     ,settle_date      
     ,NULL AS delivery_date      
     ,NULL AS delivery_com      
     --,DELIVERY_CODE_NUM as delivery_code      
     ,NULL AS delivery_code
     ,member_id      
     ,company_seq      
     ,order_name  AS MEMBER_NAME      
     ,order_email AS member_email      
     ,0 AS unit_cnt      
     ,order_g_seq      
     ,(ISNULL(isFticket, 0)       
       + ';' + ISNULL(isembo, 0)       
       + ';' + ISNULL(isinpaper, 0)      
       + ';' + ISNULL(ishandmade, 0)         
       + ';' + ISNULL(isenvinsert, 0)       
       + ';' + ISNULL(isliningjaebon, 0)       
      ) AS strAddOrder           
   FROM Custom_Order A       
   INNER JOIN S2_Card B ON A.card_seq = B.card_seq      
   --LEFT JOIN DELIVERY_INFO C ON A.order_seq = c.ORDER_SEQ      
      
   WHERE status_Seq >= 0     
     AND pay_type <> '4'       
     AND order_type <> '4'      
     AND company_seq = @company_seq      
     AND member_id = @uid      
           
  ) O ON G.order_g_seq = O.order_g_seq AND G.member_id = O.member_id       
 )      
 ,      
 CTE_Order_Count      
 AS      
 (      
  SELECT COUNT(*) AS total_cnt       
  FROM CTE_Order      
 )      
       
       
       
 -- LIST Query (Total Count 포함) --      
 --SELECT *      
 --FROM       
 --(      
  SELECT TOP 20 ROW_NUMBER() OVER (ORDER BY order_date DESC) AS RowNum      
      , T.total_cnt       
         , O.*      
         , Sub_Rows.cnt AS sub_cnt      
         , dbo.get_order_amount(O.order_seq, O.order_case) AS strGoodsAmount      
         --, ISNULL(DI.delivery_code_num, '') AS delivery_code_num,      
         , NULL AS delivery_code_num,      
       (select PG_TID from Custom_order_Group where order_g_seq=O.order_g_seq) AS TID      
      --, DI.delivery_com AS delivery_com      
      , NULL AS delivery_com
  FROM CTE_Order O      
  INNER JOIN CTE_Order_Count T ON 1 = 1      
  INNER JOIN       
  (      
   SELECT order_g_seq, SUM(cnt) AS cnt      
   FROM      
   (      
    SELECT order_g_seq, COUNT(order_g_seq) AS cnt        
    FROM Custom_Order      
    WHERE 1 = 1      
     AND status_Seq >= 0       
     AND pay_type <> '4'       
     AND order_type <> '4'      
     AND member_id = @uid      
     AND company_seq = @company_seq      
    GROUP BY order_g_seq      
    HAVING COUNT(order_g_seq) > 0      
      
    UNION ALL      
      
    SELECT order_g_seq, COUNT(order_g_seq) AS cnt        
    FROM Custom_etc_Order      
    WHERE 1 = 1      
     AND status_seq >= 1      
      AND member_id = @uid      
     AND company_seq = @company_seq      
    GROUP BY order_g_seq      
    HAVING COUNT(order_g_seq) > 0      
            
    UNION ALL      
      
    SELECT order_g_seq, COUNT(order_g_seq) AS cnt        
    FROM Custom_Sample_Order      
    WHERE 1 = 1      
      AND member_id = @uid      
     AND company_seq = @company_seq      
     AND status_seq >= 1      
    GROUP BY order_g_seq      
    HAVING COUNT(order_g_seq) > 0      
   ) AA      
   GROUP BY order_g_seq      
  ) Sub_Rows ON O.order_g_seq = Sub_Rows.order_g_seq      
  --LEFT OUTER JOIN Delivery_Info DI ON O.order_seq = DI.order_seq      
  --LEFT OUTER JOIN      
  --(      
  -- SELECT TOP 1      
  --  A.order_seq      
  --  , A.delivery_code_num      
  --  , A.delivery_com      
  -- FROM Delivery_Info AS A      
  --  INNER JOIN CTE_Order AS B      
  --   ON A.order_seq = B.order_seq      
  --) AS DI      
  -- ON O.order_seq = DI.order_seq      
         
 --) AS Result      
 --WHERE RowNum BETWEEN ( ( (@page - 1) * @pagesize ) + 1 ) AND ( @page * @pagesize )      
       
       
      
END 
GO
