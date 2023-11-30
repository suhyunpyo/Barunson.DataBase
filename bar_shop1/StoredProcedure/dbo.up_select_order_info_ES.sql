IF OBJECT_ID (N'dbo.up_select_order_info_ES', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_info_ES
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  조창연  
-- Create date: 2014-12-23  
-- Description: 마이페이지 주문상세내역 주문정보 (부가상품 / 샘플)  
-- TEST : up_select_order_info_ES 3148112, 'palaoh', 5007, 'E'    
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_order_info_ES]  
   
 @order_seq  int,  
 @uid   nvarchar(16),   
 @company_seq int,  
 @kind   varchar(1)   
  
AS  
BEGIN  
   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;  
   
 /*  
 declare @order_seq int=1970723  
 declare @uid varchar(16)='palaoh'  
 declare @company_seq int=5007  
 */  
   
 IF @kind = 'S' -- 샘플 주문  
   
  BEGIN  
     
   SELECT   sample_order_seq AS order_seq --0  
     ,'S' AS order_type --1  
     ,status_seq --2  
     ,settle_price --3  
     ,delivery_price --4  
     ,member_name AS recv_name --5  
     ,member_phone AS recv_phone --6  
     ,member_hphone AS recv_hphone --7  
     ,member_zip AS recv_zip --8  
     ,member_address AS recv_address --9  
     ,member_address_detail AS recv_address_detail --10  
     ,delivery_com --11  
     ,delivery_code_num AS delivery_code --12  
     ,ISNULL(memo, '') AS recv_msg --13  
     ,card_price --14  
     ,invoice_print_yorn -- 15
   FROM Custom_Sample_Order  
   WHERE sample_order_seq = @order_seq  
     AND company_seq = @company_seq   
     AND member_id = @uid   
     AND status_seq >= 1  
       
     
   SELECT   I.card_seq  
     ,I.sample_order_seq AS order_Seq      
     ,C.card_code  
     ,C.card_name  
     --,C.card_image  
     ,I.card_price  
   FROM Custom_Sample_Order_Item I  
   INNER JOIN S2_Card C ON I.card_seq = C.card_seq  
   WHERE I.sample_order_seq = @order_seq  
     
    
  END   
   
 ELSE   -- 부가상품 주문  
   
  BEGIN  
     
   SELECT   O.order_seq --0  
     ,'E' AS order_type --1  
     ,O.status_seq --2       
     ,O.settle_price --3  
     ,O.delivery_price --4  
     ,O.recv_name --5  
     ,O.recv_phone --6  
     ,O.recv_hphone --7  
     ,O.recv_zip --8  
     ,O.recv_address --9  
     ,O.recv_address_detail --10  
     ,O.delivery_com --11  
     ,O.delivery_code --12  
     ,ISNULL(O.recv_msg, '') AS recv_msg  --13  
     ,ISNULL(O.couponseq, '') AS couponseq --14  
     ,O.coupon_price --15  
     ,ISNULL(CM.Subject, '') AS coupon_name --16  
   FROM Custom_Etc_Order O  
   LEFT OUTER JOIN tCouponSub CS ON O.couponseq = CS.CouponNum  
   LEFT OUTER JOIN tCouponMst CM ON CS.CouponCD = CM.CouponCD  
   WHERE O.order_seq = @order_seq         
     AND O.company_seq = @company_seq  
     AND O.member_id = @uid   
     AND O.status_seq >= 1  
       
       
   SELECT   I.card_seq  --0  
     ,I.order_seq --1      
     ,C.card_code --2   
     ,C.card_name --3  
     --,C.card_image  
     ,I.order_count --4  
     ,I.card_price --5      
   FROM Custom_Etc_Order_Item I  
   INNER JOIN S2_Card C ON I.card_seq = C.card_seq  
   WHERE I.order_seq = @order_seq  
     
    
  END     
    
    
END  
GO
