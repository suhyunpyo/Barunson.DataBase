IF OBJECT_ID (N'dbo.up_update_mypage_order_status', N'P') IS NOT NULL DROP PROCEDURE dbo.up_update_mypage_order_status
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- =============================================    
-- Author:  조창연    
-- Create date: 2014-12-18    
-- Description: 마이페이지 주문 취소      
-- TEST : up_update_mypage_order_status    
-- =============================================    
CREATE PROCEDURE [dbo].[up_update_mypage_order_status]    
     
 @company_seq int,    
 @uid   nvarchar(16),    
 @order_seq  int,    
 @order_g_seq int,    
 @price   int,   -- settle_price 금액     
 @kind   varchar(1),  --상품 종류 ( S : 샘플 / E : 부가상품 / C : 청첩장, 답례장 등 )    
 @result_code int = 0 OUTPUT,    
 @result_cnt  int = 0 OUTPUT     
    
AS    
BEGIN    
     
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
     
 SET NOCOUNT ON;    
    
     
 --DECLARE @company_seq INT=5007    
 --DECLARE @uid VARCHAR(16)='palaoh'    
     
 BEGIN TRAN    
     
  -- 선택된 주문에 대한 [주문취소](3) 또는 [결제취소](5) 처리    
  -- order_price : 카드세트 가격 합계    
  -- order_total_price : 할인이 적용된 카드가격 합계 + 봉투가격(유료)    
  -- last_total_price : 최종가격 (+ 배송비)    
  DECLARE @status INT    
      
  IF @price = 0 -- settle_price 금액    
   BEGIN    
    SET @status = 3 --주문취소    
   END    
  ELSE    
   BEGIN    
    SET @status = 5 --결제취소    
   END    
       
      
  IF (@kind = 'C' or @kind='1' or @kind='2' or @kind='6' or @kind='7' or @kind='12')  -- 청첩장 / 답례장    
   BEGIN    
    UPDATE Custom_Order SET status_seq = @status, settle_status=@status, settle_cancel_date=getdate()      
    WHERE order_seq = @order_seq    
      AND member_id = @uid    
      AND company_seq = @company_seq    
   END    
  ELSE IF @kind = 'E' -- 부가상품 / 플러스쇼핑    
   BEGIN    
    UPDATE Custom_Etc_Order SET status_seq = @status, settle_Cancel_Date=GETDATE()      
    WHERE order_seq = @order_seq    
      AND member_id = @uid    
      AND company_seq = @company_seq    
   END    
  ELSE    -- 샘플    
   BEGIN    
    UPDATE Custom_Sample_Order SET status_seq = @status, CANCEL_DATE=GETDATE()    
    WHERE sample_order_seq = @order_seq    
      AND member_id = @uid    
      AND company_seq = @company_seq    
   END    
      
      
  DECLARE @sum_order_price INT    
  DECLARE @sum_last_total_price INT    
      
      
  IF (@kind = 'C' or @kind='1' or @kind='2' or @kind='6' or @kind='7' or @kind='12')  -- 청첩장 / 답례장    
   BEGIN    
    SELECT  @sum_order_price = ISNULL(SUM(order_price), 0)    
        ,@sum_last_total_price = ISNULL(SUM(last_total_price), 0)    
    FROM Custom_Order    
    WHERE order_g_seq = @order_g_seq    
      AND member_id = @uid    
      AND company_seq = @company_seq    
      AND status_seq NOT IN (3, 5)    
   END    
  ELSE IF @kind = 'E' -- 부가상품 / 플러스쇼핑    
   BEGIN     
    SELECT  @sum_order_price = ISNULL(SUM(settle_price), 0)    
        ,@sum_last_total_price = ISNULL(SUM(settle_price), 0)    
    FROM Custom_Etc_Order    
    WHERE order_g_seq = @order_g_seq    
      AND member_id = @uid    
      AND company_seq = @company_seq    
      AND status_seq NOT IN (3, 5)    
   END    
  ELSE    -- 샘플    
   BEGIN     
    SELECT  @sum_order_price = ISNULL(SUM(settle_price), 0)    
        ,@sum_last_total_price = ISNULL(SUM(settle_price), 0)    
    FROM Custom_Sample_Order    
    WHERE order_g_seq = @order_g_seq    
      AND member_id = @uid    
      AND company_seq = @company_seq    
      AND status_seq NOT IN (3, 5)    
   END    
       
      
  -- 선택된 주문이 속한 주문 그룹에 대한 주문금액 수정 (주문취소 건을 제외한 금액 합계)    
  --UPDATE Custom_order_Group SET  order_price = @sum_order_price    
  --        ,order_total_price = @sum_last_total_price       
  --WHERE order_g_seq = @order_g_seq      
      
     
 SET @result_cnt = @@ROWCOUNT --변경된 rowcount    
 SET @result_code = @@Error  --에러발생 cnt    
     
 IF (@result_code <> 0) GOTO PROBLEM    
 COMMIT TRAN    
    
 PROBLEM:    
 IF (@result_code <> 0) BEGIN    
  ROLLBACK TRAN    
 END    
     
 RETURN @result_code    
 RETURN @result_cnt    
     
    
END    
    
    
/*    
select *    
from custom_order_group    
where order_g_seq = 2085554    
    
update custom_order_group set order_price = 600000, order_total_price = 600000    
where order_g_seq = 2085554    
    
    
select *     
from custom_order     
where order_seq in (1970607, 1970608, 1970609)    
    
    
    
update custom_order set status_seq = 1    
where order_seq in (1970607, 1970608, 1970609)    
*/    
    
    
    
    
--select top 10 * FROM Custom_Etc_Order    
    
--select top 10 * FROM Custom_sample_Order 
GO
