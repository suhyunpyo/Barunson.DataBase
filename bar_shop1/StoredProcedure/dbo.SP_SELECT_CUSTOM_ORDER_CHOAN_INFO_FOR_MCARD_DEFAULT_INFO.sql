IF OBJECT_ID (N'dbo.SP_SELECT_CUSTOM_ORDER_CHOAN_INFO_FOR_MCARD_DEFAULT_INFO', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_SELECT_CUSTOM_ORDER_CHOAN_INFO_FOR_MCARD_DEFAULT_INFO
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

	
EXEC SP_SELECT_CUSTOM_ORDER_CHOAN_INFO_FOR_MCARD_DEFAULT_INFO 's5guest', 1460305

1594813
1594813

*/

CREATE PROCEDURE [dbo].[SP_SELECT_CUSTOM_ORDER_CHOAN_INFO_FOR_MCARD_DEFAULT_INFO]
	@P_USER_ID			AS VARCHAR(50)
	, @P_ORDER_SEQ		AS INT
AS
BEGIN

	SELECT	TOP 1 
			
			CO.sales_gubun
		,	CO.company_seq

		,	COW.groom_initial          
		,	COW.bride_initial          
		,	COW.groom_name_eng         
		,	COW.bride_name_eng         
		,	COW.groom_Fname_eng        
		,	COW.bride_Fname_eng
		,   COW.etc_comment
		,   COW.etc_file
		,   COW.picture1
		,   COW.picture2
		,   COW.picture3
		,	COW.msg1
		,	COW.keyimg
		,	COW.wedd_date
		,	COW.groom_star
		,	COW.bride_star
		,	COW.groom_Illustration
		,	COW.bride_Illustration
		
		,   CO.order_name
		,   CO.order_hphone
		,   CO.order_email

		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_name                  , '') ELSE COW.groom_name                   END AS gname         
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_name                  , '') ELSE COW.bride_name                   END AS bname
		
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_year                  , '') ELSE ISNULL(COW.event_year, '')	    END AS event_year        
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_month                 , '') ELSE ISNULL(COW.event_month, '')	    END AS event_month       
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_Day                   , '') ELSE ISNULL(COW.event_Day, '')		END AS event_Day         
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_weekname              , '') ELSE COW.event_weekname			    END AS event_weekname    
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.lunar_yes_or_no             , '') ELSE COW.lunar_yes_or_no      		END AS lunar_yes_or_no   
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.lunar_event_Date            , '') ELSE COW.lunar_event_Date     		END AS lunar_event_Date  
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_ampm                  , '') ELSE COW.event_ampm           		END AS event_ampm        
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_hour                  , '') ELSE COW.event_hour           		END AS event_hour        
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.event_minute                , '') ELSE COW.event_minute         		END AS event_minute      
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.wedd_name                   , '') ELSE COW.wedd_name            		END AS wedd_name         
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.wedd_place                  , '') ELSE COW.wedd_place           		END AS wedd_place        
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.wedd_addr                   , '') ELSE COW.wedd_addr            		END AS wedd_addr         
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.wedd_phone                  , '') ELSE replace(COW.wedd_phone,')','-')	END AS wedd_phone        
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.wedd_idx                    , '') ELSE COW.wedd_idx             		END AS wedd_idx          
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.wedd_imgidx                 , '') ELSE COW.weddimg_idx          		END AS weddimg_idx       
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.map_trans_method            , '') ELSE COW.map_trans_method     		END AS map_trans_method  
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.map_uploadfile              , '') ELSE COW.map_uploadfile       		END AS map_uploadfile    
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.isNotMapPrint               , '') ELSE COW.isNotMapPrint        		END AS isNotMapPrint     
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.map_id					    , '') ELSE COW.map_id					    END AS map_id     
		,   CASE WHEN AD.pid IS NOT NULL THEN ISNULL(AD.traffic_id				    , '') ELSE COW.traffic_id				    END AS traffic_id     
		
		,   CASE WHEN AG.pid IS NOT NULL THEN ISNULL(AG.greeting_content            , '') ELSE COW.greeting_content     		END AS greeting_content

		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_name                  , '') ELSE ISNULL(COW.groom_name, '')	    END AS groom_name         
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_name                  , '') ELSE ISNULL(COW.bride_name, '')       END AS bride_name     
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_tail                  , '') ELSE COW.groom_tail				    END AS groom_tail         
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_tail                  , '') ELSE COW.bride_tail           		END AS bride_tail         
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_father                , '') ELSE COW.groom_father         		END AS groom_father       
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_mother                , '') ELSE COW.groom_mother         		END AS groom_mother       
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_rank                  , '') ELSE COW.groom_rank           		END AS groom_rank         
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_father                , '') ELSE COW.bride_father         		END AS bride_father       
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_mother                , '') ELSE COW.bride_mother         		END AS bride_mother       
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_rank                  , '') ELSE COW.bride_rank           		END AS bride_rank         
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_fname                 , '') ELSE COW.groom_fname          		END AS groom_fname        
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_fname                 , '') ELSE COW.bride_fname          		END AS bride_fname        
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_father_fname          , '') ELSE COW.groom_father_fname   		END AS groom_father_fname 
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_mother_fname          , '') ELSE COW.groom_mother_fname   		END AS groom_mother_fname 
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_father_fname          , '') ELSE COW.bride_father_fname   		END AS bride_father_fname 
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_mother_fname          , '') ELSE COW.bride_mother_fname   		END AS bride_mother_fname 
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_father_tail           , '') ELSE COW.groom_father_tail    		END AS groom_father_tail  
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_mother_tail           , '') ELSE COW.groom_mother_tail    		END AS groom_mother_tail  
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_father_tail           , '') ELSE COW.bride_father_tail    		END AS bride_father_tail  
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_mother_tail           , '') ELSE COW.bride_mother_tail    		END AS bride_mother_tail  
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.isgroom_tail                , '') ELSE COW.isgroom_tail         		END AS isgroom_tail       
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.isbride_tail                , '') ELSE COW.isbride_tail         		END AS isbride_tail       
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_father_header         , '') ELSE COW.groom_father_header  		END AS groom_father_header
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.groom_mother_header         , '') ELSE COW.groom_mother_header  		END AS groom_mother_header
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_father_header         , '') ELSE COW.bride_father_header  		END AS bride_father_header
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.bride_mother_header         , '') ELSE COW.bride_mother_header  		END AS bride_mother_header
		,   CASE WHEN AN.pid IS NOT NULL THEN ISNULL(AN.invite_name                 , '') ELSE COW.invite_name          		END AS invite_name   
		
	FROM	CUSTOM_ORDER CO
		INNER JOIN	custom_order_WeddInfo COW ON CO.order_seq = COW.order_seq
		INNER JOIN	custom_order_plist COP ON CO.order_seq = COP.order_seq
		LEFT OUTER JOIN	custom_order_plistAddD AD ON COP.id = AD.pid
		LEFT OUTER JOIN	custom_order_plistAddG AG ON COP.id = AG.pid
		LEFT OUTER JOIN	custom_order_plistAddN AN ON COP.id = AN.pid
	
	WHERE	1 = 1
	--AND		CO.STATUS_SEQ >= 9
	AND		CASE WHEN ISNULL(CO.MEMBER_ID, '') = '' THEN CO.ORDER_EMAIL ELSE CO.MEMBER_ID END = @P_USER_ID
	AND		CO.ORDER_SEQ = @P_ORDER_SEQ

	
END

GO
