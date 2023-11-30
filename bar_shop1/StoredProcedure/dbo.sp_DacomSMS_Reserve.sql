IF OBJECT_ID (N'dbo.sp_DacomSMS_Reserve', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomSMS_Reserve
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
sp_DacomSMS_reserve '01089961225','16440708','SMS예약발송테스트','2020-11-23 13:39:00.113'
SELECT GETDATE()

EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', 'SMS발송테스트2', '', '16440708', 1, 'AA^01089961225', 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
*/
CREATE Procedure [dbo].[sp_DacomSMS_Reserve]
	@to_pnum 	varchar(20),
	@from_pnum 	varchar(20),
	@msg 	varchar(160),
	@reserve_date varchar(30)
as
begin
	/*
	INSERT  INTO  invtmng.SC_TRAN (
	TR_ID
	,TR_SENDSTAT
	,TR_SENDDATE
	, TR_RSLTSTAT
	,TR_PHONE
	, TR_CALLBACK
	, TR_MSG
	) 
	values(
	'SM136890_001'
	,'0'
	,@reserve_date
	,'00'
	,@to_pnum
	,@from_pnum,@msg
	)
	*/

	DECLARE @SEND_DATE VARCHAR(16)  --예약시간 : yyyyMMddHHmmss
	DECLARE @DEST_INFO VARCHAR(100)
	SET @DEST_INFO = 'AA^' + @to_pnum

	SET @SEND_DATE = FORMAT(CONVERT(DATETIME,@reserve_date),'yyyyMMddHHmmss')

	EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 1, '', @msg, @SEND_DATE, @from_pnum, 1, @DEST_INFO, 0, '', 0, '', '', '', '', '', '', '', '', '', '', ''
end


/****** Object:  StoredProcedure [dbo].[up_Update_Review_detail_Status2_new]    Script Date: 2020-11-23 오후 2:36:11 ******/
SET ANSI_NULLS ON

/****** Object:  StoredProcedure [dbo].[up_Update_Review_detail_Status2_new]    Script Date: 2020-11-23 오후 5:21:09 ******/
SET ANSI_NULLS ON
GO
