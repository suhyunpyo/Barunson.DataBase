IF OBJECT_ID (N'dbo.SP_BACKUP_MSG_BACKUP_RV', N'P') IS NOT NULL DROP PROCEDURE dbo.SP_BACKUP_MSG_BACKUP_RV
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_BACKUP_MSG_BACKUP_RV] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @MM int;
	declare @MM_STR nvarchar(250);
	declare @sql1 nvarchar(250)
	declare @sql2 nvarchar(250)
	
	set @mm = DATEPART(mm, dateadd(m, -1, getdate()));

	if (@MM >= 10)
		begin
		set @MM_STR = '' + CONVERT(CHAR,@MM);
		end
	else
		begin
		set @MM_STR = '0' + CONVERT(CHAR,@MM);
		end

	set @sql1 = 'INSERT INTO T_SMS_HIST_RV SELECT * from T_SMS_HIST_RV_' + @MM_STR ;
	set @sql2 = 'INSERT INTO T_MMS_HIST_RV SELECT * from T_MMS_HIST_RV_' + @MM_STR ;
	execute sp_executesql @sql1;
	execute sp_executesql @sql2;
END
GO
