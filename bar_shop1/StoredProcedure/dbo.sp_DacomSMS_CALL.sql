IF OBJECT_ID (N'dbo.sp_DacomSMS_CALL', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_DacomSMS_CALL
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_DacomSMS_CALL]
	@RECV_PNUM 	VARCHAR(20),
	@SEND_PNUM 	VARCHAR(20),
	@MSG 	VARCHAR(160)
AS
BEGIN

		/****** 20201123 표수현 추가 START ****/
		DECLARE	@ErrNum   INT          
			  , @ErrSev   INT          
			  , @ErrState INT          
			  , @ErrProc  VARCHAR(50)  
			  , @ErrLine  INT          
			  , @ErrMsg   VARCHAR(2000)
		/****** 20201123 표수현 추가 END ****/

	 /***********************20201123 KT *************/
	 SET @RECV_PNUM = '^' + @RECV_PNUM
		EXEC bar_shop1.dbo.PROC_SMS_MMS_SEND '', 0, '', @MSG, '', @SEND_PNUM, 1, @RECV_PNUM, 0, '', 0, '', '', '', '', '', @ErrNum OUTPUT, @ErrSev OUTPUT, @ErrState OUTPUT, @ErrProc OUTPUT, @ErrLine OUTPUT, @ErrMsg OUTPUT


	--INSERT  INTO  INVTMNG.SC_TRAN (
	--TR_ID
	--,TR_SENDSTAT
	--, TR_RSLTSTAT
	--,TR_PHONE
	--, TR_CALLBACK
	--, TR_MSG
	--) 
	--VALUES(
	--'SM136890_003'
	--,'0'
	--,'00'
	--,@RECV_PNUM
	--,@SEND_PNUM,@MSG
	--)
END
GO
