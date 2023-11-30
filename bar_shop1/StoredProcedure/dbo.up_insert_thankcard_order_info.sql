IF OBJECT_ID (N'dbo.up_insert_thankcard_order_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_thankcard_order_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조창연
-- Create date: 2015-01-21
-- Description:	답례장 주문 1단계 정보 저장/수정 
-- TEST : up_insert_thankcard_order_info --1970473 null
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_thankcard_order_info]
	
	@order_seq	int,
	@card_seq int,
	@company_seq int,	
	@member_id varchar(50),
	
	@order_count int,
	@order_price int, 
	@discount_rate int, 
	@order_total_price int,
	 
	@option_price int, 
	@last_total_price int,
	@ftype int,	
	@fetype int,
	
	@event_year varchar(4), 
	@event_month varchar(2), 
	@event_day varchar(2),
	
	@bGreeting text,
	--@bSendDate varchar,	
	@bCardSender1 varchar(50), 
	@bCardSender2 varchar(50),
	@bCardSenderTitle varchar(30),
	@bEtcRequest text,
	@bAttachFile varchar(100),	
	
	@newOrder_Seq	int = 0 OUTPUT,
	@result_code	int = 0 OUTPUT,
	@result_cnt		int = 0 OUTPUT
	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;
	
	BEGIN TRAN
		
		-----------------------------------------------
		DECLARE @order_name varchar(50)
		DECLARE @order_email varchar(100)
		DECLARE @order_phone varchar(15)
		DECLARE @order_hphone varchar(15)
		
		SELECT   @order_name = uname
				,@order_email = umail
				,@order_phone = phone1 + '-' + phone2 + '-' + phone3
				,@order_hphone = hand_phone1  + '-' + hand_phone2  + '-' + hand_phone3 
		FROM S2_UserInfo_TheCard 
		WHERE uid = @member_id	        
	        
		
		IF @order_seq IS NULL
		
			BEGIN
			
				SELECT @order_seq = MAX(order_seq) + 1
				FROM Custom_Order
				
				SET @newOrder_Seq = @order_seq
				
				INSERT INTO Custom_Order 
				( 
				  order_seq, order_type, sales_gubun, site_gubun, print_type, company_seq, member_id, order_name, order_email, order_phone, order_hphone,				
				  card_seq, order_count, card_opt, order_price, discount_rate, order_total_price, option_price, last_total_price, pg_tid, weddinfo_id, print_color, inflow_route 				  
				) 
				VALUES
				(
				  @order_seq, 2, 'ST', 0, '', @company_seq, @member_id, @order_name, @order_email, @order_phone, @order_hphone,
				  @card_seq, @order_count, '', @order_price, @discount_rate, @order_total_price, @option_price, @last_total_price, 'IC' + CONVERT(varchar, @order_seq), @order_seq, '', 'PC'
				)
				
				INSERT INTO custom_order_WeddInfo
				(
				  order_seq, ftype, fetype, event_year, event_month, event_day, etc_comment, etc_file,				  
				  isNotMapPrint, greeting_content, groom_name, bride_name, groom_tail  
				  
				)
				VALUES
				(
				  @order_seq, @ftype, @fetype, @event_year, @event_month, @event_day, @bEtcRequest, @bAttachFile,
				  1, @bGreeting, @bCardSender1, @bCardSender2, @bCardSenderTitle  
				)
				
			END
		
		ELSE
		
			BEGIN				
				
				UPDATE Custom_Order SET 
					member_id = @member_id, order_name = @order_name, order_email = @order_email, order_phone = @order_phone, order_hphone = @order_hphone,
					order_count = @order_count, order_price = @order_price, discount_rate = @discount_rate, order_total_price = @order_total_price, 
					option_price = @option_price, last_total_price = @last_total_price,
					isInpaper = 0, isHandmade = 0, isEnvInsert = 0, isEmbo = 0
				WHERE order_seq = @order_seq
				
				UPDATE custom_order_WeddInfo SET
					fetype = @fetype, event_year = @event_year, event_month = @event_month, event_day = @event_day, etc_comment = @bEtcRequest, etc_file = @bAttachFile,				  
					greeting_content = @bGreeting, groom_name = @bCardSender1, bride_name = @bCardSender2, groom_tail = @bCardSenderTitle
				WHERE order_seq = @order_seq
				
			END	
		-----------------------------------------------
		
	SET @result_cnt = @@ROWCOUNT	-- 변경된 rowcount
	SET @result_code = @@Error		-- 에러발생 cnt
	
	IF (@result_code <> 0) GOTO PROBLEM
	COMMIT TRAN

	PROBLEM:
	IF (@result_code <> 0) BEGIN
		ROLLBACK TRAN
	END
	
	RETURN @newOrder_Seq
	RETURN @result_code
	RETURN @result_cnt
		
	/*	
	select * 
	from custom_order 
	where order_seq = 1970473
	
	select * 
	from custom_order_WeddInfo 
	where order_seq = 1970473
	
	select * 
	from custom_order_item 
	where order_seq = 1970473	
	
	select * 
	from custom_order_plist 
	where order_seq = 1970473

	select  G.*
	       ,N.*
	       ,D.* 
	from custom_order_plistAddG G
	inner join custom_order_plistAddN N ON G.pid = N.pid
	inner join custom_order_plistAddD D ON G.pid = D.pid 
	where G.pid in (select id from custom_order_plist where order_seq = 1970473)
	*/
	
END
GO
