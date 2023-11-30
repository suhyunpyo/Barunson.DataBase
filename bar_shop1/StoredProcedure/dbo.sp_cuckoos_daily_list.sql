IF OBJECT_ID (N'dbo.sp_cuckoos_daily_list', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_cuckoos_daily_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_cuckoos_daily_list   [sp_cuckoos_daily]
2.작성일   : 2021.08.24 
3.실행		:  exec sp_cuckoos_daily_list '1','2021-09-06'
-----------------------------------------------------------------------------------------------*/  
  
CREATE Procedure [dbo].[sp_cuckoos_daily_list]  
@type  varchar(1),   
@today varchar(10)


as  
SET NOCOUNT ON  
DECLARE @sql NVARCHAR(4000)  
 -- 마케팅동의
 IF @type = '1'  
 BEGIN  
  
	SET @sql = '	select bb.uname,	'
	SET @sql = @sql + '	bb.hand_phone,	bb.phone, '
	SET @sql = @sql + '	bb.zipcode , bb.address, '
	SET @sql = @sql + '	bb.umail,	'
	SET @sql = @sql + '	bb.wedding_day,	'
	SET @sql = @sql + '	convert(varchar(10),bb.barun_reg_Date,112) as barun_reg_Date,	'
	SET @sql = @sql + '( case when barun_reg_site = ''SB'' THEN ''바른손'' ' 
	SET @sql = @sql + '	 when barun_reg_site = ''SA'' THEN ''비핸즈''  '
	SET @sql = @sql + 'when barun_reg_site = ''ST'' THEN ''더카드''  '
	SET @sql = @sql + 'when barun_reg_site = ''SS'' THEN ''프리미어페이퍼''   '
	SET @sql = @sql + 'ELSE '
	SET @sql = @sql + '''바른손몰'' '
	SET @sql = @sql + ' END ) barun_reg_site,  '
	SET @sql = @sql + '	convert(varchar(10),bb.cuckos_reg_date,112) as cuckos_reg_date, bb.uid	'
	SET @sql = @sql + '	from CUCKOOS_DAILY_INFO bb	'
	SET @sql = @sql + '	where file_dt =	''' + @today + ''' '
		
 END
 -- 철회  
 ELSE IF @type = '2'
 BEGIN
 		SET @sql = 'select hand_phone, uid, (select top 1 file_dt from CUCKOOS_DAILY_INFO where uid = c.uid) reg_file_dt '
		SET @sql = @sql + 'from CUCKOOS_DAILY_INFO_CANCEL c '
		SET @sql = @sql + 'where file_dt =	''' + @today + ''''
 END

 -- 렌탈상담
 ELSE IF @type = '3'
 BEGIN
 		SET @sql = 'select uname, birth_dt, wedding_dt, hand_phone, convert(varchar(10),reg_date,112) reg_dt, inbound_info '
		SET @sql = @sql + 'from CUCKOOS_INBOUND c '
		SET @sql = @sql + 'where file_dt =	''' + @today + ''''
 END
  
 --select @sql  
exec (@sql) 
GO
