IF OBJECT_ID (N'dbo.up_select_order_print_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_print_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
-- =============================================  
-- Author:  조창연  
-- Create date: 2014-12-23  
-- Description: 마이페이지 주문상세내역 - 카드 인쇄 정보  
-- TEST : up_select_order_print_info 2267592  
-- =============================================  
CREATE PROCEDURE [dbo].[up_select_order_print_info]  
 @order_seq  int   
  
AS  
 BEGIN  
   
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 SET NOCOUNT ON;  
   
 SELECT A.ftype, A.fetype, A.greeting_content, A.bride_name, A.bride_tail, A.groom_name, 
		A.groom_tail, A.event_year, A.event_month, A.event_day, A.invite_name, A.bride_fname, 
		A.bride_father_header, A.bride_father_fname, A.bride_father, A.bride_father_tail, 
		A.bride_mother_header, A.bride_mother_fname, A.bride_mother  , A.bride_mother_tail  
, A.bride_rank  
, A.groom_fname  
, A.groom_father_header  
, A.groom_father_fname  
, A.groom_father  
, A.groom_father_tail  
, A.groom_mother_header  
   , A.groom_mother_fname  
   , A.groom_mother  
   , A.groom_mother_tail  
   , A.groom_rank  
   , A.lunar_yes_or_no  
   , A.lunar_event_date  
   , A.event_weekname  
   , A.event_ampm  
   , A.event_hour  
   , A.event_minute  
   , A.isNotMapPrint  
   , A.wedd_name  
   , A.wedd_place  
   , A.wedd_phone  
   , A.wedd_addr  
   , A.map_info  
   , A.map_trans_method  
   , A.map_uploadfile  
   , A.wedd_idx  
   , A.weddimg_idx  
   , A.groom_name_eng  
   , A.groom_fname_eng  
   , A.bride_name_eng  
   , A.bride_fname_eng  
   , A.groom_name_eng1  
   , A.groom_fname_eng1  
   , A.bride_name_eng1  
   , A.bride_fname_eng1  
   , A.picture1  
   , A.picture2  
   , A.picture3  
   , A.picture4  
   , A.picture5  
   , A.picture6  
   , A.picture7  
   , A.picture8  
   , A.msg1  
   , A.etc_comment  
   , A.etc_file  
   , A.map_id  
   , C.wedd_name AS add_wedd_name  
   , C.wedd_place AS add_wedd_place  
   , A.bible_title
   , A.bible_content
   , A.hymn_title1
   , A.hymn_title2
   , A.hymn_content1
   , A.hymn_content2
   , A.worship_content
   , A.worship_title
   , A.worship_header
   , A.worship_name,
	A.Account_Number
 FROM Custom_Order_WeddInfo AS A  
  LEFT OUTER JOIN custom_order_plist AS B   
   ON A.order_seq = B.order_seq  
   AND B.title = '카드추가인쇄1'  
  LEFT OUTER JOIN custom_order_plistAddD AS C  
   ON B.id = C.pid  
 WHERE A.order_seq = @order_seq  
   
   
END 
GO
