IF OBJECT_ID (N'dbo.up_insert_mcard_info', N'P') IS NOT NULL DROP PROCEDURE dbo.up_insert_mcard_info
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		강현주
-- Create date: 2015-01-08
-- Description:	모바일청첩장 기본정보 저장/수정
-- =============================================
CREATE PROCEDURE [dbo].[up_insert_mcard_info]
	@method		VARCHAR(6),
	@order_seq	INT,
	@company_seq INT, 
	@mobile_skin_seq INT, 
	@Uid VARCHAR(50), 
	@order_name VARCHAR(50), 
	@order_email VARCHAR(50), 
	@order_phone VARCHAR(20), 
	@order_hphone VARCHAR(20), 
	@addr VARCHAR(50), 
	@groom_name_kor VARCHAR(30), 
	@groom_name_eng VARCHAR(30), 
	@groom_hphone VARCHAR(20),
	@bride_name_kor VARCHAR(30), 
	@bride_name_eng VARCHAR(30), 
	@bride_hphone VARCHAR(20), 
	@greeting_content VARCHAR(2000), 
	@event_year VARCHAR(4), 
	@event_month VARCHAR(2), 
	@event_day VARCHAR(2), 
	@event_weekname VARCHAR(10), 
	@event_ampm VARCHAR(5), 
	@event_hour VARCHAR(12), 
	@event_minute VARCHAR(2), 
	@lunar_yorn CHAR(1),
	@weddinghall VARCHAR(100), 
	@wedd_phone VARCHAR(50), 
	@wedd_place VARCHAR(100), 
	@weddingaddr VARCHAR(200), 
	@latitude VARCHAR(50), 
	@longitude VARCHAR(50), 
	@Qrcode VARCHAR(200), 
	@worder_seq INT, 
	@map_type VARCHAR(20), 
	@result_seq		int = 0 OUTPUT
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	SET NOCOUNT ON;	
	--custom_order
	IF @method = 'INSERT'
	
		BEGIN
			
			INSERT INTO S5_nmCardOrder 
			(
				company_seq, mobile_skin_seq, Uid, 
				order_name, order_email, order_phone, order_hphone, addr, 
				groom_name_kor, groom_name_eng, groom_hphone,bride_name_kor, bride_name_eng, bride_hphone, 
				greeting_content, 
				event_year, event_month, event_day, event_weekname, event_ampm, event_hour, event_minute, lunar_yorn,
				weddinghall, wedd_phone, wedd_place, weddingaddr, latitude, longitude, Qrcode, worder_seq, map_type
			) 
			 VALUES
			(
				@company_seq, @mobile_skin_seq, @Uid, 
				@order_name, @order_email, @order_phone, @order_hphone, @addr, 
				@groom_name_kor, @groom_name_eng, @groom_hphone, @bride_name_kor, @bride_name_eng, @bride_hphone, 
				@greeting_content, 
				@event_year, @event_month, @event_day, @event_weekname, @event_ampm, @event_hour, @event_minute, @lunar_yorn,
				@weddinghall, @wedd_phone, @wedd_place, @weddingaddr, @latitude, @longitude, @Qrcode, @worder_seq, @map_type
			)
			
			set @result_seq = SCOPE_IDENTITY() 
		END
	
	ELSE
	
		BEGIN
			
			UPDATE S5_nmCardOrder SET
				 mobile_skin_seq = @mobile_skin_seq
				,Uid = @Uid
				,order_name = @order_name
				,order_email = @order_email
				,order_phone = @order_phone
				,order_hphone = @order_hphone
				,addr = @addr
				,groom_name_kor = @groom_name_kor
				,groom_name_eng = @groom_name_eng
				,groom_hphone = @groom_hphone
				,bride_name_kor = @bride_name_kor
				,bride_name_eng = @bride_name_eng
				,bride_hphone = @bride_hphone
				,greeting_content = @greeting_content
				,event_year = @event_year
				,event_month = @event_month
				,event_day = @event_day
				,event_weekname = @event_weekname
				,event_ampm = @event_ampm
				,event_hour = @event_hour
				,event_minute = @event_minute
				,lunar_yorn = @lunar_yorn
				,weddinghall = @weddinghall
				,wedd_phone = @wedd_phone
				,wedd_place = @wedd_place
				,weddingaddr = @weddingaddr
				,latitude = @latitude
				,longitude = @longitude
				,Qrcode = @Qrcode
				,map_type = @map_type
				,ModDate = GETDATE()
			WHERE order_seq = @order_seq
			
			set @result_seq = @order_seq
		END
	
	return @result_seq
--select * from S5_nmCardOrder
END
GO
