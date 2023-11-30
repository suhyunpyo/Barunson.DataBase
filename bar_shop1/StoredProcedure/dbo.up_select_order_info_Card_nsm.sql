IF OBJECT_ID (N'dbo.up_select_order_info_Card_nsm', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_info_Card_nsm
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
    
-- =============================================        
-- Author:  김덕중        
-- Create date: 2015-04-14        
-- Description: 마이페이지 주문상세내역 주문정보 (청첩장 / 답례장)        
-- TEST : up_select_order_info_Card 1970723, 'palaoh', 5007          
-- =============================================        


create PROCEDURE [dbo].[up_select_order_info_Card_nsm]        
         
 @order_seq  int,        
 @uid   nvarchar(16),         
 @company_seq int         
        
AS        
BEGIN        
         
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
         
 SET NOCOUNT ON;        
         
 /*        
 declare @order_seq int=1970723        
 declare @uid varchar(16)='palaoh'        
 declare @company_seq int=5007        
 */        
         
 SELECT   A.order_seq   --0        
   ,A.up_order_seq   --1        
   ,A.order_add_type  --2        
   ,A.order_add_flag  --3        
   ,A.weddinfo_id   --4        
   ,A.order_type   --5        
   ,A.order_date   --6        
   ,A.status_seq   --7        
   ,A.order_name   --8        
   ,A.member_id   --9        
   ,A.order_email   --10        
   ,A.order_phone   --11        
   ,A.order_hphone   --12        
   ,A.order_Count   --13        
   ,A.order_price   --14        
   ,A.order_total_price --15         
   ,A.last_total_price  --16        
   ,A.option_price   --17        
   ,A.discount_rate  --18        
   ,A.isinpaper   --19 속지 제본        
   --,1 AS isinpaper        
   ,A.ishandmade   --20 부속품 제본        
   --,1 AS ishandmade        
   ,A.isColorPrint   --21 칼라인쇄        
   ,A.isColorInpaper  --22 칼라속지        
   ,A.isLiningJaebon  --23 라이닝제본        
   ,A.print_price   --24        
   ,A.jebon_price   --25        
   --,100 AS jebon_price        
   ,A.embo_price   --26        
   --,100 AS embo_price        
   ,A.cont_price   --27        
   ,A.guestbook_price  --28        
   ,A.isEmbo    --29 송진인쇄        
   ,A.label_price   --30        
   ,A.envInsert_price  --31        
   --,100 AS envInsert_price         
   ,A.isEnvInsert   --32 봉투삽입        
   ,A.fticket_price  --33         
   ,A.sticker_price  --34        
   ,ISNULL(A.liningjaebon_price, 0) AS liningjaebon_price --35        
   ,A.unicef_price   --36        
   ,A.coop_sale_price  --37        
   ,A.etc_price   --38        
   ,A.etc_price_ment  --39        
   ,ISNULL(A.couponseq, '') AS couponseq --40        
   ,'' AS coupon_name --41        
   ,A.reduce_price   --42        
   ,A.delivery_price  --43        
   ,A.last_total_price  --44        
   ,CASE WHEN C.isHoneyMoon = '1' THEN '' ELSE ISNULL(A.print_color, '') END print_color --45        
   ,A.card_seq    --46        
   ,B.card_code   --47        
   ,B.cardset_price  --48        
   ,B.card_image   --49        
   ,C.isEmbo AS card_embo --50 송진인쇄        
   ,C.isEmboColor AS card_embocolor --51 송진칼라인쇄        
   ,C.isInpaper AS card_inpaper  --52 속지        
   ,C.isEnvInsert AS card_envInsert --53 봉투삽입        
   ,C.ishandmade AS card_handmade  --54        
   ,C.isJaebon AS card_jaebon   --55 제본        
   ,C.isColorPrint AS card_colorprint --56 칼라인쇄        
   ,C.isSelfEditor AS card_selfeditor --57        
   ,C.isOutsideInitial     --58        
   ,C.isLInitial      --59        
   ,C.isUsrImg1      --60        
   ,C.isUsrImg2      --61        
   ,C.isUsrImg3      --62        
   ,C.isUsrComment      --63        
   ,A.isVar       --64        
   ,A.settle_status     --65        
   ,A.src_compose_date     --66        
   ,B.card_name      --67        
   ,A.settle_price      --68        
   ,ISNULL(C.isJigunamu, '0') AS isJigunamu  --69        
   ,ISNULL(A.isEnvSpecial, '0') AS isEnvSpecial    
   ,A.EnvSpecial_Price      
   ,ISNULL(A.isperfume, '0') AS isperfume    
   ,A.perfume_price 

   , isnull((select coa.is_print from custom_order_agreement coa with(nolock) where coa.order_seq = a.order_seq and coa.is_agreemented = 1) ,0)as africa_agree
 FROM Custom_Order A         
 INNER JOIN S2_Card B ON A.card_seq = B.card_Seq        
 INNER JOIN S2_CardOption C ON A.card_seq = C.card_seq       
 WHERE 1 = 1        
   AND A.order_seq = @order_seq        
   AND A.member_id = @uid        
   AND A.company_seq = @company_seq         
          
          
END
GO
