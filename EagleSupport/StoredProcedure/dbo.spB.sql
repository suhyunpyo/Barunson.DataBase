IF OBJECT_ID (N'dbo.spB', N'P') IS NOT NULL DROP PROCEDURE dbo.spB
GO

USE [EagleSupport]
GO
/****** Object:  StoredProcedure [dbo].[spB]    Script Date: 2023-03-17 오전 10:53:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[spB]        
 @TABLE_NAME as varchar(40),        
 @WhereClause as varchar(8000) = NULL        
as        
        
set nocount on        
        
 declare @COLUMNS varchar(8000), @CNT int, @MAX_CNT int, @TABLE_ID int        
 declare @Values varchar(8000)        
 declare @DataType varchar(1), @TempColumn varchar(400)        
       
 -- get the Column List        
 select @TABLE_ID = (select ID from sysobjects where NAME = @TABLE_NAME )        
 select @CNT = 1, @MAX_CNT = (select max(COLID) from syscolumns where ID = @TABLE_ID)        
 select @COLUMNS  = '', @Values = ''        
       
 while @CNT <= @MAX_CNT        
 begin        
  if ( 0 = ( select iscomputed from syscolumns where ID = @TABLE_ID and COLID = @CNT ) )        
  begin        
   select @TempColumn =  name   from syscolumns where ID = @TABLE_ID and COLID = @CNT        
   set @COLUMNS = @COLUMNS + case when @CNT = 1 then '' else ', ' end + @TempColumn        
   -- 숫자인지 문자인지 식별해서 Values Clause에 들어갈 구문을 조합        
   select @DataType = case when A.name in ( 'char', 'varchar', 'nchar', 'nvarchar' )  then 'S' when A.Name in ( 'text', 'ntext' ) then 'T' else 'N' end        
   from systypes A, syscolumns B         
   where A.xusertype = B.xusertype and B.ID = @TABLE_ID and B.COLID = @CNT        
        
   set @Values = @Values + case when @CNT = 1 then '' else '+' + char(39) + ', ' + char(39) + '+' end        
   + case when @DataType = 'S' then ' case when ' + @TempColumn + ' is null then ' + char(39) + 'NULL' + char(39)        
   + ' else '  + char(39) + 'N' + char(39)       
   + ' + char(39) + replace ( rtrim (' + @TempColumn + '), char(39), char(39) + char(39) ) +char(39) end'        
   when @DataType = 'T' then ' case when ' + @TempColumn + ' is null then ' + char(39) + 'NULL' + char(39)        
   + ' else '  + char(39) + 'N' + char(39)       
   + ' + char(39) + replace ( cast(' + @TempColumn + ' as nvarchar(4000)), char(39), char(39) + char(39) ) +char(39) end'        
   else ' case when ' + ' cast(' + @TempColumn + ' as nvarchar(100)) is null then ' + char(39) + 'NULL' + char(39)        
   + ' else rtrim(cast(' + @TempColumn + ' as nvarchar(100))) end'        
   end        
  end        
       
  set @CNT= @CNT + 1        
 end        
       
 declare @ResultString varchar(8000)        
 set @ResultString = 'select ' + char(13) + char(39) + 'insert into ' + @TABLE_NAME + ' ( ' + @COLUMNS + ' ) ' + char(13)         
 + 'values ( ' + char(39) + ' + ' + @Values + '  + ' + char(39) + ' )' + char(39) + ' as DataScriptingQuery'        
 + char(13) + 'from ' + @TABLE_NAME + ' ' + IsNull ( @WhereClause, '' )        
 --select @ResultString        
       
 select '-- delete from ' + @TABLE_NAME + ' ' + IsNUll ( @WhereClause, '' ) as DeleteQuery        
       
 --select @ResultString      
 
-- select len(@ResultString)
 --select len(@Values)
exec ( @ResultString )        
       
       
set nocount off        
      
-- spb ItemSiteMAster
--sp_helptext spb        
        
--spb poOrderHeader        
--spb 'sdOrderHeader' , 'where SiteCode = "K102"'        
        
      
GO
