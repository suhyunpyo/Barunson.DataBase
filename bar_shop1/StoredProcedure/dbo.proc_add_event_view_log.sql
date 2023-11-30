IF OBJECT_ID (N'dbo.proc_add_event_view_log', N'P') IS NOT NULL DROP PROCEDURE dbo.proc_add_event_view_log
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		jaewon.cha
-- Create date: 2022-08-30
-- Description:	이벤트 진입 로그 남기기
-- =============================================
CREATE PROCEDURE [dbo].[proc_add_event_view_log]
	@P_Event_Type varchar(10),
	@P_Remote_Ip varchar(40),
	@P_Agent nvarchar(1000),
	@P_Point varchar(10) = 'link',
	@P_Referer nvarchar(255) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @T_REG_DATE DATETIME
	DECLARE @T_REG_DATE_STR VARCHAR(10)
	DECLARE @T_HOUR SMALLINT, @T_DAY SMALLINT

	DECLARE @T_M_DEVICE VARCHAR(100), @T_VALUE VARCHAR(20), @T_DEVICE VARCHAR(2)
	SET @T_M_DEVICE = 'iPod|iPhone|Android|BlackBerry|SymbianOS|SCH-M\d+|Opera Mini|Windows CE|Nokia|SonyEricsson|webOS|PalmOS'
	SET @T_DEVICE = 'PC'

	DECLARE CUR CURSOR FOR
	SELECT VALUE FROM fn_split(@T_M_DEVICE, '|')

	OPEN CUR
	FETCH NEXT FROM CUR INTO @T_VALUE

	WHILE @@FETCH_STATUS = 0
	BEGIN

		IF CHARINDEX(@T_VALUE, @P_Agent) > 0 
		BEGIN
			SET @T_DEVICE = 'MO'
		END

	FETCH NEXT FROM CUR INTO @T_VALUE
	END

	SELECT @T_DEVICE DEVICE
	CLOSE CUR
	DEALLOCATE CUR


	SET @T_REG_DATE = getdate()
	SET @T_REG_DATE_STR = CONVERT(CHAR(10), @T_REG_DATE, 23)
	SET @T_HOUR = DATEPART("hh", @T_REG_DATE)
	SET @T_DAY = DATEPART(WEEKDAY,@T_REG_DATE)

    -- Insert statements for procedure here
	INSERT INTO Event_View_Log (event_type, ip, agent, device, reg_date, reg_date_str, [hour], [day], point, referer) values 
	(
		@P_Event_Type, @P_Remote_Ip, @P_Agent, @T_DEVICE, @T_REG_DATE,@T_REG_DATE_STR , @T_HOUR, @T_DAY, @P_Point, @P_Referer
	)
END
GO
