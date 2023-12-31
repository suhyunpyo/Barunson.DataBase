IF OBJECT_ID (N'dbo.SP_EXEC_DEARDEER_ORDER_ENV_ADDR_CHK', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_EXEC_DEARDEER_ORDER_ENV_ADDR_CHK
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[SP_EXEC_DEARDEER_ORDER_ENV_ADDR_CHK]
	@P_ORDER_SEQ int

AS
BEGIN

DECLARE @ADDR_EXIST INT;

SET @ADDR_EXIST = (SELECT COUNT(1) CNT FROM custom_order_WeddInfo WHERE ORDER_SEQ = @P_ORDER_SEQ)

IF (@ADDR_EXIST = 0)
	BEGIN
	INSERT INTO [dbo].[custom_order_WeddInfo](
			   [order_seq]
			   ,[ftype]
			   ,[fetype]
			   ,[event_year]
			   ,[event_month]
			   ,[event_Day]
			   ,[event_weekname]
			   ,[lunar_yes_or_no]
			   ,[lunar_event_Date]
			   ,[event_ampm]
			   ,[event_hour]
			   ,[event_minute]
			   ,[wedd_name]
			   ,[wedd_place]
			   ,[wedd_addr]
			   ,[wedd_phone]
			   ,[map_trans_method]
			   ,[wedd_idx]
			   ,[weddimg_idx]
			   ,[map_uploadfile]
			   ,[map_info]
			   ,[isNotMapPrint]
			   ,[greeting_content]
			   ,[groom_name]
			   ,[bride_name]
			   ,[groom_initial]
			   ,[bride_initial]
			   ,[groom_name_eng]
			   ,[bride_name_eng]
			   ,[groom_Fname_eng]
			   ,[bride_Fname_eng]
			   ,[groom_tail]
			   ,[bride_tail]
			   ,[groom_father]
			   ,[groom_mother]
			   ,[groom_rank]
			   ,[bride_father]
			   ,[bride_mother]
			   ,[bride_rank]
			   ,[groom_fname]
			   ,[bride_fname]
			   ,[groom_father_fname]
			   ,[groom_mother_fname]
			   ,[bride_father_fname]
			   ,[bride_mother_fname]
			   ,[groom_father_tail]
			   ,[groom_mother_tail]
			   ,[bride_father_tail]
			   ,[bride_mother_tail]
			   ,[isgroom_tail]
			   ,[isbride_tail]
			   ,[groom_father_header]
			   ,[groom_mother_header]
			   ,[bride_father_header]
			   ,[bride_mother_header]
			   ,[invite_name]
			   ,[etc_comment]
			   ,[etc_file]
			   ,[picture1]
			   ,[picture2]
			   ,[picture3]
			   ,[msg1]
			   ,[keyimg]
			   ,[wedd_date]
			   ,[map_id]
			   ,[traffic_id]
			   ,[wedd_ename]
			   ,[picture4]
			   ,[picture5]
			   ,[picture6]
			   ,[picture7]
			   ,[picture8]
			   ,[groom_initial1]
			   ,[bride_initial1]
			   ,[groom_name_eng1]
			   ,[bride_name_eng1]
			   ,[groom_Fname_eng1]
			   ,[bride_Fname_eng1]
			   ,[groom_star]
			   ,[bride_star]
			   ,[isNotPlacePrint]
			   ,[wedd_road_Addr]
			   ,[addr_gb]
			   ,[AddrDirectInd]
			   ,[groom_Illustration]
			   ,[bride_Illustration]
			   ,[worship_title]
			   ,[worship_header]
			   ,[worship_name]
			   ,[worship_content]
			   ,[hymn_title1]
			   ,[hymn_content1]
			   ,[hymn_title2]
			   ,[hymn_content2]
			   ,[bible_title]
			   ,[bible_content]
	)
	select 
	@P_ORDER_SEQ [order_seq]
			   ,[ftype]
			   ,[fetype]
			   ,[event_year]
			   ,[event_month]
			   ,[event_Day]
			   ,[event_weekname]
			   ,[lunar_yes_or_no]
			   ,[lunar_event_Date]
			   ,[event_ampm]
			   ,[event_hour]
			   ,[event_minute]
			   ,[wedd_name]
			   ,[wedd_place]
			   ,[wedd_addr]
			   ,[wedd_phone]
			   ,[map_trans_method]
			   ,[wedd_idx]
			   ,[weddimg_idx]
			   ,[map_uploadfile]
			   ,[map_info]
			   ,[isNotMapPrint]
			   ,[greeting_content]
			   ,[groom_name]
			   ,[bride_name]
			   ,[groom_initial]
			   ,[bride_initial]
			   ,[groom_name_eng]
			   ,[bride_name_eng]
			   ,[groom_Fname_eng]
			   ,[bride_Fname_eng]
			   ,[groom_tail]
			   ,[bride_tail]
			   ,[groom_father]
			   ,[groom_mother]
			   ,[groom_rank]
			   ,[bride_father]
			   ,[bride_mother]
			   ,[bride_rank]
			   ,[groom_fname]
			   ,[bride_fname]
			   ,[groom_father_fname]
			   ,[groom_mother_fname]
			   ,[bride_father_fname]
			   ,[bride_mother_fname]
			   ,[groom_father_tail]
			   ,[groom_mother_tail]
			   ,[bride_father_tail]
			   ,[bride_mother_tail]
			   ,[isgroom_tail]
			   ,[isbride_tail]
			   ,[groom_father_header]
			   ,[groom_mother_header]
			   ,[bride_father_header]
			   ,[bride_mother_header]
			   ,[invite_name]
			   ,[etc_comment]
			   ,[etc_file]
			   ,[picture1]
			   ,[picture2]
			   ,[picture3]
			   ,[msg1]
			   ,[keyimg]
			   ,[wedd_date]
			   ,[map_id]
			   ,[traffic_id]
			   ,[wedd_ename]
			   ,[picture4]
			   ,[picture5]
			   ,[picture6]
			   ,[picture7]
			   ,[picture8]
			   ,[groom_initial1]
			   ,[bride_initial1]
			   ,[groom_name_eng1]
			   ,[bride_name_eng1]
			   ,[groom_Fname_eng1]
			   ,[bride_Fname_eng1]
			   ,[groom_star]
			   ,[bride_star]
			   ,[isNotPlacePrint]
			   ,[wedd_road_Addr]
			   ,[addr_gb]
			   ,[AddrDirectInd]
			   ,[groom_Illustration]
			   ,[bride_Illustration]
			   ,[worship_title]
			   ,[worship_header]
			   ,[worship_name]
			   ,[worship_content]
			   ,[hymn_title1]
			   ,[hymn_content1]
			   ,[hymn_title2]
			   ,[hymn_content2]
			   ,[bible_title]
			   ,[bible_content]
	from [custom_order_WeddInfo]
	where order_seq = (select up_order_seq from custom_order where order_seq = @P_ORDER_SEQ)

	END

	SELECT @ADDR_EXIST AS ADDR_EXIST;
END
GO
