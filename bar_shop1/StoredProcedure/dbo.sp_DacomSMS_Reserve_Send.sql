IF OBJECT_ID (N'dbo.sp_DacomSMS_Reserve_Send', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomSMS_Reserve_Send
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[sp_DacomSMS_Reserve_Send]
as

DECLARE sms_reserve_tmp CURSOR FOR
	SELECT id, to_phone, from_phone, send_msg 
	  FROM sms_reserve 
	 WHERE is_send = 'N' 
	   AND reserve_date >= DateAdd(HOUR, -1, GetDate())
	   AND reserve_date < GetDate()

DECLARE @id INT, 
        @to_phone VARCHAR(20), 
        @from_phone VARCHAR(20), 
        @sms_msg VARCHAR(160)
OPEN sms_reserve_tmp
FETCH NEXT FROM sms_reserve_tmp INTO @id, @to_phone, @from_phone, @sms_msg

WHILE(@@FETCH_STATUS = 0)

	begin
		EXEC sp_DacomSMS @to_phone, @from_phone, @sms_msg
		update sms_reserve set is_send = 'Y', send_date = GETDATE() where id = @id
		
		FETCH NEXT FROM sms_reserve_tmp INTO @id, @to_phone, @from_phone, @sms_msg
	end
GO
