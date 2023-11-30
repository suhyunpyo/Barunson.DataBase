IF OBJECT_ID (N'dbo.sp_myomee_daily_list', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_myomee_daily_list
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/*----------------------------------------------------------------------------------------------  
1.Stored Procedure : sp_myomee_daily_list  
2.작성일   : 2018.02.21 
3.실행		:  exec sp_myomee_daily_list '20180220'
-----------------------------------------------------------------------------------------------*/  
  
CREATE Procedure [dbo].[sp_myomee_daily_list]  
  
@today varchar(8)

as  
SET NOCOUNT ON  
DECLARE @sql NVARCHAR(4000)  
  
 BEGIN  
  
	SET @sql = '	select bb.ConnInfo, bb.uname,  Birth_date,	'
	SET @sql = @sql + '	bb.phone, bb.hand_phone,	'
	SET @sql = @sql + '	bb.zipcode , bb.address, bb.addr_detail,	'
	SET @sql = @sql + '	bb.umail,	'
	SET @sql = @sql + '	bb.wedding_day,	'
	SET @sql = @sql + '	bb.wedd_pgubun,	'
	SET @sql = @sql + '	convert(varchar(10),bb.barun_reg_Date,112) as barun_reg_Date	'
	SET @sql = @sql + '	from MYOMEE_DAILY_INFO bb	'
	SET @sql = @sql + '	where convert(varchar(10),bb.create_date,112)=	''' + @today + ''' '
		
 END   
  
 --select @sql  
exec (@sql) 
GO
