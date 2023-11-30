IF OBJECT_ID (N'dbo.sp_Season_Cancel_alarm', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_Season_Cancel_alarm
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO
-- 시즌카드 자동 주문 취소 sms 문자 발송...
CREATE PROCEDURE [dbo].[sp_Season_Cancel_alarm]
AS

declare @order_seq int
declare @order_hphone varchar(20)
declare @sms_phone varchar(20)
declare @sms_msg varchar(200)

SET @sms_phone = '1644-9713'

-- 인쇄카드 주문취소 고객
BEGIN
	DECLARE tableCursor CURSOR FOR
		select order_seq,order_hphone
		from custom_order where sales_gubun='X' and order_type='4' and status_seq=9 and settle_status<>2
		and datediff(day,order_date,getdate())=15 and left(convert(varchar(10),order_date,21),10)>='2010-11-01' 

	OPEN tableCursor
	FETCH NEXT FROM tableCursor INTO @order_seq,@order_hphone
	WHILE @@FETCH_STATUS = 0
	BEGIN
			
		BEGIN
			SET @sms_msg = '[바른손카드]주문번호'+cast(@order_seq as varchar(200))+'의 주문후진행이없어,금일오후4시에자동주문취소됩니다'
			exec sp_DacomSMS @order_hphone,@sms_phone,@sms_msg
		END

		FETCH NEXT FROM tableCursor INTO @order_seq,@order_hphone
	END
	
	CLOSE tableCursor
	DEALLOCATE tableCursor

END

-- 완제품 주문취소 고객
BEGIN
	DECLARE tableCursor CURSOR FOR
		select order_seq,order_hphone
		from custom_etc_order where sales_gubun='X' and order_type='C' and status_seq=1 
		and datediff(day,order_date,getdate())=7 and left(convert(varchar(10),order_date,21),10)>='2010-11-01' 

	OPEN tableCursor
	FETCH NEXT FROM tableCursor INTO @order_seq,@order_hphone
	WHILE @@FETCH_STATUS = 0
	BEGIN
				
		BEGIN
			SET @sms_msg = '[바른손카드]주문번호'+cast(@order_seq as varchar(200))+'의 입금이확인되지않아,금일오후4시에자동주문취소됩니다'
			exec sp_DacomSMS @order_hphone,@sms_phone,@sms_msg
		END

		FETCH NEXT FROM tableCursor INTO @order_seq,@order_hphone
	END
	
	CLOSE tableCursor
	DEALLOCATE tableCursor

END
GO
