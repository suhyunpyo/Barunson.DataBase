IF OBJECT_ID (N'dbo.up_select_addcard_pan_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_addcard_pan_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조창연
-- Create date: 2015-01-19
-- Description:	마이페이지 주문상세내역 - 추가인쇄카드 인쇄 정보
-- TEST : up_select_addcard_pan_info 5930643
-- =============================================
CREATE PROCEDURE [dbo].[up_select_addcard_pan_info]
	
	@pid		int	

AS
BEGIN

	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;



	SELECT  G.greeting_content
		   ,N.bride_father
		   ,N.bride_father_fname
		   ,N.bride_father_header
		   ,N.bride_father_tail
		   ,N.bride_fname
		   ,N.bride_mother
		   ,N.bride_mother_fname
		   ,N.bride_mother_header
		   ,N.bride_mother_tail
		   ,N.bride_name
		   ,N.bride_rank
		   ,N.bride_tail
		   ,N.groom_father
		   ,N.groom_father_fname
		   ,N.groom_father_header
		   ,N.groom_father_tail
		   ,N.groom_fname
		   ,N.groom_mother
		   ,N.groom_mother_fname
		   ,N.groom_mother_header
		   ,N.groom_mother_tail
		   ,N.groom_name
		   ,N.groom_rank
		   ,N.groom_tail
		   ,N.invite_name
		   ,N.isbride_tail
		   ,N.isgroom_tail
		   ,D.event_ampm
		   ,D.event_day
		   ,D.event_hour
		   ,D.event_minute
		   ,D.event_month
		   ,D.event_weekname
		   ,D.event_year
		   ,D.isNotMapPrint
		   ,D.lunar_event_date
		   ,D.lunar_yes_or_no
		   ,D.map_id
		   ,D.map_trans_method
		   ,D.map_uploadfile
		   ,D.traffic_id
		   ,D.wedd_addr
		   ,D.wedd_road_addr
		   ,D.wedd_idx
		   ,D.wedd_imgidx
		   ,D.wedd_name
		   ,D.wedd_phone
		   ,D.wedd_place
	FROM Custom_Order_plistAddG G
	LEFT OUTER JOIN Custom_Order_plistAddN N ON G.pid = N.pid
	LEFT OUTER JOIN Custom_Order_plistAddD D ON G.pid = D.pid
	WHERE G.pid = @pid
	
	


END
GO
