IF OBJECT_ID (N'dbo.up_select_thankcard_order_option_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thankcard_order_option_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  조창연  
-- Create date: 2015-01-23  
-- Description: 답례장 주문 2단계 주문정보 가져오기   
-- TEST : up_select_thankcard_order_option_info 1970473, 'palaoh'   
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_thankcard_order_option_info]  
  
 @order_seq int,  
 @uid varchar(16)  
  
AS  
BEGIN  
   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
   
 SET NOCOUNT ON;  
    
    
    SELECT   A.order_seq  
   ,A.order_type  
   ,A.isSpecial  
   ,A.card_Seq  
   ,A.order_name  
   ,A.member_id  
   ,A.order_phone  
   ,A.order_hphone  
   ,A.order_type  
   ,A.order_count  
   ,A.fticket_price  
   ,A.sticker_price  
   ,A.guestbook_price  
   ,A.order_price  
   ,A.order_total_price  
   ,A.last_total_price  
   ,A.option_price  
   ,A.discount_rate  
   ,A.isinpaper  
   ,A.ishandmade  
   ,A.isColorPrint  
   ,A.isColorInpaper  
   ,A.isLiningJaebon  
   ,A.print_price  
   ,A.jebon_price  
   ,A.embo_price  
   ,A.isEmbo  
   ,A.label_price  
   ,A.envInsert_price  
   ,A.isEnvInsert  
   ,A.isCorel  
   ,A.card_seq  
   ,ISNULL(A.print_color, '') AS print_color  
   ,B.card_code  
   ,B.cardset_price  
   ,B.card_image  
   ,C.isEmbo AS card_embo  
   ,C.isEmboColor AS card_embocolor  
   ,C.isInpaper AS card_inpaper  
   ,C.isJaebon AS card_jaebon  
   ,C.isEnvInsert AS card_envInsert  
   ,C.ishandmade AS card_handmade  
   ,C.isJaebon AS card_jaebon  
   ,C.isColorPrint AS card_colorprint  
   ,C.isSelfEditor AS card_selfeditor  
   ,C.isSticker AS card_sticker  
   ,C.isLiningJaebon AS card_lining  
   ,A.order_g_seq
    FROM Custom_Order A    
    LEFT OUTER JOIN S2_Card B ON A.card_seq = B.card_Seq  
    INNER JOIN S2_CardOption C ON B.card_seq = C.card_seq   
    WHERE A.order_seq = @order_seq  
      AND A.member_id = @uid  
        
          
END    
GO
