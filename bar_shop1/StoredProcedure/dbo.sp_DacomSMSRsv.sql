IF OBJECT_ID (N'dbo.sp_DacomSMSRsv', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomSMSRsv
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[sp_DacomSMSRsv]
	@recv_pnum 	varchar(20),
	@send_pnum 	varchar(20),
	@msg 	varchar(160),
	@stime	smalldatetime
as
begin
	--INSERT INTO invtmng.SC_TRAN 
	--		( 
	--				TR_SENDDATE
	--			,	TR_PHONE
	--			,	TR_CALLBACK
	--			,	TR_MSG 
	--		) 
	--VALUES	(
	--				@stime
	--			,	@recv_pnum
	--			,	@send_pnum
	--			,	@msg
	--		)
	-- exec [sp_DacomSMSRsv] '1644-0708','010-9484-4697','test',''
	
	EXEC SP_EXEC_SMS_OR_MMS_SEND @recv_pnum, @send_pnum, '', @msg, '', '기타', 'sp_DacomSMSRsv', '', 0, ''

end
GO
