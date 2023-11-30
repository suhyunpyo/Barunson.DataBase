IF OBJECT_ID (N'dbo.up_select_thankcard_order_panlist_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_select_thankcard_order_panlist_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-24
-- Description:	답례장 주문 1단계 판 정보 가져오기 
-- TEST : up_select_thankcard_order_panlist_info 1970860
-- =============================================
CREATE PROCEDURE [dbo].[up_select_thankcard_order_panlist_info]
	
	@order_seq	int	
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;

	-- rs1 (판 정보) --
	SELECT   isFPrint
			,print_type
			,card_seq
			,title
			,print_count
			,etc_comment
			,order_filename
			,isNotPrint
			,env_zip
			,env_addr
			,env_addr_detail
			,ISNULL(env_hphone, '') AS env_hphone
			,ISNULL(env_hphone2, '') AS env_hphone2
			,env_person1
			,env_person2
			,env_person_tail
			,env_person1_tail
			,env_person2_tail
			,isZipBox
			,recv_tail
			,isPostMark
			,postname
			,postname_tail
			,isBasic	
			,isNotPrint_Addr 
	FROM Custom_Order_Plist
	WHERE order_seq = @order_seq 
	
	
	-- rs2 (추가인쇄카드 판인쇄 정보) --
	SELECT   G.pid
			,G.greeting_content
			,N.groom_name
			,N.bride_name
			,N.groom_tail
			,D.event_year
			,D.event_month
			,D.event_day 
	FROM Custom_Order_PlistAddG G
	INNER JOIN Custom_Order_PlistAddN N ON G.pid = N.pid
	INNER JOIN Custom_Order_PlistAddD D ON G.pid = D.pid
	WHERE G.pid = (SELECT id
				   FROM Custom_Order_Plist 
				   WHERE order_seq = @order_seq 
					 AND print_type = 'C' 
					 AND isBasic = 0)
	
	  
END
GO
