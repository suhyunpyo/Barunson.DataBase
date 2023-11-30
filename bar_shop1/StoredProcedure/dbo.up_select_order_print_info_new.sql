IF OBJECT_ID (N'dbo.up_select_order_print_info_new', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_order_print_info_new
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
-- =============================================    
-- AUTHOR:  김현기    
-- CREATE DATE: 2016-08-18    
-- DESCRIPTION: 마이페이지 주문상세내역 - 웨딩홀 지번, 도로명추가    
-- TEST : UP_SELECT_ORDER_PRINT_INFO 2365685    
-- =============================================    
CREATE PROCEDURE [dbo].[up_select_order_print_info_new]    
 @ORDER_SEQ  INT     
AS    
 BEGIN    
 
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED    
 SET NOCOUNT ON;    
     
 SELECT A.FTYPE    
   , A.FETYPE    
   , A.GREETING_CONTENT    
   , A.BRIDE_NAME    
   , A.BRIDE_TAIL    
   , A.GROOM_NAME    
   , A.GROOM_TAIL    
   , A.EVENT_YEAR    
   , A.EVENT_MONTH    
   , A.EVENT_DAY    
   , A.INVITE_NAME    
   , A.BRIDE_FNAME    
   , A.BRIDE_FATHER_HEADER    
   , A.BRIDE_FATHER_FNAME    
   , A.BRIDE_FATHER    
   , A.BRIDE_FATHER_TAIL    
   , A.BRIDE_MOTHER_HEADER    
   , A.BRIDE_MOTHER_FNAME    
   , A.BRIDE_MOTHER    
   , A.BRIDE_MOTHER_TAIL    
   , A.BRIDE_RANK    
   , A.GROOM_FNAME    
   , A.GROOM_FATHER_HEADER    
   , A.GROOM_FATHER_FNAME    
   , A.GROOM_FATHER    
   , A.GROOM_FATHER_TAIL    
   , A.GROOM_MOTHER_HEADER    
   , A.GROOM_MOTHER_FNAME    
   , A.GROOM_MOTHER    
   , A.GROOM_MOTHER_TAIL    
   , A.GROOM_RANK    
   , A.LUNAR_YES_OR_NO    
   , A.LUNAR_EVENT_DATE    
   , A.EVENT_WEEKNAME    
   , A.EVENT_AMPM    
   , A.EVENT_HOUR    
   , A.EVENT_MINUTE    
   , A.ISNOTMAPPRINT    
   , A.WEDD_NAME    
   , A.WEDD_PLACE    
   , A.WEDD_PHONE    
   , A.WEDD_ADDR    
   , A.WEDD_ROAD_ADDR    
   , A.MAP_INFO    
   , A.MAP_TRANS_METHOD    
   , A.MAP_UPLOADFILE    
   , A.WEDD_IDX    
   , A.WEDDIMG_IDX    
   , A.GROOM_NAME_ENG    
   , A.GROOM_FNAME_ENG    
   , A.BRIDE_NAME_ENG    
   , A.BRIDE_FNAME_ENG    
   , A.GROOM_NAME_ENG1    
   , A.GROOM_FNAME_ENG1    
   , A.BRIDE_NAME_ENG1    
   , A.BRIDE_FNAME_ENG1    
   , A.PICTURE1    
   , A.PICTURE2    
   , A.PICTURE3    
   , A.PICTURE4    
   , A.PICTURE5    
   , A.PICTURE6    
   , A.PICTURE7    
   , A.PICTURE8    
   , A.MSG1    
   , A.ETC_COMMENT    
   , A.ETC_FILE    
   , A.MAP_ID    
   , C.WEDD_NAME AS ADD_WEDD_NAME    
   , C.WEDD_PLACE AS ADD_WEDD_PLACE    
   , A.BIBLE_TITLE  
   , A.BIBLE_CONTENT  
   , A.HYMN_CONTENT1  
   , A.HYMN_CONTENT2
   , A.HYMN_TITLE1  
   , A.HYMN_TITLE2  
   , A.WORSHIP_CONTENT  
   , A.WORSHIP_TITLE  
   , A.WORSHIP_NAME  
   , A.WORSHIP_HEADER  
   , A.ETC_COMMENT  
   , A.ADDR_GB,
	A.Account_Number
 FROM CUSTOM_ORDER_WEDDINFO AS A    
  LEFT OUTER JOIN CUSTOM_ORDER_PLIST AS B     
   ON A.ORDER_SEQ = B.ORDER_SEQ    
   AND B.TITLE = '카드추가인쇄1'    
  LEFT OUTER JOIN CUSTOM_ORDER_PLISTADDD AS C    
   ON B.ID = C.PID    
 WHERE A.ORDER_SEQ = @ORDER_SEQ    
     
     
END 
GO
