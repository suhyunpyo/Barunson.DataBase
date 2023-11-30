IF OBJECT_ID (N'invtmng.sp_DacomSMS', N'P') IS NOT NULL DROP PROCEDURE invtmng.sp_DacomSMS
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [invtmng].[sp_DacomSMS]
	@recv_pnum 	varchar(20),
	@send_pnum 	varchar(20),
	@msg 	varchar(160)
AS
----------------------------------------------------------------------------------------------------
-- Declare Block
----------------------------------------------------------------------------------------------------
DECLARE @DEST_INFO VARCHAR(50)

----------------------------------------------------------------------------------------------------
-- Execute Block
----------------------------------------------------------------------------------------------------
BEGIN
	IF LEFT(@recv_pnum,1) <> '0'
	BEGIN
		SET @DEST_INFO = 'AA^002' + @recv_pnum
		--INSERT  INTO  invtmng.SC_TRAN (TR_ID,TR_SENDSTAT, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) VALUES (
		--'SM136890_001','0','00','002'+@recv_pnum,@send_pnum,@msg)
	END
	ELSE
	BEGIN
		SET @DEST_INFO = 'AA^' + @recv_pnum
		--INSERT  INTO  invtmng.SC_TRAN (TR_ID,TR_SENDSTAT, TR_RSLTSTAT,TR_PHONE, TR_CALLBACK, TR_MSG) VALUES (
		--'SM136890_001','0','00',@recv_pnum,@send_pnum,@msg)
	END

	----------------------------------------------------------------------------------
	-- KT
	----------------------------------------------------------------------------------
	EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @msg, '', @send_pnum, 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
END
GO
