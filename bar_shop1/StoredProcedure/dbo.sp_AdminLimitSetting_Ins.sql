IF OBJECT_ID (N'dbo.sp_AdminLimitSetting_Ins', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_AdminLimitSetting_Ins
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************************
-- SP Name       : sp_AdminLimitSetting_Ins
-- Author        : 임승인
-- Create date   : 2022-10-14
-- Description   : 관리자 발송일제한관리
-- Update History: 
-- Comment       : 관리자 발송일제한관리 수정
****************************************************************************************************************/

	ALTER PROCEDURE [dbo].[sp_AdminLimitSetting_Ins]
		@type   VARCHAR(1),
		@startdate datetime,
		@enddate datetime,
		@useyn varchar(1),
		@adminid varchar(20),
		@adminName varchar(20),
		@ip varchar(20)
	AS

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	SET LOCK_TIMEOUT 60000

	UPDATE ADMIN_LIMIT_SETTING SET
		START_DATE = @startdate,
		END_DATE = @enddate,
		USE_YN = @useyn,
		ADMINID = @adminid,
		ADMINNAME = @adminName,
		IP = @IP,
		MOD_DATE = GETDATE()
	WHERE TYPE = @type

	INSERT INTO ADMIN_LIMIT_SETTING_LOG
	VALUES(@type, @startdate, @enddate, @useyn, @adminid, @adminName, @ip, GETDATE())


	IF @@ERROR <> 0
	BEGIN
		SELECT 'N' AS 'success'
	END
	ELSE
	BEGIN
		SELECT 'Y' AS 'success'
	END
GO
